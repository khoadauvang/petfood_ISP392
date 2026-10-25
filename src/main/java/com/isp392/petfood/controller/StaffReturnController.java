package com.isp392.petfood.controller;

import com.isp392.petfood.dto.InspectForm;
import com.isp392.petfood.dto.ReturnDetailDto;
import com.isp392.petfood.dto.ReturnRow;
import com.isp392.petfood.enums.InspectionResult;
import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ReturnService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.function.Supplier;

// Duyệt và thẩm định trả hàng cho STAFF và ADMIN (/staff/**), BR-36, BR-37, BR-38.
//   GET  /staff/returns                  danh sách, lọc trạng thái, lý do, ngày gửi, từ khoá
//   GET  /staff/returns/{id}             chi tiết: ảnh/video, dòng hàng, tài khoản nhận hoàn
//   POST /staff/returns/{id}/approve | reject (lý do) | receive | inspect | refunded
@Controller
@RequestMapping("/staff/returns")
@RequiredArgsConstructor
public class StaffReturnController {

    private final ReturnService returnService;

    @GetMapping
    public String list(@RequestParam(name = "status", required = false) ReturnStatus status,
                       @RequestParam(name = "reason", required = false) ReturnReason reason,
                       @RequestParam(name = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                       @RequestParam(name = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page, Model model) {
        Page<ReturnRow> result = returnService.search(status, reason, from, to, keyword, Math.max(page, 1) - 1);
        model.addAttribute("returns", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("statuses", ReturnStatus.values());
        model.addAttribute("reasons", ReturnReason.values());
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterReason", reason);
        model.addAttribute("filterFrom", from);
        model.addAttribute("filterTo", to);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of(
                "status", status, "reason", reason, "from", from, "to", to, "keyword", keyword));
        model.addAttribute("returnCounts", returnService.getReturnCounts());
        return "staff/returns/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        ReturnDetailDto ret = returnService.getForStaff(id);
        InspectForm form = new InspectForm();
        ret.getLines().forEach(l -> {
            InspectForm.Line line = new InspectForm.Line();
            line.setReturnItemId(l.getReturnItemId());
            form.getLines().add(line);
        });
        model.addAttribute("ret", ret);
        model.addAttribute("inspectForm", form);
        model.addAttribute("inspectionResults", InspectionResult.values());
        return "staff/returns/detail";
    }

    @PostMapping("/{id}/approve")
    public String approve(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                          RedirectAttributes redirect) {
        return act(id, redirect, "Đã duyệt yêu cầu #" + id + ", chờ nhận hàng khách gửi",
                () -> returnService.approve(id, user.getEmployeeId()));
    }

    @PostMapping("/{id}/reject")
    public String reject(@PathVariable("id") Long id, @RequestParam(name = "rejectReason", required = false) String reason,
                         @AuthenticationPrincipal AccountPrincipal user, RedirectAttributes redirect) {
        return act(id, redirect, "Đã từ chối yêu cầu #" + id, () -> returnService.reject(id, user.getEmployeeId(), reason));
    }

    @PostMapping("/{id}/receive")
    public String receive(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã xác nhận nhận hàng trả của yêu cầu #" + id, () -> returnService.receive(id));
    }

    @PostMapping("/{id}/inspect")
    public String inspect(@PathVariable("id") Long id, @ModelAttribute("inspectForm") InspectForm form,
                          @AuthenticationPrincipal AccountPrincipal user, RedirectAttributes redirect) {
        return act(id, redirect, "Đã thẩm định yêu cầu #" + id, () -> returnService.inspect(id, user.getEmployeeId(), form));
    }

    @PostMapping("/{id}/refunded")
    public String refunded(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã ghi nhận hoàn tiền yêu cầu #" + id, () -> returnService.markRefunded(id));
    }

    private static String act(Long id, RedirectAttributes redirect, String success, Supplier<?> action) {
        try {
            action.get();
            redirect.addFlashAttribute("successMessage", success + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/returns/" + id;
    }
}
