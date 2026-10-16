package com.isp392.petfood.controller;

import com.isp392.petfood.dto.SupportTicketRow;
import com.isp392.petfood.enums.SupportStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.SupportService;
import com.isp392.petfood.service.SupportService.SendResult;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Yêu cầu hỗ trợ (nút "Khác" của chatbox) cho STAFF và ADMIN (/staff/**, module 9).
//   GET  /staff/support                          lọc trạng thái, tìm mã / email / tên
//   GET  /staff/support/{id}                     chi tiết + lịch sử email + form trả lời
//   POST /staff/support/{id}/claim | reply | close | spam
//   POST /staff/support/{id}/replies/{replyId}/resend   gửi lại email lỗi SMTP
@Controller
@RequestMapping("/staff/support")
@RequiredArgsConstructor
public class StaffSupportController {

    private final SupportService supportService;

    @GetMapping
    public String list(@RequestParam(name = "status", required = false) SupportStatus status,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page, Model model) {
        Page<SupportTicketRow> result = supportService.search(status, keyword, Math.max(page, 1) - 1);
        model.addAttribute("tickets", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("statuses", SupportStatus.values());
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of("status", status, "keyword", keyword));
        return "staff/support/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        model.addAttribute("ticket", supportService.detail(id));
        return "staff/support/detail";
    }

    @PostMapping("/{id}/claim")
    public String claim(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                        RedirectAttributes redirect) {
        try {
            supportService.claim(id, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage", "Bạn đã nhận xử lý yêu cầu này.");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/support/" + id;
    }

    @PostMapping("/{id}/reply")
    public String reply(@PathVariable("id") Long id, @RequestParam(name = "content", required = false) String content,
                        @AuthenticationPrincipal AccountPrincipal user, RedirectAttributes redirect) {
        try {
            flashSendResult(supportService.reply(id, user.getEmployeeId(), content), redirect);
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            redirect.addFlashAttribute("replyDraft", content);   // giữ nội dung đang gõ
        }
        return "redirect:/staff/support/" + id;
    }

    @PostMapping("/{id}/replies/{replyId}/resend")
    public String resend(@PathVariable("id") Long id, @PathVariable("replyId") Long replyId,
                         RedirectAttributes redirect) {
        try {
            flashSendResult(supportService.resend(id, replyId), redirect);
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/support/" + id;
    }

    @PostMapping("/{id}/close")
    public String close(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            supportService.close(id);
            redirect.addFlashAttribute("successMessage", "Đã đóng yêu cầu.");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/support/" + id;
    }

    @PostMapping("/{id}/spam")
    public String spam(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                       RedirectAttributes redirect) {
        try {
            supportService.markSpam(id, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage", "Đã đánh dấu spam.");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/support/" + id;
    }

    private static void flashSendResult(SendResult result, RedirectAttributes redirect) {
        if (result.sent()) {
            redirect.addFlashAttribute("successMessage", "Đã gửi email trả lời cho khách.");
        } else {
            redirect.addFlashAttribute("warningMessage",
                    "Đã lưu nội dung nhưng gửi email lỗi: " + result.error() + ". Bấm \"Gửi lại\" sau khi khắc phục.");
        }
    }
}
