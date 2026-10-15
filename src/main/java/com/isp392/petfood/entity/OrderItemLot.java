package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// Dòng đơn đã lấy bao nhiêu từ lô nào (bảng thêm 15/10, script FoodPetShop_OrderItemLot.sql).
// Huỷ đơn cộng trả đúng lô này (BR-19); chi tiết đơn hiện HSD lô khách nhận (BR-12, BR-56).
@Entity
@Table(name = "OrderItemLot")
@Getter
@Setter
@NoArgsConstructor
public class OrderItemLot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_item_lot_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_item_id", nullable = false)
    private OrderItem orderItem;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lot_id", nullable = false)
    private Lot lot;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    public OrderItemLot(OrderItem orderItem, Lot lot, int quantity) {
        this.orderItem = orderItem;
        this.lot = lot;
        this.quantity = quantity;
    }
}
