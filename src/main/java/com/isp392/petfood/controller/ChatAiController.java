package com.isp392.petfood.controller;

import com.isp392.petfood.service.GeminiChatService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import java.util.Map;

// API cho chatbox tư vấn AI (Gemini) trong widget _chat-widget.jspf. Không cần đăng nhập (/support/** đã permitAll).
//   POST /support/ai   body: {"message": "...", "history": [{"role":"user|model","text":"..."}]}
//   -> {"ok": true, "reply": "..."}  hoặc  {"ok": false, "reason": "..."} (widget dùng câu trả lời mặc định)
@RestController
@RequiredArgsConstructor
public class ChatAiController {

    private static final int MAX_MESSAGE_LENGTH = 1000;
    private static final int MAX_HISTORY_TURNS = 10;
    private static final int MAX_TURN_LENGTH = 2000;
    // Chống spam làm cạn quota miễn phí: tối đa 15 tin / 5 phút cho mỗi phiên
    private static final int RATE_LIMIT = 15;
    private static final long RATE_WINDOW_MILLIS = 5 * 60 * 1000L;
    private static final String RATE_ATTR = "petfood.chatAi.timestamps";

    private final GeminiChatService geminiChatService;

    public record ChatRequest(String message, List<GeminiChatService.Turn> history) {
    }

    @PostMapping("/support/ai")
    public Map<String, Object> chat(@RequestBody ChatRequest request, HttpSession session) {
        if (!geminiChatService.isConfigured()) {
            return Map.of("ok", false, "reason", "not_configured");
        }
        String message = request == null || request.message() == null ? "" : request.message().trim();
        if (message.isEmpty()) {
            return Map.of("ok", false, "reason", "empty");
        }
        if (message.length() > MAX_MESSAGE_LENGTH) {
            message = message.substring(0, MAX_MESSAGE_LENGTH);
        }
        if (!allow(session)) {
            return Map.of("ok", false, "reason", "rate_limited",
                    "reply", "Bạn nhắn hơi nhanh rồi ạ 😅 Vui lòng đợi vài phút rồi hỏi tiếp, "
                            + "hoặc gọi hotline **1900 6868** để được hỗ trợ ngay nhé!");
        }
        List<GeminiChatService.Turn> history = sanitize(request.history());
        return geminiChatService.reply(history, message)
                .<Map<String, Object>>map(reply -> Map.of("ok", true, "reply", reply))
                .orElseGet(() -> Map.of("ok", false, "reason", "upstream_error"));
    }

    private static List<GeminiChatService.Turn> sanitize(List<GeminiChatService.Turn> history) {
        if (history == null || history.isEmpty()) {
            return List.of();
        }
        List<GeminiChatService.Turn> tail = history.subList(Math.max(0, history.size() - MAX_HISTORY_TURNS), history.size());
        return tail.stream()
                .filter(t -> t != null && t.text() != null && !t.text().isBlank())
                .map(t -> new GeminiChatService.Turn("model".equals(t.role()) ? "model" : "user",
                        t.text().length() > MAX_TURN_LENGTH ? t.text().substring(0, MAX_TURN_LENGTH) : t.text()))
                .toList();
    }

    @SuppressWarnings("unchecked")
    private static boolean allow(HttpSession session) {
        synchronized (session.getId().intern()) {
            Deque<Long> stamps = (Deque<Long>) session.getAttribute(RATE_ATTR);
            if (stamps == null) {
                stamps = new ArrayDeque<>();
            }
            long now = System.currentTimeMillis();
            while (!stamps.isEmpty() && now - stamps.peekFirst() > RATE_WINDOW_MILLIS) {
                stamps.pollFirst();
            }
            if (stamps.size() >= RATE_LIMIT) {
                return false;
            }
            stamps.addLast(now);
            session.setAttribute(RATE_ATTR, stamps);
            return true;
        }
    }
}

