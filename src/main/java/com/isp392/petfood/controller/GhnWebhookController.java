package com.isp392.petfood.controller;

import com.isp392.petfood.service.GhnShippingService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

// GHN gọi về khi trạng thái vận đơn đổi: POST /ghn/webhook (không đăng nhập, không CSRF - SecurityConfig).
// Khai báo URL https://<domain-ngrok>/ghn/webhook ở trang Webhook của tài khoản GHN dev.
// Không tin trạng thái trong payload: GhnShippingService.sync tra lại GHN bằng Token của shop.
// Luôn trả 200 (trừ sai secret) để GHN không gửi lại mãi; lỗi xử lý chỉ ghi log, staff bấm "Cập nhật từ GHN" sau.
@RestController
@RequiredArgsConstructor
public class GhnWebhookController {

    private static final Logger log = LoggerFactory.getLogger(GhnWebhookController.class);

    private final GhnShippingService ghnShippingService;

    @PostMapping("/ghn/webhook")
    public ResponseEntity<String> webhook(@RequestBody Map<String, Object> payload,
                                          @RequestHeader(name = "X-Webhook-Secret", required = false) String secret) {
        if (!ghnShippingService.isWebhookSecretValid(secret)) {
            return ResponseEntity.status(401).body("invalid secret");
        }
        if (!ghnShippingService.isEnabled()) {
            return ResponseEntity.ok("ignored");
        }
        try {
            ghnShippingService.handleWebhook(payload);
        } catch (RuntimeException e) {
            log.warn("Xử lý webhook GHN {} lỗi: {}", payload.get("ClientOrderCode"), e.getMessage());
        }
        return ResponseEntity.ok("ok");
    }
}
