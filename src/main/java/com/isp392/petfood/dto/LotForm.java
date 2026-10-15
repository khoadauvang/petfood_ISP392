package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Lot;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

// Form nhập lô / sửa lô nhập nhầm. name của input trên JSP: productId, expiryDate, receivedQty.
// on_hand_qty không có ô nhập: lúc nhập lô, hàng còn trong kho = số lượng nhập (service tự gán).
@Getter
@Setter
public class LotForm {

    @NotNull(message = "Vui lòng chọn sản phẩm")
    private Long productId;

    // <input type="date"> gửi lên dạng 2027-01-31 (ISO)
    @NotNull(message = "Vui lòng nhập hạn sử dụng")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate expiryDate;

    @NotNull(message = "Vui lòng nhập số lượng nhập")
    @Min(value = 1, message = "Số lượng nhập phải lớn hơn 0")
    @Max(value = 1_000_000, message = "Số lượng nhập quá lớn")
    private Integer receivedQty;

    public static LotForm from(Lot lot) {
        LotForm form = new LotForm();
        form.setProductId(lot.getProduct().getId());
        form.setExpiryDate(lot.getExpiryDate());
        form.setReceivedQty(lot.getReceivedQty());
        return form;
    }
}
