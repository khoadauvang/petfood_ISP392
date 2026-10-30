package com.isp392.petfood.service;

import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.entity.OrderItem;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentStatus;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.OrderItemRepository;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.service.GhnClient.Area;
import com.isp392.petfood.service.GhnClient.CreatedOrder;
import com.isp392.petfood.service.GhnClient.GhnException;
import com.isp392.petfood.service.GhnClient.OrderInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// Giao hàng qua GHN (chốt 30/10, thay LI-01 "vận chuyển mô phỏng"). Không thêm cột vào Orders:
//   - Địa chỉ đơn lưu một chuỗi "số nhà đường, phường/xã, tỉnh/thành" (2 phần cuối chọn từ danh mục GHN ở trang đặt hàng).
//   - Mã đơn gửi GHN (client_order_code) = <prefix>-<order_id>-<created_at yyMMddHHmmss>, tính lại được từ đơn nên
//     không cần lưu mã vận đơn GHN: tra cứu bằng detail-by-client-code. Thêm created_at để làm lại DB (id chạy lại từ 1)
//     không đụng đơn GHN cũ cùng mã.
// Staff bấm "Giao hàng" (PROCESSING -> SHIPPED) thì tạo đơn GHN. GHN báo giao xong (delivered) thì đơn COMPLETED,
// trả về shop (returned) thì RETURNED, qua webhook hoặc nút "Cập nhật từ GHN" của staff.
// Phí ship khách trả vẫn theo quy tắc của nhóm (ShippingFeeService); shop trả phí GHN (payment_type_id = 1).
// Chưa cấu hình GHN thì mọi thứ chạy như cũ: staff chuyển trạng thái tay.
@Service
public class GhnShippingService {

    private static final Logger log = LoggerFactory.getLogger(GhnShippingService.class);
    private static final DateTimeFormatter CODE_TIME = DateTimeFormatter.ofPattern("yyMMddHHmmss");
    private static final DateTimeFormatter DISPLAY_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Pattern VARIANT_WEIGHT = Pattern.compile("(\\d+(?:[.,]\\d+)?)\\s*(KG|G)", Pattern.CASE_INSENSITIVE);
    private static final int MAX_LIGHT_WEIGHT = 20_000;          // < 20kg: dịch vụ hàng nhẹ (service_type_id = 2)
    private static final int MAX_COD = 50_000_000;
    private static final Map<String, String> STATUS_LABELS = Map.ofEntries(
            Map.entry("ready_to_pick", "Chờ lấy hàng"),
            Map.entry("picking", "Shipper đang đến lấy hàng"),
            Map.entry("money_collect_picking", "Đang lấy hàng"),
            Map.entry("picked", "Đã lấy hàng"),
            Map.entry("storing", "Đang ở kho GHN"),
            Map.entry("sorting", "Đang phân loại"),
            Map.entry("transporting", "Đang luân chuyển"),
            Map.entry("delivering", "Đang giao hàng"),
            Map.entry("money_collect_delivering", "Đang giao hàng"),
            Map.entry("delivered", "Giao thành công"),
            Map.entry("delivery_fail", "Giao thất bại"),
            Map.entry("waiting_to_return", "Chờ trả hàng về shop"),
            Map.entry("return", "Chờ trả hàng về shop"),
            Map.entry("return_transporting", "Đang trả hàng về shop"),
            Map.entry("return_sorting", "Đang trả hàng về shop"),
            Map.entry("returning", "Đang trả hàng về shop"),
            Map.entry("return_fail", "Trả hàng thất bại"),
            Map.entry("returned", "Đã trả hàng về shop"),
            Map.entry("cancel", "Đơn GHN đã huỷ"),
            Map.entry("exception", "Sự cố, GHN đang xử lý"),
            Map.entry("lost", "Thất lạc"),
            Map.entry("damage", "Hư hỏng"));

    // Kết quả bấm "Giao hàng": ghnOrderCode null nghĩa là giao thủ công (không qua GHN)
    public record ShipResult(String ghnOrderCode, String expectedDelivery) {
    }

    // Thông tin vận đơn hiện ở trang chi tiết đơn; error != null khi không tra được GHN
    public record Shipment(String clientOrderCode, String orderCode, String status, String statusLabel,
                           String expectedDelivery, String error) {
    }

    private final GhnClient ghn;
    private final OrderService orderService;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final TransactionTemplate readOnlyTx;
    private final String codePrefix;
    private final int defaultItemWeight;
    private final int boxLength;
    private final int boxWidth;
    private final int boxHeight;
    private final String requiredNote;
    private final String webhookSecret;
    private final Map<String, String> sender;

