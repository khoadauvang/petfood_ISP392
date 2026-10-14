package com.isp392.petfood.controller;

import com.isp392.petfood.dto.RegisterForm;
import com.isp392.petfood.exception.EmailAlreadyExistsException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.RegistrationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final RegistrationService registrationService;

    @GetMapping("/login")
    public String loginPage() {
        return "auth/login";
        //Hãy nhớ trong application.properties có cái dòng
        //  spring.mvc.view.prefix=/WEB-INF/views/
        //  spring.mvc.view.suffix=.jsp
        //Vì thế auth/login biến thành auth/login.jsp
    }

    @GetMapping("/register")
    public String registerPage(@AuthenticationPrincipal AccountPrincipal user, Model model) {
        if (user != null) return "redirect:/";
        model.addAttribute("registerForm", new RegisterForm());
        return "auth/register";
    }

    @PostMapping("/register")
    public String register(@Valid @ModelAttribute("registerForm") RegisterForm form,
                           BindingResult result) {

        if (form.getPassword() != null
                && !form.getPassword().equals(form.getConfirmPassword())) {
            result.rejectValue("confirmPassword", "password.mismatch",
                    "Mật khẩu nhập lại không khớp");
        }
        if (result.hasErrors()) {
            return "auth/register";
        }

        try {
            registrationService.registerCustomer(form);
        } catch (EmailAlreadyExistsException e) {
            result.rejectValue("email", "email.duplicate", "Email này đã được đăng ký");
            return "auth/register";
        }

        return "redirect:/login?registered";   // cùng kiểu với ?error, ?logout của trang login
    }
}
