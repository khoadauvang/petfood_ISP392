package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Lô hàng bình thường (hạn > 90 ngày) để đưa vào chương trình khuyến mãi dịp lễ / mong muốn
@Getter
@AllArgsConstructor
public class NormalLotOption {
    private final Long lotId;
    private final Long productId;
    private final String sku;
    private final String productName;
    private final String expiryDate;
    private final long daysLeft;
    private final int onHandQty;
    private final BigDecimal sellingPrice;
    private final String imageUrl;
}
