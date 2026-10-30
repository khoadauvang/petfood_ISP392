package com.isp392.petfood.service;

import com.isp392.petfood.dto.CartView;
import com.isp392.petfood.dto.CheckoutForm;
import com.isp392.petfood.dto.CheckoutSummary;
import com.isp392.petfood.dto.ShippingQuote;
import com.isp392.petfood.entity.CartItem;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.FlashSaleItem;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.entity.OrderItem;
import com.isp392.petfood.entity.OrderItemLot;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CartItemRepository;
import com.isp392.petfood.repository.CustomerRepository;
import com.isp392.petfood.repository.FlashSaleItemRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.LotRepository.LotStock;
import com.isp392.petfood.repository.OrderItemLotRepository;
import com.isp392.petfood.repository.OrderItemRepository;
import com.isp392.petfood.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Đặt hàng (module 4): tạo Orders + OrderItem từ giỏ trong MỘT transaction.
//   - giá chốt lúc đặt (BR-10, BR-16): giá thường = Product.selling_price, Flash Sale = sale_price
//   - giảm giá hạng chỉ áp cho dòng giá thường (BR-43), phần trăm chốt vào Orders.tier_discount_rate
//   - phí ship theo ShippingFeeService; total_amount = tiền hàng sau giảm + phí ship
//   - trừ tồn theo FEFO ngay lúc đặt (Remaining_Features), mỗi lần trừ là một câu UPDATE có điều kiện (BR-20);
//     lô đã trừ ghi vào OrderItemLot để huỷ đơn cộng trả đúng lô
//   - lỗi ở bất kỳ dòng nào (hết hàng do người khác vừa mua) -> rollback toàn bộ, giỏ giữ nguyên
//   - khách tick chọn dòng ở trang giỏ (itemIds): chỉ đặt các dòng đó, dòng không chọn ở lại giỏ
@Service
@RequiredArgsConstructor
public class CheckoutService {

    // Số lần đọc lại lô khi bị đơn khác tranh mất hàng giữa lúc đọc và lúc trừ
    private static final int MAX_ALLOCATION_ROUNDS = 3;

    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final CustomerRepository customerRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderItemLotRepository orderItemLotRepository;
    private final LotRepository lotRepository;
    private final FlashSaleItemRepository flashSaleItemRepository;
    private final InventoryPolicy inventoryPolicy;
    private final MembershipPolicy membershipPolicy;
    private final ShippingFeeService shippingFeeService;
    private final PaymentService paymentService;

    // Trang đặt hàng. address == null: chưa tính phí ship (khách chưa nhập địa chỉ).
    // itemIds: các dòng khách chọn; id không còn trong giỏ thì bỏ qua (place() mới báo lỗi)
    @Transactional(readOnly = true)
    public CheckoutSummary preview(Long customerId, String address, List<Long> itemIds) {
        Customer customer = findCustomer(customerId);
        CartView cart = cartService.getCart(customerId, itemIds);
        Pricing pricing = price(CartService.onlySelected(cartItemRepository.findDetailedByCustomerId(customerId), itemIds), customer);
        ShippingQuote quote = address == null || address.isBlank()
                ? null
                : shippingFeeService.quote(address, pricing.goodsTotal());
        return new CheckoutSummary(cart.getLines(), pricing.subtotal(), customer.getMembershipTier().getLabel(),
                pricing.rate(), pricing.discountTotal(), pricing.goodsTotal(), quote, customer.getPhone());
    }

    @Transactional
    public Order place(Long customerId, CheckoutForm form) {
        Customer customer = findCustomer(customerId);
        if (customer.getPhone() == null || customer.getPhone().isBlank()) {
            // Không lưu SĐT người nhận riêng: shipper gọi theo SĐT trong hồ sơ khách (chốt 15/10)
            throw new BusinessRuleException("Vui lòng cập nhật số điện thoại trong hồ sơ để shipper liên hệ khi giao hàng.");
        }
        if (form.getPaymentMethod() == PaymentMethod.VNPAY && !paymentService.isVnpayEnabled()) {
            throw new BusinessRuleException("paymentMethod", "Thanh toán VNPay chưa được cấu hình, vui lòng chọn COD.");
        }

        List<Long> itemIds = form.getItemIds();
        if (itemIds == null || itemIds.isEmpty()) {
            throw new BusinessRuleException("Vui lòng chọn ít nhất một sản phẩm trong giỏ hàng để đặt hàng.");
        }
        List<CartItem> items = CartService.onlySelected(cartItemRepository.findDetailedByCustomerId(customerId), itemIds);
        if (items.size() != new HashSet<>(itemIds).size()) {
            // Dòng đã chọn bị xoá / đặt ở tab khác trong lúc đang ở trang đặt hàng
            throw new BusinessRuleException("Một số sản phẩm đã chọn không còn trong giỏ. Vui lòng quay lại giỏ hàng để chọn lại.");
        }
        CartView cart = cartService.getCart(customerId, itemIds);
        if (cart.getLines().isEmpty()) {
            throw new BusinessRuleException("Giỏ hàng đang trống.");
        }
        if (cart.isHasProblems()) {
            // BR-13: kiểm tra lại tồn lúc đặt (chỉ các dòng được chọn)
            throw new BusinessRuleException("Sản phẩm đã chọn có dòng hết hàng hoặc vượt số lượng còn lại. "
                    + "Vui lòng quay lại giỏ hàng để sửa.");
        }

        Pricing pricing = price(items, customer);
        String address = form.getShippingAddress().trim();
        ShippingQuote quote = shippingFeeService.quote(address, pricing.goodsTotal());

        Order order = new Order();
        order.setCustomer(customer);
        order.setShippingAddress(address);
        order.setPaymentMethod(form.getPaymentMethod());
        order.setTierDiscountRate(pricing.rate());
        order.setShippingFee(quote.getFee());
        order.setTotalAmount(pricing.goodsTotal().add(quote.getFee()));
        orderRepository.save(order);

        for (CartItem item : items) {
            FlashSaleItem fsItem = item.getFlashSaleItem();
            BigDecimal unitPrice = unitPrice(item);
            OrderItem orderItem = orderItemRepository.save(new OrderItem(order, item.getProduct(), fsItem,
                    item.getQuantity(), unitPrice, discountOf(item, pricing.rate())));
            if (fsItem == null) {
                allocateRegular(orderItem);
            } else {
                allocateFlashSale(orderItem, fsItem);
            }
        }

        // Đặt xong thì bỏ các dòng đã đặt khỏi giỏ; dòng khách không chọn vẫn ở lại
        cartItemRepository.deleteAll(items);
        items.getFirst().getCart().touch();

        // VNPay: tạo lần thanh toán đang chờ; hàng vừa trừ được giữ 15 phút chờ khách trả tiền (BR-23)
        if (order.getPaymentMethod() == PaymentMethod.VNPAY) {
            paymentService.createVnpayAttempt(order);
        }
        return order;
    }

