package com.isp392.petfood.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.isp392.petfood.entity.Payment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

// Làm việc với VNPay Sandbox (API v2.1.0):
//   - paymentUrl : tạo link sang trang thanh toán VNPay, ký HMAC-SHA512
//   - verify     : kiểm chữ ký dữ liệu VNPay gửi về (return URL, IPN). Chỉ tin dữ liệu có chữ ký đúng (BR-24)
//   - query      : API tra cứu giao dịch (querydr). Shop CHỦ ĐỘNG hỏi VNPay nên chạy được trên localhost,
//                  dùng trước khi tự huỷ đơn quá 15 phút để không huỷ nhầm đơn đã trả tiền (chốt 16/10, cách A)
// Mã TMN và secret đặt trong .env: petfood.vnpay.tmn-code, petfood.vnpay.hash-secret.
@Component
public class VnpayClient {

    private static final Logger log = LoggerFactory.getLogger(VnpayClient.class);
    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNP_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final String VERSION = "2.1.0";

    public enum QueryOutcome { PAID, NOT_PAID, UNKNOWN }

    public record QueryResult(QueryOutcome outcome, String responseCode, String transactionNo) {
    }

    private final String tmnCode;
    private final String hashSecret;
    private final String payUrl;
    private final String apiUrl;
    private final String returnUrl;
    private final int holdMinutes;
    private final RestClient restClient;

    public VnpayClient(@Value("${petfood.vnpay.tmn-code:}") String tmnCode,
                       @Value("${petfood.vnpay.hash-secret:}") String hashSecret,
                       @Value("${petfood.vnpay.pay-url}") String payUrl,
                       @Value("${petfood.vnpay.api-url}") String apiUrl,
                       @Value("${petfood.vnpay.return-url}") String returnUrl,
                       @Value("${petfood.vnpay.hold-minutes:15}") int holdMinutes) {
        this.tmnCode = tmnCode == null ? "" : tmnCode.trim();
        this.hashSecret = hashSecret == null ? "" : hashSecret.trim();
        this.payUrl = payUrl;
        this.apiUrl = apiUrl;
        this.returnUrl = returnUrl;
        this.holdMinutes = holdMinutes;
        HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(http);
        factory.setReadTimeout(Duration.ofSeconds(10));
        this.restClient = RestClient.builder().requestFactory(factory).build();
    }

    public boolean isConfigured() {
        return !tmnCode.isEmpty() && !hashSecret.isEmpty();
    }

    public int getHoldMinutes() {
        return holdMinutes;
    }

    // Giờ VN, tròn giây: dùng làm Payment.created_at = vnp_CreateDate (querydr cần gửi lại đúng giá trị này)
    public static LocalDateTime nowVn() {
        return LocalDateTime.now(VN).withNano(0);
    }

    // Hạn giữ hàng của đơn VNPay, tính từ lần thanh toán đầu tiên (giờ VN)
    public LocalDateTime holdUntil(LocalDateTime firstAttemptAt) {
        return firstAttemptAt.plusMinutes(holdMinutes);
    }

    // Đổi giờ VN sang epoch millis cho đồng hồ đếm ngược trên trình duyệt
    public static long toEpochMillis(LocalDateTime vnTime) {
        return vnTime.atZone(VN).toInstant().toEpochMilli();
    }

