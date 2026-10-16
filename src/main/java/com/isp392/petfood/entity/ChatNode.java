package com.isp392.petfood.entity;

import com.isp392.petfood.enums.ChatNodeStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Nút trong cây kịch bản chatbox (module 9): parent trống là chủ đề gốc, nút không có con là giải pháp.
// CK_ChatNode_not_self_parent chỉ chặn nút tự trỏ về chính nó; chặn trỏ về con cháu (vòng lặp) do ChatNodeService kiểm tra.
@Entity
@Table(name = "ChatNode")
@Getter
@Setter
@NoArgsConstructor
public class ChatNode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "node_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private ChatNode parent;

    @Column(name = "label", nullable = false, length = 150)
    private String label;

    @Column(name = "bot_message", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String botMessage;

    // Link gợi ý kèm giải pháp, ví dụ /orders hoặc /products?keyword=...
    @Column(name = "action_url", length = 255)
    private String actionUrl;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private ChatNodeStatus status = ChatNodeStatus.ACTIVE;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "updated_by", nullable = false)
    private Employee updatedBy;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    void touch() {
        updatedAt = LocalDateTime.now();
    }
}
