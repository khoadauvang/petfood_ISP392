package com.isp392.petfood.exception;

// Ảnh tải lên không dùng được (không phải ảnh, sai định dạng, quá nhỏ, quá lớn...).
// Message viết sẵn tiếng Việt để hiện thẳng dưới ô chọn ảnh.
public class InvalidImageException extends RuntimeException {

    public InvalidImageException(String message) {
        super(message);
    }
}
