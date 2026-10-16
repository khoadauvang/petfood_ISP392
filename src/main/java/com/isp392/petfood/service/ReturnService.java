package com.isp392.petfood.service;

import com.isp392.petfood.dto.InspectForm;
import com.isp392.petfood.dto.ReturnDetailDto;
import com.isp392.petfood.dto.ReturnDetailDto.MediaDto;
import com.isp392.petfood.dto.ReturnForm;
import com.isp392.petfood.dto.ReturnLineDto;
import com.isp392.petfood.dto.ReturnRow;
import com.isp392.petfood.dto.ReturnableLine;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.entity.OrderItem;
import com.isp392.petfood.entity.OrderItemLot;
import com.isp392.petfood.entity.ReturnItem;
import com.isp392.petfood.entity.ReturnMedia;
import com.isp392.petfood.entity.ReturnRequest;
import com.isp392.petfood.enums.InspectionResult;
import com.isp392.petfood.enums.MediaType;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentStatus;
import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.OrderItemLotRepository;
import com.isp392.petfood.repository.OrderItemRepository;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.ReturnItemRepository;
import com.isp392.petfood.repository.ReturnMediaRepository;
import com.isp392.petfood.repository.ReturnRequestRepository;
import com.isp392.petfood.service.ReturnMediaStorage.Detected;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

// Trả hàng và hoàn tiền (module 7).
//   Khách gửi: chỉ đơn COMPLETED trong 3 ngày (BR-32), mỗi dòng đơn trả một lần, kèm 1-5 ảnh/video (BR-33);
//     hàng Flash Sale không trả với lý do hạn dùng (BR-35); đơn COD nhập đủ tài khoản nhận hoàn (LI-05).
//   Staff: REQUESTED -> APPROVED | REJECTED (phải ghi lý do, BR-36) -> RECEIVED -> INSPECTED -> REFUNDED | CLOSED.
//     Thẩm định từng dòng: RESTOCKED (cộng trả đúng lô gốc qua OrderItemLot) hoặc DISPOSED (BR-38);
//     refund_amount = phần khách thực trả cho số lượng trả (sau giảm hạng, không gồm phí ship), BR-37.
//     Dòng không được chấp nhận (ví dụ đã mở mà không phải lỗi sản phẩm, BR-34) thì hoàn 0đ.
//   Đơn RETURNED (khách không nhận hàng): hệ thống tạo sẵn yêu cầu REFUSED_DELIVERY ở trạng thái RECEIVED để thẩm định.
//   Hoàn tiền làm thủ công (mục 9.12): staff chuyển khoản rồi bấm "Đã hoàn tiền".
@Service
@RequiredArgsConstructor
public class ReturnService {

    private static final Logger log = LoggerFactory.getLogger(ReturnService.class);
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final int MAX_MEDIA = 5;
    private static final int PAGE_SIZE = 15;

    private final ReturnRequestRepository returnRequestRepository;
    private final ReturnItemRepository returnItemRepository;
    private final ReturnMediaRepository returnMediaRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderItemLotRepository orderItemLotRepository;
    private final LotRepository lotRepository;
    private final EmployeeRepository employeeRepository;
    private final MembershipPolicy membershipPolicy;
    private final ReturnMediaStorage mediaStorage;

    // ===== Phía khách =====

    // Đơn còn trả được không (để hiện nút "Yêu cầu trả hàng")
    @Transactional(readOnly = true)
    public boolean canRequest(Long customerId, Long orderId) {
        return orderRepository.findByIdAndCustomer_Id(orderId, customerId)
                .filter(this::withinWindow)
                .map(o -> !returnableLines(o).isEmpty())
                .orElse(false);
    }

    @Transactional(readOnly = true)
    public List<ReturnableLine> returnableLines(Long customerId, Long orderId) {
        Order order = customerOrder(customerId, orderId);
        requireWindow(order);
        List<ReturnableLine> lines = returnableLines(order);
        if (lines.isEmpty()) {
            throw new BusinessRuleException("Các sản phẩm của đơn #" + orderId + " đều đã gửi yêu cầu trả hàng.");
        }
        return lines;
    }

    @Transactional(readOnly = true)
    public boolean isCod(Long customerId, Long orderId) {
        return customerOrder(customerId, orderId).getPaymentMethod() == PaymentMethod.COD;
    }

