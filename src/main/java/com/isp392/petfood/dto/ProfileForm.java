package com.isp392.petfood.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

// Form sửa hồ sơ khách (/profile). Email không sửa được (định danh tài khoản, BR-01).
@Getter
@Setter
public class ProfileForm {

    @NotBlank(message = "Vui lòng nhập họ tên")
    @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
    private String fullName;

    // Được để trống (khách đăng nhập Google chưa có số điện thoại); có nhập thì phải đúng dạng như lúc đăng ký
    @Pattern(regexp = "^(0|\\+84)\\d{9}$", message = "Số điện thoại không hợp lệ")
    private String phone;

    // Ảnh đại diện mới (JPG/PNG/WEBP); không chọn file thì giữ ảnh cũ
    private MultipartFile avatar;

    // Tick "Xoá ảnh đại diện"
    private boolean removeAvatar;
}
