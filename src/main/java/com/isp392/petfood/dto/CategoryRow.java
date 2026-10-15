package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Category;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.PetType;
import lombok.Getter;

// Một dòng ở trang danh sách danh mục (và option của ô chọn danh mục trong form sản phẩm)
@Getter
public class CategoryRow {

    private final Long id;
    private final String name;
    private final PetType petType;
    private final CategoryStatus status;
    private final long productCount;   // > 0 thì không cho xoá, chỉ cho ẩn

    public CategoryRow(Category category, long productCount) {
        this.id = category.getId();
        this.name = category.getName();
        this.petType = category.getPetType();
        this.status = category.getStatus();
        this.productCount = productCount;
    }
}
