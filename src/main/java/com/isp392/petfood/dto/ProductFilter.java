package com.isp392.petfood.dto;

import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.Species;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

// Bộ lọc trang sản phẩm của khách, Spring gắn từ query string: /products?keyword=..&categoryId=..&species=CAT...
// Ô nào để trống (hoặc gõ sai kiểu, ví dụ giá "abc") thì là null = không lọc theo ô đó.
@Getter
@Setter
public class ProductFilter {

    private String keyword;
    private Long categoryId;
    private Species species;
    private AgeGroup ageGroup;
    private String brand;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;

    // Giá âm coi như bỏ trống; nhập ngược (từ > đến) thì đổi chỗ cho nhau
    public void normalize() {
        if (minPrice != null && minPrice.signum() < 0) {
            minPrice = null;
        }
        if (maxPrice != null && maxPrice.signum() < 0) {
            maxPrice = null;
        }
        if (minPrice != null && maxPrice != null && minPrice.compareTo(maxPrice) > 0) {
            BigDecimal tmp = minPrice;
            minPrice = maxPrice;
            maxPrice = tmp;
        }
    }
}
