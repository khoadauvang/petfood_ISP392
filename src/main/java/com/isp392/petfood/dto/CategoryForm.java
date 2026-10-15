package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Category;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.PetType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Form thêm / sửa danh mục. name của input trên JSP: name, petType, status
@Getter
@Setter
public class CategoryForm {

    @NotBlank(message = "Vui lòng nhập tên danh mục")
    @Size(max = 100, message = "Tên danh mục tối đa 100 ký tự")
    private String name;

    @NotNull(message = "Vui lòng chọn loại thú cưng")
    private PetType petType;

    @NotNull(message = "Vui lòng chọn trạng thái")
    private CategoryStatus status = CategoryStatus.ACTIVE;

    // Đổ dữ liệu có sẵn vào form sửa
    public static CategoryForm from(Category category) {
        CategoryForm form = new CategoryForm();
        form.setName(category.getName());
        form.setPetType(category.getPetType());
        form.setStatus(category.getStatus());
        return form;
    }
}
