package com.isp392.petfood.enums;

// Trạng thái một lần thanh toán (bảng Payment): khớp CK_Payment_status.
// Khác PaymentStatus của đơn (UNPAID/PAID/FAILED/REFUNDED).
public enum PaymentRecordStatus {
    PENDING("Đang chờ"),
    SUCCESS("Thành công"),
    FAILED("Thất bại");

    private final String label;

    PaymentRecordStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
