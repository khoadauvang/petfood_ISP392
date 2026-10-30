package com.isp392.petfood.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// Gọi API Giao Hàng Nhanh (https://developer.ghn.dev). Môi trường dev mặc định: dev-online-gateway.ghn.vn.
// Token và ShopId đặt trong .env: petfood.ghn.token, petfood.ghn.shop-id. Thiếu -> isConfigured() = false,
// app chạy như trước (giao hàng mô phỏng, staff chuyển trạng thái tay).
// Địa chỉ dùng mô hình hành chính 2 cấp (tỉnh/thành -> phường/xã, sau 01/07/2025), tạo đơn với is_new_to_address = true.
// Danh mục tỉnh và phường được nhớ lại trong bộ nhớ vì gần như không đổi.
@Component
public class GhnClient {

    private static final Logger log = LoggerFactory.getLogger(GhnClient.class);

    private final String baseUrl;
    private final String token;
    private final String shopId;
    private final RestClient restClient;
    private volatile List<Area> provinces;
    private final Map<Integer, List<Area>> wardsByProvince = new ConcurrentHashMap<>();

    public GhnClient(@Value("${petfood.ghn.base-url:https://dev-online-gateway.ghn.vn/shiip/public-api}") String baseUrl,
                     @Value("${petfood.ghn.token:}") String token,
                     @Value("${petfood.ghn.shop-id:}") String shopId) {
        this.baseUrl = baseUrl;
        this.token = token == null ? "" : token.trim();
        this.shopId = shopId == null ? "" : shopId.trim();
        HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(http);
        factory.setReadTimeout(Duration.ofSeconds(10));
        this.restClient = RestClient.builder().requestFactory(factory).baseUrl(this.baseUrl).build();
    }

    public boolean isConfigured() {
        return !token.isEmpty() && !shopId.isEmpty();
    }

    public String getShopId() {
        return shopId;
    }

    // Một tỉnh/thành hoặc phường/xã: _id và tên chuẩn (truyền nguyên văn vào to_province_name / to_ward_name)
    public record Area(int id, String name) {
    }

    // Đơn GHN tạo xong: mã vận đơn và thời gian giao dự kiến (ISO 8601)
    public record CreatedOrder(String orderCode, Long totalFee, String expectedDeliveryTime) {
    }

    // Thông tin đơn GHN tra theo client_order_code
    public record OrderInfo(String orderCode, String status, String leadtime) {
    }

    // Lỗi do GHN trả về (sai địa chỉ, sai số điện thoại...) hoặc không gọi được GHN; message đọc được cho staff
    public static class GhnException extends RuntimeException {
        public GhnException(String message) {
            super(message);
        }
    }

    public List<Area> provinces() {
        List<Area> cached = provinces;
        if (cached == null) {
            cached = areas(get("/v3/master-data/province/all?offset=0&limit=200",
                    new ParameterizedTypeReference<GhnResponse<List<RawArea>>>() { }));
            provinces = cached;
        }
        return cached;
    }

    public List<Area> wards(int provinceId) {
        List<Area> cached = wardsByProvince.get(provinceId);
        if (cached == null) {
            cached = areas(get("/v3/master-data/ward/all-by-province-id?province_id=" + provinceId + "&offset=0&limit=200",
                    new ParameterizedTypeReference<GhnResponse<List<RawArea>>>() { }));
            wardsByProvince.put(provinceId, cached);
        }
        return cached;
    }

    // POST /v2/shipping-order/create. body theo tài liệu GHN (snake_case); gửi lại cùng client_order_code
    // thì GHN trả về đơn đã tạo trước đó chứ không tạo trùng.
    public CreatedOrder createOrder(Map<String, Object> body) {
        GhnResponse<CreatedData> response = call(() -> restClient.post()
                .uri("/v2/shipping-order/create")
                .headers(h -> {
                    h.set("Token", token);
                    h.set("ShopId", shopId);
                })
                .contentType(MediaType.APPLICATION_JSON)
                .body(body)
                .retrieve()
                .body(new ParameterizedTypeReference<GhnResponse<CreatedData>>() { }));
        CreatedData data = response.data();
        if (data == null || data.orderCode() == null) {
            throw new GhnException("GHN không trả về mã vận đơn.");
        }
        return new CreatedOrder(data.orderCode(), data.totalFee(), data.expectedDeliveryTime());
    }

