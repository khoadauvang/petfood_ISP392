package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Lô cận hạn (RED) chọn được khi thêm suất Flash Sale
@Getter
@AllArgsConstructor
public class RedLotOption {
    private final Long lotId;
    private final String sku;
    private final String productName;
    private final String expiryText;
    private final long daysLeft;
    private final int onHandQty;
    private final long availableQty;       // on_hand trừ phần đang dành cho chiến dịch khác chưa kết thúc
    private final BigDecimal sellingPrice;
}
