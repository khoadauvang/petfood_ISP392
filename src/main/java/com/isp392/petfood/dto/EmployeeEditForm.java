package com.isp392.petfood.dto;

import com.isp392.petfood.enums.Role;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Admin sửa thông tin nhân viên. Email không sửa (định danh tài khoản, BR-01).
@Getter
@Setter
public class EmployeeEditForm {

    @NotBlank(message = "Vui lòng nhập họ tên")
    @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
    private String fullName;

    @Pattern(regexp = "^(0|\\+84)\\d{9}$", message = "Số điện thoại không hợp lệ")
    private String phone;

    @NotNull(message = "Vui lòng chọn vai trò")
    private Role role;
}
