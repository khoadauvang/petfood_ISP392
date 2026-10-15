package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Bảng tạo bằng claude/FoodPetShop_ProductImage.sql. Mỗi sản phẩm đúng 5 ảnh, sort_order 1..5, ảnh 1 là ảnh đại diện.
// DB chặn tối đa 5 (UQ_ProductImage_product_sort + CK_ProductImage_sort_order), BE kiểm tra đủ 5.
@Entity
@Table(name = "ProductImage")
@Getter
@Setter
@NoArgsConstructor
public class ProductImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "image_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "image_url", nullable = false, length = 255)
    private String imageUrl;          // ví dụ /images/products/RC-KITTEN36-400G/1-3f9a2c1b.jpg

    // Không đổi sort_order của dòng đã có (vướng UNIQUE): thay ảnh thì sửa image_url của đúng vị trí đó
    @Column(name = "sort_order", nullable = false, updatable = false)
    private Integer sortOrder;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public ProductImage(Product product, int sortOrder, String imageUrl) {
        this.product = product;
        this.sortOrder = sortOrder;
        this.imageUrl = imageUrl;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
