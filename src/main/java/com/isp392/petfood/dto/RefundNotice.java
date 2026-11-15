package com.isp392.petfood.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// Thông báo "đã hoàn tiền" gửi cho khách (JSON): đẩy qua WebSocket /orders/ws/refunds ngay khi staff bấm
// "Đã hoàn tiền", và trả lại qua GET /orders/refund-notices để khách mở lại trình duyệt / đăng nhập lại vẫn thấy.
//   refundAmount            tổng tiền hoàn của yêu cầu (đã thẩm định)
//   bankName, accountNo     tài khoản khách đã nhập lúc gửi yêu cầu (số tài khoản chỉ hiện 4 số cuối)
public record RefundNotice(Long returnId, Long orderId, BigDecimal refundAmount, LocalDateTime refundedAt,
                           String bankName, String accountNo) {
}
