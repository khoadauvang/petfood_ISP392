package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ProductStatus;
import lombok.Getter;

// Một lựa chọn trong ô chọn sản phẩm (form nhập lô, bộ lọc trang tồn theo lô)
@Getter
public class ProductOption {

    private final Long id;
    private final String sku;
    private final String name;
    private final ProductStatus status;

    public ProductOption(Product product) {
        this.id = product.getId();
        this.sku = product.getSku();
        this.name = product.getName();
        this.status = product.getStatus();
    }
}
