package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một dòng sản phẩm đang Flash Sale trong BẢNG 1
@Getter
@AllArgsConstructor
public class ActiveFlashSaleProductRow {
    private final Long itemId;
    private final Long saleId;
    private final String saleName;
    private final String saleCode;
    private final Long productId;
    private final String productName;
    private final String sku;
    private final String imageUrl;
    private final Long lotId;
    private final String lotCode;
    private final String expiryDate;
    private final long daysLeft;
    private final BigDecimal originalPrice;
    private final BigDecimal salePrice;
    private final int discountPercent;
    private final int allocatedQty;
    private final int remainingQty;
    private final String timeRangeText;
    private final String statusDisplay;
    private final boolean active;
}
