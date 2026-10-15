package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Tổng tiền ở trang đặt hàng, tính cùng công thức với lúc tạo đơn:
//   tiền hàng = tạm tính − giảm giá hạng (chỉ dòng giá thường, BR-43);  tổng = tiền hàng + phí ship
@Getter
@AllArgsConstructor
public class CheckoutSummary {
    private final List<CartLineDto> lines;
    private final BigDecimal subtotal;          // giá hiện tại × số lượng, chưa giảm
    private final String tierLabel;
    private final BigDecimal tierRate;          // phần trăm, ví dụ 3.00 = 3%
    private final BigDecimal discountTotal;
    private final BigDecimal goodsTotal;
    private final ShippingQuote shipping;       // null khi khách chưa bấm "Tính phí giao hàng"
    private final String customerPhone;         // null -> phải cập nhật hồ sơ trước khi đặt

    public BigDecimal getTotal() {
        return shipping == null ? null : goodsTotal.add(shipping.getFee());
    }
}
