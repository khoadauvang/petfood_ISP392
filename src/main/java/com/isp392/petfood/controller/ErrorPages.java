package com.isp392.petfood.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.servlet.ModelAndView;

// Trang lỗi chung error/error.jsp. Model: status (số), errorTitle, errorDetail.
// Không dùng tên "errorMessage" vì tên đó là flash message của các trang khác.
final class ErrorPages {

    static final String VIEW = "error/error";

    private ErrorPages() {
    }

    // detail = null: dùng câu mặc định theo mã lỗi (không bao giờ đưa chi tiết lỗi kỹ thuật ra trang)
    static ModelAndView of(HttpStatus status, String detail) {
        ModelAndView mav = new ModelAndView(VIEW, status);
        mav.addObject("status", status.value());
        mav.addObject("errorTitle", title(status));
        mav.addObject("errorDetail", detail != null ? detail : defaultDetail(status));
        return mav;
    }

    private static String title(HttpStatus status) {
        return switch (status) {
            case BAD_REQUEST -> "Yêu cầu không hợp lệ";
            case FORBIDDEN -> "Bạn không có quyền vào trang này";
            case NOT_FOUND -> "Không tìm thấy trang";
            case METHOD_NOT_ALLOWED -> "Thao tác không được hỗ trợ";
            case CONFLICT -> "Dữ liệu vừa bị thay đổi";
            default -> status.is5xxServerError() ? "Hệ thống đang gặp sự cố" : "Không xử lý được yêu cầu";
        };
    }

    private static String defaultDetail(HttpStatus status) {
        return switch (status) {
            case BAD_REQUEST -> "Đường dẫn hoặc dữ liệu gửi lên không đúng. Hãy quay lại trang trước và thử lại.";
            case FORBIDDEN -> "Tài khoản của bạn không được phép thực hiện thao tác này.";
            case NOT_FOUND -> "Trang bạn tìm không tồn tại hoặc đã bị xoá.";
            case METHOD_NOT_ALLOWED -> "Hãy dùng các nút trên trang thay vì gõ đường dẫn trực tiếp.";
            case CONFLICT -> "Người khác vừa cập nhật dữ liệu này. Hãy tải lại trang rồi thử lại.";
            default -> status.is5xxServerError()
                    ? "Đã có lỗi xảy ra phía máy chủ. Vui lòng thử lại sau ít phút."
                    : "Vui lòng quay lại trang trước và thử lại.";
        };
    }
}
