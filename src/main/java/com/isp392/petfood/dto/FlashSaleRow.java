package com.isp392.petfood.dto;

import com.isp392.petfood.enums.FlashSaleStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một chiến dịch trong danh sách quản lý
@Getter
@AllArgsConstructor
public class FlashSaleRow {
    private final Long id;
    private final String name;
    private final String startText;
    private final String endText;
    private final FlashSaleStatus status;
    private final String createdByName;
    private final long itemCount;
    private final long remainingQty;
}
