package com.isp392.petfood.controller;

import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.ModelAndView;

// Xử lý exception tập trung (module 10): lỗi mà controller không tự bắt thì hiện trang lỗi chung có câu dễ hiểu.
//   - NotFoundException (id trên URL không có)          -> 404, kèm câu của service ("Không tìm thấy đơn #12")
//   - BusinessRuleException controller không bắt         -> 400, kèm câu của service (đã viết cho người dùng đọc)
//   - id trên URL không phải số, thiếu tham số bắt buộc  -> 400
//   - hai người sửa cùng lúc (khoá lạc quan)             -> 409
// Các lỗi còn lại (500, URL không tồn tại, sai phương thức...) đi qua /error và AppErrorViewResolver.
// Controller nào đã tự bắt các exception này (form, PRG) thì vẫn chạy như cũ.
@Slf4j
@ControllerAdvice
public class ErrorPageAdvice {

    @ExceptionHandler(NotFoundException.class)
    public ModelAndView notFound(NotFoundException e) {
        return ErrorPages.of(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(BusinessRuleException.class)
    public ModelAndView businessRule(BusinessRuleException e) {
        return ErrorPages.of(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler({MethodArgumentTypeMismatchException.class, MissingServletRequestParameterException.class})
    public ModelAndView badRequest(Exception e) {
        log.debug("Yêu cầu không hợp lệ: {}", e.getMessage());
        return ErrorPages.of(HttpStatus.BAD_REQUEST, null);
    }

    @ExceptionHandler(ObjectOptimisticLockingFailureException.class)
    public ModelAndView conflict(ObjectOptimisticLockingFailureException e) {
        log.info("Xung đột cập nhật đồng thời: {}", e.getMessage());
        return ErrorPages.of(HttpStatus.CONFLICT, null);
    }
}
