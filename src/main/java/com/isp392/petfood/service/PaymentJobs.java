package com.isp392.petfood.service;

import com.isp392.petfood.entity.Payment;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.service.VnpayClient.QueryOutcome;
import com.isp392.petfood.service.VnpayClient.QueryResult;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Optional;

// Job định kỳ của module thanh toán (Scheduler trong actor "Bên ngoài"):
//   - mỗi phút: đơn VNPay quá thời gian giữ hàng -> hỏi VNPay (querydr) lần đang chờ rồi PAID hoặc huỷ (BR-23,
//     cách A); không còn lần nào đang chờ (khách huỷ / thất bại rồi không thử lại) thì huỷ luôn
//   - mỗi 10 phút: đơn COD chưa xác nhận quá 24 giờ -> huỷ (BR-27)
// Mỗi đơn xử lý trong transaction riêng: một đơn lỗi không làm hỏng các đơn khác.
@Component
@RequiredArgsConstructor
public class PaymentJobs {

    private static final Logger log = LoggerFactory.getLogger(PaymentJobs.class);
    // Chờ thêm 1 phút sau hạn thanh toán VNPay (vnp_ExpireDate) để giao dịch sát giờ kịp ghi nhận
    private static final int GRACE_MINUTES = 1;

    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
    private final VnpayClient vnpay;

    @Value("${petfood.order.cod-confirm-hours:24}")
    private int codConfirmHours;

    @Scheduled(fixedDelayString = "${petfood.vnpay.expire-job-delay-ms:60000}", initialDelay = 30_000)
    public void expireUnpaidVnpayOrders() {
        LocalDateTime before = VnpayClient.nowVn().minusMinutes(vnpay.getHoldMinutes() + GRACE_MINUTES);
        for (Long orderId : orderRepository.findUnpaidIdsCreatedBefore(PaymentMethod.VNPAY, OrderStatus.PENDING, before)) {
            try {
                Optional<Payment> pending = paymentService.findPendingVnpay(orderId);
                if (pending.isEmpty()) {
                    paymentService.cancelExpiredVnpay(orderId);
                    continue;
                }
                QueryResult result = vnpay.isConfigured()
                        ? paymentService.queryVnpay(pending.get())
                        : new QueryResult(QueryOutcome.NOT_PAID, "99", null);
                paymentService.applyQueryResult(pending.get().getId(), result);
            } catch (RuntimeException e) {
                log.warn("Xử lý đơn VNPay quá hạn #{} lỗi: {}", orderId, e.getMessage());
            }
        }
    }

    @Scheduled(fixedDelayString = "${petfood.order.cod-job-delay-ms:600000}", initialDelay = 60_000)
    public void cancelStaleCodOrders() {
        LocalDateTime before = VnpayClient.nowVn().minusHours(codConfirmHours);
        for (Long orderId : orderRepository.findUnpaidIdsCreatedBefore(PaymentMethod.COD, OrderStatus.PENDING, before)) {
            try {
                paymentService.cancelStaleCod(orderId, codConfirmHours);
                log.info("Tự huỷ đơn COD #{}: quá {} giờ chưa xác nhận", orderId, codConfirmHours);
            } catch (RuntimeException e) {
                log.warn("Tự huỷ đơn COD #{} lỗi: {}", orderId, e.getMessage());
            }
        }
    }
}
