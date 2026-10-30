package com.isp392.petfood.service;

import com.isp392.petfood.dto.AdminDashboard;
import com.isp392.petfood.enums.MembershipTier;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.ReturnStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.repository.DashboardRepository;
import com.isp392.petfood.repository.DashboardRepository.StatusCountRow;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.ReturnRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

// Dashboard thống kê cho Admin (module 10, phần thêm): doanh thu, đơn theo trạng thái, sản phẩm bán chạy,
// khách theo hạng và các việc đang chờ xử lý. Doanh thu chỉ tính đơn COMPLETED theo ngày hoàn tất.
@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("dd/MM");
    private static final int MAX_DAYS = 366;

    private final DashboardRepository dashboardRepository;
    private final OrderRepository orderRepository;
    private final ReturnRequestRepository returnRequestRepository;
    private final SupportService supportService;

    // from, to: ngày bắt đầu và kết thúc (tính cả ngày "to")
    @Transactional(readOnly = true)
    public AdminDashboard build(LocalDate from, LocalDate to) {
        if (from.isAfter(to)) {
            throw new BusinessRuleException("Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.");
        }
        if (ChronoUnit.DAYS.between(from, to) >= MAX_DAYS) {
            throw new BusinessRuleException("Chỉ xem được tối đa " + MAX_DAYS + " ngày một lần.");
        }
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end = to.plusDays(1).atStartOfDay();

        DashboardRepository.RevenueRow revenue = dashboardRepository.revenue(start, end);
        BigDecimal gross = revenue.getTotalAmount();
        BigDecimal refunds = dashboardRepository.refunds(start, end);

        List<DashboardRepository.DailyRevenueRow> days = dashboardRepository.dailyRevenue(start, end);
        BigDecimal maxDay = days.stream().map(DashboardRepository.DailyRevenueRow::getTotalAmount)
                .max(BigDecimal::compareTo).orElse(BigDecimal.ZERO);
        List<AdminDashboard.DayRevenue> daily = days.stream().map(d -> new AdminDashboard.DayRevenue(
                d.getDay().toString(), d.getDay().format(DAY), d.getOrderCount(), d.getTotalAmount(),
                percent(d.getTotalAmount(), maxDay))).toList();

        Map<String, Long> byStatus = toMap(dashboardRepository.ordersByStatus(start, end));
        List<AdminDashboard.Count> orders = Arrays.stream(OrderStatus.values())
                .map(s -> new AdminDashboard.Count(s.name(), s.getLabel(), byStatus.getOrDefault(s.name(), 0L))).toList();

        Map<String, Long> byTier = toMap(dashboardRepository.customersByTier());
        List<AdminDashboard.Count> tiers = Arrays.stream(MembershipTier.values())
                .map(t -> new AdminDashboard.Count(t.name(), t.getLabel(), byTier.getOrDefault(t.name(), 0L))).toList();

        List<AdminDashboard.TopProduct> top = dashboardRepository.topProducts(start, end).stream()
                .map(p -> new AdminDashboard.TopProduct(p.getProductId(), p.getName(), p.getSku(), p.getQuantity(),
                        p.getRevenue())).toList();

        return new AdminDashboard(revenue.getOrderCount(), gross, gross.subtract(revenue.getShippingFee()), refunds,
                gross.subtract(refunds), dashboardRepository.newCustomers(start, end), daily, orders, top, tiers,
                orderRepository.countByStatus(OrderStatus.PENDING),
                returnRequestRepository.countByStatus(ReturnStatus.REQUESTED),
                supportService.countNew(),
                allOrders(), allCustomers());
    }

    // 3 query cho toàn bộ dữ liệu (không tải entity từng đơn, tránh N+1)
    private List<AdminDashboard.OrderAuditItem> allOrders() {
        Map<Long, Map<Long, Long>> byCategory = new HashMap<>();
        for (DashboardRepository.OrderCategoryAmountRow r : dashboardRepository.orderCategoryAmounts()) {
            byCategory.computeIfAbsent(r.getOrderId(), id -> new HashMap<>())
                    .merge(r.getCategoryId(), r.getAmount().longValue(), Long::sum);
        }
        return dashboardRepository.allOrders().stream()
                .map(o -> new AdminDashboard.OrderAuditItem(o.getId(), o.getCustomerId(), o.getCustomerTier(), o.getDate(),
                        LocalDate.parse(o.getDate()).format(DAY), o.getStatus(), o.getPay(), o.getTotal().longValue(),
                        o.getDiscount() != null ? o.getDiscount().longValue() : 0L,
                        byCategory.getOrDefault(o.getId(), Map.of())))
                .toList();
    }

    private List<AdminDashboard.CustomerAuditItem> allCustomers() {
        return dashboardRepository.allCustomers().stream()
                .map(c -> new AdminDashboard.CustomerAuditItem(
                        c.getId(),
                        c.getFullName() != null ? c.getFullName() : "Khách hàng",
                        c.getEmail() != null ? c.getEmail() : "",
                        c.getPhone() != null ? c.getPhone() : "",
                        c.getAvatarUrl() != null ? c.getAvatarUrl() : "",
                        c.getTier(),
                        c.getCreatedAt()))
                .toList();
    }

    private static Map<String, Long> toMap(List<StatusCountRow> rows) {
        return rows.stream().collect(Collectors.toMap(StatusCountRow::getStatus, StatusCountRow::getCount));
    }

    private static int percent(BigDecimal value, BigDecimal max) {
        if (max.signum() == 0) {
            return 0;
        }
        return Math.max(1, value.multiply(BigDecimal.valueOf(100)).divide(max, 0, RoundingMode.HALF_UP).intValue());
    }
}
