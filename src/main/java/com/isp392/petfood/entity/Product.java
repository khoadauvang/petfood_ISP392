package com.isp392.petfood.entity;

import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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

    // Mã dòng sản phẩm, chung cho mọi quy cách: RC-BRITISHSHORTHAIR (FoodPetShop_FullSetup3_ProductVariant.sql)
    @Column(name = "sku", nullable = false, length = 50)
    private String sku;

    // Biến thể / quy cách: 2000G. UNIQUE (sku, variant); không chứa '-', sku + '-' + variant <= 50 ký tự (CK_Product_variant)
    @Column(name = "variant", nullable = false, length = 20)
    private String variant;

    @Column(name = "barcode", length = 50)
    private String barcode;            // được NULL; UNIQUE có lọc (UX_Product_barcode) nên ô trống phải lưu NULL, không lưu ""

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "brand", length = 100)
    private String brand;

    // NVARCHAR(MAX): dùng columnDefinition, không dùng @Lob (ddl-auto=validate sẽ báo lệch kiểu)
    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    // LAZY: chỉ đụng tới Category khi thật sự gọi getCategory()
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Enumerated(EnumType.STRING)
    @Column(name = "species", nullable = false, length = 10)
    private Species species;

    @Enumerated(EnumType.STRING)
    @Column(name = "age_group", nullable = false, length = 20)
    private AgeGroup ageGroup;

    @Column(name = "selling_price", nullable = false, precision = 12, scale = 0)
    private BigDecimal sellingPrice;   // DECIMAL(12,0) -> BigDecimal, không dùng double cho tiền

    // Tồn bán thường <= ngưỡng này thì hiện cảnh báo tồn thấp (BR-62)
    @Column(name = "low_stock_threshold", nullable = false)
    private Integer lowStockThreshold = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ProductStatus status;

    // Ảnh đại diện = bản sao image_url của ProductImage sort_order = 1 (giống script seed).
    // ProductAdminService luôn cập nhật hai chỗ cùng lúc, trang chủ chỉ cần đọc cột này.
    @Column(name = "image_url", length = 255)
    private String imageUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // Mã đầy đủ để hiển thị / tìm kiếm / đặt tên thư mục ảnh: RC-BRITISHSHORTHAIR-2000G
    public String getFullSku() {
        return sku + "-" + variant;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
