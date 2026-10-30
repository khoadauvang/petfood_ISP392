package com.isp392.petfood.dto;

import com.isp392.petfood.enums.FlashSaleStatus;
import com.isp392.petfood.enums.SaleType;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một chiến dịch trong Bảng 2 danh sách chương trình giảm giá
@Getter
@AllArgsConstructor
public class FlashSaleRow {
    private final Long id;
    private final String name;
    private final SaleType saleType;
    private final String code;
    private final String description;
    private final String scopeText;
    private final String discountText;
    private final String startText;
    private final String endText;
    private final String timeRangeText;
    private final FlashSaleStatus status;
    private final String statusDisplay;
    private final String createdByName;
    private final long itemCount;
    private final long remainingQty;
}
