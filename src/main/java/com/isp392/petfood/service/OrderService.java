package com.isp392.petfood.service;

import com.isp392.petfood.dto.OrderDetailDto;
import com.isp392.petfood.dto.OrderItemPreview;
import com.isp392.petfood.dto.OrderLineDto;
import com.isp392.petfood.dto.OrderRow;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.Employee;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.entity.OrderItem;
import com.isp392.petfood.entity.OrderItemLot;
import com.isp392.petfood.entity.Payment;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentRecordStatus;
import com.isp392.petfood.enums.PaymentStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.FlashSaleItemRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.OrderItemLotRepository;
import com.isp392.petfood.repository.OrderItemRepository;
import com.isp392.petfood.repository.OrderItemRepository.OrderCountRow;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.PaymentRepository;
import com.isp392.petfood.repository.ProductReviewRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

// Xem đơn và vòng đời đơn (module 4).
//   PENDING --staff xác nhận (confirmed_by)--> CONFIRMED --đóng gói (packed_by)--> PROCESSING
//   --giao--> SHIPPED --giao thành công--> COMPLETED   (chỉ đi tiến, không bỏ bước, BR-17)
//   SHIPPED --khách không nhận--> RETURNED (hàng về được thẩm định ở module trả hàng, REFUSED_DELIVERY)
// Huỷ (BR-19): khách tự huỷ khi PENDING / CONFIRMED; khi PROCESSING khách gửi yêu cầu (lưu cancel_reason) để staff
// duyệt; từ SHIPPED không huỷ được. Huỷ thì cộng trả tồn đúng lô đã trừ (OrderItemLot) và trả suất Flash Sale.
@Service
@RequiredArgsConstructor
public class OrderService {

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);
    private static final int PAGE_SIZE = 10;
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Set<OrderStatus> STAFF_CANCELLABLE =
            Set.of(OrderStatus.PENDING, OrderStatus.CONFIRMED, OrderStatus.PROCESSING);

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderItemLotRepository orderItemLotRepository;
    private final LotRepository lotRepository;
    private final FlashSaleItemRepository flashSaleItemRepository;
    private final EmployeeRepository employeeRepository;
    private final PaymentRepository paymentRepository;
    private final VnpayClient vnpayClient;
    private final ReturnService returnService;
    private final ProductReviewRepository productReviewRepository;

    // ===== Phía khách =====

    // Lịch sử đơn, mới nhất trước. pageNumber tính từ 0. statuses rỗng: mọi trạng thái.
    @Transactional(readOnly = true)
    public Page<OrderRow> listForCustomer(Long customerId, Collection<OrderStatus> statuses, int pageNumber) {
        PageRequest pageable = PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt", "id"));
        Page<Order> orders = statuses.isEmpty()
                ? orderRepository.findByCustomer_Id(customerId, pageable)
                : orderRepository.findByCustomer_IdAndStatusIn(customerId, statuses, pageable);
        return toRows(orders);
    }

    // Sản phẩm rút gọn của các đơn trên một trang lịch sử đơn: orderId -> các dòng
    @Transactional(readOnly = true)
    public Map<Long, List<OrderItemPreview>> itemPreviews(Collection<Long> orderIds) {
        if (orderIds.isEmpty()) {
            return Map.of();
        }
        return orderItemRepository.findWithProductByOrderIds(orderIds).stream()
                .collect(Collectors.groupingBy(i -> i.getOrder().getId(), LinkedHashMap::new,
                        Collectors.mapping(i -> new OrderItemPreview(i.getProduct().getName(),
                                i.getProduct().getImageUrl(), i.getQuantity(), i.getLineTotal()), Collectors.toList())));
    }

    @Transactional(readOnly = true)
    public OrderDetailDto getForCustomer(Long customerId, Long orderId) {
        return toDetail(orderRepository.findByIdAndCustomer_Id(orderId, customerId)
                .orElseThrow(() -> notFound(orderId)));
    }

    @Transactional
    public Order cancelByCustomer(Long customerId, Long orderId, String reason) {
        requireReason(reason);
        Order order = lockOrder(orderId);
        if (!order.getCustomer().getId().equals(customerId)) {
            throw notFound(orderId);                     // đơn của người khác: coi như không tồn tại
        }
        switch (order.getStatus()) {
            case PENDING, CONFIRMED -> cancel(order, reason.trim());
            case PROCESSING -> {
                if (order.isCancelRequested()) {
                    throw new BusinessRuleException("Bạn đã gửi yêu cầu huỷ đơn này, vui lòng chờ cửa hàng xử lý.");
                }
                order.setCancelReason(reason.trim());    // yêu cầu huỷ, chờ staff duyệt
            }
            default -> throw new BusinessRuleException("Đơn " + order.getStatus().getLabel().toLowerCase()
                    + " không huỷ được. Nếu đã nhận hàng, bạn có thể gửi yêu cầu trả hàng.");
        }
        return order;
    }

    // ===== Phía Staff / Admin =====

    @Transactional(readOnly = true)
    public Page<OrderRow> search(OrderStatus status, boolean cancelRequested, String keyword, int pageNumber) {
        Long orderId = null;
        String text = keyword == null || keyword.isBlank() ? null : keyword.trim();
        if (text != null && text.replace("#", "").matches("\\d{1,18}")) {
            orderId = Long.parseLong(text.replace("#", ""));    // gõ mã đơn, ví dụ "#12" hoặc "12"
            text = null;
        }
        Page<Order> orders = orderRepository.search(status, cancelRequested, orderId, text,
                PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt", "id")));
        return toRows(orders);
    }

    @Transactional(readOnly = true)
    public OrderDetailDto getForStaff(Long orderId) {
        return toDetail(orderRepository.findById(orderId).orElseThrow(() -> notFound(orderId)));
    }

    @Transactional(readOnly = true)
    public long countCancelRequests() {
        return orderRepository.search(OrderStatus.PROCESSING, true, null, null, PageRequest.of(0, 1)).getTotalElements();
    }

    @Transactional(readOnly = true)
    public long countAll() {
        return orderRepository.count();
    }

    @Transactional(readOnly = true)
    public long countByStatus(OrderStatus status) {
        return orderRepository.countByStatus(status);
    }

    // PENDING -> CONFIRMED
    @Transactional
    public Order confirm(Long orderId, Long employeeId) {
        Order order = lockOrder(orderId);
        requireStatus(order, OrderStatus.PENDING, "xác nhận");
        // BR-25: đơn VNPay chưa trả tiền thì staff không xử lý
        if (order.getPaymentMethod() == PaymentMethod.VNPAY && order.getPaymentStatus() != PaymentStatus.PAID) {
            throw new BusinessRuleException("Đơn VNPay chưa thanh toán, chưa xác nhận được.");
        }
        order.setStatus(OrderStatus.CONFIRMED);
        order.setConfirmedBy(employee(employeeId));
        order.setConfirmedAt(LocalDateTime.now());
        return order;
    }

    // CONFIRMED -> PROCESSING (đóng gói)
    @Transactional
    public Order pack(Long orderId, Long employeeId) {
        Order order = lockOrder(orderId);
        requireStatus(order, OrderStatus.CONFIRMED, "đóng gói");
        order.setStatus(OrderStatus.PROCESSING);
        order.setPackedBy(employee(employeeId));
        return order;
    }

    // PROCESSING -> SHIPPED
    @Transactional
    public Order ship(Long orderId) {
        Order order = lockOrder(orderId);
        requireStatus(order, OrderStatus.PROCESSING, "giao");
        if (order.isCancelRequested()) {
            throw new BusinessRuleException("Khách đang yêu cầu huỷ đơn này: hãy duyệt hoặc từ chối yêu cầu trước khi giao.");
        }
        order.setStatus(OrderStatus.SHIPPED);
        order.setShippedAt(LocalDateTime.now());
        return order;
    }

    // SHIPPED -> COMPLETED. Từ lúc này tính hạn trả hàng (BR-29); đơn COD chuyển PAID (BR-26).
    @Transactional
    public Order complete(Long orderId) {
        Order order = lockOrder(orderId);
        requireStatus(order, OrderStatus.SHIPPED, "hoàn tất");
        order.setStatus(OrderStatus.COMPLETED);
        order.setCompletedAt(LocalDateTime.now());
        if (order.getPaymentMethod() == PaymentMethod.COD) {
            order.setPaymentStatus(PaymentStatus.PAID);
            Payment payment = new Payment(order, PaymentMethod.COD, order.getTotalAmount());
            payment.setStatus(PaymentRecordStatus.SUCCESS);
            payment.setPaidAt(order.getCompletedAt());
            paymentRepository.save(payment);
        }
        return order;
    }

    // SHIPPED -> RETURNED: khách không nhận hàng. Không tự cộng tồn: tạo sẵn yêu cầu trả hàng REFUSED_DELIVERY
    // để staff thẩm định từng dòng (tái nhập / tiêu huỷ) ở module trả hàng.
    @Transactional
    public Order markReturned(Long orderId) {
        Order order = lockOrder(orderId);
        requireStatus(order, OrderStatus.SHIPPED, "chuyển sang 'khách không nhận hàng'");
        order.setStatus(OrderStatus.RETURNED);
        order.setReturnedAt(LocalDateTime.now());
        returnService.createForRefusedDelivery(order);
        return order;
    }

    // Staff huỷ đơn chưa giao (hết hàng, không liên lạc được khách...), bắt buộc ghi lý do
    @Transactional
    public Order cancelByStaff(Long orderId, String reason) {
        requireReason(reason);
        Order order = lockOrder(orderId);
        if (!STAFF_CANCELLABLE.contains(order.getStatus())) {
            throw new BusinessRuleException("Đơn " + order.getStatus().getLabel().toLowerCase() + " không huỷ được.");
        }
        cancel(order, reason.trim());
        return order;
    }

    // Duyệt yêu cầu huỷ của khách khi đơn đang đóng gói
    @Transactional
    public Order approveCancelRequest(Long orderId) {
        Order order = lockOrder(orderId);
        if (!order.isCancelRequested()) {
            throw new BusinessRuleException("Đơn #" + orderId + " không có yêu cầu huỷ đang chờ.");
        }
        cancel(order, order.getCancelReason());
        return order;
    }

    @Transactional
    public Order rejectCancelRequest(Long orderId) {
        Order order = lockOrder(orderId);
        if (!order.isCancelRequested()) {
            throw new BusinessRuleException("Đơn #" + orderId + " không có yêu cầu huỷ đang chờ.");
        }
        order.setCancelReason(null);
        return order;
    }

    // Đơn VNPay đã trả tiền nhưng bị huỷ: staff chuyển khoản hoàn cho khách rồi bấm "Đã hoàn tiền" (thủ công, mục 9.12)
    @Transactional
    public Order markRefunded(Long orderId) {
        Order order = lockOrder(orderId);
        if (!needsRefund(order)) {
            throw new BusinessRuleException("Đơn #" + orderId + " không có khoản cần hoàn tiền.");
        }
        order.setPaymentStatus(PaymentStatus.REFUNDED);
        return order;
    }

    static boolean needsRefund(Order order) {
        return order.getStatus() == OrderStatus.CANCELLED && order.getPaymentStatus() == PaymentStatus.PAID;
    }

    // ===== Huỷ + cộng trả tồn =====

    // Gọi khi đã khoá đơn (lockOrder). PaymentService dùng để tự huỷ đơn VNPay thất bại / COD quá hạn.
    void cancel(Order order, String reason) {
        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelReason(reason);
        order.setCancelledAt(LocalDateTime.now());

        for (OrderItemLot taken : orderItemLotRepository.findByOrderId(order.getId())) {
            // Cộng trả đúng lô gốc. Lô giờ đã dưới 90 ngày thì tự thành hàng RED (chỉ bán qua Flash Sale).
            if (lotRepository.putBack(taken.getLot().getId(), taken.getQuantity()) == 0) {
                log.warn("Huỷ đơn #{}: không cộng trả được {} sp vào lô #{} (vượt số lượng nhập)",
                        order.getId(), taken.getQuantity(), taken.getLot().getId());
            }
        }
        for (OrderItem item : orderItemRepository.findDetailedByOrderId(order.getId())) {
            if (item.getFlashSaleItem() != null) {
                flashSaleItemRepository.unsell(item.getFlashSaleItem().getId(), item.getQuantity());
            }
        }
    }

    // ===== Phụ trợ =====

    private Order lockOrder(Long orderId) {
        return orderRepository.findByIdForUpdate(orderId).orElseThrow(() -> notFound(orderId));
    }

    // Chỉ cho chuyển từ đúng trạng thái trước đó (BR-17)
    private static void requireStatus(Order order, OrderStatus expected, String action) {
        if (order.getStatus() != expected) {
            throw new BusinessRuleException("Đơn #" + order.getId() + " đang \"" + order.getStatus().getLabel()
                    + "\", không " + action + " được (chỉ " + action + " đơn \"" + expected.getLabel() + "\").");
        }
    }

    private static void requireReason(String reason) {
        if (reason == null || reason.isBlank()) {
            throw new BusinessRuleException("cancelReason", "Vui lòng nhập lý do huỷ");
        }
        if (reason.trim().length() > 255) {
            throw new BusinessRuleException("cancelReason", "Lý do huỷ tối đa 255 ký tự");
        }
    }

    private Employee employee(Long employeeId) {
        return employeeRepository.getReferenceById(employeeId);
    }

    private static NotFoundException notFound(Long orderId) {
        return new NotFoundException("Không tìm thấy đơn #" + orderId);
    }

    private Page<OrderRow> toRows(Page<Order> orders) {
        List<Long> ids = orders.getContent().stream().map(Order::getId).toList();
        Map<Long, OrderCountRow> counts = ids.isEmpty() ? Map.of()
                : orderItemRepository.countByOrderIds(ids).stream()
                .collect(Collectors.toMap(OrderCountRow::getOrderId, Function.identity()));
        return orders.map(o -> {
            OrderCountRow count = counts.get(o.getId());
            Customer c = o.getCustomer();
            return new OrderRow(o.getId(), o.getCreatedAt().format(DATE_TIME), o.getStatus(),
                    o.getPaymentMethod().getLabel(), o.getPaymentStatus().getLabel(), o.getTotalAmount(),
                    count == null ? 0 : count.getLineCount(), count == null ? 0 : count.getTotalQuantity(),
                    c.getFullName(), c.getAccount().getEmail(), o.isCancelRequested());
        });
    }

    // Gọi trong transaction: các quan hệ LAZY (khách, nhân viên) được nạp ở đây
    private OrderDetailDto toDetail(Order order) {
        Map<Long, List<String>> lotsByItem = orderItemLotRepository.findByOrderId(order.getId()).stream()
                .collect(Collectors.groupingBy(x -> x.getOrderItem().getId(),
                        Collectors.mapping(x -> "Lô #" + x.getLot().getId() + " · HSD "
                                + x.getLot().getExpiryDate().format(DATE) + " · " + x.getQuantity() + " sp",
                                Collectors.toList())));

        List<OrderItem> items = orderItemRepository.findDetailedByOrderId(order.getId());
        Set<Long> reviewed = items.isEmpty() ? Set.of() : new HashSet<>(
                productReviewRepository.findReviewedOrderItemIds(items.stream().map(OrderItem::getId).toList()));
        List<OrderLineDto> lines = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal discountTotal = BigDecimal.ZERO;
        for (OrderItem item : items) {
            BigDecimal gross = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            subtotal = subtotal.add(gross);
            discountTotal = discountTotal.add(item.getDiscountAmount());
            lines.add(new OrderLineDto(item.getId(), item.getProduct().getId(), item.getProduct().getFullSku(), item.getProduct().getName(),
                    item.getProduct().getImageUrl(), item.getFlashSaleItem() != null,
                    item.getFlashSaleItem() == null ? null : item.getFlashSaleItem().getFlashSale().getName(),
                    item.getQuantity(), item.getUnitPrice(), item.getDiscountAmount(), item.getLineTotal(),
                    lotsByItem.getOrDefault(item.getId(), List.of()), reviewed.contains(item.getId())));
        }

        // Hạn giữ hàng VNPay (tính từ lần thanh toán đầu), chỉ khi đơn còn chờ thanh toán
        LocalDateTime holdUntil = order.getPaymentMethod() == PaymentMethod.VNPAY
                && order.getStatus() == OrderStatus.PENDING && order.getPaymentStatus() == PaymentStatus.UNPAID
                ? paymentRepository.findFirstByOrder_IdAndMethodOrderByCreatedAtAscIdAsc(order.getId(), PaymentMethod.VNPAY)
                        .map(p -> vnpayClient.holdUntil(p.getCreatedAt())).orElse(null)
                : null;

        Customer customer = order.getCustomer();
        return OrderDetailDto.builder()
                .id(order.getId())
                .status(order.getStatus())
                .paymentMethod(order.getPaymentMethod())
                .paymentStatus(order.getPaymentStatus())
                .shippingAddress(order.getShippingAddress())
                .customerName(customer.getFullName())
                .customerEmail(customer.getAccount().getEmail())
                .customerPhone(customer.getPhone())
                .lines(lines)
                .subtotal(subtotal)
                .tierDiscountRate(order.getTierDiscountRate())
                .discountTotal(discountTotal)
                .shippingFee(order.getShippingFee())
                .totalAmount(order.getTotalAmount())
                .createdAtText(format(order.getCreatedAt()))
                .confirmedAtText(format(order.getConfirmedAt()))
                .confirmedByName(order.getConfirmedBy() == null ? null : order.getConfirmedBy().getFullName())
                .packedByName(order.getPackedBy() == null ? null : order.getPackedBy().getFullName())
                .shippedAtText(format(order.getShippedAt()))
                .completedAtText(format(order.getCompletedAt()))
                .cancelledAtText(format(order.getCancelledAt()))
                .returnedAtText(format(order.getReturnedAt()))
                .cancelReason(order.getCancelReason())
                .cancelRequested(order.isCancelRequested())
                .needsRefund(needsRefund(order))
                .vnpayHoldUntil(holdUntil == null ? null : holdUntil.format(DATE_TIME))
                .vnpayHoldUntilMillis(holdUntil == null ? null : VnpayClient.toEpochMillis(holdUntil))
                .payments(paymentRepository.findByOrder_IdOrderByCreatedAtAscIdAsc(order.getId()).stream()
                        .map(p -> p.getMethod().name() + " · " + p.getStatus().getLabel()
                                + (p.getVnpTransactionNo() == null ? "" : " · mã VNPay " + p.getVnpTransactionNo())
                                + (p.getPaidAt() == null ? "" : " · " + format(p.getPaidAt())))
                        .toList())
                .build();
    }

    private static String format(LocalDateTime time) {
        return time == null ? null : time.format(DATE_TIME);
    }
}
