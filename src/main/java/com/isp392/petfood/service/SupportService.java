package com.isp392.petfood.service;

import com.isp392.petfood.dto.SupportReplyDto;
import com.isp392.petfood.dto.SupportTicketDetailDto;
import com.isp392.petfood.dto.SupportTicketForm;
import com.isp392.petfood.dto.SupportTicketRow;
import com.isp392.petfood.entity.ChatNode;
import com.isp392.petfood.entity.Employee;
import com.isp392.petfood.entity.SupportReply;
import com.isp392.petfood.entity.SupportTicket;
import com.isp392.petfood.enums.ChatNodeStatus;
import com.isp392.petfood.enums.SendStatus;
import com.isp392.petfood.enums.SupportStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.ChatNodeRepository;
import com.isp392.petfood.repository.CustomerRepository;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.SupportReplyRepository;
import com.isp392.petfood.repository.SupportTicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.UUID;

// Yêu cầu hỗ trợ từ nút "Khác" của chatbox (module 9, requirements 7.10):
//   - khách (kể cả guest) nhập vấn đề + email bắt buộc; hệ thống cấp mã HT-000123
//   - trạng thái chỉ đi tiến: NEW -> IN_PROGRESS -> RESPONDED -> CLOSED; NEW / IN_PROGRESS có thể đánh dấu SPAM
//   - staff trả lời qua email; mỗi email là một SupportReply SENT / FAILED, lỗi SMTP thì gửi lại
@Slf4j
@Service
@RequiredArgsConstructor
public class SupportService {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final int PAGE_SIZE = 20;
    private static final int PREVIEW_LENGTH = 80;

    private final SupportTicketRepository ticketRepository;
    private final SupportReplyRepository replyRepository;
    private final ChatNodeRepository nodeRepository;
    private final CustomerRepository customerRepository;
    private final EmployeeRepository employeeRepository;
    private final SupportMailer mailer;

    // Kết quả gửi một email: error là lý do lỗi SMTP (null khi gửi được)
    public record SendResult(boolean sent, String error) {
    }

    // ===== Phía khách =====

