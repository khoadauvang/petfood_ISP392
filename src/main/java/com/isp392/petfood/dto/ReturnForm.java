package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ReturnReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

// Form khách gửi yêu cầu trả hàng (BR-32, BR-33). lines: mỗi dòng đơn còn trả được một phần tử, tick "selected" để trả.
@Getter
@Setter
public class ReturnForm {

    @NotNull(message = "Vui lòng chọn lý do trả hàng")
    private ReturnReason reason;

    @Size(max = 2000, message = "Mô tả tối đa 2000 ký tự")
    private String description;

    private List<Line> lines = new ArrayList<>();

    // 1 đến 5 ảnh / video (BR-33)
    private List<MultipartFile> media = new ArrayList<>();

    // Đơn COD: tài khoản nhận hoàn tiền chuyển khoản thủ công (LI-05). Đơn VNPay bỏ trống.
    @Size(max = 100, message = "Tên ngân hàng tối đa 100 ký tự")
    private String refundBankName;

    @Size(max = 30, message = "Số tài khoản tối đa 30 ký tự")
    private String refundAccountNo;

    @Size(max = 100, message = "Tên chủ tài khoản tối đa 100 ký tự")
    private String refundAccountHolder;

    @Getter
    @Setter
    public static class Line {
        private Long orderItemId;
        private boolean selected;
        private Integer quantity;
        private boolean opened;
    }
}
