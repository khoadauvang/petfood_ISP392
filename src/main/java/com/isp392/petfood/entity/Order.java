package com.isp392.petfood.entity;

import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// Bảng tên Orders ("Order" là từ khoá SQL). Tiền đều DECIMAL(12,0) -> BigDecimal.
// total_amount = tổng (unit_price × quantity − discount_amount) các dòng + shipping_fee, chốt lúc đặt (BR-10, BR-16).
// Số điện thoại người nhận không lưu ở đây: lấy theo Customer.phone của chủ đơn (chốt 15/10).
@Entity
@Table(name = "Orders")
@Getter
@Setter
@NoArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "shipping_address", nullable = false, length = 500)
    private String shippingAddress;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", nullable = false, length = 10)
    private PaymentMethod paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(name = "order_status", nullable = false, length = 20)
    private OrderStatus status = OrderStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false, length = 20)
    private PaymentStatus paymentStatus = PaymentStatus.UNPAID;

    // Phần trăm giảm theo hạng lúc đặt: 0.10 = 0,1%; 3.00 = 3% (ghi chú cột trong script SQL)
    @Column(name = "tier_discount_rate", nullable = false, precision = 5, scale = 2)
    private BigDecimal tierDiscountRate = BigDecimal.ZERO;

    @Column(name = "shipping_fee", nullable = false, precision = 12, scale = 0)
    private BigDecimal shippingFee = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 0)
    private BigDecimal totalAmount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "confirmed_by")
    private Employee confirmedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "packed_by")
    private Employee packedBy;

    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    // Có giá trị khi đơn CANCELLED (lý do huỷ), hoặc khi đơn còn PROCESSING nghĩa là khách đang yêu cầu huỷ
    // chờ staff duyệt (BR-19: đang đóng gói thì không tự huỷ được)
    @Column(name = "cancel_reason", length = 255)
    private String cancelReason;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "returned_at")
    private LocalDateTime returnedAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public boolean isCancelRequested() {
        return status == OrderStatus.PROCESSING && cancelReason != null;
    }
}
