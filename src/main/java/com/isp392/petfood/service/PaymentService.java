package com.isp392.petfood.service;

import com.isp392.petfood.entity.Order;
import com.isp392.petfood.entity.Payment;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentRecordStatus;
import com.isp392.petfood.enums.PaymentStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.PaymentRepository;
import com.isp392.petfood.service.VnpayClient.QueryOutcome;
import com.isp392.petfood.service.VnpayClient.QueryResult;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

// Thanh toán (module 5).
// VNPay: đặt hàng xong tạo một Payment PENDING rồi chuyển khách sang VNPay. Hàng đã trừ kho được giữ 15 phút (BR-23).
//   Kết quả đến qua return URL (trình duyệt quay về) hoặc IPN (VNPay gọi server; cần URL public như ngrok):
//     thành công + chữ ký đúng (BR-24) -> Payment SUCCESS, đơn PAID
//     thất bại / khách bấm huỷ, còn hạn -> Payment FAILED, đơn vẫn PENDING + UNPAID, giữ hàng đến hết 15 phút tính
//                                         từ lần đầu; khách thanh toán lại bằng một Payment mới (chốt 29/10)
//     thất bại, đã quá hạn             -> Payment FAILED, đơn FAILED + tự huỷ, trả kho (BR-23)
//   Quá 15 phút: job hỏi lại VNPay (querydr) lần đang chờ trước khi huỷ, không huỷ nhầm đơn đã trả tiền (cách A);
//   không còn lần nào đang chờ (các lần đều thất bại) thì huỷ luôn.
// COD: chưa xác nhận sau 24 giờ thì tự huỷ (BR-27); ghi Payment SUCCESS khi giao thành công (BR-26, ở OrderService).
// Đơn VNPay đã trả tiền mà bị huỷ: staff chuyển khoản hoàn rồi bấm "Đã hoàn tiền" -> REFUNDED (thủ công, mục 9.12).
@Service
@RequiredArgsConstructor
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);
    private static final DateTimeFormatter TXN_TIME = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final DateTimeFormatter HOLD_TIME = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
    private static final Set<OrderStatus> AUTO_CANCELLABLE = Set.of(OrderStatus.PENDING, OrderStatus.CONFIRMED);

    // Kết quả xử lý dữ liệu VNPay gửi về: ipnCode / ipnMessage là thứ IPN phải trả lời VNPay
    // held = thanh toán chưa thành công nhưng đơn vẫn được giữ, khách thanh toán lại được
    public record CallbackResult(Long orderId, boolean paid, boolean held, String message, String ipnCode, String ipnMessage) {
    }

    private final VnpayClient vnpay;
    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;
    private final OrderService orderService;

    public boolean isVnpayEnabled() {
        return vnpay.isConfigured();
    }

    // Gọi trong transaction đặt hàng: tạo lần thanh toán VNPay đang chờ
    @Transactional
    public Payment createVnpayAttempt(Order order) {
        LocalDateTime createdAt = VnpayClient.nowVn();
        Payment payment = new Payment(order, PaymentMethod.VNPAY, order.getTotalAmount());
        payment.setCreatedAt(createdAt);
        payment.setVnpTxnRef("PF" + order.getId() + "T" + createdAt.format(TXN_TIME));   // UX_Payment_vnp_txn_ref
        return paymentRepository.save(payment);
    }

    // Link sang VNPay cho đơn của khách (lúc vừa đặt, hoặc nút "Tiếp tục thanh toán" trong 15 phút giữ hàng).
    // Lần trước đã thất bại / bị huỷ thì tạo lần mới với vnp_TxnRef mới (VNPay không nhận lại mã đã dùng).
    @Transactional
    public String paymentUrl(Long customerId, Long orderId, String clientIp) {
        orderRepository.findByIdAndCustomer_Id(orderId, customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy đơn #" + orderId));
        Order order = orderRepository.findByIdForUpdate(orderId).orElseThrow();   // không tạo hai lần mới khi bấm nhanh
        if (order.getPaymentMethod() != PaymentMethod.VNPAY
                || order.getStatus() != OrderStatus.PENDING || order.getPaymentStatus() != PaymentStatus.UNPAID) {
            throw new BusinessRuleException("Đơn #" + orderId + " không còn chờ thanh toán.");
        }
        LocalDateTime holdUntil = holdUntil(orderId)
                .orElseThrow(() -> new BusinessRuleException("Đơn #" + orderId + " không có giao dịch VNPay."));
        if (!VnpayClient.nowVn().isBefore(holdUntil)) {
            throw new BusinessRuleException("Đã quá " + vnpay.getHoldMinutes()
                    + " phút giữ hàng, đơn sẽ tự huỷ. Vui lòng đặt lại.");
        }
        Payment payment = pendingVnpay(orderId).orElseGet(() -> createVnpayAttempt(order));
        return vnpay.paymentUrl(payment, holdUntil, clientIp);
    }

    // ===== Return URL + IPN: cùng một cách xử lý, chạy lại nhiều lần không sao (VNPay có thể gửi IPN nhiều lần) =====
    @Transactional
    public CallbackResult handleVnpayCallback(Map<String, String> params) {
        if (!vnpay.verify(params)) {
            return new CallbackResult(null, false, false, "Dữ liệu thanh toán không hợp lệ (sai chữ ký).", "97", "Invalid Checksum");
        }
        Optional<Payment> found = paymentRepository.findByVnpTxnRef(params.get("vnp_TxnRef"));
        if (found.isEmpty()) {
            return new CallbackResult(null, false, false, "Không tìm thấy giao dịch.", "01", "Order not Found");
        }
        Payment payment = found.get();
        Long orderId = payment.getOrder().getId();
        if (!VnpayClient.toVnpAmount(payment.getAmount()).equals(params.get("vnp_Amount"))) {
            return new CallbackResult(orderId, false, false, "Số tiền thanh toán không khớp với đơn.", "04", "invalid amount");
        }
        Order order = orderRepository.findByIdForUpdate(orderId).orElseThrow();   // chặn return URL, IPN, job chạy chồng
        if (payment.getStatus() != PaymentRecordStatus.PENDING) {
            boolean paid = payment.getStatus() == PaymentRecordStatus.SUCCESS;
            boolean held = !paid && isHeld(order);
            return new CallbackResult(orderId, paid, held, paid ? "Đơn đã được thanh toán."
                    : held ? "Thanh toán chưa thành công, bạn vẫn có thể thanh toán lại trong thời gian giữ hàng."
                    : "Thanh toán không thành công.", "02", "Order already confirmed");
        }
        String responseCode = params.get("vnp_ResponseCode");
        boolean success = "00".equals(responseCode) && "00".equals(params.get("vnp_TransactionStatus"));
        if (success) {
            markPaid(order, payment, responseCode, params.get("vnp_TransactionNo"));
            return new CallbackResult(orderId, true, false, "Thanh toán VNPay thành công.", "00", "Confirm Success");
        }
        String failure = "24".equals(responseCode) ? "Bạn đã huỷ thanh toán VNPay"
                : "Thanh toán VNPay không thành công (mã " + responseCode + ")";
        if (isHeld(order)) {
            // Còn hạn giữ hàng: chỉ đánh dấu lần này thất bại, đơn chờ khách thanh toán lại (chốt 29/10)
            recordFailure(payment, responseCode, params.get("vnp_TransactionNo"));
            String until = holdUntil(orderId).orElseThrow().format(HOLD_TIME);
            return new CallbackResult(orderId, false, true, failure + ". Hàng vẫn được giữ đến " + until
                    + ", bạn có thể thanh toán lại trước giờ này.", "00", "Confirm Success");
        }
        markFailed(order, payment, responseCode, params.get("vnp_TransactionNo"), failure);
        return new CallbackResult(orderId, false, false, failure + ", đơn đã được huỷ và trả hàng về kho.",
                "00", "Confirm Success");
    }

    // ===== Job (PaymentJobs gọi từng đơn, mỗi đơn một transaction) =====

    // Lần thanh toán đang chờ của đơn VNPay quá hạn giữ hàng, để job tra cứu (gọi VNPay ngoài transaction)
    @Transactional(readOnly = true)
    public Optional<Payment> findPendingVnpay(Long orderId) {
        return pendingVnpay(orderId).map(p -> {
            p.getOrder().getId();   // nạp sẵn để dùng ngoài transaction
            return p;
        });
    }

    public QueryResult queryVnpay(Payment payment) {
        return vnpay.query(payment, "127.0.0.1");
    }

    // Áp kết quả tra cứu: đã trả -> PAID; chưa trả -> huỷ đơn; không rõ -> để lần chạy sau hỏi lại
    @Transactional
    public void applyQueryResult(Long paymentId, QueryResult result) {
        Payment payment = paymentRepository.findById(paymentId).orElseThrow();
        Order order = orderRepository.findByIdForUpdate(payment.getOrder().getId()).orElseThrow();
        if (payment.getStatus() != PaymentRecordStatus.PENDING) {
            return;                                     // return URL / IPN đã xử lý trong lúc job đang hỏi
        }
        switch (result.outcome()) {
            case PAID -> markPaid(order, payment, result.responseCode(), result.transactionNo());
            case NOT_PAID -> markFailed(order, payment, result.responseCode(), result.transactionNo(),
                    "Quá " + vnpay.getHoldMinutes() + " phút chưa thanh toán VNPay");
            case UNKNOWN -> log.info("Đơn #{}: chưa rõ kết quả VNPay, sẽ hỏi lại", order.getId());
        }
    }

    // Đơn VNPay quá hạn giữ hàng mà không còn lần thanh toán nào đang chờ (các lần đều thất bại / bị huỷ): huỷ đơn
    @Transactional
    public void cancelExpiredVnpay(Long orderId) {
        Order order = orderRepository.findByIdForUpdate(orderId).orElseThrow();
        if (order.getStatus() != OrderStatus.PENDING || order.getPaymentStatus() != PaymentStatus.UNPAID
                || pendingVnpay(orderId).isPresent()) {
            return;                                     // đã xử lý, hoặc vừa có lần mới -> để job hỏi VNPay
        }
        order.setPaymentStatus(PaymentStatus.FAILED);
        orderService.cancel(order, "Quá " + vnpay.getHoldMinutes() + " phút chưa thanh toán VNPay");   // BR-23
    }

    // BR-27: đơn COD chưa được xác nhận sau 24 giờ thì tự huỷ
    @Transactional
    public void cancelStaleCod(Long orderId, int hours) {
        Order order = orderRepository.findByIdForUpdate(orderId).orElseThrow();
        if (order.getStatus() == OrderStatus.PENDING && order.getPaymentMethod() == PaymentMethod.COD) {
            orderService.cancel(order, "Quá " + hours + " giờ cửa hàng chưa xác nhận đơn, hệ thống tự huỷ");
        }
    }

    // ===== Phụ trợ =====

    private void markPaid(Order order, Payment payment, String responseCode, String transactionNo) {
        payment.setStatus(PaymentRecordStatus.SUCCESS);
        payment.setVnpResponseCode(responseCode);
        payment.setVnpTransactionNo(transactionNo);
        payment.setPaidAt(LocalDateTime.now());
        order.setPaymentStatus(PaymentStatus.PAID);
        // Đơn đã bị huỷ trước đó mà tiền vẫn về: giữ CANCELLED + PAID, staff thấy "cần hoàn tiền"
    }

    private void markFailed(Order order, Payment payment, String responseCode, String transactionNo, String reason) {
        recordFailure(payment, responseCode, transactionNo);
        order.setPaymentStatus(PaymentStatus.FAILED);
        if (AUTO_CANCELLABLE.contains(order.getStatus())) {
            orderService.cancel(order, reason);         // BR-23: trả tồn về đúng lô
        }
    }

    private void recordFailure(Payment payment, String responseCode, String transactionNo) {
        payment.setStatus(PaymentRecordStatus.FAILED);
        payment.setVnpResponseCode(responseCode);
        payment.setVnpTransactionNo(transactionNo);
    }

    // Đơn còn chờ thanh toán và chưa hết 15 phút giữ hàng (tính từ lần VNPay đầu)
    private boolean isHeld(Order order) {
        return order.getStatus() == OrderStatus.PENDING && order.getPaymentStatus() == PaymentStatus.UNPAID
                && holdUntil(order.getId()).map(VnpayClient.nowVn()::isBefore).orElse(false);
    }

    private Optional<LocalDateTime> holdUntil(Long orderId) {
        return paymentRepository.findFirstByOrder_IdAndMethodOrderByCreatedAtAscIdAsc(orderId, PaymentMethod.VNPAY)
                .map(p -> vnpay.holdUntil(p.getCreatedAt()));
    }

    private Optional<Payment> pendingVnpay(Long orderId) {
        return paymentRepository.findFirstByOrder_IdAndMethodAndStatus(orderId, PaymentMethod.VNPAY,
                PaymentRecordStatus.PENDING);
    }
}
