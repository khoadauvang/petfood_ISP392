package com.isp392.petfood.enums;

// Hạng thành viên: khớp CK_Customer_membership_tier (mục 7.6 requirements)
public enum MembershipTier {
    BRONZE("Đồng"),
    SILVER("Bạc"),
    GOLD("Vàng"),
    DIAMOND("Kim cương");

    private final String label;

    MembershipTier(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
