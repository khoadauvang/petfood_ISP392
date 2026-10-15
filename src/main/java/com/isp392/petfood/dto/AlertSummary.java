package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Số cảnh báo hiện trên trang tổng quan /staff, /admin (FR-38, FR-45)
@Getter
@AllArgsConstructor
public class AlertSummary {

    private final int lowStockCount;      // sản phẩm dưới ngưỡng tồn thấp
    private final int redLotCount;        // lô còn hàng, còn 21 đến dưới 90 ngày
    private final int blockedLotCount;    // lô còn hàng, còn dưới 21 ngày
    private final int expiredLotCount;    // lô còn hàng nhưng đã quá hạn

    public int getNearExpiryLotCount() {
        return redLotCount + blockedLotCount + expiredLotCount;
    }
}
