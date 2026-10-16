package com.isp392.petfood.dto;

import com.isp392.petfood.enums.SupportStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một dòng trong danh sách yêu cầu hỗ trợ (Staff)
@Getter
@AllArgsConstructor
public class SupportTicketRow {
    private final Long id;
    private final String ticketCode;
    private final String contactName;
    private final String contactEmail;
    private final String contentPreview;
    private final SupportStatus status;
    private final String handledByName;     // null khi còn NEW
    private final String createdAtText;
}
