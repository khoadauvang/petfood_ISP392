package com.isp392.petfood.enums;

// Trạng thái thanh toán của đơn, độc lập với trạng thái đơn (BR-18). Khớp CK_Orders_payment_status.
public enum PaymentStatus {
    UNPAID("Chưa thanh toán"),
    PAID("Đã thanh toán"),
    FAILED("Thanh toán lỗi"),
    REFUNDED("Đã hoàn tiền");

    private final String label;

    PaymentStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
