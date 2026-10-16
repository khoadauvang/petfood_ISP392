package com.isp392.petfood.entity;

import com.isp392.petfood.enums.InspectionResult;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

// Một dòng đơn được trả. Mỗi dòng đơn chỉ trả một lần (UQ_ReturnItem_order_item_id, BR-32).
// quantity <= OrderItem.quantity; refund_amount <= số tiền khách thực trả cho phần đó (BR-37, BE kiểm tra).
@Entity
@Table(name = "ReturnItem")
@Getter
@Setter
@NoArgsConstructor
public class ReturnItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "return_item_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "return_id", nullable = false)
    private ReturnRequest returnRequest;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_item_id", nullable = false, unique = true)
    private OrderItem orderItem;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    // Hàng đã mở: chỉ trả được nếu lỗi thuộc sản phẩm / cửa hàng (BR-34)
    @Column(name = "is_opened", nullable = false)
    private Boolean opened = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "inspection_result", length = 20)
    private InspectionResult inspectionResult;

    @Column(name = "inspection_note", length = 255)
    private String inspectionNote;

    @Column(name = "refund_amount", precision = 12, scale = 0)
    private BigDecimal refundAmount;

    public ReturnItem(ReturnRequest returnRequest, OrderItem orderItem, int quantity, boolean opened) {
        this.returnRequest = returnRequest;
        this.orderItem = orderItem;
        this.quantity = quantity;
        this.opened = opened;
    }
}
