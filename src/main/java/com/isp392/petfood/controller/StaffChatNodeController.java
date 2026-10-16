package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ChatNodeForm;
import com.isp392.petfood.entity.ChatNode;
import com.isp392.petfood.enums.ChatNodeStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ChatNodeService;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Quản lý cây kịch bản chatbox cho STAFF và ADMIN (/staff/**, module 9).
//   GET  /staff/chat-nodes                   cả cây (thụt lề theo cấp)
//   GET  /staff/chat-nodes/new?parent={id}   form thêm (điền sẵn nút cha)     POST /staff/chat-nodes/new
//   GET  /staff/chat-nodes/{id}/edit         form sửa / chuyển nút cha        POST cùng URL
//   POST /staff/chat-nodes/{id}/hide | show | delete
@Controller
@RequestMapping("/staff/chat-nodes")
@RequiredArgsConstructor
public class StaffChatNodeController {

    private final ChatNodeService chatNodeService;

    @InitBinder("chatNodeForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("nodes", chatNodeService.tree());
        return "staff/chat-nodes/list";
    }

    @GetMapping("/new")
    public String createForm(@RequestParam(name = "parent", required = false) Long parentId, Model model) {
        ChatNodeForm form = new ChatNodeForm();
        form.setParentId(parentId);
        model.addAttribute("chatNodeForm", form);
        return showForm(null, model);
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("chatNodeForm") ChatNodeForm form, BindingResult result,
                         @AuthenticationPrincipal AccountPrincipal user, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(null, model);
        }
        try {
            ChatNode node = chatNodeService.create(form, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage", "Đã thêm nút \"" + node.getLabel() + "\".");
            return "redirect:/staff/chat-nodes";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(null, model);
        }
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("chatNodeForm", chatNodeService.getForm(id));
        return showForm(id, model);
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id, @Valid @ModelAttribute("chatNodeForm") ChatNodeForm form,
                         BindingResult result, @AuthenticationPrincipal AccountPrincipal user, Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(id, model);
        }
        try {
            ChatNode node = chatNodeService.update(id, form, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage", "Đã lưu nút \"" + node.getLabel() + "\".");
            return "redirect:/staff/chat-nodes";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(id, model);
        }
    }

    @PostMapping("/{id}/hide")
    public String hide(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                       RedirectAttributes redirect) {
        ChatNode node = chatNodeService.setStatus(id, ChatNodeStatus.HIDDEN, user.getEmployeeId());
        redirect.addFlashAttribute("successMessage", "Đã ẩn nút \"" + node.getLabel() + "\" (khách không thấy cả nhánh con).");
        return "redirect:/staff/chat-nodes";
    }

    @PostMapping("/{id}/show")
    public String show(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                       RedirectAttributes redirect) {
        ChatNode node = chatNodeService.setStatus(id, ChatNodeStatus.ACTIVE, user.getEmployeeId());
        redirect.addFlashAttribute("successMessage", "Đã hiện lại nút \"" + node.getLabel() + "\".");
        return "redirect:/staff/chat-nodes";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            chatNodeService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá nút #" + id + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/chat-nodes";
    }

    private String showForm(Long nodeId, Model model) {
        model.addAttribute("nodeId", nodeId);
        model.addAttribute("parentOptions", chatNodeService.parentOptions(nodeId));
        model.addAttribute("nodeStatuses", ChatNodeStatus.values());
        return "staff/chat-nodes/form";
    }
}
