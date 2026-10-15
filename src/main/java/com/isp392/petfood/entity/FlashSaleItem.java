package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

// Một suất Flash Sale: một lô cận hạn (mức RED, BR-63) bán giá sale_price, tối đa allocated_qty đơn vị (BR-66).
// DB chặn: một lô một lần mỗi chiến dịch (UQ_FlashSaleItem_sale_lot), 0 <= sold_qty <= allocated_qty.
@Entity
@Table(name = "FlashSaleItem")
@Getter
@Setter
@NoArgsConstructor
public class FlashSaleItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "fs_item_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "flash_sale_id", nullable = false)
    private FlashSale flashSale;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lot_id", nullable = false)
    private Lot lot;

    @Column(name = "sale_price", nullable = false, precision = 12, scale = 0)
    private BigDecimal salePrice;

    @Column(name = "allocated_qty", nullable = false)
    private Integer allocatedQty;

    // Chỉ tăng bằng UPDATE có điều kiện sold_qty + qty <= allocated_qty khi đặt hàng (BR-20), không set trực tiếp
    @Column(name = "sold_qty", nullable = false)
    private Integer soldQty = 0;

    // Số suất còn lại
    public int getRemainingQty() {
        return allocatedQty - soldQty;
    }
}
