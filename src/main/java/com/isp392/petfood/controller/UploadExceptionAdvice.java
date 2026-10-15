package com.isp392.petfood.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.net.URI;

// File gửi lên vượt spring.servlet.multipart.max-file-size / max-request-size: Spring ném lỗi trước khi vào controller.
// Bắt ở đây để quay lại đúng trang form kèm thông báo, thay vì trang lỗi trắng.
@ControllerAdvice
public class UploadExceptionAdvice {

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public String uploadTooLarge(HttpServletRequest request, RedirectAttributes redirect) {
        redirect.addFlashAttribute("errorMessage",
                "File tải lên quá lớn: mỗi ảnh tối đa 5MB, cả lần gửi tối đa 30MB. Hãy chọn ảnh nhỏ hơn rồi gửi lại.");
        return "redirect:" + backTo(request);
    }

    // Quay lại trang đang mở (header Referer). Chỉ lấy phần đường dẫn trong app, bỏ host,
    // nên không thể bị lợi dụng để chuyển hướng sang trang web khác.
    private static String backTo(HttpServletRequest request) {
        String referer = request.getHeader("Referer");
        if (referer != null) {
            try {
                URI uri = URI.create(referer);
                String path = uri.getRawPath();
                String contextPath = request.getContextPath();
                if (path != null && path.startsWith(contextPath + "/")) {
                    String inApp = path.substring(contextPath.length());   // "redirect:" tự thêm context path
                    return uri.getRawQuery() == null ? inApp : inApp + "?" + uri.getRawQuery();
                }
            } catch (IllegalArgumentException ignored) {
                // Referer lạ: về trang mặc định
            }
        }
        return "/";
    }
}
