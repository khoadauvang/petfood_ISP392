package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Dòng đơn còn trả được (hiện trong form yêu cầu trả hàng)
@Getter
@AllArgsConstructor
public class ReturnableLine {
    private final Long orderItemId;
    private final String productName;
    private final boolean flashSale;
    private final int quantity;
    private final BigDecimal lineTotal;
}
