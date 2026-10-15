package com.isp392.petfood.enums;

// Nhóm tuổi: khớp CK_Product_age_group trong script tạo bảng
public enum AgeGroup {
    YOUNG("Con non"),
    ADULT("Trưởng thành"),
    SENIOR("Lớn tuổi"),
    ALL_AGES("Mọi lứa tuổi");

    private final String label;

    AgeGroup(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
