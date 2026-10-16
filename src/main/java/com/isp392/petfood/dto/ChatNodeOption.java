package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Lựa chọn "nút cha" trên form (nhãn đã thụt lề theo độ sâu)
@Getter
@AllArgsConstructor
public class ChatNodeOption {
    private final Long id;
    private final String label;
}
