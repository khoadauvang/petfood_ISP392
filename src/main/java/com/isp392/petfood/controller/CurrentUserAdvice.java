package com.isp392.petfood.controller;


import com.isp392.petfood.security.AccountPrincipal;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class CurrentUserAdvice {

        @ModelAttribute("currentUser")
        public AccountPrincipal currentUser(@AuthenticationPrincipal AccountPrincipal user) {
            return user;    //null neu la guest
        }
}
