package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Lot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
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
                   or concat(p.sku, '-', p.variant) like concat('%', :keyword, '%')
                   or p.name like concat('%', :keyword, '%'))
              and l.onHandQty >= :minOnHand
              and (:maxOnHand is null or l.onHandQty <= :maxOnHand)
              and (:expiryBefore is null or l.expiryDate < :expiryBefore)
            """,
            countQuery = """
            select count(l) from Lot l
            where (:productId is null or l.product.id = :productId)
              and (:keyword is null
                   or concat(l.product.sku, '-', l.product.variant) like concat('%', :keyword, '%')
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

    // ===== Đặt hàng / huỷ đơn: trừ và cộng tồn an toàn khi nhiều đơn chạy cùng lúc (BR-20) =====

    // Lô còn hàng bán thường của một sản phẩm theo FEFO: HSD gần trước, cùng HSD thì lô nhập trước (BR-53).
    // Trả về số liệu đọc thẳng từ DB (không phải entity) nên không bị cache cũ của Hibernate.
    interface LotStock {
        Long getLotId();
        Integer getOnHandQty();
    }

    @Query("""
            select l.id as lotId, l.onHandQty as onHandQty
            from Lot l
            where l.product.id = :productId
              and l.expiryDate >= :minExpiry
              and l.onHandQty > 0
            order by l.expiryDate asc, l.receivedAt asc, l.id asc
            """)
    List<LotStock> findSellableFefo(@Param("productId") Long productId, @Param("minExpiry") LocalDate minExpiry);

    // Trừ tồn bằng MỘT câu UPDATE có điều kiện: chỉ trừ khi lô còn đủ và vẫn đủ hạn bán thường.
    // Trả về 0 nghĩa là đơn khác vừa lấy mất hàng của lô này -> service đọc lại và thử lô khác.
    @Modifying(flushAutomatically = true)
    @Query("""
            update Lot l set l.onHandQty = l.onHandQty - :qty
            where l.id = :lotId and l.onHandQty >= :qty and l.expiryDate >= :minExpiry
            """)
    int takeSellable(@Param("lotId") Long lotId, @Param("qty") int qty, @Param("minExpiry") LocalDate minExpiry);

    // Trừ tồn lô của suất Flash Sale (lô RED, không có điều kiện 90 ngày)
    @Modifying(flushAutomatically = true)
    @Query("update Lot l set l.onHandQty = l.onHandQty - :qty where l.id = :lotId and l.onHandQty >= :qty")
    int take(@Param("lotId") Long lotId, @Param("qty") int qty);

    // Cộng trả khi huỷ đơn; không bao giờ vượt số lượng đã nhập (CK_Lot_on_hand_qty)
    @Modifying(flushAutomatically = true)
    @Query("""
            update Lot l set l.onHandQty = l.onHandQty + :qty
            where l.id = :lotId and l.onHandQty + :qty <= l.receivedQty
            """)
    int putBack(@Param("lotId") Long lotId, @Param("qty") int qty);

    // ===== Flash Sale: lô cận hạn mức RED còn hàng (21 đến dưới 90 ngày, BR-63), để chọn khi tạo suất =====
    @Query("""
            select l from Lot l join fetch l.product p
            where l.onHandQty > 0 and l.expiryDate >= :minExpiry and l.expiryDate < :maxExpiry
            order by l.expiryDate, l.id
            """)
    List<Lot> findRedInStock(@Param("minExpiry") LocalDate minExpiry, @Param("maxExpiry") LocalDate maxExpiry);

    // Tổng số lô còn hàng trong kho
    @Query("select count(l) from Lot l where l.onHandQty > 0")
    long countInStock();
}
