package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Sản phẩm rút gọn của một đơn, hiện ngay trên card đơn ở trang lịch sử đơn của khách
@Getter
@AllArgsConstructor
public class OrderItemPreview {
    private final String productName;
    private final String imageUrl;
    private final int quantity;
    private final BigDecimal subtotal;
}
