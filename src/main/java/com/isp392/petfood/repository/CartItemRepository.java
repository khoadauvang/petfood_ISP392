package com.isp392.petfood.repository;

import com.isp392.petfood.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CartItemRepository extends JpaRepository<CartItem, Long> {

    // Các dòng trong giỏ của một khách, lấy luôn sản phẩm + danh mục + suất Flash Sale + lô trong 1 câu (tránh N+1).
    // left join: dòng giá thường không có suất Flash Sale.
    @Query("""
            select i from CartItem i
            join fetch i.product p
            join fetch p.category
            left join fetch i.flashSaleItem fsi
            left join fetch fsi.flashSale
            left join fetch fsi.lot
            where i.cart.customer.id = :customerId
            order by i.addedAt asc, i.id asc
            """)
    List<CartItem> findDetailedByCustomerId(@Param("customerId") Long customerId);

    // Dòng giá thường của một sản phẩm trong giỏ (tối đa 1 dòng, UX_CartItem_regular)
    Optional<CartItem> findByCart_IdAndProduct_IdAndFlashSaleItemIsNull(Long cartId, Long productId);

    // Dòng của một suất Flash Sale trong giỏ (tối đa 1 dòng, UX_CartItem_flash_sale)
    Optional<CartItem> findByCart_IdAndFlashSaleItem_Id(Long cartId, Long flashSaleItemId);

    // Chỉ lấy dòng thuộc giỏ của đúng khách đang đăng nhập: khách không sửa/xoá được dòng của người khác
    @Query("""
            select i from CartItem i
            join fetch i.product
            left join fetch i.flashSaleItem fsi
            left join fetch fsi.flashSale
            left join fetch fsi.lot
            where i.id = :id and i.cart.customer.id = :customerId
            """)
    Optional<CartItem> findOwnedById(@Param("id") Long id, @Param("customerId") Long customerId);

    // Tổng số lượng sản phẩm trong giỏ (cộng quantity mọi dòng), hiện trên icon giỏ ở thanh đầu trang
    @Query("select coalesce(sum(i.quantity), 0) from CartItem i where i.cart.customer.id = :customerId")
    long sumQuantityByCustomerId(@Param("customerId") Long customerId);
}
