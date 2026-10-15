package com.isp392.petfood.enums;

// Loài của sản phẩm: khớp CK_Product_species (DOG, CAT) trong script tạo bảng
public enum Species {
    DOG("Chó"),
    CAT("Mèo");

    private final String label;

    Species(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
