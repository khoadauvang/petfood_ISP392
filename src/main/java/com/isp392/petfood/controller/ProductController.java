package com.isp392.petfood.controller;

import com.isp392.petfood.dto.FlashSaleOffer;
import com.isp392.petfood.dto.ProductCardDto;
import com.isp392.petfood.dto.ProductFilter;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.Species;
import com.isp392.petfood.service.FlashSaleService;
import com.isp392.petfood.service.ProductService;
import com.isp392.petfood.service.ReviewService;
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

import java.util.List;

// Trang sản phẩm phía khách. Guest xem được (SecurityConfig permitAll "/" và "/products/**", BR-07).
//   GET /                     trang chủ (product/list.jsp của nhóm FE): banner + sản phẩm bán chạy & mới về
//   GET /products             danh sách (product/products.jsp): tìm theo từ khoá, lọc danh mục / loài / độ tuổi /
//                             thương hiệu / khoảng giá
//   GET /products/{id}        chi tiết: 5 ảnh, mô tả, tồn bán thường, HSD lô gần nhất
@Controller
@RequiredArgsConstructor
public class ProductController {

    private static final int FEATURED_COUNT = 8;

    private final ProductService productService;
    private final ReviewService reviewService;
    private final FlashSaleService flashSaleService;

    @InitBinder("filter")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    // Trên URL, page tính từ 1 cho người dùng; Spring Data tính từ 0 nên trừ 1 ở đây.
    // BindingResult đứng ngay sau filter: ô gõ sai kiểu (giá "abc", species lạ) chỉ bị bỏ qua thay vì lỗi 400.
    // Trang chủ: "featuredProducts" là tên FE dùng trong product/list.jsp
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("featuredProducts", productService.featuredProducts(FEATURED_COUNT));
        model.addAttribute("flashSaleOffers", flashSaleService.runningOffers(null));
        return "product/list";   // -> /WEB-INF/views/product/list.jsp
    }

    @GetMapping("/products")
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
        return "product/products";   // -> /WEB-INF/views/product/products.jsp
    }

    @GetMapping("/products/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        var product = productService.getDetail(id);
        model.addAttribute("product", product);   // không bán / không có -> 404
        model.addAttribute("variants", productService.getVariants(id));
        model.addAttribute("reviewSummary", reviewService.productReviews(id));
        model.addAttribute("flashSaleOffers", flashSaleService.runningOffers(id));
        model.addAttribute("shelfLifeDays", productService.getShelfLifeCommitmentDays());

        // Đề xuất sản phẩm cùng danh mục (khoảng 3 dòng = 12 sản phẩm)
        ProductFilter filter = new ProductFilter();
        filter.setCategoryId(product.getCategoryId());
        List<ProductCardDto> related = productService.search(filter, 0).getContent().stream()
                .filter(p -> !p.getId().equals(id))
                .limit(12)
                .toList();
        if (related.size() < 4) {
            var existingIds = related.stream()
                    .map(ProductCardDto::getId)
                    .collect(java.util.stream.Collectors.toSet());
            existingIds.add(id);

            List<ProductCardDto> featured = productService.featuredProducts(12).stream()
                    .filter(p -> !existingIds.contains(p.getId()))
                    .toList();
            related = java.util.stream.Stream.concat(related.stream(), featured.stream()).limit(12).toList();
        }
        // Đưa sản phẩm hết hàng xuống cuối
        related = related.stream()
                .sorted(java.util.Comparator.comparing(ProductCardDto::isInStock).reversed())
                .toList();
        model.addAttribute("relatedProducts", related);

        return "product/detail";
    }
}