    // GET /v2/shipping-order/detail-by-client-code
    public OrderInfo orderByClientCode(String clientOrderCode) {
        GhnResponse<InfoData> response = get("/v2/shipping-order/detail-by-client-code?client_order_code=" + clientOrderCode,
                new ParameterizedTypeReference<GhnResponse<InfoData>>() { });
        InfoData data = response.data();
        if (data == null) {
            throw new GhnException("GHN không có đơn " + clientOrderCode + ".");
        }
        return new OrderInfo(data.orderCode(), data.status(), data.leadtime());
    }

    // POST /v2/switch-status/cancel; chỉ dùng để gỡ đơn GHN vừa tạo khi bước chuyển trạng thái phía mình thất bại
    public void cancel(String orderCode) {
        call(() -> restClient.post()
                .uri("/v2/switch-status/cancel")
                .headers(h -> {
                    h.set("Token", token);
                    h.set("ShopId", shopId);
                })
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("order_codes", List.of(orderCode), "reason_code", "GHN-CANCEL-OTHER",
                        "reason", "Huỷ do lỗi đồng bộ trạng thái đơn ở cửa hàng"))
                .retrieve()
                .body(new ParameterizedTypeReference<GhnResponse<Object>>() { }));
    }

    private <T> GhnResponse<T> get(String path, ParameterizedTypeReference<GhnResponse<T>> type) {
        return call(() -> restClient.get()
                .uri(path)
                .headers(h -> {
                    h.set("Token", token);
                    h.set("ShopId", shopId);
                })
                .retrieve()
                .body(type));
    }

    private <T> GhnResponse<T> call(java.util.function.Supplier<GhnResponse<T>> request) {
        if (!isConfigured()) {
            throw new GhnException("Chưa cấu hình GHN (petfood.ghn.token, petfood.ghn.shop-id trong .env).");
        }
        try {
            GhnResponse<T> response = request.get();
            if (response == null) {
                throw new GhnException("GHN không trả về dữ liệu.");
            }
            return response;
        } catch (RestClientResponseException e) {
            // GHN báo lỗi nghiệp vụ bằng HTTP 4xx kèm JSON {code, message, code_message_value}
            String message = readMessage(e);
            // ghi cả thân phản hồi: câu báo lỗi cho người dùng thường chung chung ("Sai thông tin đầu vào"),
            // chi tiết thật nằm ở trường "message"
            log.warn("GHN trả lỗi {}: {} | {}", e.getStatusCode().value(), message, e.getResponseBodyAsString());
            throw new GhnException(message);
        } catch (RestClientException e) {
            log.warn("Không gọi được GHN: {}", e.getMessage());
            throw new GhnException("Không kết nối được GHN, thử lại sau.");
        }
    }

    private static String readMessage(RestClientResponseException e) {
        try {
            GhnResponse<?> body = e.getResponseBodyAs(GhnResponse.class);
            if (body != null) {
                String message = body.codeMessageValue() != null && !body.codeMessageValue().isBlank()
                        ? body.codeMessageValue() : body.message();
                if (message != null && !message.isBlank()) {
                    // "Lỗi gọi API: corev2_... - Đơn hàng không tồn tại": phần có nghĩa nằm sau dấu '-' cuối
                    int dash = message.lastIndexOf(" - ");
                    return dash >= 0 ? message.substring(dash + 3) : message;
                }
            }
        } catch (RuntimeException ignored) {
            // thân lỗi không phải JSON: dùng thông báo chung bên dưới
        }
        return "GHN từ chối yêu cầu (HTTP " + e.getStatusCode().value() + ").";
    }

    private static List<Area> areas(GhnResponse<List<RawArea>> response) {
        if (response.data() == null) {
            return List.of();
        }
        return response.data().stream()
                .filter(a -> a.status() == null || a.status() == 1)          // 1 = đang hoạt động
                .map(a -> new Area(a.id(), a.name()))
                .sorted(Comparator.comparing(Area::name))
                .toList();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record GhnResponse<T>(Integer code, String message,
                          @JsonProperty("code_message_value") String codeMessageValue,
                          T data) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record RawArea(@JsonProperty("_id") int id, String name, Integer status) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record CreatedData(@JsonProperty("order_code") String orderCode,
                       @JsonProperty("total_fee") Long totalFee,
                       @JsonProperty("expected_delivery_time") String expectedDeliveryTime) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record InfoData(@JsonProperty("order_code") String orderCode, String status, String leadtime) {
    }
}
