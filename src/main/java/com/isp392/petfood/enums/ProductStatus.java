package com.isp392.petfood.enums;

public enum ProductStatus {
    ACTIVE("Đang bán"),
    DISCONTINUED("Ngừng kinh doanh");   // "ẩn" sản phẩm, thay cho xoá (BR-11)

    private final String label;

    ProductStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
