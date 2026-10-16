package com.isp392.petfood.entity;

import com.isp392.petfood.enums.SupportStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Yêu cầu hỗ trợ (bảng SupportForm): tạo khi khách bấm "Khác" trong chatbox và gửi form, không cần đăng nhập.
// Đặt tên class SupportTicket để không lẫn với các form-backing bean *Form trong dto/.
@Entity
@Table(name = "SupportForm")
@Getter
@Setter
@NoArgsConstructor
public class SupportTicket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ticket_id")
    private Long id;

    // Dạng HT-000123, hiện trong tiêu đề email (UQ_SupportForm_ticket_code)
    @Column(name = "ticket_code", nullable = false, length = 20, unique = true)
    private String ticketCode;

    // Trống nếu khách bấm "Khác" ngay ở danh sách chủ đề
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_node_id")
    private ChatNode fromNode;

    // Trống với guest
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @Column(name = "contact_email", nullable = false, length = 255)
    private String contactEmail;

    @Column(name = "contact_name", length = 100)
    private String contactName;

    @Column(name = "content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private SupportStatus status = SupportStatus.NEW;

    // Trống khi còn NEW
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "handled_by")
    private Employee handledBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "closed_at")
    private LocalDateTime closedAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
