package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Một suất Flash Sale đang mở bán, hiển thị cho khách kèm ghi chú hạn dùng còn lại (BR-65)
@Getter
@AllArgsConstructor
public class FlashSaleOffer {
    private final Long flashSaleItemId;
    private final String saleName;
    private final String endText;
    private final Long productId;
    private final String productName;
    private final String brand;
    private final String imageUrl;
    private final BigDecimal sellingPrice;
    private final BigDecimal salePrice;
    private final int discountPercent;
    private final int remainingQty;
    private final String expiryText;
    private final long daysLeft;
    private final String species;     // DOG / CAT, để trang Flash Sale lọc theo loài
    private final int soldPercent;    // sold_qty / allocated_qty của suất (thanh "Đã bán")
    private final String endAt;       // giờ kết thúc dạng ISO (yyyy-MM-ddTHH:mm:ss) cho đồng hồ đếm ngược
}
