package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ReturnForm;
import com.isp392.petfood.dto.ReturnableLine;
import com.isp392.petfood.entity.ReturnRequest;
import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ReturnService;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Arrays;
import java.util.List;

// Yêu cầu trả hàng của khách, nằm dưới /orders/** (chỉ CUSTOMER, chỉ đơn của chính mình).
//   GET  /orders/{orderId}/returns/new          form: chọn sản phẩm + số lượng, lý do, 1-5 ảnh/video, tài khoản (COD)
//   POST /orders/{orderId}/returns/new          gửi yêu cầu
//   GET  /orders/{orderId}/returns/{returnId}   theo dõi yêu cầu
@Controller
@RequestMapping("/orders/{orderId}/returns")
@RequiredArgsConstructor
public class ReturnController {

    private final ReturnService returnService;

    @InitBinder("returnForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping("/new")
    public String form(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("orderId") Long orderId,
                       Model model, RedirectAttributes redirect) {
        try {
            List<ReturnableLine> lines = returnService.returnableLines(user.getCustomerId(), orderId);
            ReturnForm form = new ReturnForm();
            for (ReturnableLine l : lines) {
                ReturnForm.Line line = new ReturnForm.Line();
                line.setOrderItemId(l.getOrderItemId());
                line.setQuantity(l.getQuantity());
                form.getLines().add(line);
            }
            model.addAttribute("returnForm", form);
            return show(user, orderId, lines, model);
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/orders/" + orderId;
        }
    }

    @PostMapping("/new")
    public String create(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("orderId") Long orderId,
                         @Valid @ModelAttribute("returnForm") ReturnForm form, BindingResult result,
                         Model model, RedirectAttributes redirect) {
        List<ReturnableLine> lines;
        try {
            lines = returnService.returnableLines(user.getCustomerId(), orderId);
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/orders/" + orderId;
        }
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return show(user, orderId, lines, model);
        }
        try {
            ReturnRequest request = returnService.create(user.getCustomerId(), orderId, form);
            redirect.addFlashAttribute("successMessage", "Đã gửi yêu cầu trả hàng #" + request.getId()
                    + ". Cửa hàng sẽ duyệt và liên hệ với bạn.");
            return "redirect:/orders/" + orderId + "/returns/" + request.getId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return show(user, orderId, lines, model);
        }
    }

    @GetMapping("/{returnId}")
    public String detail(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("orderId") Long orderId,
                         @PathVariable("returnId") Long returnId, Model model) {
        model.addAttribute("ret", returnService.getForCustomer(user.getCustomerId(), orderId, returnId));
        return "customer/return-detail";
    }

    private String show(AccountPrincipal user, Long orderId, List<ReturnableLine> lines, Model model) {
        model.addAttribute("orderId", orderId);
        model.addAttribute("returnableLines", lines);
        model.addAttribute("cod", returnService.isCod(user.getCustomerId(), orderId));
        // Khách không chọn được REFUSED_DELIVERY (chỉ hệ thống tạo)
        model.addAttribute("reasons", Arrays.stream(ReturnReason.values())
                .filter(r -> r != ReturnReason.REFUSED_DELIVERY).toList());
        return "customer/return-form";
    }
}
