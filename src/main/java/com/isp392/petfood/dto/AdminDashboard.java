package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

// Số liệu dashboard Admin cho một khoảng ngày (module 10, phần thêm)
@Getter
@AllArgsConstructor
public class AdminDashboard {
    private final long completedOrders;
    private final BigDecimal grossRevenue;      // tổng total_amount đơn COMPLETED (gồm phí ship)
    private final BigDecimal goodsRevenue;      // tiền hàng = gross - phí ship
    private final BigDecimal refunds;           // tiền đã hoàn trong kỳ
    private final BigDecimal netRevenue;        // gross - refunds
    private final long newCustomers;
    private final List<DayRevenue> dailyRevenue;
    private final List<Count> ordersByStatus;   // mọi trạng thái, kể cả 0
    private final List<TopProduct> topProducts;
    private final List<Count> customersByTier;  // mọi hạng, kể cả 0
    // Việc đang chờ xử lý (không phụ thuộc khoảng ngày)
    private final long pendingOrders;
    private final long requestedReturns;
    private final long newSupportTickets;
    // Toàn bộ đơn / khách (không phụ thuộc khoảng ngày): JS trên trang tự lọc theo các ô ngày riêng của từng tab
    // và so sánh với kỳ trước
    private final List<OrderAuditItem> allOrders;
    private final List<CustomerAuditItem> allCustomers;

    @Getter
    @AllArgsConstructor
    public static class DayRevenue {
        private final String date;              // yyyy-MM-dd
        private final String dayText;           // dd/MM
        private final long orderCount;
        private final BigDecimal amount;
        private final int barPercent;           // độ dài thanh so với ngày cao nhất (0-100)
    }

    @Getter
    @AllArgsConstructor
    public static class Count {
        private final String code;
        private final String label;
        private final long count;
    }

    @Getter
    @AllArgsConstructor
    public static class TopProduct {
        private final Long productId;
        private final String name;
        private final String sku;
        private final long quantity;
        private final BigDecimal revenue;
    }

    @Getter
    @AllArgsConstructor
    public static class OrderAuditItem {
        private final Long id;
        private final Long customerId;
        private final String customerTier;      // hạng hiện tại của khách
        private final String date;              // yyyy-MM-dd, ngày đặt
        private final String dayText;           // dd/MM
        private final String status;
        private final String pay;               // COD | VNPAY
        private final long total;
        private final long discount;
        private final Map<Long, Long> categoryAmounts;   // category_id -> tiền hàng sau giảm hạng

        public Map<Long, Long> getCats() {
            return categoryAmounts;
        }

        // JSP nhúng thẳng vào JS: {"<categoryId>":<tiền>,...}
        public String getCatsJson() {
            return categoryAmounts.entrySet().stream()
                    .map(e -> "\"" + e.getKey() + "\":" + e.getValue())
                    .collect(Collectors.joining(",", "{", "}"));
        }
    }

    @Getter
    @AllArgsConstructor
    public static class CustomerAuditItem {
        private final Long id;
        private final String fullName;
        private final String email;
        private final String phone;
        private final String avatarUrl;
        private final String tier;
        private final String createdAt;         // yyyy-MM-dd, ngày tạo tài khoản
    }
}
