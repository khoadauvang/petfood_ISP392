package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ProductReview;
import com.isp392.petfood.enums.ReviewStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {

    // Mỗi dòng đơn một đánh giá (UQ_ProductReview_order_item_id)
    Optional<ProductReview> findByOrderItem_Id(Long orderItemId);

    // Dòng đơn nào đã có đánh giá (trang chi tiết đơn hiện "Đánh giá" / "Sửa đánh giá")
    @Query("select r.orderItem.id from ProductReview r where r.orderItem.id in :orderItemIds")
    List<Long> findReviewedOrderItemIds(@Param("orderItemIds") Collection<Long> orderItemIds);

    // Đánh giá đang hiện của một sản phẩm, mới nhất trước (trang chi tiết sản phẩm)
    @Query("""
            select r from ProductReview r join fetch r.customer
            where r.product.id = :productId and r.status = com.isp392.petfood.enums.ReviewStatus.VISIBLE
            order by r.createdAt desc, r.id desc
            """)
    List<ProductReview> findVisibleByProduct(@Param("productId") Long productId);

    // Trang quản lý đánh giá: lọc trạng thái, chỉ đánh giá chưa phản hồi, tìm theo tên / SKU sản phẩm
    @Query(value = """
            select r from ProductReview r join fetch r.product p join fetch r.customer c
            where (:status is null or r.status = :status)
              and (:unreplied = false or not exists (select 1 from ReviewReply rr where rr.review = r))
              and (:keyword is null or p.name like concat('%', :keyword, '%') or concat(p.sku, '-', p.variant) like concat('%', :keyword, '%'))
            """,
            countQuery = """
            select count(r) from ProductReview r
            where (:status is null or r.status = :status)
              and (:unreplied = false or not exists (select 1 from ReviewReply rr where rr.review = r))
              and (:keyword is null or r.product.name like concat('%', :keyword, '%')
                   or concat(r.product.sku, '-', r.product.variant) like concat('%', :keyword, '%'))
            """)
    Page<ProductReview> search(@Param("status") ReviewStatus status,
                               @Param("unreplied") boolean unreplied,
                               @Param("keyword") String keyword,
                               Pageable pageable);
}
