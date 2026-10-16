package com.isp392.petfood.enums;

// Trạng thái yêu cầu hỗ trợ: khớp CK_SupportForm_status. NEW -> IN_PROGRESS -> RESPONDED -> CLOSED; SPAM đóng yêu cầu rác
public enum SupportStatus {
    NEW("Mới"),
    IN_PROGRESS("Đang xử lý"),
    RESPONDED("Đã trả lời"),
    CLOSED("Đã đóng"),
    SPAM("Spam");

    private final String label;

    SupportStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    // Đã đóng hoặc spam: không trả lời thêm
    public boolean isFinished() {
        return this == CLOSED || this == SPAM;
    }
}
