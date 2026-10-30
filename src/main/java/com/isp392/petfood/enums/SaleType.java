package com.isp392.petfood.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

// Phân loại chiến dịch: Flash Sale xả hàng cận date vs Chương trình khuyến mãi (dịp lễ / giảm giá thường)
@Getter
@RequiredArgsConstructor
public enum SaleType {
    FLASH_SALE("Flash Sale", "⚡ Flash Sale"),
    PROMOTION("Giảm giá thường", "🏷️ Giảm giá thường");

    private final String label;
    private final String badgeText;
}
