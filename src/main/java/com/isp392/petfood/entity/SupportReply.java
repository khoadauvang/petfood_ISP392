package com.isp392.petfood.entity;

import com.isp392.petfood.enums.SendStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Mỗi email nhân viên gửi cho khách là một dòng. SENT phải có sent_at (CK_SupportReply_sent_at)
@Entity
@Table(name = "SupportReply")
@Getter
@Setter
@NoArgsConstructor
public class SupportReply {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reply_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ticket_id", nullable = false)
    private SupportTicket ticket;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "replied_by", nullable = false)
    private Employee repliedBy;

    @Column(name = "content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "send_status", nullable = false, length = 20)
    private SendStatus sendStatus;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    public SupportReply(SupportTicket ticket, Employee repliedBy, String content) {
        this.ticket = ticket;
        this.repliedBy = repliedBy;
        this.content = content;
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
