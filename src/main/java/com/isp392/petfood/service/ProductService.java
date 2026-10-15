package com.isp392.petfood.service;

import com.isp392.petfood.dto.ProductCardDto;
import com.isp392.petfood.dto.ProductFilter;
import com.isp392.petfood.dto.CategoryOption;
import com.isp392.petfood.dto.ShopProductDto;
import com.isp392.petfood.entity.Category;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.entity.ProductImage;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CategoryRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.LotRepository.StockRow;
import com.isp392.petfood.repository.ProductImageRepository;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

// Phần sản phẩm phía khách (Guest/Customer): danh sách có tìm kiếm, lọc, phân trang và trang chi tiết.
@Service
@RequiredArgsConstructor
public class ProductService {

    private static final int PAGE_SIZE = 12;
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final ProductRepository productRepository;
    private final LotRepository lotRepository;
    private final ProductImageRepository productImageRepository;
    private final CategoryRepository categoryRepository;
    private final InventoryPolicy inventoryPolicy;   // mốc 90 ngày dùng chung với phía Staff

    // BR-12: cam kết hạn dùng tối thiểu (mặc định 90 ngày)
    public int getShelfLifeCommitmentDays() {
        return inventoryPolicy.getShelfLifeCommitmentDays();
    }

    // pageNumber tính từ 0 (đúng kiểu của Spring Data)
    @Transactional(readOnly = true)
    public Page<ProductCardDto> search(ProductFilter filter, int pageNumber) {
        Pageable pageable = PageRequest.of(pageNumber, PAGE_SIZE, Sort.by("id"));

        Page<Product> products = productRepository.searchForShop(
                blankToNull(filter.getKeyword()),
                filter.getCategoryId(),
                filter.getSpecies(),
                filter.getAgeGroup(),
                blankToNull(filter.getBrand()),
                filter.getMinPrice(),
                filter.getMaxPrice(),
                pageable);

        Map<Long, StockRow> stockByProductId = loadSellableStock(
                products.getContent().stream().map(Product::getId).toList());

        // Page.map giữ nguyên thông tin phân trang, chỉ đổi kiểu phần tử Product -> ProductCardDto
        return products.map(p -> {
            StockRow stock = stockByProductId.get(p.getId());
            boolean inStock = stock != null && stock.getQuantity() > 0;
            return new ProductCardDto(
                    p.getId(),
                    p.getSku(),
                    p.getName(),
                    p.getBrand(),
                    p.getSellingPrice(),
                    p.getImageUrl(),
                    inStock,
                    inStock ? stock.getNearestExpiry().format(DATE) : null);
        });
    }

    // Chi tiết sản phẩm cho khách. Sản phẩm ngừng kinh doanh hoặc thuộc danh mục ẩn thì khách không xem được (404).
    @Transactional(readOnly = true)
    public ShopProductDto getDetail(Long id) {
        Product product = productRepository.findWithCategoryById(id)
                .filter(p -> p.getStatus() == ProductStatus.ACTIVE
                        && p.getCategory().getStatus() == CategoryStatus.ACTIVE)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy sản phẩm #" + id));

        List<String> imageUrls = productImageRepository.findByProduct_IdOrderBySortOrderAsc(id).stream()
                .map(ProductImage::getImageUrl)
                .toList();
        if (imageUrls.isEmpty() && product.getImageUrl() != null) {
            imageUrls = List.of(product.getImageUrl());     // dữ liệu cũ chưa có bảng ProductImage
        }

        StockRow stock = loadSellableStock(List.of(id)).get(id);
        long sellableQty = stock == null ? 0 : stock.getQuantity();
        LocalDate nearestExpiry = sellableQty > 0 ? stock.getNearestExpiry() : null;

        Category category = product.getCategory();
        return new ShopProductDto(
                product.getId(),
                product.getSku(),
                product.getName(),
                product.getBrand(),
                product.getDescription(),
                category.getId(),
                category.getName(),
                product.getSpecies().getLabel(),
                product.getAgeGroup().getLabel(),
                product.getSellingPrice(),
                imageUrls,
                sellableQty,
                nearestExpiry == null ? null : nearestExpiry.format(DATE),
                nearestExpiry == null ? null : inventoryPolicy.daysLeft(nearestExpiry));
    }

    // ===== Dữ liệu cho các ô lọc =====
    @Transactional(readOnly = true)
    public List<CategoryOption> listShopCategories() {
        return categoryRepository.findByStatusOrderByNameAsc(CategoryStatus.ACTIVE).stream()
                .map(c -> new CategoryOption(c.getId(), c.getName()))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<String> listShopBrands() {
        return productRepository.findShopBrands();
    }

    // productId -> tồn bán thường + HSD lô gần nhất. Sản phẩm không có lô đạt điều kiện thì không có trong map.
    private Map<Long, StockRow> loadSellableStock(List<Long> productIds) {
        if (productIds.isEmpty()) {
            return Map.of();
        }
        return lotRepository.sumSellableQuantity(productIds, inventoryPolicy.minSellableExpiry()).stream()
                .collect(Collectors.toMap(StockRow::getProductId, Function.identity()));
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
