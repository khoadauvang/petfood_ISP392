package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ProductCardDto;
import com.isp392.petfood.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    // "/" là trang chủ. "/products" trỏ về cùng một trang (SecurityConfig đã permitAll cả hai).
    // Trên URL, page tính từ 1 cho người dùng; Spring Data tính từ 0 nên trừ 1 ở đây.
    @GetMapping({"/", "/products"})
    public String list(@RequestParam(defaultValue = "1") int page, Model model) {
        Page<ProductCardDto> result = productService.getProductPage(Math.max(page, 1) - 1);

        model.addAttribute("products", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("shelfLifeDays", productService.getShelfLifeCommitmentDays());
        return "product/list";   // -> /WEB-INF/views/product/list.jsp
    }
}