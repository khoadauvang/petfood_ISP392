package com.isp392.petfood.controller;

import com.isp392.petfood.dto.CheckoutForm;
import com.isp392.petfood.dto.CheckoutSummary;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.CheckoutService;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Đặt hàng. /checkout/** chỉ cho CUSTOMER (SecurityConfig).
//   GET  /checkout          form địa chỉ + phương thức thanh toán, tóm tắt giỏ và giảm giá hạng
//   POST /checkout/quote    tính phí giao hàng theo địa chỉ (Geoapify), hiện tổng tiền
//   POST /checkout          tạo đơn (server tính lại mọi khoản, không dùng số tiền trình duyệt gửi lên)
@Controller
@RequestMapping("/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;

    @InitBinder("checkoutForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String form(@AuthenticationPrincipal AccountPrincipal user, Model model, RedirectAttributes redirect) {
        CheckoutSummary summary = checkoutService.preview(user.getCustomerId(), null);
        String blocked = blockedReason(summary);
        if (blocked != null) {
            redirect.addFlashAttribute("errorMessage", blocked);
            return "redirect:/cart";
        }
        model.addAttribute("checkoutForm", new CheckoutForm());
        return show(model, summary);
    }

    @PostMapping("/quote")
    public String quote(@AuthenticationPrincipal AccountPrincipal user,
                        @Valid @ModelAttribute("checkoutForm") CheckoutForm form,
                        BindingResult result,
                        Model model) {
        String address = result.hasFieldErrors("shippingAddress") ? null : form.getShippingAddress();
        return show(model, checkoutService.preview(user.getCustomerId(), address));
    }

    @PostMapping
    public String place(@AuthenticationPrincipal AccountPrincipal user,
                        @Valid @ModelAttribute("checkoutForm") CheckoutForm form,
                        BindingResult result,
                        Model model,
                        RedirectAttributes redirect) {
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return show(model, checkoutService.preview(user.getCustomerId(), null));
        }
        try {
            Order order = checkoutService.place(user.getCustomerId(), form);
            redirect.addFlashAttribute("successMessage", "Đặt hàng thành công! Mã đơn của bạn là #" + order.getId() + ".");
            return "redirect:/orders/" + order.getId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return show(model, checkoutService.preview(user.getCustomerId(), form.getShippingAddress()));
        }
    }

    private String show(Model model, CheckoutSummary summary) {
        model.addAttribute("summary", summary);
        model.addAttribute("paymentMethods", PaymentMethod.values());
        return "customer/checkout";
    }

    private static String blockedReason(CheckoutSummary summary) {
        if (summary.getLines().isEmpty()) {
            return "Giỏ hàng đang trống, chưa đặt hàng được.";
        }
        if (summary.getLines().stream().anyMatch(l -> l.getProblem() != null)) {
            return "Giỏ hàng có sản phẩm hết hàng hoặc vượt số lượng còn lại, vui lòng sửa trước khi đặt hàng.";
        }
        return null;
    }
}
