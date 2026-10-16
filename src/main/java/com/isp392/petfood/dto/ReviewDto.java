package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ReviewStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một đánh giá kèm phản hồi của cửa hàng (nếu có)
@Getter
@AllArgsConstructor
public class ReviewDto {
    private final Long id;
    private final Long productId;
    private final String productName;
    private final String customerName;
    private final int rating;
    private final String title;
    private final String content;
    private final ReviewStatus status;
    private final String createdAtText;
    private final boolean edited;
    private final String replyContent;      // null nếu chưa phản hồi
    private final String replyByName;
    private final String replyAtText;
}
