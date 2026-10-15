package com.isp392.petfood.service;

import com.isp392.petfood.dto.CategoryForm;
import com.isp392.petfood.dto.CategoryRow;
import com.isp392.petfood.entity.Category;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.PetType;
import com.isp392.petfood.enums.Species;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CategoryRepository;
import com.isp392.petfood.repository.ProductRepository;
import com.isp392.petfood.repository.ProductRepository.CategoryCountRow;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

// Quản lý danh mục (FR-09): thêm, sửa, ẩn/hiện, xoá danh mục chưa có sản phẩm
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Transactional(readOnly = true)
    public List<CategoryRow> listAll() {
        // Đếm sản phẩm của mọi danh mục bằng 1 câu GROUP BY, không đếm từng danh mục
        Map<Long, Long> productCounts = productRepository.countGroupByCategory().stream()
                .collect(Collectors.toMap(CategoryCountRow::getCategoryId, CategoryCountRow::getTotal));

        return categoryRepository.findAllByOrderByIdAsc().stream()
                .map(category -> new CategoryRow(category, productCounts.getOrDefault(category.getId(), 0L)))
                .toList();
    }

    @Transactional(readOnly = true)
    public CategoryForm getForm(Long id) {
        return CategoryForm.from(findOrThrow(id));
    }

    @Transactional
    public Category create(CategoryForm form) {
        if (categoryRepository.existsByNameIgnoreCase(form.getName())) {
            throw new BusinessRuleException("name", "Đã có danh mục tên \"" + form.getName() + "\"");
        }
        Category category = new Category();
        copy(form, category);
        return categoryRepository.save(category);
    }

    @Transactional
    public Category update(Long id, CategoryForm form) {
        Category category = findOrThrow(id);
        Map<String, String> errors = new LinkedHashMap<>();

        if (categoryRepository.existsByNameIgnoreCaseAndIdNot(form.getName(), id)) {
            errors.put("name", "Đã có danh mục khác tên \"" + form.getName() + "\"");
        }

        // Đổi danh mục sang chỉ DOG hoặc chỉ CAT mà bên trong còn sản phẩm của loài kia -> sản phẩm nằm sai chỗ
        PetType newType = form.getPetType();
        if (newType != PetType.ALL && newType != category.getPetType()) {
            Species onlySpecies = Species.valueOf(newType.name());
            if (productRepository.existsByCategory_IdAndSpeciesNot(id, onlySpecies)) {
                errors.put("petType", "Danh mục đang có sản phẩm không dành cho "
                        + onlySpecies.getLabel().toLowerCase(Locale.ROOT)
                        + ", hãy chuyển các sản phẩm đó sang danh mục khác trước");
            }
        }

        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }
        copy(form, category);
        return category;       // entity đang được quản lý: Hibernate tự UPDATE khi transaction commit
    }

    // Ẩn <-> hiện. Ẩn danh mục thì sản phẩm của nó không hiện ở trang khách (ProductService lọc Category.status)
    @Transactional
    public Category toggleStatus(Long id) {
        Category category = findOrThrow(id);
        category.setStatus(category.getStatus() == CategoryStatus.ACTIVE
                ? CategoryStatus.HIDDEN
                : CategoryStatus.ACTIVE);
        return category;
    }

    // Chỉ xoá được danh mục chưa có sản phẩm nào; còn sản phẩm thì chỉ ẩn (khoá ngoại NO ACTION, xoá mềm)
    @Transactional
    public String delete(Long id) {
        Category category = findOrThrow(id);
        if (productRepository.existsByCategory_Id(id)) {
            throw new BusinessRuleException("Danh mục \"" + category.getName()
                    + "\" đang có sản phẩm nên không xoá được, chỉ có thể ẩn.");
        }
        categoryRepository.delete(category);
        return category.getName();
    }

    private Category findOrThrow(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy danh mục #" + id));
    }

    private static void copy(CategoryForm form, Category category) {
        category.setName(form.getName());
        category.setPetType(form.getPetType());
        category.setStatus(form.getStatus());
    }
}
