package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Order;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    // Lịch sử đơn của khách, mới nhất trước (IX_Orders_customer_created)
    Page<Order> findByCustomer_Id(Long customerId, Pageable pageable);

    // Lịch sử đơn của khách lọc theo nhóm trạng thái (tab "Chờ xác nhận", "Đang giao", ...)
    Page<Order> findByCustomer_IdAndStatusIn(Long customerId, Collection<OrderStatus> statuses, Pageable pageable);

    // Đơn của đúng khách đang đăng nhập (khách không xem được đơn người khác)
    Optional<Order> findByIdAndCustomer_Id(Long id, Long customerId);

    // Trang quản lý đơn của Staff: lọc trạng thái (null = tất cả), chỉ đơn khách đang yêu cầu huỷ, tìm theo mã đơn / email / tên / số điện thoại
    @Query(value = """
            select o from Order o join fetch o.customer c join fetch c.account a
            where (:status is null or o.status = :status)
              and (:cancelRequested = false
                   or (o.status = com.isp392.petfood.enums.OrderStatus.PROCESSING
                       and o.cancelReason is not null
                       and o.cancelReason not like '[REJECTED]%'))
              and (
                   (:orderId is null and :keyword is null)
                   or (:orderId is not null and o.id = :orderId)
                   or (:keyword is not null and (
                        a.email like concat('%', :keyword, '%')
                        or c.fullName like concat('%', :keyword, '%')
                        or c.phone like concat('%', :keyword, '%')
                   ))
              )
            """,
            countQuery = """
            select count(o) from Order o
            where (:status is null or o.status = :status)
              and (:cancelRequested = false
                   or (o.status = com.isp392.petfood.enums.OrderStatus.PROCESSING
                       and o.cancelReason is not null
                       and o.cancelReason not like '[REJECTED]%'))
              and (
                   (:orderId is null and :keyword is null)
                   or (:orderId is not null and o.id = :orderId)
                   or (:keyword is not null and (
                        o.customer.account.email like concat('%', :keyword, '%')
                        or o.customer.fullName like concat('%', :keyword, '%')
                        or o.customer.phone like concat('%', :keyword, '%')
                   ))
              )
            """)
    Page<Order> search(@Param("status") OrderStatus status,
                       @Param("cancelRequested") boolean cancelRequested,
                       @Param("orderId") Long orderId,
                       @Param("keyword") String keyword,
                       Pageable pageable);

    // Khoá dòng đơn khi đổi trạng thái: 2 nhân viên bấm "Xác nhận" cùng lúc thì người sau phải chờ,
    // rồi thấy đơn đã CONFIRMED và bị báo lỗi, không ghi đè lên nhau
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select o from Order o where o.id = :id")
    Optional<Order> findByIdForUpdate(@Param("id") Long id);

    long countByStatus(OrderStatus status);

    // ===== Hạng thành viên (BR-40, BR-41) =====
    interface CustomerAmountRow {
        Long getCustomerId();
        BigDecimal getAmount();
    }

    // Tiền hàng (không tính phí ship) của các đơn COMPLETED đã qua hạn trả hàng và không còn yêu cầu trả hàng đang xử lý
    @Query(value = """
            SELECT o.customer_id AS customerId, SUM(o.total_amount - o.shipping_fee) AS amount
            FROM dbo.Orders o
            WHERE o.order_status = N'COMPLETED' AND o.completed_at <= :cutoff
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.ReturnRequest rr
                  WHERE rr.order_id = o.order_id
                    AND rr.status IN (N'REQUESTED', N'APPROVED', N'RECEIVED', N'INSPECTED')
              )
            GROUP BY o.customer_id
            """, nativeQuery = true)
    List<CustomerAmountRow> sumSettledGoodsByCustomer(@Param("cutoff") LocalDateTime cutoff);

    // Tiền đã hoàn của yêu cầu trả hàng REFUNDED trên các đơn đó (bảng của module trả hàng)
    @Query(value = """
            SELECT o.customer_id AS customerId, SUM(ri.refund_amount) AS amount
            FROM dbo.ReturnItem ri
            JOIN dbo.ReturnRequest rr ON rr.return_id = ri.return_id
            JOIN dbo.Orders o ON o.order_id = rr.order_id
            WHERE rr.status = N'REFUNDED' AND ri.refund_amount IS NOT NULL
              AND o.order_status = N'COMPLETED' AND o.completed_at <= :cutoff
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.ReturnRequest rr2
                  WHERE rr2.order_id = o.order_id
                    AND rr2.status IN (N'REQUESTED', N'APPROVED', N'RECEIVED', N'INSPECTED')
              )
            GROUP BY o.customer_id
            """, nativeQuery = true)
    List<CustomerAmountRow> sumRefundsByCustomer(@Param("cutoff") LocalDateTime cutoff);

    // ===== Job thanh toán (module 5) =====
    // Đơn chưa thanh toán đặt trước mốc "before" theo phương thức, còn ở trạng thái status:
    //   VNPay quá thời gian giữ hàng 15 phút (BR-23) / COD chưa xác nhận sau 24 giờ (BR-27)
    @Query("""
            select o.id from Order o
            where o.paymentMethod = :method and o.status = :status
              and o.paymentStatus = com.isp392.petfood.enums.PaymentStatus.UNPAID
              and o.createdAt < :before
            order by o.createdAt
            """)
    List<Long> findUnpaidIdsCreatedBefore(@Param("method") PaymentMethod method,
                                          @Param("status") OrderStatus status,
                                          @Param("before") LocalDateTime before);
}
