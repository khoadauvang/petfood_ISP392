package com.isp392.petfood.controller;

import com.isp392.petfood.service.FlashSaleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

// Mục Flash Sale riêng cho khách (Guest xem được, BR-65). Thêm vào giỏ: POST /cart/add với flashSaleItemId.
@Controller
@RequiredArgsConstructor
public class FlashSaleController {

    private final FlashSaleService flashSaleService;

    @GetMapping("/flash-sale")
    public String list(Model model) {
        model.addAttribute("offers", flashSaleService.runningOffers(null));
        return "product/flash-sale";
    }
}
