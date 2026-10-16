package com.isp392.petfood.enums;

// Lý do trả hàng: khớp CK_ReturnRequest_reason_type (BR-33). REFUSED_DELIVERY chỉ hệ thống tạo khi khách không nhận hàng
public enum ReturnReason {
    DAMAGED("Sản phẩm lỗi / hư hỏng"),
    EXPIRY_ISSUE("Hạn dùng thấp hơn cam kết / hết hạn"),
    WRONG_OR_MISSING("Giao sai / thiếu hàng"),
    REFUSED_DELIVERY("Khách không nhận hàng");

    private final String label;

    ReturnReason(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
