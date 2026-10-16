package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ExpiryLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một suất trong chi tiết chiến dịch (phía Staff)
@Getter
@AllArgsConstructor
public class FlashSaleItemRow {
    private final Long id;
    private final Long lotId;
    private final Long productId;
    private final String sku;
    private final String productName;
    private final String expiryText;
    private final long daysLeft;
    private final ExpiryLevel level;
    private final BigDecimal sellingPrice;
    private final BigDecimal salePrice;
    private final int allocatedQty;
    private final int soldQty;

    public int getRemainingQty() {
        return allocatedQty - soldQty;
    }
}
