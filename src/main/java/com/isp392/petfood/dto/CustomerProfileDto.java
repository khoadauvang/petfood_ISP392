package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Thông tin hiển thị ở trang hồ sơ khách (phần không sửa được + ảnh hiện tại)
@Getter
@AllArgsConstructor
public class CustomerProfileDto {
    private final String email;
    private final String fullName;
    private final String phone;
    private final String avatarUrl;        // null nếu chưa có ảnh
    private final String tierLabel;        // Đồng / Bạc / Vàng / Kim cương
    private final boolean googleLinked;    // tài khoản đã liên kết Google
    private final boolean hasPassword;     // false: tài khoản chỉ đăng nhập bằng Google
}
