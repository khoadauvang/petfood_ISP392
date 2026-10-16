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

    // Lần thanh toán VNPay đang chờ của một đơn (mỗi đơn VNPay chỉ có một lần, BR-23: thất bại thì huỷ đơn)
    Optional<Payment> findFirstByOrder_IdAndMethodAndStatus(Long orderId, PaymentMethod method, PaymentRecordStatus status);
}
