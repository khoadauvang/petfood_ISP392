package com.isp392.petfood.controller;

import com.isp392.petfood.dto.RefundNotice;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.ReturnService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

// GET /orders/refund-notices (JSON, chỉ CUSTOMER): các yêu cầu trả hàng đã hoàn tiền trong 7 ngày gần đây.
// _refund-notice.jspf gọi khi tải trang để khách đóng trình duyệt / đăng nhập lại vẫn thấy thông báo;
// thông báo tức thời đi qua WebSocket /orders/ws/refunds (RefundNotifier).
@RestController
@RequiredArgsConstructor
public class RefundNoticeController {

    private static final int RECENT_DAYS = 7;

    private final ReturnService returnService;

    @GetMapping("/orders/refund-notices")
    public List<RefundNotice> recent(@AuthenticationPrincipal AccountPrincipal user) {
        return returnService.recentRefundNotices(user.getCustomerId(), RECENT_DAYS);
    }
}
