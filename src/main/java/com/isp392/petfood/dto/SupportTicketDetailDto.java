package com.isp392.petfood.dto;

import com.isp392.petfood.enums.SupportStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

// Chi tiết yêu cầu hỗ trợ cho Staff, kèm lịch sử email và các nút được phép bấm
@Getter
@AllArgsConstructor
public class SupportTicketDetailDto {
    private final Long id;
    private final String ticketCode;
    private final String fromNodeLabel;     // null nếu khách bấm "Khác" ngay ở danh sách chủ đề
    private final boolean customerAccount;  // người gửi đang đăng nhập tài khoản khách
    private final String contactName;
    private final String contactEmail;
    private final String content;
    private final SupportStatus status;
    private final String handledByName;
    private final String createdAtText;
    private final String closedAtText;
    private final List<SupportReplyDto> replies;

    public boolean isCanClaim() {
        return status == SupportStatus.NEW;
    }

    public boolean isCanReply() {
        return !status.isFinished();
    }

    public boolean isCanClose() {
        return status == SupportStatus.RESPONDED;
    }

    public boolean isCanMarkSpam() {
        return status == SupportStatus.NEW || status == SupportStatus.IN_PROGRESS;
    }
}
