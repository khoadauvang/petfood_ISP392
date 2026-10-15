package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Tồn kho của một sản phẩm, cộng từ các lô
@Getter
@AllArgsConstructor
public class StockSummary {

    public static final StockSummary EMPTY = new StockSummary(0, 0);

    private final long onHandQty;     // tồn thực tế: tổng on_hand_qty của mọi lô (dùng khi kiểm kê)
    private final long sellableQty;   // tồn bán thường: chỉ lô còn hạn >= 90 ngày (BR-54), dùng cho cảnh báo tồn thấp
}
