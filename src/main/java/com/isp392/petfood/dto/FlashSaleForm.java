package com.isp392.petfood.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

// Form tạo / sửa chiến dịch Flash Sale (chỉ sửa được khi còn DRAFT). Ô giờ dùng <input type="datetime-local">.
@Getter
@Setter
public class FlashSaleForm {

    @NotBlank(message = "Vui lòng nhập tên chiến dịch")
    @Size(max = 150, message = "Tên tối đa 150 ký tự")
    private String name;

    @NotNull(message = "Vui lòng chọn thời gian bắt đầu")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime startTime;

    @NotNull(message = "Vui lòng chọn thời gian kết thúc")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime endTime;
}
