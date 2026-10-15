package com.isp392.petfood.repository;

import com.isp392.petfood.entity.OrderItemLot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderItemLotRepository extends JpaRepository<OrderItemLot, Long> {

    // Lô đã xuất cho từng dòng của một đơn, kèm HSD lô (chi tiết đơn, cộng trả khi huỷ)
    @Query("""
            select x from OrderItemLot x
            join fetch x.lot
            join fetch x.orderItem i
            where i.order.id = :orderId
            order by i.id, x.lot.expiryDate, x.lot.id
            """)
    List<OrderItemLot> findByOrderId(@Param("orderId") Long orderId);
}
