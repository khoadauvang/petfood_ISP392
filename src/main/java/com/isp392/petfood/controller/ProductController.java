package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ProductCardDto;
import com.isp392.petfood.dto.ProductFilter;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.Species;
import com.isp392.petfood.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

// Trang sản phẩm phía khách. Guest xem được (SecurityConfig permitAll "/" và "/products/**", BR-07).
//   GET /  hoặc /products     danh sách: tìm theo từ khoá, lọc danh mục / loài / độ tuổi / thương hiệu / khoảng giá
//   GET /products/{id}        chi tiết: 5 ảnh, mô tả, tồn bán thường, HSD lô gần nhất
@Controller
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @InitBinder("filter")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    // Trên URL, page tính từ 1 cho người dùng; Spring Data tính từ 0 nên trừ 1 ở đây.
    // BindingResult đứng ngay sau filter: ô gõ sai kiểu (giá "abc", species lạ) chỉ bị bỏ qua thay vì lỗi 400.
    @GetMapping({"/", "/products"})
    public String list(@ModelAttribute("filter") ProductFilter filter,
                       BindingResult ignoredErrors,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        filter.normalize();
        Page<ProductCardDto> result = productService.search(filter, Math.max(page, 1) - 1);

        model.addAttribute("products", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());

        model.addAttribute("filterQuery", QueryStrings.of(
                "keyword", filter.getKeyword(),
                "categoryId", filter.getCategoryId(),
                "species", filter.getSpecies(),
                "ageGroup", filter.getAgeGroup(),
                "brand", filter.getBrand(),
                "minPrice", filter.getMinPrice() == null ? null : filter.getMinPrice().toPlainString(),
                "maxPrice", filter.getMaxPrice() == null ? null : filter.getMaxPrice().toPlainString()));

        model.addAttribute("categories", productService.listShopCategories());
        model.addAttribute("brands", productService.listShopBrands());
        model.addAttribute("speciesList", Species.values());
        model.addAttribute("ageGroups", AgeGroup.values());
        model.addAttribute("shelfLifeDays", productService.getShelfLifeCommitmentDays());
        return "product/list";   // -> /WEB-INF/views/product/list.jsp
    }

    @GetMapping("/products/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        model.addAttribute("product", productService.getDetail(id));   // không bán / không có -> 404
        model.addAttribute("shelfLifeDays", productService.getShelfLifeCommitmentDays());
        return "product/detail";
    }
}
