package com.isp392.petfood.exception;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

// Vi phạm quy tắc nghiệp vụ mà @Valid không tự kiểm tra được (SKU trùng, ảnh lỗi, danh mục còn sản phẩm...).
// Có field -> controller gắn lỗi vào đúng ô trên form (result.rejectValue).
// Không có field -> lỗi chung, hiện ở đầu trang.
public class BusinessRuleException extends RuntimeException {

    private final Map<String, String> fieldErrors;

    // Lỗi chung, không gắn với ô nào
    public BusinessRuleException(String message) {
        super(message);
        this.fieldErrors = Map.of();
    }

    // Lỗi của một ô
    public BusinessRuleException(String field, String message) {
        super(message);
        this.fieldErrors = Map.of(field, message);
    }

    // Nhiều ô lỗi cùng lúc (báo hết một lần, nhân viên không phải gửi form nhiều lần)
    public BusinessRuleException(Map<String, String> fieldErrors) {
        super(String.join("; ", fieldErrors.values()));
        this.fieldErrors = Collections.unmodifiableMap(new LinkedHashMap<>(fieldErrors));
    }

    public Map<String, String> getFieldErrors() {
        return fieldErrors;
    }

    public boolean hasFieldErrors() {
        return !fieldErrors.isEmpty();
    }
}