    @Transactional
    public ReturnRequest create(Long customerId, Long orderId, ReturnForm form) {
        Order order = customerOrder(customerId, orderId);
        requireWindow(order);
        Map<String, String> errors = new LinkedHashMap<>();

        if (form.getReason() == ReturnReason.REFUSED_DELIVERY) {
            errors.put("reason", "Vui lòng chọn lý do trả hàng");
        }

        // Dòng trả: thuộc đơn này, chưa trả lần nào, số lượng 1..số đã mua
        Map<Long, OrderItem> orderItems = orderItemRepository.findDetailedByOrderId(orderId).stream()
                .collect(Collectors.toMap(OrderItem::getId, Function.identity()));
        Set<Long> alreadyReturned = new HashSet<>(returnItemRepository.findReturnedOrderItemIds(orderId));
        List<ReturnForm.Line> chosen = form.getLines().stream().filter(ReturnForm.Line::isSelected).toList();
        if (chosen.isEmpty()) {
            errors.put("lines", "Vui lòng chọn ít nhất một sản phẩm muốn trả");
        }
        for (ReturnForm.Line line : chosen) {
            OrderItem item = orderItems.get(line.getOrderItemId());
            if (item == null || alreadyReturned.contains(line.getOrderItemId())) {
                errors.put("lines", "Có sản phẩm không thuộc đơn hoặc đã gửi yêu cầu trả trước đó");
                continue;
            }
            if (line.getQuantity() == null || line.getQuantity() < 1 || line.getQuantity() > item.getQuantity()) {
                errors.put("lines", item.getProduct().getName() + ": số lượng trả từ 1 đến " + item.getQuantity());
            }
            // BR-35: hàng Flash Sale không trả với lý do hạn ngắn (khách đã biết hạn khi mua)
            if (item.getFlashSaleItem() != null && form.getReason() == ReturnReason.EXPIRY_ISSUE) {
                errors.put("reason", item.getProduct().getName()
                        + " mua qua Flash Sale nên không trả được với lý do hạn sử dụng");
            }
        }

        // 1 đến 5 ảnh / video (BR-33)
        List<MultipartFile> files = form.getMedia() == null ? List.of()
                : form.getMedia().stream().filter(f -> f != null && !f.isEmpty()).toList();
        if (files.isEmpty() || files.size() > MAX_MEDIA) {
            errors.put("media", "Vui lòng gửi từ 1 đến " + MAX_MEDIA + " ảnh hoặc video làm bằng chứng");
        }

        // Đơn COD: phải có đủ tài khoản nhận hoàn (LI-05); đơn VNPay không cần
        boolean cod = order.getPaymentMethod() == PaymentMethod.COD;
        if (cod && (blank(form.getRefundBankName()) || blank(form.getRefundAccountNo()) || blank(form.getRefundAccountHolder()))) {
            errors.put("refundBankName", "Đơn COD: vui lòng nhập đủ ngân hàng, số tài khoản và chủ tài khoản để nhận tiền hoàn");
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        // Đọc và kiểm tra file trước khi ghi gì vào DB
        List<byte[]> contents = new ArrayList<>();
        List<Detected> types = new ArrayList<>();
        for (int i = 0; i < files.size(); i++) {
            try {
                byte[] data = files.get(i).getBytes();
                types.add(mediaStorage.detect(data, "File số " + (i + 1)));
                contents.add(data);
            } catch (IOException e) {
                throw new BusinessRuleException("media", "Không đọc được file số " + (i + 1));
            }
        }

        ReturnRequest request = new ReturnRequest();
        request.setOrder(order);
        request.setReason(form.getReason());
        request.setDescription(blank(form.getDescription()) ? null : form.getDescription().trim());
        if (cod) {
            request.setRefundBankName(form.getRefundBankName().trim());
            request.setRefundAccountNo(form.getRefundAccountNo().trim());
            request.setRefundAccountHolder(form.getRefundAccountHolder().trim());
        }
        returnRequestRepository.save(request);
        for (ReturnForm.Line line : chosen) {
            returnItemRepository.save(new ReturnItem(request, orderItems.get(line.getOrderItemId()),
                    line.getQuantity(), line.isOpened()));
        }
        for (int i = 0; i < contents.size(); i++) {
            String url = mediaStorage.save(request.getId(), contents.get(i), types.get(i).extension());
            returnMediaRepository.save(new ReturnMedia(request, types.get(i).type(), url));
        }
        try {
            returnItemRepository.flush();
        } catch (DataIntegrityViolationException e) {
            // Gửi 2 lần cùng lúc: UQ_ReturnItem_order_item_id chặn dòng trả trùng
            throw new BusinessRuleException("Sản phẩm này vừa được gửi yêu cầu trả hàng, vui lòng tải lại trang.");
        }
        return request;
    }

    @Transactional(readOnly = true)
    public List<ReturnRow> listForOrder(Long customerId, Long orderId) {
        customerOrder(customerId, orderId);
        return returnRequestRepository.findByOrder_IdOrderByCreatedAtDesc(orderId).stream().map(this::toRow).toList();
    }

    @Transactional(readOnly = true)
    public ReturnDetailDto getForCustomer(Long customerId, Long orderId, Long returnId) {
        ReturnRequest request = find(returnId);
        Order order = request.getOrder();
        if (!order.getId().equals(orderId) || !order.getCustomer().getId().equals(customerId)) {
            throw new NotFoundException("Không tìm thấy yêu cầu trả hàng #" + returnId);
        }
        return toDetail(request);
    }

    // ===== Phía Staff =====

    @Transactional(readOnly = true)
    public Page<ReturnRow> search(ReturnStatus status, int pageNumber) {
        return returnRequestRepository.search(status,
                        PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt", "id")))
                .map(this::toRow);
    }

    @Transactional(readOnly = true)
    public long countWaiting() {
        return returnRequestRepository.countByStatus(ReturnStatus.REQUESTED)
                + returnRequestRepository.countByStatus(ReturnStatus.RECEIVED);
    }

    @Transactional(readOnly = true)
    public ReturnDetailDto getForStaff(Long returnId) {
        return toDetail(find(returnId));
    }

    @Transactional
    public ReturnRequest approve(Long returnId, Long employeeId) {
        ReturnRequest r = lock(returnId);
        requireStatus(r, ReturnStatus.REQUESTED, "duyệt");
        r.setStatus(ReturnStatus.APPROVED);
        r.setReviewedBy(employeeRepository.getReferenceById(employeeId));
        r.setReviewedAt(LocalDateTime.now());
        return r;
    }

    @Transactional
    public ReturnRequest reject(Long returnId, Long employeeId, String reason) {
        if (blank(reason)) {
            throw new BusinessRuleException("Vui lòng nhập lý do từ chối (BR-36)");
        }
        ReturnRequest r = lock(returnId);
        requireStatus(r, ReturnStatus.REQUESTED, "từ chối");
        r.setStatus(ReturnStatus.REJECTED);
        r.setRejectReason(reason.trim().length() > 255 ? reason.trim().substring(0, 255) : reason.trim());
        r.setReviewedBy(employeeRepository.getReferenceById(employeeId));
        r.setReviewedAt(LocalDateTime.now());
        return r;
    }

    // Đã nhận hàng khách gửi trả
    @Transactional
    public ReturnRequest receive(Long returnId) {
        ReturnRequest r = lock(returnId);
        requireStatus(r, ReturnStatus.APPROVED, "xác nhận nhận hàng");
        r.setStatus(ReturnStatus.RECEIVED);
        r.setReceivedAt(LocalDateTime.now());
        return r;
    }

    // Thẩm định từng dòng; tổng hoàn 0đ thì đóng luôn yêu cầu
    @Transactional
    public ReturnRequest inspect(Long returnId, Long employeeId, InspectForm form) {
        ReturnRequest r = lock(returnId);
        requireStatus(r, ReturnStatus.RECEIVED, "thẩm định");
        Map<Long, InspectForm.Line> byItem = form.getLines().stream()
                .filter(l -> l.getReturnItemId() != null)
                .collect(Collectors.toMap(InspectForm.Line::getReturnItemId, Function.identity(), (a, b) -> a));
        List<ReturnItem> items = returnItemRepository.findByReturnId(returnId);
        for (ReturnItem item : items) {
            InspectForm.Line line = byItem.get(item.getId());
            if (line == null || line.getResult() == null) {
                throw new BusinessRuleException("Vui lòng chọn kết quả thẩm định cho mọi sản phẩm (tái nhập hoặc tiêu huỷ)");
            }
        }

        boolean paid = r.getOrder().getPaymentStatus() == PaymentStatus.PAID;
        BigDecimal total = BigDecimal.ZERO;
        for (ReturnItem item : items) {
            InspectForm.Line line = byItem.get(item.getId());
            item.setInspectionResult(line.getResult());
            item.setInspectionNote(blank(line.getNote()) ? null
                    : line.getNote().trim().length() > 255 ? line.getNote().trim().substring(0, 255) : line.getNote().trim());
            // Đơn chưa trả tiền (COD khách không nhận) thì không có gì để hoàn
            BigDecimal refund = paid && line.isRefund() ? maxRefund(item) : BigDecimal.ZERO;
            item.setRefundAmount(refund);
            total = total.add(refund);
            if (line.getResult() == InspectionResult.RESTOCKED) {
                restock(item);
            }
        }
        r.setInspectedBy(employeeRepository.getReferenceById(employeeId));
        r.setStatus(total.signum() > 0 ? ReturnStatus.INSPECTED : ReturnStatus.CLOSED);
        return r;
    }

    // Staff đã chuyển khoản hoàn tiền (thủ công, mục 9.12)
    @Transactional
    public ReturnRequest markRefunded(Long returnId) {
        ReturnRequest r = lock(returnId);
        requireStatus(r, ReturnStatus.INSPECTED, "ghi nhận hoàn tiền");
        r.setStatus(ReturnStatus.REFUNDED);
        r.setRefundedAt(LocalDateTime.now());
        returnItemRepository.flush();

        // Hoàn đủ toàn bộ tiền hàng của đơn thì đơn chuyển REFUNDED (BR-18)
        Order order = r.getOrder();
        BigDecimal goods = order.getTotalAmount().subtract(order.getShippingFee());
        if (returnItemRepository.sumRefundedOfOrder(order.getId()).compareTo(goods) >= 0) {
            order.setPaymentStatus(PaymentStatus.REFUNDED);
        }
        return r;
    }

    // Đơn RETURNED (khách không nhận hàng): tạo sẵn yêu cầu, hàng đã về kho nên ở RECEIVED chờ thẩm định
    @Transactional
    public ReturnRequest createForRefusedDelivery(Order order) {
        ReturnRequest request = new ReturnRequest();
        request.setOrder(order);
        request.setReason(ReturnReason.REFUSED_DELIVERY);
        request.setDescription("Khách không nhận hàng, hệ thống tạo yêu cầu để thẩm định");
        request.setStatus(ReturnStatus.RECEIVED);
        request.setReceivedAt(LocalDateTime.now());
        returnRequestRepository.save(request);
        for (OrderItem item : orderItemRepository.findDetailedByOrderId(order.getId())) {
            returnItemRepository.save(new ReturnItem(request, item, item.getQuantity(), false));
        }
        return request;
    }

    // ===== Phụ trợ =====

    // Số tiền khách thực trả cho phần trả của dòng: (đơn giá × SL − giảm hạng) × SL trả / SL mua (BR-37)
    private static BigDecimal maxRefund(ReturnItem item) {
        OrderItem oi = item.getOrderItem();
        return oi.getLineTotal().multiply(BigDecimal.valueOf(item.getQuantity()))
                .divide(BigDecimal.valueOf(oi.getQuantity()), 0, RoundingMode.HALF_UP);
    }

    // Tái nhập về đúng lô đã xuất cho dòng đơn này (BR-38)
    private void restock(ReturnItem item) {
        int remaining = item.getQuantity();
        for (OrderItemLot taken : orderItemLotRepository.findByOrderId(item.getOrderItem().getOrder().getId())) {
            if (remaining == 0) {
                break;
            }
            if (!taken.getOrderItem().getId().equals(item.getOrderItem().getId())) {
                continue;
            }
            int qty = Math.min(remaining, taken.getQuantity());
            if (lotRepository.putBack(taken.getLot().getId(), qty) == 1) {
                remaining -= qty;
            } else {
                log.warn("Trả hàng #{}: không tái nhập được {} sp vào lô #{}", item.getReturnRequest().getId(),
                        qty, taken.getLot().getId());
            }
        }
    }

    private boolean withinWindow(Order order) {
        return order.getStatus() == OrderStatus.COMPLETED && order.getCompletedAt() != null
                && !LocalDateTime.now().isAfter(order.getCompletedAt().plusDays(membershipPolicy.getReturnWindowDays()));
    }

    private void requireWindow(Order order) {
        if (!withinWindow(order)) {
            throw new BusinessRuleException("Chỉ trả hàng cho đơn đã giao thành công trong vòng "
                    + membershipPolicy.getReturnWindowDays() + " ngày (BR-32).");
        }
    }

    private List<ReturnableLine> returnableLines(Order order) {
        Set<Long> returned = new HashSet<>(returnItemRepository.findReturnedOrderItemIds(order.getId()));
        return orderItemRepository.findDetailedByOrderId(order.getId()).stream()
                .filter(i -> !returned.contains(i.getId()))
                .map(i -> new ReturnableLine(i.getId(), i.getProduct().getName(), i.getFlashSaleItem() != null,
                        i.getQuantity(), i.getLineTotal()))
                .toList();
    }

    private Order customerOrder(Long customerId, Long orderId) {
        return orderRepository.findByIdAndCustomer_Id(orderId, customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy đơn #" + orderId));
    }

    private ReturnRequest find(Long id) {
        return returnRequestRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy yêu cầu trả hàng #" + id));
    }

    private ReturnRequest lock(Long id) {
        return returnRequestRepository.findByIdForUpdate(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy yêu cầu trả hàng #" + id));
    }

    private static void requireStatus(ReturnRequest r, ReturnStatus expected, String action) {
        if (r.getStatus() != expected) {
            throw new BusinessRuleException("Yêu cầu #" + r.getId() + " đang \"" + r.getStatus().getLabel()
                    + "\", không " + action + " được.");
        }
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }

    private ReturnRow toRow(ReturnRequest r) {
        Customer c = r.getOrder().getCustomer();
        return new ReturnRow(r.getId(), r.getOrder().getId(), r.getCreatedAt().format(DATE_TIME), r.getReason(),
                r.getStatus(), c.getFullName(), c.getAccount().getEmail());
    }

    private ReturnDetailDto toDetail(ReturnRequest r) {
        List<ReturnLineDto> lines = returnItemRepository.findByReturnId(r.getId()).stream()
                .map(i -> new ReturnLineDto(i.getId(), i.getOrderItem().getProduct().getId(),
                        i.getOrderItem().getProduct().getSku(), i.getOrderItem().getProduct().getName(),
                        i.getOrderItem().getFlashSaleItem() != null, i.getOrderItem().getQuantity(), i.getQuantity(),
                        Boolean.TRUE.equals(i.getOpened()), maxRefund(i), i.getInspectionResult(),
                        i.getInspectionNote(), i.getRefundAmount()))
                .toList();
        BigDecimal refundTotal = lines.stream().map(ReturnLineDto::getRefundAmount)
                .filter(a -> a != null).reduce(BigDecimal.ZERO, BigDecimal::add);
        Order order = r.getOrder();
        Customer c = order.getCustomer();
        return ReturnDetailDto.builder()
                .id(r.getId())
                .orderId(order.getId())
                .reason(r.getReason())
                .description(r.getDescription())
                .status(r.getStatus())
                .rejectReason(r.getRejectReason())
                .refundBankName(r.getRefundBankName())
                .refundAccountNo(r.getRefundAccountNo())
                .refundAccountHolder(r.getRefundAccountHolder())
                .customerName(c.getFullName())
                .customerEmail(c.getAccount().getEmail())
                .customerPhone(c.getPhone())
                .paymentMethod(order.getPaymentMethod())
                .paymentStatus(order.getPaymentStatus())
                .lines(lines)
                .media(returnMediaRepository.findByReturnRequest_IdOrderByIdAsc(r.getId()).stream()
                        .map(m -> new MediaDto(m.getMediaType() == MediaType.VIDEO, m.getMediaUrl())).toList())
                .refundTotal(refundTotal)
                .createdAtText(r.getCreatedAt().format(DATE_TIME))
                .reviewedText(r.getReviewedAt() == null ? null : r.getReviewedAt().format(DATE_TIME)
                        + (r.getReviewedBy() == null ? "" : " · " + r.getReviewedBy().getFullName()))
                .receivedAtText(r.getReceivedAt() == null ? null : r.getReceivedAt().format(DATE_TIME))
                .inspectedByName(r.getInspectedBy() == null ? null : r.getInspectedBy().getFullName())
                .refundedAtText(r.getRefundedAt() == null ? null : r.getRefundedAt().format(DATE_TIME))
                .build();
    }
}
