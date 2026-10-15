package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Lot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface LotRepository extends JpaRepository<Lot, Long> {

    // Kết quả mỗi dòng: (productId, quantity, nearestExpiry). Tên getter khớp với alias trong câu query bên dưới.
    interface StockRow {
        Long getProductId();
        Long getQuantity();
        LocalDate getNearestExpiry();   // HSD của lô bán thường gần nhất = lô sẽ xuất trước theo FEFO (BR-53)
    }

    // Tồn bán thường của một nhóm sản phẩm: chỉ cộng các lô còn hàng, còn hạn >= minExpiry (BR-54).
    // Chạy 1 câu cho cả trang, tránh gọi 12 lần (mỗi sản phẩm một lần).
    @Query("""
            select l.product.id as productId, sum(l.onHandQty) as quantity, min(l.expiryDate) as nearestExpiry
            from Lot l
            where l.product.id in :productIds
              and l.expiryDate >= :minExpiry
              and l.onHandQty > 0
            group by l.product.id
            """)
    List<StockRow> sumSellableQuantity(@Param("productIds") Collection<Long> productIds,
                                       @Param("minExpiry") LocalDate minExpiry);

    // Tồn thực tế (mọi lô) và tồn bán thường (lô còn hạn >= minExpiry) của nhiều sản phẩm trong 1 câu.
    interface StockSummaryRow {
        Long getProductId();
        Long getOnHandQty();
        Long getSellableQty();
    }

    @Query("""
            select l.product.id as productId,
                   sum(l.onHandQty) as onHandQty,
                   sum(case when l.expiryDate >= :minExpiry then l.onHandQty else 0 end) as sellableQty
            from Lot l
            where l.product.id in :productIds
            group by l.product.id
            """)
    List<StockSummaryRow> summarizeStock(@Param("productIds") Collection<Long> productIds,
                                         @Param("minExpiry") LocalDate minExpiry);

    boolean existsByProduct_Id(Long productId);

    @Query("select l from Lot l join fetch l.product where l.id = :id")
    Optional<Lot> findWithProductById(@Param("id") Long id);

    // Các lô của một sản phẩm theo thứ tự FEFO: hết hạn trước đứng trước, cùng hạn thì lô nhập trước (BR-53)
    List<Lot> findByProduct_IdOrderByExpiryDateAscIdAsc(Long productId);

    // ===== Trang "Tồn theo lô" =====
    // Tham số null thì bỏ qua điều kiện. minOnHand = 1 nghĩa là chỉ lấy lô còn hàng.
    @Query(value = """
            select l from Lot l join fetch l.product p
            where (:productId is null or p.id = :productId)
              and (:keyword is null
                   or p.sku like concat('%', :keyword, '%')
                   or p.name like concat('%', :keyword, '%'))
              and l.onHandQty >= :minOnHand
              and (:maxOnHand is null or l.onHandQty <= :maxOnHand)
              and (:expiryBefore is null or l.expiryDate < :expiryBefore)
            """,
            countQuery = """
            select count(l) from Lot l
            where (:productId is null or l.product.id = :productId)
              and (:keyword is null
                   or l.product.sku like concat('%', :keyword, '%')
                   or l.product.name like concat('%', :keyword, '%'))
              and l.onHandQty >= :minOnHand
              and (:maxOnHand is null or l.onHandQty <= :maxOnHand)
              and (:expiryBefore is null or l.expiryDate < :expiryBefore)
            """)
    Page<Lot> search(@Param("productId") Long productId,
                     @Param("keyword") String keyword,
                     @Param("minOnHand") int minOnHand,
                     @Param("maxOnHand") Integer maxOnHand,
                     @Param("expiryBefore") LocalDate expiryBefore,
                     Pageable pageable);

    // ===== Cảnh báo lô sắp hết hạn (BR-59) =====
    // Lô còn hàng có HSD trước mốc "before" (hôm nay + 90 ngày), gồm cả lô đã quá hạn mà chưa xử lý.
    @Query("""
            select l from Lot l join fetch l.product
            where l.onHandQty > 0 and l.expiryDate < :before
            order by l.expiryDate asc, l.id asc
            """)
    List<Lot> findInStockExpiringBefore(@Param("before") LocalDate before);
}
