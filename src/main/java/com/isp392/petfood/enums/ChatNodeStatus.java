package com.isp392.petfood.enums;

// Trạng thái nút kịch bản chatbox: khớp CK_ChatNode_status. Nút đã có yêu cầu hỗ trợ tham chiếu thì chỉ ẩn, không xoá
public enum ChatNodeStatus {
    ACTIVE("Đang hiện"),
    HIDDEN("Đã ẩn");

    private final String label;

    ChatNodeStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
