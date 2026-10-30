package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReturnItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface ReturnItemRepository extends JpaRepository<ReturnItem, Long> {

    @Query("""
            select ri from ReturnItem ri
            join fetch ri.orderItem oi
            join fetch oi.product
            left join fetch oi.flashSaleItem
            where ri.returnRequest.id = :returnId
            order by ri.id
            """)
    List<ReturnItem> findByReturnId(@Param("returnId") Long returnId);

    // Dòng đơn đã nằm trong một yêu cầu trả hàng hợp lệ (không tính yêu cầu đã bị REJECTED để khách có thể gửi lại, BR-32)
    @Query("""
            select ri.orderItem.id from ReturnItem ri
            where ri.orderItem.order.id = :orderId
              and ri.returnRequest.status <> com.isp392.petfood.enums.ReturnStatus.REJECTED
            """)
    List<Long> findReturnedOrderItemIds(@Param("orderId") Long orderId);

    // Xoá dòng ReturnItem thuộc yêu cầu đã bị từ chối (REJECTED) trước khi tạo yêu cầu mới cho cùng order_item_id (tránh đụng UQ_ReturnItem_order_item_id)
    @Modifying
    @Query("""
            delete from ReturnItem ri
            where ri.orderItem.id = :orderItemId
              and ri.returnRequest.status = com.isp392.petfood.enums.ReturnStatus.REJECTED
            """)
    int deleteRejectedByOrderItemId(@Param("orderItemId") Long orderItemId);

    boolean existsByOrderItem_Id(Long orderItemId);

    // Kiểm tra dòng đơn đã được trả đủ số lượng và hoàn tiền (REFUNDED) hay chưa
    @Query("""
            select case when count(ri) > 0 then true else false end
            from ReturnItem ri
            where ri.orderItem.id = :orderItemId
              and ri.returnRequest.status = com.isp392.petfood.enums.ReturnStatus.REFUNDED
              and ri.quantity >= ri.orderItem.quantity
            """)
    boolean existsRefundedFullItem(@Param("orderItemId") Long orderItemId);

    // Tổng tiền đã hoàn của một đơn (các yêu cầu REFUNDED)
    @Query("""
            select coalesce(sum(ri.refundAmount), 0) from ReturnItem ri
            where ri.returnRequest.order.id = :orderId
              and ri.returnRequest.status = com.isp392.petfood.enums.ReturnStatus.REFUNDED
            """)
    BigDecimal sumRefundedOfOrder(@Param("orderId") Long orderId);
}
