package com.isp392.petfood.entity;

import com.isp392.petfood.enums.ReviewStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Đánh giá sản phẩm (module 8): chỉ cho dòng hàng thuộc đơn COMPLETED, mỗi order_item một đánh giá
// (UQ_ProductReview_order_item_id). product_id và customer_id phải khớp dòng đơn (ghi chú 4 trong script, BE kiểm tra).
@Entity
@Table(name = "ProductReview")
@Getter
@Setter
@NoArgsConstructor
public class ProductReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "review_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_item_id", nullable = false, unique = true)
    private OrderItem orderItem;

    // 1 đến 5 sao (CK_ProductReview_rating)
    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "title", length = 150)
    private String title;

    @Column(name = "content", columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ReviewStatus status = ReviewStatus.VISIBLE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
