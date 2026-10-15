package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một dòng trong trang giỏ hàng. Giá là giá hiện tại (chưa chốt, BR-10): giá thường = Product.selling_price,
// dòng Flash Sale = FlashSaleItem.sale_price.
@Getter
@AllArgsConstructor
public class CartLineDto {
    private final Long id;                 // cart_item_id
    private final Long productId;
    private final String sku;
    private final String name;
    private final String imageUrl;
    private final boolean flashSale;
    private final String flashSaleName;    // null với dòng giá thường
    private final String expiryNote;       // dòng Flash Sale: "HSD 09/11/2026 (còn 25 ngày)" (BR-65); null với dòng thường
    private final BigDecimal regularPrice;
    private final BigDecimal unitPrice;
    private final int quantity;
    private final BigDecimal lineTotal;
    private final int availableQty;        // số lượng tối đa dòng này được mua lúc này (BR-13)
    private final String problem;          // null nếu dòng hợp lệ; có giá trị thì phải sửa trước khi đặt hàng
}
