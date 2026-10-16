package com.isp392.petfood.enums;

// Loại file đính kèm yêu cầu trả hàng: khớp CK_ReturnMedia_media_type
public enum MediaType {
    IMAGE("Ảnh"),
    VIDEO("Video");

    private final String label;

    MediaType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
