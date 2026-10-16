package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Một nút chatbox phía khách: label là câu khách chọn, botMessage / actionUrl là câu chatbox đáp lại
@Getter
@AllArgsConstructor
public class ChatStep {
    private final Long id;
    private final String label;
    private final String botMessage;
    private final String actionUrl;
}
