package com.isp392.petfood.enums;

// Kết quả thẩm định từng dòng trả: khớp CK_ReturnItem_inspection_result (BR-38)
public enum InspectionResult {
    RESTOCKED("Tái nhập về lô gốc"),
    DISPOSED("Tiêu huỷ");

    private final String label;

    InspectionResult(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
