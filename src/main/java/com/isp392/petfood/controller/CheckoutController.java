package com.isp392.petfood.controller;

import com.isp392.petfood.dto.CartLineDto;
import com.isp392.petfood.dto.CheckoutForm;
import com.isp392.petfood.dto.CheckoutSummary;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.CheckoutService;
import com.isp392.petfood.service.GeoapifyGeocoder;
import com.isp392.petfood.service.GhnClient.Area;
import com.isp392.petfood.service.GhnClient.GhnException;
import com.isp392.petfood.service.GhnShippingService;
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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

// Đặt hàng. /checkout/** chỉ cho CUSTOMER (SecurityConfig).
//   GET  /checkout?itemIds=1,2   form địa chỉ + phương thức thanh toán, tóm tắt các dòng đã chọn và giảm giá hạng
//                                (không có itemIds: cả giỏ). itemIds đi tiếp qua input ẩn của form.
//   POST /checkout/quote    tính phí giao hàng theo địa chỉ (Geoapify), hiện tổng tiền
//   POST /checkout          tạo đơn (server tính lại mọi khoản, không dùng số tiền trình duyệt gửi lên)
//   GET  /checkout/ghn/provinces, /checkout/ghn/wards?provinceId=   danh mục tỉnh/thành, phường/xã của GHN (JSON)
//                                cho 2 ô chọn địa chỉ; chỉ dùng khi đã cấu hình GHN (ghnAddressPicker = true)
//   GET  /checkout/address-suggest?q=&ward=&province=   gợi ý tên đường trong phường đã chọn (Geoapify, JSON)
@Controller
@RequestMapping("/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;
    private final PaymentService paymentService;
    private final GhnShippingService ghnShippingService;
    private final GeoapifyGeocoder geocoder;

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
        checkArea(form, result);
        String address = result.hasFieldErrors("shippingAddress") || result.hasFieldErrors("province")
                || result.hasFieldErrors("ward") ? null : form.getFullAddress();
        return show(model, checkoutService.preview(user.getCustomerId(), address, form.getItemIds()));
    }

    @PostMapping
    public String place(@AuthenticationPrincipal AccountPrincipal user,
                        @Valid @ModelAttribute("checkoutForm") CheckoutForm form,
                        BindingResult result,
                        Model model,
                        RedirectAttributes redirect,
                        HttpServletRequest request) {
        checkArea(form, result);
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
            return show(model, checkoutService.preview(user.getCustomerId(), form.getFullAddress(), form.getItemIds()));
        }
    }

    private String show(Model model, CheckoutSummary summary) {
        model.addAttribute("summary", summary);
        model.addAttribute("paymentMethods", PaymentMethod.values());
        model.addAttribute("vnpayEnabled", paymentService.isVnpayEnabled());
        boolean picker = ghnShippingService.isAddressPickerAvailable();
        model.addAttribute("ghnAddressPicker", picker);
        // Gợi ý tên đường cần biết phường đã chọn nên chỉ bật cùng ô chọn phường GHN
        model.addAttribute("addressSuggest", picker && geocoder.isConfigured());
        return "customer/checkout";
    }

    @GetMapping("/ghn/provinces")
    @ResponseBody
    public List<Area> provinces() {
        try {
            return ghnShippingService.provinces();
        } catch (GhnException e) {
            return List.of();
        }
    }

    @GetMapping("/ghn/wards")
    @ResponseBody
    public List<Area> wards(@RequestParam("provinceId") int provinceId) {
        try {
            return ghnShippingService.wards(provinceId);
        } catch (GhnException e) {
            return List.of();
        }
    }

    // q: phần tên đường khách đang gõ (JS đã bỏ số nhà ở đầu)
    @GetMapping("/address-suggest")
    @ResponseBody
    public List<String> suggestStreets(@RequestParam("q") String q,
                                       @RequestParam("ward") String ward,
                                       @RequestParam(name = "province", required = false) String province) {
        if (q.trim().length() < 2 || q.length() > 100) {
            return List.of();
        }
        return geocoder.suggestStreets(q, ward, province);
    }

    // Đã cấu hình GHN: bắt chọn tỉnh/thành và phường/xã có trong danh mục GHN, để lúc giao tạo được vận đơn.
    // GHN không tải được danh mục thì bỏ qua, khách gõ địa chỉ đầy đủ như trước.
    private void checkArea(CheckoutForm form, BindingResult result) {
        if (!ghnShippingService.isAddressPickerAvailable()) {
            form.setProvince(null);
            form.setWard(null);
            return;
        }
        if (form.getProvince() == null || form.getProvince().isBlank()) {
            result.rejectValue("province", "required", "Vui lòng chọn tỉnh/thành phố");
        } else if (form.getWard() == null || form.getWard().isBlank()) {
            result.rejectValue("ward", "required", "Vui lòng chọn phường/xã");
        } else {
            try {
                if (!ghnShippingService.isValidArea(form.getProvince(), form.getWard())) {
                    result.rejectValue("ward", "invalid", "Phường/xã không thuộc tỉnh/thành đã chọn");
                }
            } catch (GhnException e) {
                // GHN vừa lỗi giữa chừng: vẫn cho đặt, staff giao thủ công nếu không tạo được vận đơn
            }
        }
        if (!result.hasFieldErrors("shippingAddress") && form.getFullAddress() != null
                && form.getFullAddress().length() > 500) {
            result.rejectValue("shippingAddress", "size", "Địa chỉ quá dài");
        }
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
