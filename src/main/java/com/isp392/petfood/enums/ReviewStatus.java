package com.isp392.petfood.enums;

// Trạng thái đánh giá: khớp CK_ProductReview_status. HIDDEN: staff ẩn đánh giá vi phạm, không xoá
public enum ReviewStatus {
    VISIBLE("Đang hiện"),
    HIDDEN("Đã ẩn");

    private final String label;

    ReviewStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
