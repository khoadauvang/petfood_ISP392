package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Một lựa chọn trong ô lọc danh mục ở trang sản phẩm của khách
@Getter
@AllArgsConstructor
public class CategoryOption {
    private final Long id;
    private final String name;
}
