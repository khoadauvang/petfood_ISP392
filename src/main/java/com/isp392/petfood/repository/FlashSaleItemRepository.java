package com.isp392.petfood.repository;

import com.isp392.petfood.entity.FlashSaleItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
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

    // Huỷ đơn / tái nhập kho: trả suất lại cho Flash Sale
    @Modifying(flushAutomatically = true)
    @Query("update FlashSaleItem f set f.soldQty = f.soldQty - :qty where f.id = :id and f.soldQty >= :qty")
    int unsell(@Param("id") Long id, @Param("qty") int qty);

    // ===== Quản lý chiến dịch (module 6) =====

    // Các suất của một chiến dịch, kèm lô và sản phẩm
    @Query("""
            select fsi from FlashSaleItem fsi
            join fetch fsi.lot l
            join fetch l.product
            where fsi.flashSale.id = :saleId
            order by l.expiryDate, fsi.id
            """)
    List<FlashSaleItem> findBySaleId(@Param("saleId") Long saleId);

    // Các suất gắn với một lô hàng (để kiểm tra trước khi sửa/xoá/tiêu huỷ lô)
    @Query("""
            select fsi from FlashSaleItem fsi
            join fetch fsi.flashSale fs
            where fsi.lot.id = :lotId
            """)
    List<FlashSaleItem> findByLotId(@Param("lotId") Long lotId);

    boolean existsByLot_Id(Long lotId);

    // Một lô chỉ xuất hiện một lần trong một chiến dịch (UQ_FlashSaleItem_sale_lot)
    boolean existsByFlashSale_IdAndLot_Id(Long saleId, Long lotId);

    // Số lượng của lô đang được dành cho các chiến dịch KHÁC chưa kết thúc (phần chưa bán), để không dành trùng (BR-66, BR-68)
    @Query("""
            select coalesce(sum(fsi.allocatedQty - fsi.soldQty), 0) from FlashSaleItem fsi
            where fsi.lot.id = :lotId
              and fsi.flashSale.id <> :excludeSaleId
              and fsi.flashSale.status <> com.isp392.petfood.enums.FlashSaleStatus.ENDED
              and fsi.allocatedQty > fsi.soldQty
            """)
    long reservedByOtherSales(@Param("lotId") Long lotId, @Param("excludeSaleId") Long excludeSaleId);

    // Số suất còn lại của chiến dịch (= 0 thì bán hết, scheduler kết thúc chiến dịch)
    @Query("select coalesce(sum(fsi.allocatedQty - fsi.soldQty), 0) from FlashSaleItem fsi where fsi.flashSale.id = :saleId")
    long remainingOfSale(@Param("saleId") Long saleId);

    long countByFlashSale_Id(Long saleId);

    // ===== Trang Flash Sale & Khuyến mãi cho khách =====
    // Suất đang mở bán: chiến dịch ACTIVE trong khung giờ, còn suất, sản phẩm/danh mục đang bán, lô chưa vào diện cách ly (< 21 ngày).
    // Tầng Service sẽ lọc chi tiết theo loại chiến dịch (FLASH_SALE: lô RED 21-89 ngày; PROMOTION: lô OK >= 90 ngày).
    @Query("""
            select fsi from FlashSaleItem fsi
            join fetch fsi.flashSale fs
            join fetch fsi.lot l
            join fetch l.product p
            join fetch p.category c
            where fs.status = com.isp392.petfood.enums.FlashSaleStatus.ACTIVE
              and fs.startTime <= :now and fs.endTime > :now
              and fsi.soldQty < fsi.allocatedQty
              and l.onHandQty > 0
              and l.expiryDate >= :minExpiry
              and p.status = com.isp392.petfood.enums.ProductStatus.ACTIVE
              and c.status = com.isp392.petfood.enums.CategoryStatus.ACTIVE
              and (:productId is null or p.id = :productId)
            order by fs.endTime, l.expiryDate, fsi.id
            """)
    List<FlashSaleItem> findRunningOffers(@Param("now") LocalDateTime now,
                                          @Param("minExpiry") LocalDate minExpiry,
                                          @Param("maxExpiry") LocalDate maxExpiry,
                                          @Param("productId") Long productId);

    // ===== BẢNG 1: Mặt hàng đang Flash Sale (Staff/Admin) =====
    @Query("""
            select fsi from FlashSaleItem fsi
            join fetch fsi.flashSale fs
            join fetch fsi.lot l
            join fetch l.product p
            where fs.status in (com.isp392.petfood.enums.FlashSaleStatus.ACTIVE, com.isp392.petfood.enums.FlashSaleStatus.DRAFT)
            order by fs.status asc, fs.endTime desc, fsi.id desc
            """)
    List<FlashSaleItem> findActiveFlashSaleProducts();
}
