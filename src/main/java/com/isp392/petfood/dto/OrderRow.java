package com.isp392.petfood.dto;

import com.isp392.petfood.enums.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một dòng trong danh sách đơn (lịch sử đơn của khách, trang quản lý đơn của Staff)
@Getter
@AllArgsConstructor
public class OrderRow {
    private final Long id;
    private final String createdAtText;
    private final OrderStatus status;
    private final String paymentMethodLabel;
    private final String paymentStatusLabel;
    private final BigDecimal totalAmount;
    private final long lineCount;
    private final long totalQuantity;
    private final String customerName;
    private final String customerEmail;
    private final boolean cancelRequested;
}
