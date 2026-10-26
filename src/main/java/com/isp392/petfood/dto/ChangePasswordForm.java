package com.isp392.petfood.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

// Khách tự đổi mật khẩu trong trang hồ sơ: nhập mật khẩu hiện tại + mật khẩu mới 2 lần (BR-02)
@Getter
@Setter
public class ChangePasswordForm {

    @NotBlank(message = "Vui lòng nhập mật khẩu hiện tại")
    private String currentPassword;

    @NotBlank(message = "Vui lòng nhập mật khẩu mới")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[\\x20-\\x7E]{8,64}$",
            message = "Mật khẩu 8–64 ký tự, gồm cả chữ và số (không dùng ký tự có dấu)")
    private String newPassword;

    @NotBlank(message = "Vui lòng nhập lại mật khẩu mới")
    private String confirmPassword;
}
