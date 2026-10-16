package com.isp392.petfood.enums;

// Kết quả gửi email trả lời: khớp CK_SupportReply_send_status. FAILED (lỗi SMTP) thì nhân viên bấm gửi lại
public enum SendStatus {
    SENT("Đã gửi"),
    FAILED("Gửi lỗi");

    private final String label;

    SendStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
