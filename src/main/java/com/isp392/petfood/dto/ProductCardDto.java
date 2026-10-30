package com.isp392.petfood.dto;

import lombok.Getter;

import java.math.BigDecimal;

// Dữ liệu một thẻ sản phẩm trên trang chủ và danh sách sản phẩm. JSP chỉ biết class này, không đụng tới entity.
@Getter
public class ProductCardDto {
    private final Long id;
    private final String sku;
    private final String name;
    private final String brand;
    private final BigDecimal price;
    private final String imageUrl;   // có thể null nếu sản phẩm chưa có ảnh
    private final boolean inStock;   // false -> JSP hiện "Hết hàng" (BR-09)
    private final String nearestExpiryText;   // HSD lô bán thường gần nhất (dd/MM/yyyy); null khi hết hàng
    private final long soldCount;    // Số lượng sản phẩm đã bán

    public ProductCardDto(Long id, String sku, String name, String brand, BigDecimal price, String imageUrl, boolean inStock, String nearestExpiryText) {
        this(id, sku, name, brand, price, imageUrl, inStock, nearestExpiryText, 0L);
    }

    public ProductCardDto(Long id, String sku, String name, String brand, BigDecimal price, String imageUrl, boolean inStock, String nearestExpiryText, long soldCount) {
        this.id = id;
        this.sku = sku;
        this.name = name;
        this.brand = brand;
        this.price = price;
        this.imageUrl = imageUrl;
        this.inStock = inStock;
        this.nearestExpiryText = nearestExpiryText;
        this.soldCount = soldCount;
    }
}
