package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ReviewDto;
import com.isp392.petfood.enums.ReviewStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ReviewService;
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

// Quản lý đánh giá cho STAFF và ADMIN (/staff/**): phản hồi (mỗi đánh giá một lần), ẩn / hiện.
//   GET  /staff/reviews                              lọc trạng thái, chưa phản hồi, tìm sản phẩm
//   POST /staff/reviews/{id}/reply | hide | show
@Controller
@RequestMapping("/staff/reviews")
@RequiredArgsConstructor
public class StaffReviewController {

    private final ReviewService reviewService;

    @GetMapping
    public String list(@RequestParam(name = "status", required = false) ReviewStatus status,
                       @RequestParam(name = "unreplied", defaultValue = "false") boolean unreplied,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page, Model model) {
        Page<ReviewDto> result = reviewService.search(status, unreplied, keyword, Math.max(page, 1) - 1);
        model.addAttribute("reviews", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("statuses", ReviewStatus.values());
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterUnreplied", unreplied);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of("status", status,
                "unreplied", unreplied ? "true" : null, "keyword", keyword));
        return "staff/reviews/list";
    }

    @PostMapping("/{id}/reply")
    public String reply(@PathVariable("id") Long id, @RequestParam(name = "content", required = false) String content,
                        @RequestParam(name = "back", required = false) String back,
                        @AuthenticationPrincipal AccountPrincipal user, RedirectAttributes redirect) {
        try {
            reviewService.reply(id, user.getEmployeeId(), content);
            redirect.addFlashAttribute("successMessage", "Đã phản hồi đánh giá #" + id + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return redirectBack(back);
    }

    @PostMapping("/{id}/hide")
    public String hide(@PathVariable("id") Long id, @RequestParam(name = "back", required = false) String back,
                       RedirectAttributes redirect) {
        reviewService.setStatus(id, ReviewStatus.HIDDEN);
        redirect.addFlashAttribute("successMessage", "Đã ẩn đánh giá #" + id + ".");
        return redirectBack(back);
    }

    @PostMapping("/{id}/show")
    public String show(@PathVariable("id") Long id, @RequestParam(name = "back", required = false) String back,
                       RedirectAttributes redirect) {
        reviewService.setStatus(id, ReviewStatus.VISIBLE);
        redirect.addFlashAttribute("successMessage", "Đã hiện lại đánh giá #" + id + ".");
        return redirectBack(back);
    }

    // Quay lại đúng trang danh sách (giữ bộ lọc); chỉ nhận query string, không nhận URL khác
    private static String redirectBack(String back) {
        return back == null || back.isBlank() || back.contains("://") || back.contains("\n")
                ? "redirect:/staff/reviews" : "redirect:/staff/reviews?" + back;
    }
}
