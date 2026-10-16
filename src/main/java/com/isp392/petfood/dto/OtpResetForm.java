package com.isp392.petfood.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

// Bước 2 quên mật khẩu: nhập mã OTP và mật khẩu mới (BR-02)
@Getter
@Setter
public class OtpResetForm {

    @NotBlank(message = "Vui lòng nhập mã OTP")
    @Pattern(regexp = "^\\d{6}$", message = "Mã OTP gồm 6 chữ số")
    private String otp;

    @NotBlank(message = "Vui lòng nhập mật khẩu mới")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[\\x20-\\x7E]{8,64}$",
            message = "Mật khẩu 8–64 ký tự, gồm cả chữ và số (không dùng ký tự có dấu)")
    private String newPassword;

    @NotBlank(message = "Vui lòng nhập lại mật khẩu")
    private String confirmPassword;
}
