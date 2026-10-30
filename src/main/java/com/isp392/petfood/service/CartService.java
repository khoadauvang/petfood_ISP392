package com.isp392.petfood.service;

import com.isp392.petfood.dto.CartLineDto;
import com.isp392.petfood.dto.CartView;
import com.isp392.petfood.entity.Cart;
import com.isp392.petfood.entity.CartItem;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.entity.FlashSaleItem;
import com.isp392.petfood.entity.Lot;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.ExpiryLevel;
import com.isp392.petfood.enums.MembershipTier;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.SaleType;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CartItemRepository;
import com.isp392.petfood.repository.CartRepository;
import com.isp392.petfood.repository.CustomerRepository;
import com.isp392.petfood.repository.FlashSaleItemRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.LotRepository.StockRow;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

// Giỏ hàng (module 3). Quy tắc áp dụng:
//   BR-07  chỉ khách đã đăng nhập (SecurityConfig: /cart/** cho CUSTOMER)
//   BR-13  số lượng trong giỏ không vượt tồn khả dụng; kiểm tra lúc thêm/sửa, trang giỏ đánh dấu dòng vượt tồn,
//          lúc đặt hàng (module 4) phải kiểm tra lại
//   BR-65  mỗi giỏ một dòng giá thường cho mỗi sản phẩm + một dòng cho mỗi suất Flash Sale / Khuyến mãi
//   7.3    tồn khả dụng của dòng giá thường = tổng on_hand_qty các lô còn >= 90 ngày (lô RED chỉ bán qua Flash Sale)
//   BR-63, BR-66  dòng Flash Sale / Khuyến mãi chỉ lấy từ phần dành riêng của suất: allocated_qty - sold_qty
// Giỏ không giữ hàng và không chốt giá: giá hiện theo giá hiện tại, chốt khi đặt hàng (BR-10, BR-16).
@Service
@RequiredArgsConstructor
public class CartService {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final FlashSaleItemRepository flashSaleItemRepository;
    private final LotRepository lotRepository;
    private final InventoryPolicy inventoryPolicy;
    private final MembershipPolicy membershipPolicy;

    // ===== Xem giỏ =====

    @Transactional(readOnly = true)
    public CartView getCart(Long customerId) {
        return getCart(customerId, null);
    }

    // Chỉ các dòng có id trong selectedIds (khách tick ở trang giỏ để đặt); null: cả giỏ; rỗng: không chọn dòng nào
    @Transactional(readOnly = true)
    public CartView getCart(Long customerId, Collection<Long> selectedIds) {
        List<CartItem> items = onlySelected(cartItemRepository.findDetailedByCustomerId(customerId), selectedIds);
        Map<Long, Long> regularStock = loadRegularStock(items.stream()
                .filter(i -> !i.isFlashSale())
                .map(i -> i.getProduct().getId())
                .toList());
        LocalDateTime now = LocalDateTime.now();

        List<CartLineDto> lines = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int totalQuantity = 0;
        boolean hasProblems = false;
        for (CartItem item : items) {
            Availability availability = item.isFlashSale()
                    ? flashSaleAvailability(item.getFlashSaleItem(), now)
                    : regularAvailability(item.getProduct(), regularStock.getOrDefault(item.getProduct().getId(), 0L));
            String problem = availability.problem();
            if (problem == null && item.getQuantity() > availability.qty()) {
                problem = "Chỉ còn " + availability.qty() + " sản phẩm, vui lòng giảm số lượng";
            }
            CartLineDto line = toLine(item, availability.qty(), problem);
            lines.add(line);
            if (problem == null) {
                subtotal = subtotal.add(line.getLineTotal());
                totalQuantity += line.getQuantity();
            } else {
                hasProblems = true;
            }
        }
        MembershipTier tier = customerRepository.findById(customerId)
                .map(Customer::getMembershipTier)
                .orElse(MembershipTier.BRONZE);
        return new CartView(lines, subtotal, totalQuantity, hasProblems, tier.getLabel(), membershipPolicy.rateOf(tier));
    }

    // Lọc các dòng giỏ theo id khách đã chọn; null: giữ cả giỏ; rỗng: trả về danh sách trống. Giữ thứ tự của giỏ.
    static List<CartItem> onlySelected(List<CartItem> items, Collection<Long> selectedIds) {
        if (selectedIds == null) {
            return items;
        }
        if (selectedIds.isEmpty()) {
            return List.of();
        }
        Set<Long> ids = new HashSet<>(selectedIds);
        return items.stream().filter(i -> ids.contains(i.getId())).toList();
    }

    // Tổng số lượng sản phẩm trong giỏ (2 gói A + 1 gói B = 3), hiện trên icon giỏ ở thanh đầu trang
    @Transactional(readOnly = true)
    public long countItems(Long customerId) {
        return cartItemRepository.sumQuantityByCustomerId(customerId);
    }

