package com.isp392.petfood.entity;

import com.isp392.petfood.enums.FlashSaleStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Chiến dịch Flash Sale (module 6). Giỏ hàng chỉ đọc bảng này để biết suất Flash Sale còn bán được không.
@Entity
@Table(name = "FlashSale")
@Getter
@Setter
@NoArgsConstructor
public class FlashSale {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flash_sale_id")
    private Long id;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    // DB chặn: end_time > start_time (CK_FlashSale_time)
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private FlashSaleStatus status = FlashSaleStatus.DRAFT;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by", nullable = false)
    private Employee createdBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    // Đang mở bán: ACTIVE và thời điểm "now" nằm trong khung giờ (phòng khi scheduler chưa kịp chuyển trạng thái)
    public boolean isRunningAt(LocalDateTime now) {
        return status == FlashSaleStatus.ACTIVE && !now.isBefore(startTime) && now.isBefore(endTime);
    }
}
