package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

// Đánh giá đang hiện của một sản phẩm + điểm trung bình
@Getter
@AllArgsConstructor
public class ReviewSummary {
    private final List<ReviewDto> reviews;
    private final String averageText;       // ví dụ "4,5"; null khi chưa có đánh giá

    public int getCount() {
        return reviews.size();
    }
}
