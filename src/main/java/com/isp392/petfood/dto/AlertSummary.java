package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Số cảnh báo hiện trên trang tổng quan /staff, /admin (FR-38, FR-45)
@Getter
@AllArgsConstructor
public class AlertSummary {

    private final int lowStockCount;      // sản phẩm dưới ngưỡng tồn thấp
    private final int redLotCount;        // lô còn hàng, còn 21 đến dưới 90 ngày (Cận hạn Flash Sale)
    private final int blockedLotCount;    // lô còn hàng, còn dưới 21 ngày (Cấp bách)
    private final int expiredLotCount;    // lô còn hàng nhưng đã quá hạn
    private final int totalInStockLots;   // tổng số lô còn hàng trong kho
    private final int safeLotCount;       // lô còn hạn an toàn (>= 90 ngày)

    public AlertSummary(int lowStockCount, int redLotCount, int blockedLotCount, int expiredLotCount) {
        this(lowStockCount, redLotCount, blockedLotCount, expiredLotCount,
                redLotCount + blockedLotCount + expiredLotCount, 0);
    }

    public int getNearExpiryLotCount() {
        return redLotCount + blockedLotCount + expiredLotCount;
    }

    // Tỉ lệ % trên tổng lô còn hàng, làm tròn 1 chữ số thập phân (biểu đồ sức khoẻ kho)
    public double getUrgentPercent() {
        if (totalInStockLots <= 0) return 0.0;
        int urgentCount = blockedLotCount + expiredLotCount;
        return Math.round(1000.0 * urgentCount / totalInStockLots) / 10.0;
    }

    public double getRedPercent() {
        if (totalInStockLots <= 0) return 0.0;
        return Math.round(1000.0 * redLotCount / totalInStockLots) / 10.0;
    }

    public double getSafePercent() {
        if (totalInStockLots <= 0) return 0.0;
        double nonSafe = getUrgentPercent() + getRedPercent();
        double safe = Math.round(10.0 * (100.0 - nonSafe)) / 10.0;
        return Math.max(0.0, safe);
    }
}
