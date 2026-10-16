package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một yêu cầu trả hàng trong danh sách
@Getter
@AllArgsConstructor
public class ReturnRow {
    private final Long id;
    private final Long orderId;
    private final String createdAtText;
    private final ReturnReason reason;
    private final ReturnStatus status;
    private final String customerName;
    private final String customerEmail;
}
