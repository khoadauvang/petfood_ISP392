package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ChatNodeStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một dòng trong cây kịch bản ở trang quản lý; depth dùng để thụt lề (0 = chủ đề gốc)
@Getter
@AllArgsConstructor
public class ChatNodeRow {
    private final Long id;
    private final int depth;
    private final String label;
    private final String botMessage;
    private final String actionUrl;
    private final int sortOrder;
    private final ChatNodeStatus status;
    private final int childCount;
    private final boolean hiddenByAncestor;   // nút cha/ông đã ẩn nên khách không tới được
    private final String updatedByName;
    private final String updatedAtText;
}
