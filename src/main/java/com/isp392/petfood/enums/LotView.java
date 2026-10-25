package com.isp392.petfood.enums;

// Bộ lọc nhanh của trang "Tồn theo lô"
public enum LotView {
    ALL("Hạn sử dụng (Tất cả)"),
    NEAR_EXPIRY("Lô cận hạn (< 90 ngày)"),
    CRITICAL("Cấp bách (< 21 ngày / Quá hạn)"),
    SAFE("HSD an toàn (≥ 90 ngày)"),
    IN_STOCK("Còn hàng"),
    DEPLETED("Đã hết hàng"),
    LOW_STOCK("Sản phẩm tồn thấp");

    private final String label;

    LotView(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
