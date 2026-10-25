package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Số liệu thống kê tổng hợp kho hàng theo lô cho trang /staff/lots
@Getter
@AllArgsConstructor
public class LotStats {
    private final long totalOnHand;      // Tổng số lượng sản phẩm tồn kho (đơn vị)
    private final long activeLots;       // Tổng số lô đang còn hàng lưu kho (tồn > 0)
    private final long totalLots;        // Tổng số lô từng nhập trong hệ thống
    private final long warningLots;      // Số lô cận hạn (< 90 ngày và >= 21 ngày, ưu tiên Flash Sale)
    private final long criticalLots;     // Số lô nguy cấp (< 21 ngày hoặc quá hạn, cấm xuất bán)
    private final long lowStockCount;    // Số sản phẩm tồn thấp (cần nhập hàng bổ sung)
}
