package com.isp392.petfood.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.webmvc.autoconfigure.error.ErrorViewResolver;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.ModelAndView;

import java.util.Map;

// Lỗi đi qua /error của Spring Boot (URL không tồn tại, sai phương thức, exception chưa được bắt -> 500...):
// trả trang lỗi chung thay cho trang "Whitelabel Error Page". Bean này thay DefaultErrorViewResolver của Spring Boot.
// Chỉ áp cho trình duyệt (Accept: text/html); request JSON vẫn nhận JSON lỗi mặc định.
@Component
public class AppErrorViewResolver implements ErrorViewResolver {

    @Override
    public ModelAndView resolveErrorView(HttpServletRequest request, HttpStatus status, Map<String, Object> model) {
        return ErrorPages.of(status, null);
    }
}
