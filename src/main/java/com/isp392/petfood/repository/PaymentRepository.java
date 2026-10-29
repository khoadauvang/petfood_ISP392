package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Payment;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentRecordStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

    Optional<Payment> findByVnpTxnRef(String vnpTxnRef);

    List<Payment> findByOrder_IdOrderByCreatedAtAscIdAsc(Long orderId);

    // Lần thanh toán VNPay đang chờ của một đơn (mỗi lúc tối đa một lần PENDING; thất bại trong hạn giữ hàng
    // thì khách thử lại bằng một lần mới, chốt 29/10)
    Optional<Payment> findFirstByOrder_IdAndMethodAndStatus(Long orderId, PaymentMethod method, PaymentRecordStatus status);

    // Lần VNPay đầu tiên của đơn: hạn giữ hàng 15 phút tính từ lần này, các lần thử lại không gia hạn (BR-23)
    Optional<Payment> findFirstByOrder_IdAndMethodOrderByCreatedAtAscIdAsc(Long orderId, PaymentMethod method);
}