    // Link sang trang thanh toán. Cùng một lần thanh toán thì tạo lại bao nhiêu lần cũng ra cùng một link (cùng mã,
    // cùng hạn), nên nút "Tiếp tục thanh toán" dùng lại được. expireAt = hạn giữ hàng của đơn, không phải của lần này.
    public String paymentUrl(Payment payment, LocalDateTime expireAt, String clientIp) {
        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", VERSION);
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", toVnpAmount(payment.getAmount()));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", payment.getVnpTxnRef());
        params.put("vnp_OrderInfo", orderInfo(payment));
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl);
        params.put("vnp_IpAddr", clientIp);
        params.put("vnp_CreateDate", payment.getCreatedAt().format(VNP_DATE));
        params.put("vnp_ExpireDate", expireAt.format(VNP_DATE));

        String query = encode(params);
        return payUrl + "?" + query + "&vnp_SecureHash=" + hmac(query);
    }

    // Kiểm chữ ký các tham số VNPay gửi về (bỏ vnp_SecureHash, vnp_SecureHashType; sắp xếp; ký lại; so sánh)
    public boolean verify(Map<String, String> received) {
        if (!isConfigured()) {
            return false;
        }
        String given = received.get("vnp_SecureHash");
        if (given == null) {
            return false;
        }
        Map<String, String> params = new TreeMap<>();
        received.forEach((k, v) -> {
            if (k.startsWith("vnp_") && !k.equals("vnp_SecureHash") && !k.equals("vnp_SecureHashType")) {
                params.put(k, v);
            }
        });
        return constantTimeEquals(hmac(encode(params)), given);
    }

    public static String toVnpAmount(BigDecimal amount) {
        return amount.multiply(BigDecimal.valueOf(100)).toBigInteger().toString();   // VNPay tính theo đơn vị 1/100
    }

    // Tra cứu kết quả một giao dịch (querydr). Chỉ coi là đã trả tiền khi VNPay trả mã thành công VÀ chữ ký đúng.
    public QueryResult query(Payment payment, String serverIp) {
        String requestId = UUID.randomUUID().toString().replace("-", "").substring(0, 20);
        String createDate = nowVn().format(VNP_DATE);
        String transactionDate = payment.getCreatedAt().format(VNP_DATE);
        String orderInfo = "Tra cuu " + payment.getVnpTxnRef();
        String data = String.join("|", requestId, VERSION, "querydr", tmnCode, payment.getVnpTxnRef(),
                transactionDate, createDate, serverIp, orderInfo);

        Map<String, String> body = new LinkedHashMap<>();
        body.put("vnp_RequestId", requestId);
        body.put("vnp_Version", VERSION);
        body.put("vnp_Command", "querydr");
        body.put("vnp_TmnCode", tmnCode);
        body.put("vnp_TxnRef", payment.getVnpTxnRef());
        body.put("vnp_OrderInfo", orderInfo);
        body.put("vnp_TransactionDate", transactionDate);
        body.put("vnp_CreateDate", createDate);
        body.put("vnp_IpAddr", serverIp);
        body.put("vnp_SecureHash", hmac(data));

        QueryResponse r;
        try {
            r = restClient.post().uri(apiUrl).contentType(MediaType.APPLICATION_JSON).body(body)
                    .retrieve().body(QueryResponse.class);
        } catch (RestClientException e) {
            log.warn("Không gọi được VNPay querydr cho {}: {}", payment.getVnpTxnRef(), e.getMessage());
            return new QueryResult(QueryOutcome.UNKNOWN, null, null);
        }
        if (r == null) {
            return new QueryResult(QueryOutcome.UNKNOWN, null, null);
        }
        // 91: VNPay không có giao dịch này (khách chưa bấm thanh toán)
        if ("91".equals(r.vnp_ResponseCode())) {
            return new QueryResult(QueryOutcome.NOT_PAID, r.vnp_ResponseCode(), null);
        }
        if (!"00".equals(r.vnp_ResponseCode())) {
            log.warn("VNPay querydr {} trả mã {}: {}", payment.getVnpTxnRef(), r.vnp_ResponseCode(), r.vnp_Message());
            return new QueryResult(QueryOutcome.UNKNOWN, r.vnp_ResponseCode(), null);
        }
        if ("00".equals(r.vnp_TransactionStatus())) {
            if (!verifyQueryResponse(r)) {
                log.warn("VNPay querydr {}: chữ ký phản hồi không đúng, chưa ghi nhận thanh toán", payment.getVnpTxnRef());
                return new QueryResult(QueryOutcome.UNKNOWN, r.vnp_ResponseCode(), null);
            }
            if (!toVnpAmount(payment.getAmount()).equals(r.vnp_Amount())) {
                log.warn("VNPay querydr {}: số tiền {} không khớp", payment.getVnpTxnRef(), r.vnp_Amount());
                return new QueryResult(QueryOutcome.UNKNOWN, r.vnp_ResponseCode(), null);
            }
            return new QueryResult(QueryOutcome.PAID, r.vnp_TransactionStatus(), r.vnp_TransactionNo());
        }
        // Giao dịch có nhưng không thành công; đã quá hạn thanh toán nên không thể thành công nữa
        return new QueryResult(QueryOutcome.NOT_PAID, r.vnp_TransactionStatus(), r.vnp_TransactionNo());
    }

    private boolean verifyQueryResponse(QueryResponse r) {
        String data = Stream.of(r.vnp_ResponseId(), r.vnp_Command(), r.vnp_ResponseCode(), r.vnp_Message(),
                        r.vnp_TmnCode(), r.vnp_TxnRef(), r.vnp_Amount(), r.vnp_BankCode(), r.vnp_PayDate(),
                        r.vnp_TransactionNo(), r.vnp_TransactionType(), r.vnp_TransactionStatus(), r.vnp_OrderInfo(),
                        r.vnp_PromotionCode(), r.vnp_PromotionAmount())
                .map(v -> Objects.toString(v, ""))
                .collect(Collectors.joining("|"));
        return r.vnp_SecureHash() != null && constantTimeEquals(hmac(data), r.vnp_SecureHash());
    }

    // Nội dung thanh toán: chỉ chữ không dấu (VNPay yêu cầu)
    private static String orderInfo(Payment payment) {
        return "Thanh toan don hang " + payment.getOrder().getId();
    }

    // key=value&... theo thứ tự tên tham số, giá trị mã hoá URL (dùng chung cho chuỗi ký và query string)
    private static String encode(Map<String, String> sorted) {
        return sorted.entrySet().stream()
                .filter(e -> e.getValue() != null && !e.getValue().isEmpty())
                .map(e -> e.getKey() + "=" + URLEncoder.encode(e.getValue(), StandardCharsets.UTF_8))
                .collect(Collectors.joining("&"));
    }

    private String hmac(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(hashSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("Không ký được dữ liệu VNPay", e);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        return MessageDigest.isEqual(a.toLowerCase().getBytes(StandardCharsets.US_ASCII),
                b.toLowerCase().getBytes(StandardCharsets.US_ASCII));
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record QueryResponse(String vnp_ResponseId, String vnp_Command, String vnp_ResponseCode, String vnp_Message,
                         String vnp_TmnCode, String vnp_TxnRef, String vnp_Amount, String vnp_BankCode,
                         String vnp_PayDate, String vnp_TransactionNo, String vnp_TransactionType,
                         String vnp_TransactionStatus, String vnp_OrderInfo, String vnp_PromotionCode,
                         String vnp_PromotionAmount, String vnp_SecureHash) {
    }
}