    public GhnShippingService(GhnClient ghn, OrderService orderService, OrderRepository orderRepository,
                              OrderItemRepository orderItemRepository, PlatformTransactionManager transactionManager,
                              @Value("${petfood.ghn.order-code-prefix:PF}") String codePrefix,
                              @Value("${petfood.ghn.default-item-weight-grams:1000}") int defaultItemWeight,
                              @Value("${petfood.ghn.box-length-cm:30}") int boxLength,
                              @Value("${petfood.ghn.box-width-cm:20}") int boxWidth,
                              @Value("${petfood.ghn.box-height-cm:15}") int boxHeight,
                              @Value("${petfood.ghn.required-note:CHOXEMHANGKHONGTHU}") String requiredNote,
                              @Value("${petfood.ghn.webhook-secret:}") String webhookSecret,
                              @Value("${petfood.ghn.from-name:}") String fromName,
                              @Value("${petfood.ghn.from-phone:}") String fromPhone,
                              @Value("${petfood.ghn.from-address:}") String fromAddress,
                              @Value("${petfood.ghn.from-ward-name:}") String fromWard,
                              @Value("${petfood.ghn.from-province-name:}") String fromProvince) {
        this.ghn = ghn;
        this.orderService = orderService;
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.readOnlyTx = new TransactionTemplate(transactionManager);
        this.readOnlyTx.setReadOnly(true);
        this.codePrefix = codePrefix.trim();
        this.defaultItemWeight = defaultItemWeight;
        this.boxLength = boxLength;
        this.boxWidth = boxWidth;
        this.boxHeight = boxHeight;
        this.requiredNote = requiredNote;
        this.webhookSecret = webhookSecret == null ? "" : webhookSecret.trim();
        this.sender = new LinkedHashMap<>();
        if (!fromWard.isBlank() && !fromProvince.isBlank()) {
            sender.put("name", fromName.trim());
            sender.put("phone", fromPhone.trim());
            sender.put("address", fromAddress.trim());
            sender.put("ward_name", fromWard.trim());
            sender.put("province_name", fromProvince.trim());
        }
    }

    public boolean isEnabled() {
        return ghn.isConfigured();
    }

    // ===== Danh mục địa chỉ cho trang đặt hàng =====

    public List<Area> provinces() {
        return ghn.provinces();
    }

    public List<Area> wards(int provinceId) {
        return ghn.wards(provinceId);
    }

    // Trang đặt hàng có bắt chọn tỉnh/phường không: chỉ khi đã cấu hình GHN và tải được danh mục
    // (GHN lỗi thì khách vẫn đặt được bằng địa chỉ gõ tay như trước)
    public boolean isAddressPickerAvailable() {
        if (!ghn.isConfigured()) {
            return false;
        }
        try {
            return !ghn.provinces().isEmpty();
        } catch (GhnException e) {
            return false;
        }
    }

    // Phường/xã có thuộc tỉnh/thành trong danh mục GHN không (tên chuẩn, không phân biệt hoa thường)
    public boolean isValidArea(String provinceName, String wardName) {
        return findArea(provinceName, wardName).isPresent();
    }

    // ===== Staff: giao hàng, cập nhật trạng thái =====

    // PROCESSING -> SHIPPED và tạo đơn GHN. Lỗi từ GHN (địa chỉ cũ gõ tay, thiếu SĐT...) ném GhnException,
    // đơn giữ PROCESSING để staff sửa hoặc chọn giao thủ công (shipManually).
    public ShipResult ship(Long orderId) {
        if (!ghn.isConfigured()) {
            orderService.ship(orderId);
            return new ShipResult(null, null);
        }
        Map<String, Object> body = readOnlyTx.execute(s -> buildCreateBody(orderId));
        if (body == null) {
            orderService.ship(orderId);           // sai trạng thái: để OrderService báo lỗi đúng quy tắc BR-17
            return new ShipResult(null, null);
        }
        CreatedOrder created = ghn.createOrder(body);
        try {
            orderService.ship(orderId);
        } catch (RuntimeException e) {
            // đơn bên mình không chuyển được (ví dụ khách vừa gửi yêu cầu huỷ): gỡ đơn GHN vừa tạo
            try {
                ghn.cancel(created.orderCode());
            } catch (GhnException ex) {
                log.warn("Không huỷ được đơn GHN {} sau khi giao đơn #{} thất bại", created.orderCode(), orderId);
            }
            throw e;
        }
        log.info("Đơn #{} đã tạo vận đơn GHN {}", orderId, created.orderCode());
        return new ShipResult(created.orderCode(), formatTime(created.expectedDeliveryTime()));
    }

    // Giao thủ công, không tạo đơn GHN (GHN lỗi hoặc địa chỉ cũ không theo danh mục)
    public void shipManually(Long orderId) {
        orderService.ship(orderId);
    }

