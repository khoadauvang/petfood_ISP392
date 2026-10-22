package com.isp392.petfood.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

// Thêm một suất vào chiến dịch: lô cận hạn (RED), số lượng dành riêng. Giá sale do hệ thống tự tính theo HSD lô.
@Getter
@Setter
public class FlashSaleItemForm {

    @NotNull(message = "Vui lòng chọn lô")
    private Long lotId;

    @NotNull(message = "Vui lòng nhập số lượng")
    @Min(value = 1, message = "Số lượng phải từ 1 trở lên")
    private Integer allocatedQty;
}
