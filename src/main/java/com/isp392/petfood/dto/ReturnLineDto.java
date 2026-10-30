package com.isp392.petfood.dto;

import com.isp392.petfood.enums.InspectionResult;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một dòng hàng trong yêu cầu trả hàng
@Getter
@AllArgsConstructor
public class ReturnLineDto {
    private final Long returnItemId;
    private final Long productId;
    private final String sku;
    private final String productName;
    private final boolean flashSale;
    private final boolean promotion;
    private final int orderedQty;
    private final int quantity;
    private final boolean opened;
    private final BigDecimal maxRefund;          // số tiền khách thực trả cho phần trả (trần hoàn tiền, BR-37)
    private final InspectionResult inspectionResult;
    private final String inspectionNote;
    private final BigDecimal refundAmount;

    public ReturnLineDto(Long returnItemId, Long productId, String sku, String productName, boolean flashSale,
                         int orderedQty, int quantity, boolean opened, BigDecimal maxRefund,
                         InspectionResult inspectionResult, String inspectionNote, BigDecimal refundAmount) {
        this(returnItemId, productId, sku, productName, flashSale, false, orderedQty, quantity, opened, maxRefund,
                inspectionResult, inspectionNote, refundAmount);
    }
}
