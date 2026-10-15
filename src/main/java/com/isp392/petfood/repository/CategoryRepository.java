package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Category;
import com.isp392.petfood.enums.CategoryStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findAllByOrderByIdAsc();

    // Ô lọc danh mục ở trang của khách: chỉ danh mục đang hiện
    List<Category> findByStatusOrderByNameAsc(CategoryStatus status);

    // Tên danh mục không trùng (DB không có UNIQUE cho cột name, nên BE tự kiểm tra)
    boolean existsByNameIgnoreCase(String name);

    boolean existsByNameIgnoreCaseAndIdNot(String name, Long id);
}
