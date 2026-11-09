package com.isp392.petfood.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

// Định kỳ hỏi GHN trạng thái các đơn đang giao (mặc định 15 giây, petfood.ghn.tracking-delay-ms).
// Bù cho webhook khi GHN không gọi được về máy (chạy local, hoặc domain cloudflared đổi mỗi lần chạy). Trạng thái mới được đẩy qua
// WebSocket tới trang staff (OrderStatusNotifier); giao xong / trả về shop thì đơn tự chuyển COMPLETED / RETURNED.
@Component
@RequiredArgsConstructor
public class GhnTrackingJob {

    private final GhnShippingService ghnShippingService;

    @Scheduled(fixedDelayString = "${petfood.ghn.tracking-delay-ms:15000}", initialDelay = 20_000)
    public void run() {
        ghnShippingService.trackShippedOrders();
    }
}
