package com.isp392.petfood.enums;

// Khớp CK_Orders_payment_method (BR-22)
public enum PaymentMethod {
    COD("COD"),
    VNPAY("VNPay");

    private final String label;

    PaymentMethod(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
