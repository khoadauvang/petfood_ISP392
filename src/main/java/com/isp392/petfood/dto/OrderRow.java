package com.isp392.petfood.dto;

import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.ReturnStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

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

    // Các trường mở rộng hỗ trợ giao diện khách hàng (previews & trạng thái đổi trả)
    private final List<OrderItemPreview> items;
    private final ReturnStatus returnStatus;
    private final Long returnId;

    public OrderRow(Long id, String createdAtText, OrderStatus status, String paymentMethodLabel,
                    String paymentStatusLabel, BigDecimal totalAmount, long lineCount,
                    long totalQuantity, String customerName, String customerEmail,
                    boolean cancelRequested) {
        this(id, createdAtText, status, paymentMethodLabel, paymentStatusLabel, totalAmount,
             lineCount, totalQuantity, customerName, customerEmail, cancelRequested,
             Collections.emptyList(), null, null);
    }

    public List<OrderItemPreview> getItems() {
        return items != null ? items : Collections.emptyList();
    }

    public boolean isReturned() {
        return status == OrderStatus.RETURNED || returnStatus == ReturnStatus.REFUNDED;
    }

    public boolean isReturnPending() {
        return status != OrderStatus.RETURNED && returnStatus != null
                && returnStatus != ReturnStatus.REJECTED && returnStatus != ReturnStatus.REFUNDED;
    }

    public String getEffectiveStatusCode() {
        if (isReturned()) return "RETURNED";
        if (isReturnPending()) return "RETURN_REQUESTED";
        return status != null ? status.name() : "";
    }

    public String getEffectiveStatusLabel() {
        if (isReturned()) return "Đã hoàn trả";
        if (isReturnPending()) return "Đang xử lý hoàn trả";
        return status != null ? status.getLabel() : "";
    }
}
