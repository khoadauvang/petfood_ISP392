package com.isp392.petfood.entity;

import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Yêu cầu trả hàng (module 7). Chỉ cho đơn COMPLETED trong 3 ngày (BR-32), hoặc hệ thống tạo khi đơn RETURNED
// (khách không nhận hàng, lý do REFUSED_DELIVERY). DB chặn: từ chối phải có lý do; 3 cột tài khoản nhận hoàn
// đủ cả 3 hoặc trống cả 3 (chỉ đơn COD mới cần, LI-05).
@Entity
@Table(name = "ReturnRequest")
@Getter
@Setter
@NoArgsConstructor
public class ReturnRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "return_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason_type", nullable = false, length = 20)
    private ReturnReason reason;

    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ReturnStatus status = ReturnStatus.REQUESTED;

    @Column(name = "reject_reason", length = 255)
    private String rejectReason;

    @Column(name = "refund_bank_name", length = 100)
    private String refundBankName;

    @Column(name = "refund_account_no", length = 30)
    private String refundAccountNo;

    @Column(name = "refund_account_holder", length = 100)
    private String refundAccountHolder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    private Employee reviewedBy;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    @Column(name = "received_at")
    private LocalDateTime receivedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inspected_by")
    private Employee inspectedBy;

    @Column(name = "refunded_at")
    private LocalDateTime refundedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
