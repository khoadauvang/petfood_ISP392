package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Phản hồi của nhân viên cho một đánh giá, tối đa một phản hồi mỗi đánh giá (UQ_ReviewReply_review_id)
@Entity
@Table(name = "ReviewReply")
@Getter
@Setter
@NoArgsConstructor
public class ReviewReply {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reply_id")
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "review_id", nullable = false, unique = true)
    private ProductReview review;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "replied_by", nullable = false)
    private Employee repliedBy;

    @Column(name = "content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public ReviewReply(ProductReview review, Employee repliedBy, String content) {
        this.review = review;
        this.repliedBy = repliedBy;
        this.content = content;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
