package com.isp392.petfood.enums;

// Bộ lọc nhanh của trang "Tồn theo lô"
public enum LotView {
    ALL("Tất cả lô"),
    IN_STOCK("Còn hàng"),
    NEAR_EXPIRY("Còn hàng, dưới 90 ngày"),
    DEPLETED("Đã hết hàng");

    private final String label;

    LotView(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
