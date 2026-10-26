package com.isp392.petfood.repository;

import com.isp392.petfood.entity.OrderItem;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    // Các dòng của một đơn, kèm sản phẩm và suất Flash Sale (nếu có)
    @Query("""
            select i from OrderItem i
            join fetch i.product
            left join fetch i.flashSaleItem fsi
            left join fetch fsi.flashSale
            where i.order.id = :orderId
            order by i.id
            """)
    List<OrderItem> findDetailedByOrderId(@Param("orderId") Long orderId);

    // Các dòng (kèm sản phẩm) của nhiều đơn, 1 câu cho cả trang lịch sử đơn
    @Query("""
            select i from OrderItem i
            join fetch i.product
            where i.order.id in :orderIds
            order by i.order.id, i.id
            """)
    List<OrderItem> findWithProductByOrderIds(@Param("orderIds") Collection<Long> orderIds);

    // Số dòng + tổng số lượng của nhiều đơn (trang danh sách đơn), 1 câu cho cả trang
    interface OrderCountRow {
        Long getOrderId();
        Long getLineCount();
        Long getTotalQuantity();
    }

    @Query("""
            select i.order.id as orderId, count(i) as lineCount, sum(i.quantity) as totalQuantity
            from OrderItem i
            where i.order.id in :orderIds
            group by i.order.id
            """)
    List<OrderCountRow> countByOrderIds(@Param("orderIds") Collection<Long> orderIds);

    // Sản phẩm bán chạy cho trang chủ: tổng số lượng trên đơn đã giao thành công, chỉ sản phẩm khách đang xem được
    @Query("""
            select i.product.id from OrderItem i
            where i.order.status = com.isp392.petfood.enums.OrderStatus.COMPLETED
              and i.product.status = com.isp392.petfood.enums.ProductStatus.ACTIVE
              and i.product.category.status = com.isp392.petfood.enums.CategoryStatus.ACTIVE
            group by i.product.id
            order by sum(i.quantity) desc
            """)
    List<Long> findBestSellerIds(Pageable pageable);
}
