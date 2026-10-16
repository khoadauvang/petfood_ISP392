package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReturnItem;
import org.springframework.data.jpa.repository.JpaRepository;
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

    // Dòng đơn đã nằm trong một yêu cầu trả hàng (mỗi dòng chỉ trả một lần, BR-32)
    @Query("select ri.orderItem.id from ReturnItem ri where ri.orderItem.order.id = :orderId")
    List<Long> findReturnedOrderItemIds(@Param("orderId") Long orderId);

    boolean existsByOrderItem_Id(Long orderItemId);

    // Tổng tiền đã hoàn của một đơn (các yêu cầu REFUNDED)
    @Query("""
            select coalesce(sum(ri.refundAmount), 0) from ReturnItem ri
            where ri.returnRequest.order.id = :orderId
              and ri.returnRequest.status = com.isp392.petfood.enums.ReturnStatus.REFUNDED
            """)
    BigDecimal sumRefundedOfOrder(@Param("orderId") Long orderId);
}
