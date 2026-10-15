package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Dữ liệu một thẻ sản phẩm trên trang chủ. JSP chỉ biết class này, không đụng tới entity.
@Getter
@AllArgsConstructor
public class ProductCardDto {
    private final Long id;
    private final String sku;
    private final String name;
    private final String brand;
    private final BigDecimal price;
    private final String imageUrl;   // có thể null nếu sản phẩm chưa có ảnh
    private final boolean inStock;   // false -> JSP hiện "Hết hàng" (BR-09)
    private final String nearestExpiryText;   // HSD lô bán thường gần nhất (dd/MM/yyyy); null khi hết hàng
}
