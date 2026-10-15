package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Trang chi tiết sản phẩm phía khách (/products/{id}). Khác ProductDetailDto của Staff: không có tồn thực tế,
// ngưỡng tồn thấp, mã vạch... chỉ những gì khách cần xem.
@Getter
@AllArgsConstructor
public class ShopProductDto {
    private final Long id;
    private final String sku;
    private final String name;
    private final String brand;
    private final String description;
    private final Long categoryId;
    private final String categoryName;
    private final String speciesLabel;
    private final String ageGroupLabel;
    private final BigDecimal price;
    private final List<String> imageUrls;      // ảnh 1..5 theo sort_order, bỏ vị trí trống

    // Tồn bán thường = tổng on_hand các lô còn >= 90 ngày (BR-54); 0 -> "Hết hàng" (BR-09)
    private final long sellableQty;

    // Lô bán thường có HSD gần nhất, tức lô sẽ xuất cho khách trước theo FEFO (BR-53).
    // null khi hết hàng bán thường.
    private final String nearestExpiryText;
    private final Long nearestExpiryDaysLeft;

    public boolean isInStock() {
        return sellableQty > 0;
    }
}
