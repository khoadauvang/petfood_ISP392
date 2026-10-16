package com.isp392.petfood.enums;

// Trạng thái yêu cầu trả hàng: khớp CK_ReturnRequest_status. REQUESTED -> APPROVED | REJECTED; APPROVED -> RECEIVED -> INSPECTED -> REFUNDED | CLOSED (BR-36)
public enum ReturnStatus {
    REQUESTED("Chờ duyệt"),
    APPROVED("Đã duyệt, chờ nhận hàng"),
    REJECTED("Từ chối"),
    RECEIVED("Đã nhận hàng trả"),
    INSPECTED("Đã thẩm định"),
    REFUNDED("Đã hoàn tiền"),
    CLOSED("Đã đóng");

    private final String label;

    ReturnStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
