package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Order;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

// Truy vấn thống kê cho dashboard Admin (module 10, phần thêm). Chỉ đọc, khoảng thời gian [from, to).
// Doanh thu tính theo đơn COMPLETED (giao thành công) theo ngày hoàn tất, không tính đơn huỷ / khách không nhận.
public interface DashboardRepository extends Repository<Order, Long> {

    interface RevenueRow {
        Long getOrderCount();
        BigDecimal getTotalAmount();
        BigDecimal getShippingFee();
    }

    interface DailyRevenueRow {
        LocalDate getDay();
        Long getOrderCount();
        BigDecimal getTotalAmount();
    }

    interface StatusCountRow {
        String getStatus();
        Long getCount();
    }

    interface TopProductRow {
        Long getProductId();
        String getName();
        String getSku();
        Long getQuantity();
        BigDecimal getRevenue();
    }

    @Query(value = """
            SELECT COUNT(*) AS orderCount, COALESCE(SUM(o.total_amount), 0) AS totalAmount,
                   COALESCE(SUM(o.shipping_fee), 0) AS shippingFee
            FROM dbo.Orders o
            WHERE o.order_status = N'COMPLETED' AND o.completed_at >= :from AND o.completed_at < :to
            """, nativeQuery = true)
    RevenueRow revenue(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    // Tiền đã hoàn (yêu cầu trả hàng REFUNDED trong kỳ) của các đơn đã giao thành công
    @Query(value = """
            SELECT COALESCE(SUM(ri.refund_amount), 0)
            FROM dbo.ReturnItem ri
            JOIN dbo.ReturnRequest rr ON rr.return_id = ri.return_id
            JOIN dbo.Orders o ON o.order_id = rr.order_id
            WHERE rr.status = N'REFUNDED' AND o.order_status = N'COMPLETED'
              AND rr.refunded_at >= :from AND rr.refunded_at < :to
            """, nativeQuery = true)
    BigDecimal refunds(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query(value = """
            SELECT CAST(o.completed_at AS DATE) AS day, COUNT(*) AS orderCount, SUM(o.total_amount) AS totalAmount
            FROM dbo.Orders o
            WHERE o.order_status = N'COMPLETED' AND o.completed_at >= :from AND o.completed_at < :to
            GROUP BY CAST(o.completed_at AS DATE)
            ORDER BY day
            """, nativeQuery = true)
    List<DailyRevenueRow> dailyRevenue(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    // Đơn đặt trong kỳ theo trạng thái hiện tại
    @Query(value = """
            SELECT o.order_status AS status, COUNT(*) AS count
            FROM dbo.Orders o
            WHERE o.created_at >= :from AND o.created_at < :to
            GROUP BY o.order_status
            """, nativeQuery = true)
    List<StatusCountRow> ordersByStatus(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    // Sản phẩm bán chạy: số lượng và tiền hàng (sau giảm hạng) trong các đơn giao thành công
    @Query(value = """
            SELECT TOP 5 p.product_id AS productId, p.name AS name, p.sku + N'-' + p.variant AS sku,
                   SUM(oi.quantity) AS quantity, SUM(oi.unit_price * oi.quantity - oi.discount_amount) AS revenue
            FROM dbo.OrderItem oi
            JOIN dbo.Orders o ON o.order_id = oi.order_id
            JOIN dbo.Product p ON p.product_id = oi.product_id
            WHERE o.order_status = N'COMPLETED' AND o.completed_at >= :from AND o.completed_at < :to
            GROUP BY p.product_id, p.name, p.sku, p.variant
            ORDER BY quantity DESC, revenue DESC
            """, nativeQuery = true)
    List<TopProductRow> topProducts(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query(value = """
            SELECT COUNT(*) FROM dbo.Account a
            WHERE a.role = N'CUSTOMER' AND a.created_at >= :from AND a.created_at < :to
            """, nativeQuery = true)
    long newCustomers(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    // ===== Dữ liệu thô cho biểu đồ tự lọc phía trình duyệt (tab doanh thu / hội viên) =====
    interface OrderAuditRow {
        Long getId();
        Long getCustomerId();
        String getCustomerTier();
        String getDate();
        String getStatus();
        String getPay();
        BigDecimal getTotal();
        BigDecimal getDiscount();
    }

    interface OrderCategoryAmountRow {
        Long getOrderId();
        Long getCategoryId();
        BigDecimal getAmount();
    }

    interface CustomerAuditRow {
        Long getId();
        String getFullName();
        String getEmail();
        String getPhone();
        String getAvatarUrl();
        String getTier();
        String getCreatedAt();
    }

    // Mọi đơn kèm hạng hiện tại của khách, mới nhất trước;
    // date = ngày hoàn tất (cho đơn COMPLETED để khớp KPI doanh thu) hoặc ngày đặt;
    // total = tiền hàng thực thu đã trừ tiền hoàn trả hàng REFUNDED (để khớp thống kê chi tiêu và doanh thu thuần).
    @Query(value = """
            SELECT o.order_id AS id, o.customer_id AS customerId, c.membership_tier AS customerTier,
                   CONVERT(char(10), COALESCE(o.completed_at, o.created_at), 23) AS date, o.order_status AS status,
                   o.payment_method AS pay,
                   (o.total_amount - COALESCE((
                       SELECT SUM(ri.refund_amount)
                       FROM dbo.ReturnItem ri
                       JOIN dbo.ReturnRequest rr ON rr.return_id = ri.return_id
                       WHERE rr.order_id = o.order_id AND rr.status = N'REFUNDED'
                   ), 0)) AS total,
                   COALESCE((SELECT SUM(oi.discount_amount) FROM dbo.OrderItem oi WHERE oi.order_id = o.order_id), 0) AS discount
            FROM dbo.Orders o
            JOIN dbo.Customer c ON c.customer_id = o.customer_id
            ORDER BY COALESCE(o.completed_at, o.created_at) DESC, o.order_id DESC
            """, nativeQuery = true)
    List<OrderAuditRow> allOrders();

    // Tiền hàng (sau giảm hạng) của từng đơn theo danh mục
    @Query(value = """
            SELECT oi.order_id AS orderId, p.category_id AS categoryId,
                   COALESCE(SUM(oi.unit_price * oi.quantity - oi.discount_amount), 0) AS amount
            FROM dbo.OrderItem oi
            JOIN dbo.Product p ON p.product_id = oi.product_id
            GROUP BY oi.order_id, p.category_id
            """, nativeQuery = true)
    List<OrderCategoryAmountRow> orderCategoryAmounts();

    @Query(value = """
            SELECT c.customer_id AS id, c.full_name AS fullName, a.email AS email, c.phone AS phone,
                   c.avatar_url AS avatarUrl, c.membership_tier AS tier, CONVERT(char(10), a.created_at, 23) AS createdAt
            FROM dbo.Customer c
            JOIN dbo.Account a ON a.account_id = c.account_id
            """, nativeQuery = true)
    List<CustomerAuditRow> allCustomers();

    // Số khách theo hạng thành viên hiện tại
    @Query(value = """
            SELECT c.membership_tier AS status, COUNT(*) AS count
            FROM dbo.Customer c
            GROUP BY c.membership_tier
            """, nativeQuery = true)
    List<StatusCountRow> customersByTier();
}
