package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ForgotPasswordForm;
import com.isp392.petfood.dto.OtpResetForm;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.security.AccountSessionService;
import com.isp392.petfood.service.PasswordResetService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.mail.MailException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Quên mật khẩu bằng OTP (mục 9.11), không cần đăng nhập:
//   GET  /forgot-password          nhập email                       POST cùng URL: gửi mã
//   GET  /forgot-password/verify   nhập mã OTP + mật khẩu mới       POST cùng URL: đổi mật khẩu
//   POST /forgot-password/resend   gửi lại mã cho email đang làm
// Email đang đặt lại mật khẩu giữ trong session (không đưa lên URL).
@Slf4j
@Controller
@RequestMapping("/forgot-password")
@RequiredArgsConstructor
public class ForgotPasswordController {

    static final String SESSION_EMAIL = "passwordResetEmail";
    private static final String SENT_MESSAGE =
            "Nếu email này đã đăng ký tài khoản, mã OTP gồm 6 chữ số đã được gửi tới hộp thư. Hãy kiểm tra cả mục Spam.";
    private static final String MAIL_ERROR = "Hệ thống chưa gửi được email lúc này, vui lòng thử lại sau ít phút.";

    private final PasswordResetService passwordResetService;
    private final AccountSessionService sessionService;

    // Không cắt khoảng trắng của mật khẩu
    @InitBinder({"forgotPasswordForm", "otpResetForm"})
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, "email", new StringTrimmerEditor(true));
        binder.registerCustomEditor(String.class, "otp", new StringTrimmerEditor(true));
    }

    @GetMapping
    public String emailForm(@AuthenticationPrincipal AccountPrincipal user, HttpSession session, Model model) {
        if (user != null) return "redirect:/";
        ForgotPasswordForm form = new ForgotPasswordForm();
        form.setEmail((String) session.getAttribute(SESSION_EMAIL));
        model.addAttribute("forgotPasswordForm", form);
        return "auth/forgot-password";
    }

    @PostMapping
    public String sendOtp(@AuthenticationPrincipal AccountPrincipal user,
                          @Valid @ModelAttribute("forgotPasswordForm") ForgotPasswordForm form, BindingResult result,
                          HttpSession session, Model model, RedirectAttributes redirect) {
        if (user != null) return "redirect:/";
        if (result.hasErrors()) {
            return "auth/forgot-password";
        }
        try {
            passwordResetService.requestOtp(form.getEmail());
        } catch (MailException e) {
            log.error("Không gửi được email OTP: {}", e.getMessage());
            model.addAttribute("errorMessage", MAIL_ERROR);
            return "auth/forgot-password";
        }
        session.setAttribute(SESSION_EMAIL, PasswordResetService.normalizeEmail(form.getEmail()));
        redirect.addFlashAttribute("successMessage", SENT_MESSAGE);
        return "redirect:/forgot-password/verify";
    }

    @GetMapping("/verify")
    public String verifyForm(@AuthenticationPrincipal AccountPrincipal user, HttpSession session, Model model) {
        if (user != null) return "redirect:/";
        if (session.getAttribute(SESSION_EMAIL) == null) return "redirect:/forgot-password";
        model.addAttribute("otpResetForm", new OtpResetForm());
        return showVerify(session, model);
    }

    @PostMapping("/verify")
    public String verify(@AuthenticationPrincipal AccountPrincipal user,
                         @Valid @ModelAttribute("otpResetForm") OtpResetForm form, BindingResult result,
                         HttpSession session, Model model) {
        if (user != null) return "redirect:/";
        String email = (String) session.getAttribute(SESSION_EMAIL);
        if (email == null) return "redirect:/forgot-password";
        if (result.hasErrors()) {
            return showVerify(session, model);
        }
        try {
            Long accountId = passwordResetService.resetPassword(email, form);
            // mật khẩu cũ có thể đã lộ: đăng xuất mọi phiên đang mở của tài khoản
            sessionService.expireSessions(accountId);
            session.removeAttribute(SESSION_EMAIL);
            return "redirect:/login?reset";
        } catch (BusinessRuleException e) {
            // lỗi nào cũng thuộc một ô trên form (otp / confirmPassword): hiện ngay dưới ô đó
            e.getFieldErrors().forEach((field, message) -> result.rejectValue(field, "business", message));
            return showVerify(session, model);
        }
    }

    @PostMapping("/resend")
    public String resend(@AuthenticationPrincipal AccountPrincipal user, HttpSession session,
                         RedirectAttributes redirect) {
        if (user != null) return "redirect:/";
        String email = (String) session.getAttribute(SESSION_EMAIL);
        if (email == null) return "redirect:/forgot-password";
        try {
            passwordResetService.requestOtp(email);
            redirect.addFlashAttribute("successMessage", SENT_MESSAGE
                    + " Nếu đã có mã mới, mã gửi trước đó không dùng được nữa.");
        } catch (MailException e) {
            log.error("Không gửi được email OTP: {}", e.getMessage());
            redirect.addFlashAttribute("errorMessage", MAIL_ERROR);
        }
        return "redirect:/forgot-password/verify";
    }

    private String showVerify(HttpSession session, Model model) {
        model.addAttribute("email", session.getAttribute(SESSION_EMAIL));
        model.addAttribute("otpMinutes", passwordResetService.getValidMinutes());
        model.addAttribute("maxAttempts", passwordResetService.getMaxAttempts());
        model.addAttribute("resendSeconds", passwordResetService.getResendSeconds());
        return "auth/reset-password";
    }
}
