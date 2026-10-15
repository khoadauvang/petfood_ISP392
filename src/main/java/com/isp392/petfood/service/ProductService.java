package com.isp392.petfood.service;

import com.isp392.petfood.dto.ProductCardDto;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.LotRepository.StockRow;
import com.isp392.petfood.repository.ProductRepository;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductService {

    private static final int PAGE_SIZE = 12;

    private final ProductRepository productRepository;
    private final LotRepository lotRepository;

    // BR-12: cam kết hạn dùng tối thiểu (mặc định 90 ngày), đọc từ application.properties
    @Getter
    @Value("${petfood.shelf-life-commitment-days:90}")
    private int shelfLifeCommitmentDays;

    // pageNumber tính từ 0 (đúng kiểu của Spring Data)
    @Transactional(readOnly = true)
    public Page<ProductCardDto> getProductPage(int pageNumber) {
        Pageable pageable = PageRequest.of(pageNumber, PAGE_SIZE, Sort.by("id"));

        // Chỉ hiện sản phẩm đang bán và thuộc danh mục không bị ẩn
        Page<Product> products = productRepository.findByStatusAndCategory_Status(
                ProductStatus.ACTIVE, CategoryStatus.ACTIVE, pageable);

        Map<Long, Long> stockByProductId = loadSellableStock(products.getContent());

        // Page.map giữ nguyên thông tin phân trang, chỉ đổi kiểu phần tử Product -> ProductCardDto
        return products.map(p -> new ProductCardDto(
                p.getId(),
                p.getSku(),
                p.getName(),
                p.getBrand(),
                p.getSellingPrice(),
                p.getImageUrl(),
                stockByProductId.getOrDefault(p.getId(), 0L) > 0));
    }

    // productId -> tồn bán thường. Sản phẩm không có lô đạt điều kiện thì không có trong map (= 0).
    private Map<Long, Long> loadSellableStock(List<Product> products) {
        if (products.isEmpty()) {
            return Map.of();
        }
        List<Long> productIds = products.stream().map(Product::getId).toList();
        LocalDate minExpiry = LocalDate.now().plusDays(shelfLifeCommitmentDays);

        return lotRepository.sumSellableQuantity(productIds, minExpiry).stream()
                .collect(Collectors.toMap(StockRow::getProductId, StockRow::getQuantity));
    }
}