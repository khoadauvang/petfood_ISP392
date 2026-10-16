package com.isp392.petfood.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

// Mỗi phút bật / tắt chiến dịch Flash Sale theo start_time / end_time và kết thúc chiến dịch đã bán hết
@Component
@RequiredArgsConstructor
public class FlashSaleScheduler {

    private final FlashSaleService flashSaleService;

    @Scheduled(fixedDelayString = "${petfood.flash-sale.job-delay-ms:60000}", initialDelay = 20_000)
    public void run() {
        flashSaleService.tick(LocalDateTime.now());
    }
}
