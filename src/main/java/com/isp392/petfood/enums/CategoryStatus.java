package com.isp392.petfood.enums;

public enum CategoryStatus {
    ACTIVE("Đang hiện"),
    HIDDEN("Đang ẩn");      // ẩn danh mục = ẩn luôn sản phẩm của nó ở trang khách (FR-09)

    private final String label;   // chữ hiển thị trên JSP: ${category.status.label}

    CategoryStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
