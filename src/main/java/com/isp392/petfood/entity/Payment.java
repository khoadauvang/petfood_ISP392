package com.isp392.petfood.entity;

import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentRecordStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// Một lần thanh toán của đơn (module 5).
//   VNPay: tạo lúc đặt hàng (PENDING, có vnp_txn_ref), thành SUCCESS / FAILED khi VNPay báo kết quả
//   COD  : ghi SUCCESS khi staff xác nhận giao thành công (BR-26)
// DB chặn: amount > 0; dòng VNPay phải có vnp_txn_ref (CK_Payment_vnpay_ref), vnp_txn_ref không trùng.
@Entity
@Table(name = "Payment")
@Getter
@Setter
@NoArgsConstructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Enumerated(EnumType.STRING)
    @Column(name = "method", nullable = false, length = 10)
    private PaymentMethod method;

    @Column(name = "amount", nullable = false, precision = 12, scale = 0)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private PaymentRecordStatus status = PaymentRecordStatus.PENDING;

    // Mã giao dịch shop gửi sang VNPay (vnp_TxnRef)
    @Column(name = "vnp_txn_ref", length = 50)
    private String vnpTxnRef;

    // Mã giao dịch phía VNPay (vnp_TransactionNo), có khi VNPay báo kết quả
    @Column(name = "vnp_transaction_no", length = 50)
    private String vnpTransactionNo;

    @Column(name = "vnp_response_code", length = 10)
    private String vnpResponseCode;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    // Với VNPay: đúng bằng vnp_CreateDate đã gửi (giờ VN, tròn giây) vì API tra cứu querydr cần lại giá trị này
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public Payment(Order order, PaymentMethod method, BigDecimal amount) {
        this.order = order;
        this.method = method;
        this.amount = amount;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
