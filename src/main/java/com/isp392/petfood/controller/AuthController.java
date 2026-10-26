package com.isp392.petfood.controller;

import com.isp392.petfood.dto.RegisterForm;
import com.isp392.petfood.exception.EmailAlreadyExistsException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.security.LocalPaths;
import com.isp392.petfood.security.RoleBasedLoginSuccessHandler;
import com.isp392.petfood.service.RegistrationService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final RegistrationService registrationService;
    private final ObjectProvider<ClientRegistrationRepository> clientRegistrations;

    @GetMapping("/login")
    public String loginPage(@AuthenticationPrincipal AccountPrincipal user,
                            @RequestParam(name = "redirect", required = false) String redirect,
                            HttpSession session, Model model) {
        if (user != null) return "redirect:/";
        // ?redirect=/products/12: đăng nhập xong (form hoặc Google) quay lại trang đó (RoleBasedLoginSuccessHandler)
        if (LocalPaths.isLocalPath(redirect)) {
            session.setAttribute(RoleBasedLoginSuccessHandler.SESSION_REDIRECT, redirect);
        }
        // Nút "Đăng nhập bằng Google" chỉ hiện khi .env có client-id/secret (xem application.properties)
        model.addAttribute("googleLoginEnabled", clientRegistrations.getIfAvailable() != null);
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
