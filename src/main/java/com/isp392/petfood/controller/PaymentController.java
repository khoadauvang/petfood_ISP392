package com.isp392.petfood.controller;

import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.PaymentService;
import com.isp392.petfood.service.PaymentService.CallbackResult;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

// Thanh toán VNPay (module 5).
//   GET  /payment/vnpay-return    VNPay đưa trình duyệt khách về sau khi thanh toán (permitAll, tin theo chữ ký)
//   GET  /payment/vnpay-ipn       VNPay gọi thẳng server báo kết quả, trả JSON RspCode (permitAll).
//                                 Cần URL public (ngrok) khai báo ở merchant VNPay; chạy localhost không có
//                                 ngrok thì job tra cứu querydr thay thế (cách A)
//   POST /orders/{id}/pay         khách quay lại trang VNPay trong 15 phút giữ hàng, kể cả sau khi lần trước
//                                 thất bại / bị huỷ (CUSTOMER)
@Controller
@RequiredArgsConstructor
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentService paymentService;

    @GetMapping("/payment/vnpay-return")
    public String vnpayReturn(@RequestParam Map<String, String> params, RedirectAttributes redirect) {
        CallbackResult result = paymentService.handleVnpayCallback(params);
        redirect.addFlashAttribute(result.paid() ? "successMessage" : result.held() ? "warningMessage" : "errorMessage",
                result.message());
        return result.orderId() == null ? "redirect:/orders" : "redirect:/orders/" + result.orderId();
    }

    @GetMapping("/payment/vnpay-ipn")
    @ResponseBody
    public Map<String, String> vnpayIpn(@RequestParam Map<String, String> params) {
        log.info("VNPay IPN: TxnRef={}, ResponseCode={}, TransactionStatus={}",
                params.get("vnp_TxnRef"), params.get("vnp_ResponseCode"), params.get("vnp_TransactionStatus"));
        try {
            CallbackResult result = paymentService.handleVnpayCallback(params);
            log.info("VNPay IPN {} -> RspCode {}", params.get("vnp_TxnRef"), result.ipnCode());
            return Map.of("RspCode", result.ipnCode(), "Message", result.ipnMessage());
        } catch (RuntimeException e) {
            // VNPay luôn cần JSON; trả 99 để VNPay gửi lại IPN sau (xử lý lặp lại không sao)
            log.error("VNPay IPN {} lỗi", params.get("vnp_TxnRef"), e);
            return Map.of("RspCode", "99", "Message", "Unknown error");
        }
    }

    @PostMapping("/orders/{id}/pay")
    public String continuePayment(@AuthenticationPrincipal AccountPrincipal user,
                                  @PathVariable("id") Long id,
                                  HttpServletRequest request,
                                  RedirectAttributes redirect) {
        try {
            return "redirect:" + paymentService.paymentUrl(user.getCustomerId(), id, CheckoutController.clientIp(request));
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/orders/" + id;
        }
    }
}