    // ===== Thêm vào giỏ =====

    // Dòng giá thường. Sản phẩm đã có dòng giá thường trong giỏ thì cộng dồn số lượng (BR-65).
    @Transactional
    public CartItem addRegular(Long customerId, Long productId, int quantity) {
        requirePositive(quantity);
        Product product = productRepository.findWithCategoryById(productId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy sản phẩm #" + productId));
        long stock = loadRegularStock(List.of(productId)).getOrDefault(productId, 0L);
        Availability availability = regularAvailability(product, stock);
        if (availability.problem() != null) {
            throw new BusinessRuleException(availability.problem());
        }

        Cart cart = getOrCreateCart(customerId);
        CartItem item = cartItemRepository.findByCart_IdAndProduct_IdAndFlashSaleItemIsNull(cart.getId(), productId)
                .orElse(null);
        int newQuantity = checkedTotal(item, quantity, availability.qty());
        if (item == null) {
            item = new CartItem(cart, product, null, newQuantity);
        } else {
            item.setQuantity(newQuantity);
        }
        return saveLine(cart, item);
    }

    // Dòng Flash Sale / Khuyến mãi: sản phẩm lấy theo lô của suất, không tin productId từ form gửi lên
    @Transactional
    public CartItem addFlashSale(Long customerId, Long flashSaleItemId, int quantity) {
        requirePositive(quantity);
        FlashSaleItem fsItem = flashSaleItemRepository.findDetailedById(flashSaleItemId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy suất ưu đãi #" + flashSaleItemId));
        Availability availability = flashSaleAvailability(fsItem, LocalDateTime.now());
        if (availability.problem() != null) {
            throw new BusinessRuleException(availability.problem());
        }

        Cart cart = getOrCreateCart(customerId);
        CartItem item = cartItemRepository.findByCart_IdAndFlashSaleItem_Id(cart.getId(), flashSaleItemId)
                .orElse(null);
        int newQuantity = checkedTotal(item, quantity, availability.qty());
        if (item == null) {
            item = new CartItem(cart, fsItem.getLot().getProduct(), fsItem, newQuantity);
        } else {
            item.setQuantity(newQuantity);
        }
        return saveLine(cart, item);
    }

    // ===== Sửa / xoá dòng =====

    @Transactional
    public CartItem updateQuantity(Long customerId, Long cartItemId, int quantity) {
        requirePositive(quantity);
        CartItem item = findOwned(customerId, cartItemId);
        Availability availability = availabilityOf(item);
        if (availability.problem() != null) {
            throw new BusinessRuleException(availability.problem() + ". Hãy xoá dòng này khỏi giỏ.");
        }
        if (quantity > availability.qty()) {
            throw new BusinessRuleException("quantity", "Chỉ còn " + availability.qty() + " sản phẩm");
        }
        item.setQuantity(quantity);
        item.getCart().touch();
        return item;
    }

    @Transactional
    public CartItem remove(Long customerId, Long cartItemId) {
        CartItem item = findOwned(customerId, cartItemId);
        item.getCart().touch();
        cartItemRepository.delete(item);
        return item;
    }

    // ===== Tồn khả dụng =====

    private record Availability(int qty, String problem) {
    }

    private Availability availabilityOf(CartItem item) {
        if (item.isFlashSale()) {
            return flashSaleAvailability(item.getFlashSaleItem(), LocalDateTime.now());
        }
        Long productId = item.getProduct().getId();
        return regularAvailability(item.getProduct(), loadRegularStock(List.of(productId)).getOrDefault(productId, 0L));
    }

    // Giá thường: sản phẩm đang bán, danh mục đang hiện; tồn = tổng on_hand các lô còn >= 90 ngày (BR-54, BR-59)
    private Availability regularAvailability(Product product, long sellableStock) {
        if (product.getStatus() != ProductStatus.ACTIVE
                || product.getCategory().getStatus() != CategoryStatus.ACTIVE) {
            return new Availability(0, "Sản phẩm đã ngừng kinh doanh");
        }
        if (sellableStock <= 0) {
            return new Availability(0, "Sản phẩm đã hết hàng");
        }
        return new Availability((int) Math.min(sellableStock, Integer.MAX_VALUE), null);
    }

    // Flash Sale / Khuyến mãi: chiến dịch đang chạy, sản phẩm đang bán,
    // nếu là FLASH_SALE thì lô ở mức RED (21-89 ngày, BR-63), nếu là PROMOTION thì lô ở mức OK (>= 90 ngày, BR-12/54).
    private Availability flashSaleAvailability(FlashSaleItem fsItem, LocalDateTime now) {
        FlashSale sale = fsItem.getFlashSale();
        if (!sale.isRunningAt(now)) {
            return new Availability(0, "Chương trình \"" + sale.getName() + "\" hiện không mở bán");
        }
        Lot lot = fsItem.getLot();
        Product product = lot.getProduct();
        if (product.getStatus() != ProductStatus.ACTIVE
                || product.getCategory().getStatus() != CategoryStatus.ACTIVE) {
            return new Availability(0, "Sản phẩm đã ngừng kinh doanh");
        }
        ExpiryLevel level = inventoryPolicy.levelOf(lot.getExpiryDate());
        if (sale.getSaleType() == SaleType.PROMOTION) {
            if (level != ExpiryLevel.OK) {
                return new Availability(0, "Lô hàng khuyến mãi đã dưới mốc cam kết hạn dùng (90 ngày)");
            }
        } else {
            if (level != ExpiryLevel.RED) {
                return new Availability(0, "Lô hàng Flash Sale đã quá mốc được bán");
            }
        }
        int qty = Math.min(fsItem.getRemainingQty(), lot.getOnHandQty());
        if (qty <= 0) {
            return new Availability(0, "Suất ưu đãi đã bán hết");
        }
        return new Availability(qty, null);
    }

    private Map<Long, Long> loadRegularStock(Collection<Long> productIds) {
        if (productIds.isEmpty()) {
            return Map.of();
        }
        return lotRepository.sumSellableQuantity(productIds, inventoryPolicy.minSellableExpiry()).stream()
                .collect(Collectors.toMap(StockRow::getProductId, StockRow::getQuantity));
    }

    // ===== Phụ trợ =====

    // Số lượng mới của dòng = số đang có + số thêm, không được vượt tồn khả dụng (BR-13)
    private static int checkedTotal(CartItem existing, int adding, int available) {
        long inCart = existing == null ? 0 : existing.getQuantity();
        long total = inCart + adding;
        if (total > available) {
            String message = inCart > 0
                    ? "Chỉ còn " + available + " sản phẩm, giỏ của bạn đã có " + inCart
                    : "Chỉ còn " + available + " sản phẩm";
            throw new BusinessRuleException("quantity", message);
        }
        return (int) total;
    }

    private static void requirePositive(int quantity) {
        if (quantity < 1) {
            throw new BusinessRuleException("quantity", "Số lượng phải từ 1 trở lên");
        }
    }

    private CartItem findOwned(Long customerId, Long cartItemId) {
        return cartItemRepository.findOwnedById(cartItemId, customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy dòng #" + cartItemId + " trong giỏ của bạn"));
    }

    // Mỗi khách một giỏ (UQ_Cart_customer_id), tạo ở lần thêm đầu tiên
    private Cart getOrCreateCart(Long customerId) {
        return cartRepository.findByCustomer_Id(customerId).orElseGet(() -> {
            try {
                return cartRepository.saveAndFlush(new Cart(customerRepository.getReferenceById(customerId)));
            } catch (DataIntegrityViolationException e) {
                // Hai tab cùng thêm sản phẩm đầu tiên: UQ_Cart_customer_id chặn giỏ thứ hai
                throw new BusinessRuleException("Giỏ hàng vừa được cập nhật ở nơi khác, vui lòng thử lại");
            }
        });
    }

    private CartItem saveLine(Cart cart, CartItem item) {
        cart.touch();
        try {
            return cartItemRepository.saveAndFlush(item);
        } catch (DataIntegrityViolationException e) {
            // Bấm "Thêm" 2 lần cùng lúc: UX_CartItem_regular / UX_CartItem_flash_sale chặn dòng trùng
            throw new BusinessRuleException("Giỏ hàng vừa được cập nhật ở nơi khác, vui lòng thử lại");
        }
    }

    private CartLineDto toLine(CartItem item, int availableQty, String problem) {
        Product product = item.getProduct();
        FlashSaleItem fsItem = item.getFlashSaleItem();
        BigDecimal unitPrice = fsItem == null ? product.getSellingPrice() : fsItem.getSalePrice();
        String expiryNote = null;
        if (fsItem != null) {
            LocalDate expiry = fsItem.getLot().getExpiryDate();
            expiryNote = "HSD " + expiry.format(DATE) + " (còn " + inventoryPolicy.daysLeft(expiry) + " ngày)";
        }
        return new CartLineDto(
                item.getId(),
                product.getId(),
                product.getFullSku(),
                product.getName(),
                product.getImageUrl(),
                fsItem != null,
                fsItem == null ? null : fsItem.getFlashSale().getName(),
                expiryNote,
                product.getSellingPrice(),
                unitPrice,
                item.getQuantity(),
                unitPrice.multiply(BigDecimal.valueOf(item.getQuantity())),
                availableQty,
                problem);
    }
}
