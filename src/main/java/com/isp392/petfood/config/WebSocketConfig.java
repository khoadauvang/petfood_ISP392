package com.isp392.petfood.config;

import com.isp392.petfood.service.OrderStatusNotifier;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

// WebSocket thuần (không STOMP/SockJS), trình duyệt dùng new WebSocket(...) có sẵn, không cần thư viện JS.
// /staff/ws/orders nằm dưới /staff/** nên SecurityConfig chỉ cho STAFF/ADMIN bắt tay (dùng cookie phiên đăng nhập).
// Không gọi setAllowedOrigins: mặc định Spring chỉ nhận cùng origin, trang ở web khác không mở được kết nối.
@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {

    private final OrderStatusNotifier orderStatusNotifier;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(orderStatusNotifier, "/staff/ws/orders");
    }
}
