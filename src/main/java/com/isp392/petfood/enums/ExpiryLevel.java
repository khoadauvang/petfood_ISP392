package com.isp392.petfood.enums;

// Mức hạn dùng của một lô, tính từ số ngày còn lại so với hôm nay.
// Không lưu trong DB (ERD đã bỏ cột is_red_warning): mỗi lần xem là tính lại, nên luôn đúng theo ngày hiện tại.
public enum ExpiryLevel {
    OK("Bán thường"),                              // còn >= 90 ngày (BR-54)
    RED("Cảnh báo đỏ: chỉ bán qua Flash Sale"),    // còn 21 đến dưới 90 ngày (BR-59, BR-63)
    BLOCKED("Dưới 21 ngày: không được bán"),       // còn 0 đến dưới 21 ngày (BR-51, BR-54)
    EXPIRED("Đã hết hạn");                         // HSD trước hôm nay

    private final String label;

    ExpiryLevel(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
