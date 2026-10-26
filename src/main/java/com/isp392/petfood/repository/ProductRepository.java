package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {

    // Spring Data tự sinh câu query từ TÊN method, không cần viết JPQL:
    //   ... where product.status = ? and category.status = ?
    // "Category_Status" nghĩa là đi qua quan hệ Product.category rồi lấy Category.status.
    // Trả về Page nên Spring tự chạy thêm 1 câu count để biết tổng số trang.
    Page<Product> findByStatusAndCategory_Status(ProductStatus status,
                                                 CategoryStatus categoryStatus,
                                                 Pageable pageable);

    // ===== Trang sản phẩm của khách (Guest/Customer) =====
    // Chỉ sản phẩm đang bán thuộc danh mục không bị ẩn. Tham số nào null thì bỏ qua điều kiện đó.
    // Lọc độ tuổi YOUNG/ADULT/SENIOR thì lấy luôn sản phẩm ALL_AGES (dùng được cho mọi lứa tuổi).
    @Query("""
            select p from Product p join p.category c
            where p.status = com.isp392.petfood.enums.ProductStatus.ACTIVE
              and c.status = com.isp392.petfood.enums.CategoryStatus.ACTIVE
              and (:keyword is null
                   or p.name like concat('%', :keyword, '%')
                   or p.brand like concat('%', :keyword, '%')
                   or concat(p.sku, '-', p.variant) like concat('%', :keyword, '%'))
              and (:categoryId is null or c.id = :categoryId)
              and (:species is null or p.species = :species)
              and (:ageGroup is null or p.ageGroup = :ageGroup
                   or p.ageGroup = com.isp392.petfood.enums.AgeGroup.ALL_AGES)
              and (:brand is null or p.brand = :brand)
              and (:minPrice is null or p.sellingPrice >= :minPrice)
              and (:maxPrice is null or p.sellingPrice <= :maxPrice)
            """)
    Page<Product> searchForShop(@Param("keyword") String keyword,
                                @Param("categoryId") Long categoryId,
                                @Param("species") Species species,
                                @Param("ageGroup") AgeGroup ageGroup,
                                @Param("brand") String brand,
                                @Param("minPrice") BigDecimal minPrice,
                                @Param("maxPrice") BigDecimal maxPrice,
                                Pageable pageable);

    // Danh sách thương hiệu cho ô lọc: chỉ lấy thương hiệu của sản phẩm khách đang thấy được
    @Query("""
            select distinct p.brand from Product p
            where p.brand is not null
              and p.status = com.isp392.petfood.enums.ProductStatus.ACTIVE
              and p.category.status = com.isp392.petfood.enums.CategoryStatus.ACTIVE
            order by p.brand
            """)
    List<String> findShopBrands();

    // ===== Kiểm tra trùng trước khi lưu (DB vẫn là chốt chặn cuối bằng UNIQUE) =====
    // (sku, variant) là UNIQUE: RC-KITTEN36 + 400G
    boolean existsBySkuAndVariant(String sku, String variant);

    boolean existsBySkuAndVariantAndIdNot(String sku, String variant, Long id);   // khi sửa: bỏ qua chính nó

    boolean existsByBarcode(String barcode);

    boolean existsByBarcodeAndIdNot(String barcode, Long id);

    // ===== Dùng khi sửa / xoá danh mục =====
    boolean existsByCategory_Id(Long categoryId);

    // Danh mục còn sản phẩm KHÁC loài species không (đổi pet_type của danh mục sang DOG/CAT)
    boolean existsByCategory_IdAndSpeciesNot(Long categoryId, Species species);

    // Kết quả mỗi dòng: (categoryId, total) — số sản phẩm của từng danh mục
    interface CategoryCountRow {
        Long getCategoryId();
        Long getTotal();
    }

    @Query("""
            select p.category.id as categoryId, count(p) as total
            from Product p
            group by p.category.id
            """)
    List<CategoryCountRow> countGroupByCategory();

    // ===== Trang quản lý sản phẩm của Staff/Admin =====
    // Tham số nào null thì bỏ qua điều kiện đó. "join fetch" lấy luôn Category trong 1 câu (tránh N+1).
    // Có join fetch nên phải tự viết countQuery (câu count không được fetch).
    @Query(value = """
            select p from Product p join fetch p.category c
            where (:keyword is null
                   or p.name like concat('%', :keyword, '%')
                   or concat(p.sku, '-', p.variant) like concat('%', :keyword, '%')
                   or p.barcode like concat('%', :keyword, '%')
                   or p.brand like concat('%', :keyword, '%'))
              and (:categoryId is null or c.id = :categoryId)
              and (:species is null or p.species = :species)
              and (:status is null or p.status = :status)
            """,
            countQuery = """
            select count(p) from Product p
            where (:keyword is null
                   or p.name like concat('%', :keyword, '%')
                   or concat(p.sku, '-', p.variant) like concat('%', :keyword, '%')
                   or p.barcode like concat('%', :keyword, '%')
                   or p.brand like concat('%', :keyword, '%'))
              and (:categoryId is null or p.category.id = :categoryId)
              and (:species is null or p.species = :species)
              and (:status is null or p.status = :status)
            """)
    Page<Product> search(@Param("keyword") String keyword,
                         @Param("categoryId") Long categoryId,
                         @Param("species") Species species,
                         @Param("status") ProductStatus status,
                         Pageable pageable);

    @Query("select p from Product p join fetch p.category where p.id = :id")
    Optional<Product> findWithCategoryById(@Param("id") Long id);

    // Danh sách chọn sản phẩm ở form nhập lô
    List<Product> findAllByOrderBySkuAscVariantAsc();

    // ===== Cảnh báo tồn thấp (BR-62) =====
    // Tồn bán thường = tổng on_hand các lô còn hạn >= minExpiry (cùng cách tính với trang chủ, BR-54).
    // left join: sản phẩm chưa có lô nào vẫn được xét (tồn = 0).
    // Chỉ xét sản phẩm đang bán: sản phẩm ngừng kinh doanh không cần nhập thêm.
    interface LowStockView {
        Long getProductId();
        String getSku();
        String getName();
        String getImageUrl();
        Integer getThreshold();
        Long getSellableQty();
        Long getOnHandQty();
    }

    @Query("""
            select p.id as productId, concat(p.sku, '-', p.variant) as sku, p.name as name, p.imageUrl as imageUrl,
                   p.lowStockThreshold as threshold,
                   coalesce(sum(case when l.expiryDate >= :minExpiry then l.onHandQty else 0 end), 0) as sellableQty,
                   coalesce(sum(l.onHandQty), 0) as onHandQty
            from Product p left join Lot l on l.product = p
            where p.status = :status
            group by p.id, p.sku, p.variant, p.name, p.imageUrl, p.lowStockThreshold
            having coalesce(sum(case when l.expiryDate >= :minExpiry then l.onHandQty else 0 end), 0)
                   <= p.lowStockThreshold
            """)
    List<LowStockView> findLowStock(@Param("status") ProductStatus status,
                                    @Param("minExpiry") LocalDate minExpiry);
}
