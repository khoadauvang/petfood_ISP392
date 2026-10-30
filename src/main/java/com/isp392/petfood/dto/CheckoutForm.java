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

    // Đã cấu hình GHN: chỉ là số nhà, tên đường; phường/xã và tỉnh/thành chọn ở 2 ô dưới.
    // Chưa cấu hình GHN: địa chỉ đầy đủ khách tự gõ như trước.
    @NotBlank(message = "Vui lòng nhập địa chỉ giao hàng")
    @Size(max = 400, message = "Địa chỉ tối đa 400 ký tự")
    private String shippingAddress;

    // Tên chuẩn trong danh mục GHN (mô hình 2 cấp), chọn từ danh sách; kiểm tra lại ở server
    @Size(max = 50)
    private String province;

    @Size(max = 50)
    private String ward;

    @NotNull(message = "Vui lòng chọn phương thức thanh toán")
    private PaymentMethod paymentMethod = PaymentMethod.COD;

    // Id các dòng giỏ khách tick để đặt (CartItem.id); rỗng = cả giỏ. Truyền từ /cart qua ?itemIds=1,2 rồi giữ bằng input ẩn
    private List<Long> itemIds = new ArrayList<>();

    // Địa chỉ lưu vào Orders.shipping_address: "số nhà đường, phường/xã, tỉnh/thành" để lúc giao còn tách lại được
    // gửi GHN (GhnShippingService). Không chọn tỉnh/phường thì dùng nguyên chuỗi khách gõ.
    public String getFullAddress() {
        if (shippingAddress == null || province == null || province.isBlank() || ward == null || ward.isBlank()) {
            return shippingAddress;
        }
        return shippingAddress + ", " + ward.trim() + ", " + province.trim();
    }
}
