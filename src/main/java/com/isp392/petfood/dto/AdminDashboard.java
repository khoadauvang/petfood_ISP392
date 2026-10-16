package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

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

    @Getter
    @AllArgsConstructor
    public static class DayRevenue {
        private final String dayText;
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
}
