package com.isp392.petfood.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Khách đánh giá một dòng hàng: 1-5 sao, tiêu đề và nội dung tuỳ chọn (requirements 7.9)
@Getter
@Setter
public class ReviewForm {

    @NotNull(message = "Vui lòng chọn số sao")
    @Min(value = 1, message = "Từ 1 đến 5 sao")
    @Max(value = 5, message = "Từ 1 đến 5 sao")
    private Integer rating;

    @Size(max = 150, message = "Tiêu đề tối đa 150 ký tự")
    private String title;

    @Size(max = 2000, message = "Nội dung tối đa 2000 ký tự")
    private String content;
}
