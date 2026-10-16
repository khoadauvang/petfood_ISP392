package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ReviewForm;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ReviewService;
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

// Khách đánh giá một dòng hàng của đơn đã hoàn tất (/orders/** chỉ CUSTOMER).
//   GET  /orders/{orderId}/items/{itemId}/review    form (đã đánh giá thì hiện để sửa)
//   POST cùng URL                                     lưu
@Controller
@RequestMapping("/orders/{orderId}/items/{itemId}/review")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @InitBinder("reviewForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String form(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("orderId") Long orderId,
                       @PathVariable("itemId") Long itemId, Model model, RedirectAttributes redirect) {
        try {
            model.addAttribute("reviewForm", reviewService.getForm(user.getCustomerId(), orderId, itemId));
            return show(user, orderId, itemId, model);
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/orders/" + orderId;
        }
    }

    @PostMapping
    public String save(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("orderId") Long orderId,
                       @PathVariable("itemId") Long itemId, @Valid @ModelAttribute("reviewForm") ReviewForm form,
                       BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return show(user, orderId, itemId, model);
        }
        try {
            reviewService.save(user.getCustomerId(), orderId, itemId, form);
            redirect.addFlashAttribute("successMessage", "Cảm ơn bạn đã đánh giá sản phẩm!");
            return "redirect:/orders/" + orderId;
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return show(user, orderId, itemId, model);
        }
    }

    private String show(AccountPrincipal user, Long orderId, Long itemId, Model model) {
        model.addAttribute("orderId", orderId);
        model.addAttribute("itemId", itemId);
        model.addAttribute("productName", reviewService.reviewableProductName(user.getCustomerId(), orderId, itemId));
        return "customer/review-form";
    }
}
