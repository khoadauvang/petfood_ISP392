package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Lot")
@Getter
@Setter
@NoArgsConstructor
public class Lot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lot_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    // DB chặn: expiry_date > CAST(received_at AS DATE) (CK_Lot_expiry_after_received, BR-51)
    @Column(name = "expiry_date", nullable = false)
    private LocalDate expiryDate;

    // Số lượng nhập vào, giữ nguyên sau khi tạo (chỉ sửa khi nhập nhầm và lô chưa xuất hàng nào)
    @Column(name = "received_qty", nullable = false)
    private Integer receivedQty;

    // Số lượng còn trong kho: lúc nhập = received_qty, giảm khi đóng gói đơn (0 <= on_hand <= received)
    @Column(name = "on_hand_qty", nullable = false)
    private Integer onHandQty;

    @Column(name = "received_at", nullable = false, updatable = false)
    private LocalDateTime receivedAt;

    @PrePersist
    void onCreate() {
        if (receivedAt == null) {
            receivedAt = LocalDateTime.now();
        }
    }

    // Lô chưa xuất bán đơn vị nào: còn nguyên số lượng đã nhập
    public boolean isUntouched() {
        return onHandQty != null && onHandQty.equals(receivedQty);
    }
}
