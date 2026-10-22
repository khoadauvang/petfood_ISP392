package com.isp392.petfood.dto;

import com.isp392.petfood.enums.PaymentMethod;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

// Form đặt hàng: đơn bắt buộc có địa chỉ giao và phương thức thanh toán (BR-14)
@Getter
@Setter
public class CheckoutForm {

    @NotBlank(message = "Vui lòng nhập địa chỉ giao hàng")
    @Size(max = 500, message = "Địa chỉ tối đa 500 ký tự")
    private String shippingAddress;

    @NotNull(message = "Vui lòng chọn phương thức thanh toán")
    private PaymentMethod paymentMethod = PaymentMethod.COD;

    // Id các dòng giỏ khách tick để đặt (CartItem.id); rỗng = cả giỏ. Truyền từ /cart qua ?itemIds=1,2 rồi giữ bằng input ẩn
    private List<Long> itemIds = new ArrayList<>();
}
