package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

// Màn hình chatbox: các bước khách đã chọn từ chủ đề gốc tới nút hiện tại, và các lựa chọn tiếp theo
@Getter
@AllArgsConstructor
public class ChatConversation {
    private final List<ChatStep> path;       // trống ở màn hình đầu
    private final List<ChatStep> options;    // trống khi nút hiện tại là giải pháp (lá)

    public Long getCurrentNodeId() {
        return path.isEmpty() ? null : path.get(path.size() - 1).getId();
    }
}
