package com.isp392.petfood.controller;

import com.isp392.petfood.enums.Role;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

// Số dòng trong giỏ cho link "Giỏ hàng (n)" trên thanh đầu trang của khách (common/_header.jspf).
// Guest / Staff / Admin không có giỏ: null.
@ControllerAdvice
@RequiredArgsConstructor
public class CartCountAdvice {

    private final CartService cartService;

    @ModelAttribute("cartItemCount")
    public Long cartItemCount(@AuthenticationPrincipal AccountPrincipal user) {
        if (user == null || user.getRole() != Role.CUSTOMER) {
            return null;
        }
        return cartService.countLines(user.getCustomerId());
    }
}
