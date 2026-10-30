package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Thông tin hiển thị ở trang hồ sơ khách (phần không sửa được + ảnh hiện tại + chi tiêu tích lũy hạng)
@Getter
@AllArgsConstructor
public class CustomerProfileDto {
    private final String email;
    private final String fullName;
    private final String phone;
    private final String avatarUrl;        // null nếu chưa có ảnh
    private final String tierLabel;        // Đồng / Bạc / Vàng / Kim cương
    private final BigDecimal tierDiscountRate; // % giảm giá theo hạng thành viên
    private final boolean googleLinked;    // tài khoản đã liên kết Google
    private final boolean hasPassword;     // false: tài khoản chỉ đăng nhập bằng Google

    // Chi tiêu tích luỹ & mục tiêu lên hạng kế tiếp
    private final BigDecimal spentAmount;
    private final BigDecimal nextTierSpend;
    private final String nextTierLabel;
    private final int spendProgressPct;

    public CustomerProfileDto(String email, String fullName, String phone, String avatarUrl,
                              String tierLabel, BigDecimal tierDiscountRate, boolean googleLinked, boolean hasPassword) {
        this(email, fullName, phone, avatarUrl, tierLabel, tierDiscountRate, googleLinked, hasPassword,
             BigDecimal.ZERO, BigDecimal.valueOf(1200000), "Bạc", 0);
    }
}
