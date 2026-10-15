package com.isp392.petfood.enums;

// Trạng thái chiến dịch Flash Sale: khớp CK_FlashSale_status. Luồng DRAFT -> ACTIVE <-> PAUSED -> ENDED (BR-64)
public enum FlashSaleStatus {
    DRAFT("Nháp"),
    ACTIVE("Đang chạy"),
    PAUSED("Tạm dừng"),
    ENDED("Đã kết thúc");

    private final String label;

    FlashSaleStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
