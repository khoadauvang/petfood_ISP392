package com.isp392.petfood.service;

import com.isp392.petfood.dto.RefundNotice;
import com.isp392.petfood.security.AccountPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.ConcurrentWebSocketSessionDecorator;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.security.Principal;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

// WebSocket /orders/ws/refunds (WebSocketConfig): mọi trang của khách đang đăng nhập mở một kết nối (_refund-notice.jspf).
// Staff bấm "Đã hoàn tiền" -> ReturnService phát RefundNotice -> sau khi giao dịch commit thì gửi tới đúng các tab của
// khách sở hữu đơn. Chỉ một chiều server -> trình duyệt. /orders/** chỉ cho CUSTOMER (SecurityConfig kiểm ở bước bắt tay).
// Khách đang offline thì không mất thông báo: trang tự gọi GET /orders/refund-notices khi tải (lấy từ refunded_at).
@Component
public class RefundNotifier extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(RefundNotifier.class);
    private static final int SEND_TIME_LIMIT_MS = 5_000;
    private static final int BUFFER_SIZE_LIMIT = 64 * 1024;
    private static final String CUSTOMER_ID = "customerId";

    // customerId -> các phiên (mỗi tab một phiên)
    private final Map<Long, Set<WebSocketSession>> sessions = new ConcurrentHashMap<>();
    private final JsonMapper jsonMapper;

    public RefundNotifier(JsonMapper jsonMapper) {
        this.jsonMapper = jsonMapper;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws IOException {
        Long customerId = customerIdOf(session.getPrincipal());
        if (customerId == null) {
            session.close(CloseStatus.POLICY_VIOLATION);
            return;
        }
        session.getAttributes().put(CUSTOMER_ID, customerId);
        sessions.computeIfAbsent(customerId, k -> ConcurrentHashMap.newKeySet())
                .add(new ConcurrentWebSocketSessionDecorator(session, SEND_TIME_LIMIT_MS, BUFFER_SIZE_LIMIT));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        remove(session);
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        remove(session);
    }

    // Chỉ gửi khi giao dịch "Đã hoàn tiền" đã commit, tránh báo nhầm khi giao dịch bị rollback
    @TransactionalEventListener
    public void onRefunded(RefundedEvent event) {
        Set<WebSocketSession> targets = sessions.get(event.customerId());
        if (targets == null || targets.isEmpty()) {
            return;
        }
        TextMessage message = new TextMessage(jsonMapper.writeValueAsString(event.notice()));
        for (WebSocketSession session : targets) {
            try {
                if (session.isOpen()) {
                    session.sendMessage(message);
                }
            } catch (IOException | RuntimeException e) {
                log.debug("Không gửi được thông báo hoàn tiền #{} tới phiên {}: {}",
                        event.notice().returnId(), session.getId(), e.getMessage());
                targets.remove(session);
            }
        }
    }

    private void remove(WebSocketSession session) {
        Object customerId = session.getAttributes().get(CUSTOMER_ID);
        if (customerId instanceof Long id) {
            Set<WebSocketSession> set = sessions.get(id);
            if (set != null) {
                set.removeIf(s -> s.getId().equals(session.getId()));
                if (set.isEmpty()) {
                    sessions.remove(id, set);
                }
            }
        }
    }

    private static Long customerIdOf(Principal principal) {
        if (principal instanceof Authentication auth && auth.getPrincipal() instanceof AccountPrincipal user) {
            return user.getCustomerId();
        }
        return null;
    }

    // Sự kiện ReturnService phát ra trong markRefunded
    public record RefundedEvent(Long customerId, RefundNotice notice) {
    }
}
