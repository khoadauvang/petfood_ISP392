package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Một dòng trong chi tiết đơn. lots: lô đã xuất cho dòng này kèm HSD (BR-12, BR-56), từ bảng OrderItemLot.
@Getter
@AllArgsConstructor
public class OrderLineDto {
    private final Long productId;
    private final String sku;
    private final String name;
    private final String imageUrl;
    private final boolean flashSale;
    private final String flashSaleName;
    private final int quantity;
    private final BigDecimal unitPrice;
    private final BigDecimal discountAmount;
    private final BigDecimal lineTotal;
    private final List<String> lots;          // ví dụ "Lô #12 · HSD 15/10/2027 · 2 sp"
}