    // ===== Trừ tồn =====

    // Dòng giá thường: lấy dần từ các lô bán thường theo FEFO (BR-53), chỉ lô còn >= 90 ngày (chốt 15/10),
    // ưu tiên phần tồn chưa được giữ chỗ bởi các chương trình khuyến mãi (BR-68).
    private void allocateRegular(OrderItem orderItem) {
        Long productId = orderItem.getProduct().getId();
        LocalDate minExpiry = inventoryPolicy.minSellableExpiry();
        int remaining = orderItem.getQuantity();
        Map<Long, Integer> taken = new LinkedHashMap<>();

        for (int round = 0; remaining > 0 && round < MAX_ALLOCATION_ROUNDS; round++) {
            List<LotStock> lots = lotRepository.findSellableFefo(productId, minExpiry);
            if (lots.isEmpty()) {
                break;
            }
            for (LotStock lot : lots) {
                long reserved = flashSaleItemRepository.reservedByOtherSales(lot.getLotId(), 0L);
                int unreserved = (int) Math.max(0L, lot.getOnHandQty() - reserved);
                if (unreserved <= 0) {
                    continue;
                }
                int take = Math.min(remaining, unreserved);
                // 0 dòng bị sửa = đơn khác vừa lấy hàng của lô này; vòng sau đọc lại số mới
                if (lotRepository.takeSellable(lot.getLotId(), take, minExpiry) == 1) {
                    taken.merge(lot.getLotId(), take, Integer::sum);
                    remaining -= take;
                    if (remaining == 0) {
                        break;
                    }
                }
            }
        }
        if (remaining > 0) {
            throw new BusinessRuleException(orderItem.getProduct().getName()
                    + " không còn đủ hàng khả dụng (vừa có khách khác đặt hoặc đang giữ suất khuyến mãi). Vui lòng quay lại giỏ hàng.");
        }
        taken.forEach((lotId, qty) ->
                orderItemLotRepository.save(new OrderItemLot(orderItem, lotRepository.getReferenceById(lotId), qty)));
    }

    // Dòng Flash Sale: tăng sold_qty có điều kiện (hết suất thì 0 dòng), rồi trừ tồn lô của suất
    private void allocateFlashSale(OrderItem orderItem, FlashSaleItem fsItem) {
        int qty = orderItem.getQuantity();
        if (flashSaleItemRepository.sell(fsItem.getId(), qty) == 0) {
            throw new BusinessRuleException("Suất ưu đãi của " + orderItem.getProduct().getName() + " vừa hết.");
        }
        if (lotRepository.take(fsItem.getLot().getId(), qty) == 0) {
            throw new BusinessRuleException("Lô hàng của " + orderItem.getProduct().getName() + " không còn đủ hàng.");
        }
        orderItemLotRepository.save(new OrderItemLot(orderItem, fsItem.getLot(), qty));
    }

    // ===== Tính tiền =====

    private record Pricing(BigDecimal subtotal, BigDecimal rate, BigDecimal discountTotal, BigDecimal goodsTotal) {
    }

    private Pricing price(List<CartItem> items, Customer customer) {
        BigDecimal rate = membershipPolicy.rateOf(customer.getMembershipTier());
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal discount = BigDecimal.ZERO;
        for (CartItem item : items) {
            subtotal = subtotal.add(unitPrice(item).multiply(BigDecimal.valueOf(item.getQuantity())));
            discount = discount.add(discountOf(item, rate));
        }
        return new Pricing(subtotal, rate, discount, subtotal.subtract(discount));
    }

    private static BigDecimal unitPrice(CartItem item) {
        return item.isFlashSale() ? item.getFlashSaleItem().getSalePrice() : item.getProduct().getSellingPrice();
    }

    // Giảm theo hạng của một dòng, làm tròn tới đồng. Dòng Flash Sale không giảm (BR-43).
    private static BigDecimal discountOf(CartItem item, BigDecimal ratePercent) {
        if (item.isFlashSale()) {
            return BigDecimal.ZERO;
        }
        return unitPrice(item).multiply(BigDecimal.valueOf(item.getQuantity()))
                .multiply(ratePercent)
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
    }

    private Customer findCustomer(Long customerId) {
        return customerRepository.findById(customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy khách hàng #" + customerId));
    }
}
