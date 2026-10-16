package com.isp392.petfood.controller;

import com.isp392.petfood.dto.SupportTicketForm;
import com.isp392.petfood.enums.Role;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ChatNodeService;
import com.isp392.petfood.service.SupportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Chatbox hỗ trợ phía khách (module 9, requirements 7.10). Không cần đăng nhập.
//   GET  /support?node={id}          màn hình chat: các bước đã chọn + lựa chọn tiếp theo (không có node = chủ đề gốc)
//   GET  /support/ticket?node={id}   nút "Khác": form nhập vấn đề + email     POST /support/ticket để gửi
@Controller
@RequestMapping("/support")
@RequiredArgsConstructor
public class SupportController {

    private final ChatNodeService chatNodeService;
    private final SupportService supportService;

    @InitBinder("supportTicketForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String chat(@RequestParam(name = "node", required = false) Long nodeId, Model model) {
        model.addAttribute("chat", chatNodeService.conversation(nodeId));
        return "support/chat";
    }

    @GetMapping("/ticket")
    public String ticketForm(@RequestParam(name = "node", required = false) Long nodeId,
                             @AuthenticationPrincipal AccountPrincipal user, Model model) {
        SupportTicketForm form = new SupportTicketForm();
        String nodeLabel = chatNodeService.visibleLabel(nodeId);
        form.setNodeId(nodeLabel == null ? null : nodeId);
        if (user != null) {                         // đã đăng nhập thì điền sẵn, khách vẫn sửa được
            form.setContactEmail(user.getEmail());
            form.setContactName(user.getFullName());
        }
        model.addAttribute("supportTicketForm", form);
        model.addAttribute("nodeLabel", nodeLabel);
        return "support/ticket-form";
    }

    @PostMapping("/ticket")
    public String submitTicket(@Valid @ModelAttribute("supportTicketForm") SupportTicketForm form, BindingResult result,
                               @AuthenticationPrincipal AccountPrincipal user, Model model,
                               RedirectAttributes redirect) {
        if (result.hasErrors()) {
            model.addAttribute("nodeLabel", chatNodeService.visibleLabel(form.getNodeId()));
            return "support/ticket-form";
        }
        Long customerId = user != null && user.getRole() == Role.CUSTOMER ? user.getCustomerId() : null;
        String code = supportService.createTicket(form, customerId);
        redirect.addFlashAttribute("successMessage", "Đã gửi yêu cầu " + code + ". Nhân viên sẽ trả lời qua email "
                + form.getContactEmail() + ", tiêu đề email có mã " + code + ".");
        return "redirect:/support";
    }
}
