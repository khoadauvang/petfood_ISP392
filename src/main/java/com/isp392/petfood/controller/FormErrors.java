package com.isp392.petfood.controller;

import com.isp392.petfood.exception.BusinessRuleException;
import org.springframework.beans.BeanUtils;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;

import java.util.ArrayList;
import java.util.List;

// Đưa lỗi nghiệp vụ từ service lên form JSP:
//   - lỗi có tên ô trùng một field của form -> hiện dưới đúng ô đó (<form:errors path="...">)
//   - lỗi chung hoặc tên ô không có trên form -> hiện ở đầu trang qua "errorMessage"
final class FormErrors {

    static final String SUMMARY = "Chưa lưu được, vui lòng sửa các ô báo lỗi bên dưới.";

    private FormErrors() {
    }

    static void apply(BusinessRuleException e, BindingResult result, Model model) {
        if (!e.hasFieldErrors()) {
            model.addAttribute("errorMessage", e.getMessage());
            return;
        }
        Object form = result.getTarget();
        List<String> general = new ArrayList<>();
        e.getFieldErrors().forEach((field, message) -> {
            if (form != null && BeanUtils.getPropertyDescriptor(form.getClass(), field) != null) {
                result.rejectValue(field, "business", message);
            } else {
                general.add(message);
            }
        });
        model.addAttribute("errorMessage", general.isEmpty() ? SUMMARY : String.join(" ", general));
    }

    // Gọi khi @Valid đã báo lỗi: thêm một dòng nhắc ở đầu trang (form dài, lỗi có thể nằm ở dưới)
    static void summary(Model model) {
        model.addAttribute("errorMessage", SUMMARY);
    }
}
