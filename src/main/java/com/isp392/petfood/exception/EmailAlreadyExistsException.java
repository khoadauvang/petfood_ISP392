package com.isp392.petfood.exception;

public class EmailAlreadyExistsException extends RuntimeException {

    public EmailAlreadyExistsException(String email) {
        super("Email đã được đăng ký: " + email);
    }
}