    // customerId: khách đang đăng nhập (null với guest). Trả về mã yêu cầu để báo cho khách.
    @Transactional
    public String createTicket(SupportTicketForm form, Long customerId) {
        SupportTicket ticket = new SupportTicket();
        ticket.setFromNode(activeNodeOrNull(form.getNodeId()));
        ticket.setCustomer(customerId == null ? null : customerRepository.getReferenceById(customerId));
        ticket.setContactEmail(form.getContactEmail().trim().toLowerCase());
        ticket.setContactName(blankToNull(form.getContactName()));
        ticket.setContent(form.getContent().trim());
        // ticket_code NOT NULL + UNIQUE nhưng mã lấy theo ticket_id: lưu mã tạm (đúng 20 ký tự) rồi đổi sau khi có id
        ticket.setTicketCode("TMP-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16));
        ticketRepository.saveAndFlush(ticket);
        ticket.setTicketCode(String.format("HT-%06d", ticket.getId()));
        return ticket.getTicketCode();
    }

    // Nút khách đứng khi bấm "Khác"; bỏ qua nếu không tồn tại hoặc đã ẩn (không tin id gửi lên từ form)
    private ChatNode activeNodeOrNull(Long nodeId) {
        return nodeId == null ? null : nodeRepository.findById(nodeId)
                .filter(n -> n.getStatus() == ChatNodeStatus.ACTIVE).orElse(null);
    }

    // ===== Phía Staff =====

    @Transactional(readOnly = true)
    public Page<SupportTicketRow> search(SupportStatus status, String keyword, int pageNumber) {
        return ticketRepository.search(status, keyword == null || keyword.isBlank() ? null : keyword.trim(),
                        PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt", "id")))
                .map(t -> new SupportTicketRow(t.getId(), t.getTicketCode(), t.getContactName(), t.getContactEmail(),
                        preview(t.getContent()), t.getStatus(),
                        t.getHandledBy() == null ? null : t.getHandledBy().getFullName(),
                        t.getCreatedAt().format(DATE_TIME)));
    }

    // Số yêu cầu mới chưa ai nhận (hiện ở trang tổng quan)
    @Transactional(readOnly = true)
    public long countNew() {
        return ticketRepository.countByStatus(SupportStatus.NEW);
    }

    @Transactional(readOnly = true)
    public SupportTicketDetailDto detail(Long id) {
        SupportTicket t = ticketRepository.findDetail(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy yêu cầu hỗ trợ #" + id));
        return new SupportTicketDetailDto(t.getId(), t.getTicketCode(),
                t.getFromNode() == null ? null : t.getFromNode().getLabel(),
                t.getCustomer() != null, t.getContactName(), t.getContactEmail(), t.getContent(), t.getStatus(),
                t.getHandledBy() == null ? null : t.getHandledBy().getFullName(),
                t.getCreatedAt().format(DATE_TIME),
                t.getClosedAt() == null ? null : t.getClosedAt().format(DATE_TIME),
                replyRepository.findByTicket(id).stream().map(r -> new SupportReplyDto(r.getId(), r.getContent(),
                        r.getSendStatus(), r.getRepliedBy().getFullName(), r.getCreatedAt().format(DATE_TIME),
                        r.getSentAt() == null ? null : r.getSentAt().format(DATE_TIME))).toList());
    }

    // NEW -> IN_PROGRESS: nhân viên nhận xử lý
    @Transactional
    public void claim(Long id, Long employeeId) {
        SupportTicket ticket = find(id);
        if (ticket.getStatus() != SupportStatus.NEW) {
            throw new BusinessRuleException("Yêu cầu " + ticket.getTicketCode() + " đã có người nhận xử lý.");
        }
        ticket.setStatus(SupportStatus.IN_PROGRESS);
        ticket.setHandledBy(employeeRepository.getReferenceById(employeeId));
    }

    // Gửi email trả lời. Yêu cầu còn NEW thì người trả lời nhận luôn (NEW -> IN_PROGRESS),
    // gửi được thì chuyển RESPONDED; gửi lỗi vẫn lưu reply FAILED để gửi lại sau.
    @Transactional
    public SendResult reply(Long id, Long employeeId, String content) {
        if (content == null || content.isBlank()) {
            throw new BusinessRuleException("Vui lòng nhập nội dung trả lời");
        }
        if (content.trim().length() > 4000) {
            throw new BusinessRuleException("Nội dung trả lời tối đa 4000 ký tự");
        }
        SupportTicket ticket = find(id);
        requireOpen(ticket);
        Employee employee = employeeRepository.getReferenceById(employeeId);
        if (ticket.getStatus() == SupportStatus.NEW) {
            ticket.setStatus(SupportStatus.IN_PROGRESS);
        }
        if (ticket.getHandledBy() == null) {
            ticket.setHandledBy(employee);
        }
        SupportReply reply = new SupportReply(ticket, employee, content.trim());
        SendResult result = deliver(ticket, reply);
        replyRepository.save(reply);
        return result;
    }

    // Gửi lại một email đã lỗi (FAILED)
    @Transactional
    public SendResult resend(Long ticketId, Long replyId) {
        SupportReply reply = replyRepository.findById(replyId)
                .filter(r -> r.getTicket().getId().equals(ticketId))
                .orElseThrow(() -> new NotFoundException("Không tìm thấy email trả lời #" + replyId));
        if (reply.getSendStatus() == SendStatus.SENT) {
            throw new BusinessRuleException("Email này đã gửi thành công.");
        }
        SupportTicket ticket = reply.getTicket();
        requireOpen(ticket);
        return deliver(ticket, reply);
    }

    // RESPONDED -> CLOSED
    @Transactional
    public void close(Long id) {
        SupportTicket ticket = find(id);
        if (ticket.getStatus() != SupportStatus.RESPONDED) {
            throw new BusinessRuleException("Chỉ đóng được yêu cầu đã trả lời khách.");
        }
        ticket.setStatus(SupportStatus.CLOSED);
        ticket.setClosedAt(VnpayClient.nowVn());
    }

    // NEW / IN_PROGRESS -> SPAM
    @Transactional
    public void markSpam(Long id, Long employeeId) {
        SupportTicket ticket = find(id);
        if (ticket.getStatus() != SupportStatus.NEW && ticket.getStatus() != SupportStatus.IN_PROGRESS) {
            throw new BusinessRuleException("Yêu cầu đã trả lời hoặc đã đóng thì không đánh dấu spam được.");
        }
        ticket.setStatus(SupportStatus.SPAM);
        if (ticket.getHandledBy() == null) {
            ticket.setHandledBy(employeeRepository.getReferenceById(employeeId));
        }
        ticket.setClosedAt(VnpayClient.nowVn());
    }

    // ===== Phụ trợ =====

    private SendResult deliver(SupportTicket ticket, SupportReply reply) {
        try {
            mailer.sendReply(ticket, reply.getContent());
            reply.setSendStatus(SendStatus.SENT);
            reply.setSentAt(VnpayClient.nowVn());           // CK_SupportReply_sent_at
            if (ticket.getStatus() == SupportStatus.IN_PROGRESS) {
                ticket.setStatus(SupportStatus.RESPONDED);
            }
            return new SendResult(true, null);
        } catch (MailException e) {
            log.warn("Gửi email trả lời {} thất bại: {}", ticket.getTicketCode(), e.getMessage());
            reply.setSendStatus(SendStatus.FAILED);
            return new SendResult(false, e.getMessage());
        }
    }

    private static void requireOpen(SupportTicket ticket) {
        if (ticket.getStatus().isFinished()) {
            throw new BusinessRuleException("Yêu cầu " + ticket.getTicketCode() + " đã "
                    + ticket.getStatus().getLabel().toLowerCase() + ", không trả lời thêm được.");
        }
    }

    private SupportTicket find(Long id) {
        return ticketRepository.findById(id).orElseThrow(() -> new NotFoundException("Không tìm thấy yêu cầu hỗ trợ #" + id));
    }

    private static String preview(String content) {
        String oneLine = content.replaceAll("\\s+", " ").trim();
        return oneLine.length() <= PREVIEW_LENGTH ? oneLine : oneLine.substring(0, PREVIEW_LENGTH) + "…";
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
