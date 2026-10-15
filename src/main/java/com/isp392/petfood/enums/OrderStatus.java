package com.isp392.petfood.enums;

// Trạng thái đơn: khớp CK_Orders_order_status. Chỉ đi tiến, không bỏ bước, không lùi (BR-17):
//   PENDING -> CONFIRMED -> PROCESSING -> SHIPPED -> COMPLETED
//   CANCELLED: huỷ trước khi giao (BR-19); RETURNED: khách không nhận hàng
public enum OrderStatus {
    PENDING("Chờ xác nhận"),
    CONFIRMED("Đã xác nhận"),
    PROCESSING("Đang đóng gói"),
    SHIPPED("Đang giao"),
    COMPLETED("Hoàn thành"),
    CANCELLED("Đã huỷ"),
    RETURNED("Khách không nhận hàng");

    private final String label;

    OrderStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
