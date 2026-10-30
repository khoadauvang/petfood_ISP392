package com.isp392.petfood.controller;

import com.isp392.petfood.dto.CartLineDto;
import com.isp392.petfood.dto.CheckoutForm;
import com.isp392.petfood.dto.CheckoutSummary;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.CheckoutService;
import com.isp392.petfood.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
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

import java.util.List;

// Đặt hàng. /checkout/** chỉ cho CUSTOMER (SecurityConfig).
//   GET  /checkout?itemIds=1,2   form địa chỉ + phương thức thanh toán, tóm tắt các dòng đã chọn và giảm giá hạng
//                                (không có itemIds: cả giỏ). itemIds đi tiếp qua input ẩn của form.
//   POST /checkout/quote    tính phí giao hàng theo địa chỉ (Geoapify), hiện tổng tiền
//   POST /checkout          tạo đơn (server tính lại mọi khoản, không dùng số tiền trình duyệt gửi lên)
@Controller
@RequestMapping("/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;
    private final PaymentService paymentService;

    @InitBinder("checkoutForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String form(@AuthenticationPrincipal AccountPrincipal user,
                       @RequestParam(name = "itemIds", required = false) List<Long> itemIds,
                       Model model, RedirectAttributes redirect) {
        CheckoutSummary summary = checkoutService.preview(user.getCustomerId(), null, itemIds);
        String blocked = blockedReason(summary);
        if (blocked != null) {
            redirect.addFlashAttribute("errorMessage", blocked);
            return "redirect:/cart";
        }
        CheckoutForm form = new CheckoutForm();
        if (itemIds != null && !itemIds.isEmpty()) {
            form.setItemIds(itemIds);
        } else {
            form.setItemIds(summary.getLines().stream().map(CartLineDto::getId).toList());
        }
        model.addAttribute("checkoutForm", form);
        return show(model, summary);
    }

    @PostMapping("/quote")
    public String quote(@AuthenticationPrincipal AccountPrincipal user,
                        @Valid @ModelAttribute("checkoutForm") CheckoutForm form,
                        BindingResult result,
                        Model model) {
        String address = result.hasFieldErrors("shippingAddress") ? null : form.getShippingAddress();
        return show(model, checkoutService.preview(user.getCustomerId(), address, form.getItemIds()));
    }

    @PostMapping
    public String place(@AuthenticationPrincipal AccountPrincipal user,
                        @Valid @ModelAttribute("checkoutForm") CheckoutForm form,
                        BindingResult result,
                        Model model,
                        RedirectAttributes redirect,
                        HttpServletRequest request) {
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return show(model, checkoutService.preview(user.getCustomerId(), null, form.getItemIds()));
        }
        try {
            Order order = checkoutService.place(user.getCustomerId(), form);
            if (order.getPaymentMethod() == PaymentMethod.VNPAY) {
                // Sang trang VNPay; xong VNPay đưa khách về /payment/vnpay-return
                return "redirect:" + paymentService.paymentUrl(user.getCustomerId(), order.getId(), clientIp(request));
            }
            redirect.addFlashAttribute("successMessage", "Đặt hàng thành công! Mã đơn của bạn là #" + order.getId() + ".");
            return "redirect:/orders/" + order.getId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return show(model, checkoutService.preview(user.getCustomerId(), form.getShippingAddress(), form.getItemIds()));
        }
    }

    private String show(Model model, CheckoutSummary summary) {
        model.addAttribute("summary", summary);
        model.addAttribute("paymentMethods", PaymentMethod.values());
        model.addAttribute("vnpayEnabled", paymentService.isVnpayEnabled());
        return "customer/checkout";
    }

    // IP khách gửi kèm cho VNPay (vnp_IpAddr); localhost IPv6 đổi về dạng IPv4
    static String clientIp(HttpServletRequest request) {
        String ip = request.getRemoteAddr();
        return ip == null || ip.contains(":") ? "127.0.0.1" : ip;
    }

    private static String blockedReason(CheckoutSummary summary) {
        if (summary.getLines().isEmpty()) {
            return "Chưa có sản phẩm nào được chọn để đặt hàng.";
        }
        if (summary.getLines().stream().anyMatch(l -> l.getProblem() != null)) {
            return "Sản phẩm đã chọn có dòng hết hàng hoặc vượt số lượng còn lại, vui lòng sửa trước khi đặt hàng.";
        }
        return null;
    }
}
