package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ChatNodeStatus;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

// Form thêm / sửa nút kịch bản chatbox (Staff). parentId trống = chủ đề gốc.
@Getter
@Setter
public class ChatNodeForm {

    private Long parentId;

    @NotBlank(message = "Vui lòng nhập nhãn nút")
    @Size(max = 150, message = "Nhãn tối đa 150 ký tự")
    private String label;

    @NotBlank(message = "Vui lòng nhập câu trả lời của chatbox")
    @Size(max = 4000, message = "Câu trả lời tối đa 4000 ký tự")
    private String botMessage;

    // Chỉ nhận đường dẫn trong shop (/orders...) hoặc link http(s), không nhận javascript: ...
    @Size(max = 255, message = "Link tối đa 255 ký tự")
    @Pattern(regexp = "^(/[^/\\\\].*|/|https?://\\S+)$", message = "Link phải bắt đầu bằng / (trang trong shop) hoặc http(s)://")
    private String actionUrl;

    @NotNull(message = "Vui lòng nhập thứ tự")
    @Min(value = 0, message = "Thứ tự từ 0 đến 9999")
    @Max(value = 9999, message = "Thứ tự từ 0 đến 9999")
    private Integer sortOrder = 0;

    @NotNull(message = "Vui lòng chọn trạng thái")
    private ChatNodeStatus status = ChatNodeStatus.ACTIVE;
}
