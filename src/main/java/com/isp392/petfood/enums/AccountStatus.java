package com.isp392.petfood.enums;

// Trạng thái tài khoản: khớp CK_Account_status (script FoodPetShop_AccountStatus.sql, mục 9.5).
// LOCKED: Admin khoá tài khoản nhân viên, không đăng nhập được
public enum AccountStatus {
    ACTIVE("Đang hoạt động"),
    LOCKED("Đã khoá");

    private final String label;

    AccountStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
