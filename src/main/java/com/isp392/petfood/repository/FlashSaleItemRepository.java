package com.isp392.petfood.repository;

import com.isp392.petfood.entity.FlashSaleItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface FlashSaleItemRepository extends JpaRepository<FlashSaleItem, Long> {

    // Suất Flash Sale kèm chiến dịch, lô và sản phẩm của lô (để kiểm tra trước khi cho vào giỏ)
    @Query("""
            select fsi from FlashSaleItem fsi
            join fetch fsi.flashSale
            join fetch fsi.lot l
            join fetch l.product p
            join fetch p.category
            where fsi.id = :id
            """)
    Optional<FlashSaleItem> findDetailedById(@Param("id") Long id);

    // Bán suất Flash Sale: tăng sold_qty bằng một câu UPDATE có điều kiện (BR-20, ghi chú 9 trong script SQL).
    // Trả về 0 nghĩa là hết suất.
    @Modifying(flushAutomatically = true)
    @Query("""
            update FlashSaleItem f set f.soldQty = f.soldQty + :qty
            where f.id = :id and f.soldQty + :qty <= f.allocatedQty
            """)
    int sell(@Param("id") Long id, @Param("qty") int qty);

    // Huỷ đơn: trả suất lại cho Flash Sale
    @Modifying(flushAutomatically = true)
    @Query("update FlashSaleItem f set f.soldQty = f.soldQty - :qty where f.id = :id and f.soldQty >= :qty")
    int unsell(@Param("id") Long id, @Param("qty") int qty);
}
