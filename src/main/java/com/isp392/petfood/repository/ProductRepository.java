package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.ProductStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {

    // Spring Data tự sinh câu query từ TÊN method, không cần viết JPQL:
    //   ... where product.status = ? and category.status = ?
    // "Category_Status" nghĩa là đi qua quan hệ Product.category rồi lấy Category.status.
    // Trả về Page nên Spring tự chạy thêm 1 câu count để biết tổng số trang.
    Page<Product> findByStatusAndCategory_Status(ProductStatus status,
                                                 CategoryStatus categoryStatus,
                                                 Pageable pageable);
}