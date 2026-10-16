package com.isp392.petfood.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

// Thêm một suất vào chiến dịch: lô cận hạn (RED), giá sale, số lượng dành riêng
@Getter
@Setter
public class FlashSaleItemForm {

    @NotNull(message = "Vui lòng chọn lô")
    private Long lotId;

    @NotNull(message = "Vui lòng nhập giá Flash Sale")
    @Min(value = 1, message = "Giá phải lớn hơn 0")
    private BigDecimal salePrice;

    @NotNull(message = "Vui lòng nhập số lượng")
    @Min(value = 1, message = "Số lượng phải từ 1 trở lên")
    private Integer allocatedQty;
}
