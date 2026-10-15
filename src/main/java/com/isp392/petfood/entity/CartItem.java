package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Một dòng trong giỏ. Hai loại dòng tách riêng (BR-65):
//   - flashSaleItem == null : dòng giá thường, mỗi sản phẩm tối đa một dòng (UX_CartItem_regular)
//   - flashSaleItem != null : dòng Flash Sale, mỗi suất tối đa một dòng (UX_CartItem_flash_sale)
// Cùng một sản phẩm có thể vừa có dòng giá thường vừa có dòng Flash Sale.
// Giá không lưu ở đây: giỏ luôn hiện giá hiện tại, giá chỉ chốt lúc đặt hàng (BR-10, BR-16).
@Entity
@Table(name = "CartItem")
@Getter
@Setter
@NoArgsConstructor
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cart_item_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "flash_sale_item_id")
    private FlashSaleItem flashSaleItem;

    // DB chặn: quantity > 0 (CK_CartItem_quantity)
    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "added_at", nullable = false, updatable = false)
    private LocalDateTime addedAt;

    public CartItem(Cart cart, Product product, FlashSaleItem flashSaleItem, int quantity) {
        this.cart = cart;
        this.product = product;
        this.flashSaleItem = flashSaleItem;
        this.quantity = quantity;
    }

    @PrePersist
    void onCreate() {
        if (addedAt == null) {
            addedAt = LocalDateTime.now();
        }
    }

    public boolean isFlashSale() {
        return flashSaleItem != null;
    }
}
