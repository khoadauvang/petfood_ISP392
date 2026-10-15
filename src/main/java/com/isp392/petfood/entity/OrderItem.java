package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

// Một dòng đơn. Giá chốt lúc đặt (BR-16). discount_amount = giảm theo hạng, chỉ cho dòng giá thường (BR-43).
// DB chặn: 0 <= discount_amount <= unit_price × quantity (CK_OrderItem_discount_amount).
@Entity
@Table(name = "OrderItem")
@Getter
@Setter
@NoArgsConstructor
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_item_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    // Có giá trị: dòng mua qua Flash Sale
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flash_sale_item_id")
    private FlashSaleItem flashSaleItem;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "unit_price", nullable = false, precision = 12, scale = 0)
    private BigDecimal unitPrice;

    @Column(name = "discount_amount", nullable = false, precision = 12, scale = 0)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    public OrderItem(Order order, Product product, FlashSaleItem flashSaleItem, int quantity,
                     BigDecimal unitPrice, BigDecimal discountAmount) {
        this.order = order;
        this.product = product;
        this.flashSaleItem = flashSaleItem;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.discountAmount = discountAmount;
    }

    // Số tiền khách trả cho dòng này (chưa gồm phí ship)
    public BigDecimal getLineTotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity)).subtract(discountAmount);
    }
}
