package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Mỗi khách đúng một giỏ (UQ_Cart_customer_id). Tạo khi khách thêm sản phẩm đầu tiên.
@Entity
@Table(name = "Cart")
@Getter
@Setter
@NoArgsConstructor
public class Cart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cart_id")
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false, unique = true)
    private Customer customer;

    // Lần sửa giỏ gần nhất (thêm / đổi số lượng / xoá dòng)
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public Cart(Customer customer) {
        this.customer = customer;
    }

    // Thêm/sửa/xoá CartItem không làm Cart "bẩn" nên @PreUpdate không chạy; CartService gọi touch() mỗi lần sửa giỏ
    @PrePersist
    public void touch() {
        updatedAt = LocalDateTime.now();
    }
}