    // Hỏi GHN trạng thái hiện tại rồi chuyển đơn SHIPPED sang COMPLETED / RETURNED nếu GHN đã kết thúc.
    // Không tin dữ liệu webhook gửi tới: luôn tra lại GHN. Gọi nhiều lần không sao (đơn đã chuyển thì bỏ qua).
    // Trả về câu mô tả kết quả cho staff.
    public String sync(Long orderId) {
        Order order = readOnlyTx.execute(s -> orderRepository.findById(orderId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy đơn #" + orderId)));
        if (order.getStatus() != OrderStatus.SHIPPED) {
            return "Đơn #" + orderId + " không ở trạng thái đang giao, không cần cập nhật từ GHN.";
        }
        OrderInfo info = ghn.orderByClientCode(clientOrderCode(order));
        String label = label(info.status());
        switch (info.status()) {
            case "delivered" -> {
                orderService.complete(orderId);
                return "GHN đã giao thành công, đơn #" + orderId + " chuyển sang hoàn tất.";
            }
            case "returned" -> {
                orderService.markReturned(orderId, null);
                return "GHN đã trả hàng về shop, đơn #" + orderId + " ghi nhận khách không nhận hàng.";
            }
            default -> {
                return "Vận đơn GHN " + info.orderCode() + ": " + label + ".";
            }
        }
    }

    // Webhook GHN: chỉ nhận đơn của đúng shop, client_order_code đúng dạng của mình
    public void handleWebhook(Map<String, Object> payload) {
        Object shop = payload.get("ShopID");
        if (shop != null && !String.valueOf(shop).equals(ghn.getShopId())) {
            log.warn("Webhook GHN của shop khác ({}), bỏ qua", shop);
            return;
        }
        Object code = payload.get("ClientOrderCode");
        Long orderId = code == null ? null : orderIdFromCode(String.valueOf(code));
        if (orderId == null) {
            log.info("Webhook GHN không có mã đơn của cửa hàng: {}", payload.get("OrderCode"));
            return;
        }
        log.info("Webhook GHN đơn #{}: {}", orderId, payload.get("Status"));
        sync(orderId);
    }

    public boolean isWebhookSecretValid(String header) {
        return webhookSecret.isEmpty() || webhookSecret.equals(header);
    }

    // Vận đơn GHN của đơn đã giao; empty nếu chưa cấu hình GHN hoặc đơn chưa tới bước giao
    public Optional<Shipment> shipment(Long orderId) {
        if (!ghn.isConfigured()) {
            return Optional.empty();
        }
        Order order = readOnlyTx.execute(s -> orderRepository.findById(orderId).orElse(null));
        if (order == null || order.getShippedAt() == null) {
            return Optional.empty();
        }
        String clientCode = clientOrderCode(order);
        try {
            OrderInfo info = ghn.orderByClientCode(clientCode);
            return Optional.of(new Shipment(clientCode, info.orderCode(), info.status(), label(info.status()),
                    formatTime(info.leadtime()), null));
        } catch (GhnException e) {
            // đơn giao thủ công hoặc GHN lỗi: vẫn hiện trang, kèm lý do
            return Optional.of(new Shipment(clientCode, null, null, null, null, e.getMessage()));
        }
    }

    // ===== Nội bộ =====

    String clientOrderCode(Order order) {
        return codePrefix + "-" + order.getId() + "-" + order.getCreatedAt().format(CODE_TIME);
    }

    Long orderIdFromCode(String code) {
        Matcher m = Pattern.compile("^" + Pattern.quote(codePrefix) + "-(\\d+)-\\d{12}$").matcher(code);
        return m.matches() ? Long.valueOf(m.group(1)) : null;
    }

    // null nếu đơn không ở PROCESSING / đang chờ duyệt huỷ (để OrderService.ship báo lỗi)
    private Map<String, Object> buildCreateBody(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy đơn #" + orderId));
        if (order.getStatus() != OrderStatus.PROCESSING || order.isCancelRequested()) {
            return null;
        }
        Customer customer = order.getCustomer();
        if (customer.getPhone() == null || customer.getPhone().isBlank()) {
            throw new GhnException("Khách chưa có số điện thoại trong hồ sơ, GHN không nhận đơn.");
        }
        String[] parts = splitAddress(order.getShippingAddress());
        Area[] area = parts == null ? null : findArea(parts[2], parts[1]).orElse(null);
        if (area == null) {
            throw new GhnException("Địa chỉ đơn không theo danh mục phường/xã, tỉnh/thành của GHN "
                    + "(đơn đặt trước khi tích hợp GHN?).");
        }

        List<OrderItem> lines = orderItemRepository.findDetailedByOrderId(orderId);
        List<Map<String, Object>> items = new ArrayList<>();
        int totalWeight = 0;
        for (OrderItem line : lines) {
            int unitWeight = unitWeight(line.getProduct().getVariant());
            totalWeight += unitWeight * line.getQuantity();
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("name", line.getProduct().getName() + " " + line.getProduct().getVariant());
            item.put("code", line.getProduct().getFullSku());
            item.put("quantity", line.getQuantity());
            item.put("price", line.getUnitPrice().intValue());
            item.put("weight", unitWeight);
            item.put("length", boxLength);
            item.put("width", boxWidth);
            item.put("height", boxHeight);
            items.add(item);
        }
        boolean codUnpaid = order.getPaymentMethod() == PaymentMethod.COD && order.getPaymentStatus() == PaymentStatus.UNPAID;
        int cod = codUnpaid ? order.getTotalAmount().min(BigDecimal.valueOf(MAX_COD)).intValue() : 0;

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("client_order_code", clientOrderCode(order));
        body.put("to_name", customer.getFullName());
        body.put("to_phone", customer.getPhone().trim());
        body.put("to_address", order.getShippingAddress());
        body.put("to_ward_name", area[1].name());
        body.put("to_province_name", area[0].name());
        body.put("is_new_to_address", true);
        putSender(body);
        body.put("weight", Math.max(totalWeight, 1));
        body.put("length", boxLength);
        body.put("width", boxWidth);
        body.put("height", boxHeight);
        body.put("service_type_id", totalWeight < MAX_LIGHT_WEIGHT ? 2 : 5);
        body.put("payment_type_id", 1);                    // shop trả phí GHN; khách đã trả phí ship cho shop
        body.put("required_note", requiredNote);
        body.put("cod_amount", cod);
        body.put("content", "Thức ăn thú cưng - đơn #" + orderId);
        body.put("items", items);
        return body;
    }

    // Địa chỉ lấy hàng (from_*) và nhận hàng hoàn (return_*) theo mô hình 2 cấp, từ petfood.ghn.from-*.
    // Không cấu hình thì GHN lấy theo hồ sơ shop; hồ sơ shop dev bỏ trống địa chỉ thì GHN báo
    // "Chuyển đổi địa chỉ gửi không thành công".
    private void putSender(Map<String, Object> body) {
        if (sender.isEmpty()) {
            return;
        }
        for (String prefix : List.of("from_", "return_")) {
            sender.forEach((key, value) -> {
                if (!value.isEmpty()) {
                    body.put(prefix + key, value);
                }
            });
        }
        body.put("is_new_from_address", true);
        body.put("is_new_return_address", true);
    }

    // "số nhà đường, phường/xã, tỉnh/thành" -> [phần đầu, phường, tỉnh]; null nếu ít hơn 3 phần
    private static String[] splitAddress(String address) {
        if (address == null) {
            return null;
        }
        int last = address.lastIndexOf(',');
        int prev = last <= 0 ? -1 : address.lastIndexOf(',', last - 1);
        if (prev <= 0) {
            return null;
        }
        return new String[]{address.substring(0, prev).trim(), address.substring(prev + 1, last).trim(),
                address.substring(last + 1).trim()};
    }

    // [tỉnh, phường] trong danh mục GHN
    private Optional<Area[]> findArea(String provinceName, String wardName) {
        if (provinceName == null || wardName == null) {
            return Optional.empty();
        }
        Optional<Area> province = ghn.provinces().stream()
                .filter(p -> p.name().equalsIgnoreCase(provinceName.trim())).findFirst();
        if (province.isEmpty()) {
            return Optional.empty();
        }
        return ghn.wards(province.get().id()).stream()
                .filter(w -> w.name().equalsIgnoreCase(wardName.trim())).findFirst()
                .map(w -> new Area[]{province.get(), w});
    }

    // Khối lượng 1 sản phẩm theo quy cách: "2000G" -> 2000, "1.5KG" -> 1500; không đọc được thì dùng mặc định
    private int unitWeight(String variant) {
        if (variant != null) {
            Matcher m = VARIANT_WEIGHT.matcher(variant);
            if (m.find()) {
                double value = Double.parseDouble(m.group(1).replace(',', '.'));
                int grams = (int) Math.round(m.group(2).toUpperCase(Locale.ROOT).equals("KG") ? value * 1000 : value);
                if (grams > 0) {
                    return grams;
                }
            }
        }
        return defaultItemWeight;
    }

    private static String label(String status) {
        return status == null ? null : STATUS_LABELS.getOrDefault(status, status);
    }

    private static String formatTime(String iso) {
        if (iso == null || iso.isBlank()) {
            return null;
        }
        try {
            return OffsetDateTime.parse(iso).atZoneSameInstant(ZoneId.of("Asia/Ho_Chi_Minh")).format(DISPLAY_TIME);
        } catch (DateTimeParseException e) {
            return iso;
        }
    }
}
