package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {

    // 5 ảnh của một sản phẩm theo vị trí 1..5
    List<ProductImage> findByProduct_IdOrderBySortOrderAsc(Long productId);
}
