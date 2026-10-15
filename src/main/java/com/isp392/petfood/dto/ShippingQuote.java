package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

// Kết quả tính phí giao hàng cho một địa chỉ
@Getter
@AllArgsConstructor
public class ShippingQuote {
    private final BigDecimal fee;
    private final Double distanceKm;          // null khi không xác định được vị trí
    private final String matchedAddress;      // địa chỉ Google hiểu được, để khách đối chiếu; null nếu không tìm thấy
    private final String note;                // giải thích vì sao miễn phí / có phí

    public String getDistanceText() {
        return distanceKm == null ? null : String.format("%.1f", distanceKm).replace('.', ',');
    }
}
