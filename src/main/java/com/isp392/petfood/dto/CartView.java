package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Toàn bộ giỏ hàng cho trang /cart
@Getter
@AllArgsConstructor
public class CartView {
    private final List<CartLineDto> lines;
    private final BigDecimal subtotal;        // tổng tạm tính các dòng hợp lệ, chưa trừ giảm giá hạng, chưa có phí ship
    private final int totalQuantity;          // tổng số sản phẩm của các dòng hợp lệ
    private final boolean hasProblems;        // còn dòng hết hàng / vượt tồn / Flash Sale đã đóng
    private final String tierLabel;           // hạng thành viên hiện tại của khách (Đồng, Bạc, ...)
    private final BigDecimal tierDiscountRate; // % giảm của hạng (3 = 3%), chỉ áp cho dòng giá thường (BR-43)
}
