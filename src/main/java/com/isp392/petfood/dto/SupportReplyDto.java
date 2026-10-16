package com.isp392.petfood.dto;

import com.isp392.petfood.enums.SendStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một email nhân viên đã gửi (hoặc gửi lỗi) cho khách
@Getter
@AllArgsConstructor
public class SupportReplyDto {
    private final Long id;
    private final String content;
    private final SendStatus sendStatus;
    private final String repliedByName;
    private final String createdAtText;
    private final String sentAtText;        // null khi FAILED
}
