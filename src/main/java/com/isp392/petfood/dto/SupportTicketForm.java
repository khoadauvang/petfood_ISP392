package com.isp392.petfood.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Form "Khác" trong chatbox: khách nhập vấn đề + email bắt buộc (requirements 7.10), không cần đăng nhập
@Getter
@Setter
public class SupportTicketForm {

    // Nút chatbox khách đang đứng khi bấm "Khác" (trống nếu bấm ngay ở danh sách chủ đề)
    private Long nodeId;

    @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
    private String contactName;

    @NotBlank(message = "Vui lòng nhập email để nhận trả lời")
    @Email(message = "Email không hợp lệ")
    @Size(max = 255, message = "Email tối đa 255 ký tự")
    private String contactEmail;

    @NotBlank(message = "Vui lòng mô tả vấn đề của bạn")
    @Size(max = 2000, message = "Nội dung tối đa 2000 ký tự")
    private String content;
}
