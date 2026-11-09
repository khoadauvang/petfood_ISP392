package com.isp392.petfood.service;

import com.isp392.petfood.dto.OrderStatusEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.ConcurrentWebSocketSessionDecorator;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// WebSocket /staff/ws/orders (WebSocketConfig): trang quản lý đơn của STAFF/ADMIN mở kết nối, server đẩy
// OrderStatusEvent mỗi khi GHN báo trạng thái mới (webhook hoặc GhnTrackingJob). Chỉ một chiều server -> trình duyệt,
// tin nhắn trình duyệt gửi lên bị bỏ qua. Quyền truy cập do SecurityConfig kiểm ở bước bắt tay (/staff/**).
@Component
public class OrderStatusNotifier extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(OrderStatusNotifier.class);
    private static final int SEND_TIME_LIMIT_MS = 5_000;
    private static final int BUFFER_SIZE_LIMIT = 256 * 1024;

    // Bọc ConcurrentWebSocketSessionDecorator: nhiều luồng (webhook, job) gửi cùng lúc không làm hỏng phiên
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final JsonMapper jsonMapper;

    public OrderStatusNotifier(JsonMapper jsonMapper) {
        this.jsonMapper = jsonMapper;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        sessions.put(session.getId(),
                new ConcurrentWebSocketSessionDecorator(session, SEND_TIME_LIMIT_MS, BUFFER_SIZE_LIMIT));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessions.remove(session.getId());
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        sessions.remove(session.getId());
    }

    // Có trang staff nào đang mở không
    public boolean hasListeners() {
        return !sessions.isEmpty();
    }

    // Gửi cho mọi trang staff đang mở. Lỗi gửi chỉ ghi log và đóng phiên đó (trình duyệt tự kết nối lại).
    public void publish(OrderStatusEvent event) {
        if (sessions.isEmpty()) {
            return;
        }
        TextMessage message = new TextMessage(jsonMapper.writeValueAsString(event));
        sessions.values().forEach(session -> {
            try {
                if (session.isOpen()) {
                    session.sendMessage(message);
                }
            } catch (IOException | RuntimeException e) {
                log.debug("Không gửi được trạng thái đơn #{} tới phiên {}: {}", event.orderId(), session.getId(), e.getMessage());
                sessions.remove(session.getId());
                try {
                    session.close(CloseStatus.SESSION_NOT_RELIABLE);
                } catch (IOException ignored) {
                    // phiên đã hỏng sẵn
                }
            }
        });
    }
}
