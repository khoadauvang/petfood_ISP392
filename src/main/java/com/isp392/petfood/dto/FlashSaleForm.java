package com.isp392.petfood.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Form tạo / sửa chương trình khuyến mãi (dành cho dịp lễ hoặc theo nhu cầu của Admin)
@Getter
@Setter
public class FlashSaleForm {

    @NotBlank(message = "Vui lòng nhập tên chương trình")
    @Size(max = 150, message = "Tên tối đa 150 ký tự")
    private String name;

    @Size(max = 255, message = "Mô tả tối đa 255 ký tự")
    private String description;

    @NotNull(message = "Vui lòng nhập mức giảm giá chung (%) cho toàn bộ chương trình")
    @Min(value = 1, message = "Mức giảm tối thiểu 1%")
    @Max(value = 99, message = "Mức giảm tối đa 99%")
    private Integer discountPercent = 20;

    @NotNull(message = "Vui lòng chọn thời gian bắt đầu")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime startTime;

    @NotNull(message = "Vui lòng chọn thời gian kết thúc")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime endTime;

    // Danh sách ID các lô bình thường (>90 ngày) được chọn tham gia chương trình
    private List<Long> selectedLotIds = new ArrayList<>();

    // Số lượng suất khuyến mãi phân bổ cho từng lô (lotId -> số lượng)
    private Map<Long, Integer> lotQuantities = new HashMap<>();

    public int getQuantityForLot(Long lotId, int defaultQty) {
        if (lotQuantities != null && lotQuantities.containsKey(lotId)) {
            Integer q = lotQuantities.get(lotId);
            if (q != null && q > 0) return q;
        }
        return defaultQty;
    }
}
