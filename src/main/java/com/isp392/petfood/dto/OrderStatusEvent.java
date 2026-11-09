package com.isp392.petfood.dto;

// Tin nhắn WebSocket gửi tới trang /staff/orders khi trạng thái đơn / vận đơn GHN thay đổi (JSON).
//   status, statusLabel        trạng thái đơn bên cửa hàng sau khi cập nhật (OrderStatus)
//   ghnOrderCode, ghnStatus,   vận đơn GHN (ghnStatus là mã gốc của GHN, ví dụ "delivering")
//   ghnStatusLabel, expectedDelivery
//   message                    câu mô tả ngắn để hiện thông báo
public record OrderStatusEvent(Long orderId, String status, String statusLabel,
                               String ghnOrderCode, String ghnStatus, String ghnStatusLabel,
                               String expectedDelivery, String message) {
}
