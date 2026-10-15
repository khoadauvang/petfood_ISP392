package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Lot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

public interface LotRepository extends JpaRepository<Lot, Long> {

    // Kết quả mỗi dòng: (productId, quantity). Tên getter khớp với alias trong câu query bên dưới.
    interface StockRow {
        Long getProductId();
        Long getQuantity();
    }

    // Tồn bán thường của một nhóm sản phẩm: chỉ cộng các lô còn hạn >= minExpiry (BR-54).
    // Chạy 1 câu cho cả trang, tránh gọi 12 lần (mỗi sản phẩm một lần).
    @Query("""
            select l.product.id as productId, sum(l.onHandQty) as quantity
            from Lot l
            where l.product.id in :productIds
              and l.expiryDate >= :minExpiry
            group by l.product.id
            """)
    List<StockRow> sumSellableQuantity(@Param("productIds") Collection<Long> productIds,
                                       @Param("minExpiry") LocalDate minExpiry);
}