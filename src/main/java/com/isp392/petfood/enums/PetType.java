package com.isp392.petfood.enums;

// Loại thú cưng của danh mục: khớp CK_Category_pet_type (DOG, CAT, ALL)
public enum PetType {
    DOG("Chó"),
    CAT("Mèo"),
    ALL("Chó và mèo");    // danh mục dùng chung, ví dụ "Sữa cho chó mèo"

    private final String label;

    PetType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    // Danh mục loại này có chứa được sản phẩm của loài species không.
    // DOG chỉ nhận DOG, CAT chỉ nhận CAT, ALL nhận cả hai.
    public boolean accepts(Species species) {
        return this == ALL || name().equals(species.name());
    }
}
