package com.isp392.petfood.entity;

import com.isp392.petfood.enums.ProductStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "Product")
@Getter
@Setter
@NoArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private Long id;

    @Column(name = "sku", nullable = false, length = 50)
    private String sku;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "brand", length = 100)
    private String brand;

    // LAZY: chỉ đụng tới Category khi thật sự gọi getCategory()
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "selling_price", nullable = false, precision = 12, scale = 0)
    private BigDecimal sellingPrice;   // DECIMAL(12,0) -> BigDecimal, không dùng double cho tiền

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ProductStatus status;

    @Column(name = "image_url", length = 255)
    private String imageUrl;           // ảnh đại diện, dạng /images/products/<SKU>/1.jpg

    // Chưa map: barcode, description, species, age_group, low_stock_threshold, created_at.
    // Thêm dần khi làm trang chi tiết / bộ lọc / quản lý sản phẩm.
    // Lưu ý khi map description (NVARCHAR(MAX)): dùng @Column(columnDefinition = "NVARCHAR(MAX)"), đừng dùng @Lob
    // vì ddl-auto=validate sẽ báo lệch kiểu.
}