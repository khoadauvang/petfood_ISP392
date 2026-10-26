package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ChangePasswordForm;
import com.isp392.petfood.dto.CustomerProfileDto;
import com.isp392.petfood.dto.ProfileForm;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.security.AccountSessionService;
import com.isp392.petfood.security.CurrentUserRefresher;
import com.isp392.petfood.service.CustomerProfileService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
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

// Hồ sơ khách hàng. /profile/** chỉ cho CUSTOMER (SecurityConfig); customerId lấy từ người đang đăng nhập,
// không nhận id trên URL nên khách không xem/sửa được hồ sơ người khác.
//   GET  /profile    xem + form sửa họ tên, số điện thoại, ảnh đại diện
//   POST /profile    lưu
//   POST /profile/change-password   đổi mật khẩu: mật khẩu hiện tại + mật khẩu mới 2 lần; quên mật khẩu hiện tại
//                                   thì dùng luồng OTP /forgot-password (cũng mở được khi đang đăng nhập)
@Controller
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final CustomerProfileService profileService;
    private final CurrentUserRefresher currentUserRefresher;
    private final AccountSessionService sessionService;

    @InitBinder("profileForm")
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));   // ô trống -> null
    }

    @GetMapping
    public String view(@AuthenticationPrincipal AccountPrincipal user, Model model) {
        model.addAttribute("profileForm", profileService.getForm(user.getCustomerId()));
        return showForm(user, model);
    }

    @PostMapping
    public String update(@AuthenticationPrincipal AccountPrincipal user,
                         @Valid @ModelAttribute("profileForm") ProfileForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect,
                         HttpServletRequest request,
                         HttpServletResponse response) {
        if (result.hasErrors()) {
            return showForm(user, model);
        }
        try {
            CustomerProfileDto saved = profileService.update(user.getCustomerId(), form);
            currentUserRefresher.replace(user.withProfile(saved.getFullName(), saved.getAvatarUrl()), request, response);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật hồ sơ.");
            return "redirect:/profile";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(user, model);
        }
    }

    @PostMapping("/change-password")
    public String changePassword(@AuthenticationPrincipal AccountPrincipal user,
                                 @Valid @ModelAttribute("changePasswordForm") ChangePasswordForm form,
                                 BindingResult result,
                                 Model model,
                                 RedirectAttributes redirect,
                                 HttpServletRequest request) {
        model.addAttribute("activeSubTab", "password");
        if (result.hasErrors()) {
            model.addAttribute("profileForm", profileService.getForm(user.getCustomerId()));
            return showForm(user, model);
        }
        try {
            Long accountId = profileService.changePassword(user.getCustomerId(), form);
            // mật khẩu cũ có thể đã lộ: các thiết bị khác phải đăng nhập lại, phiên đang dùng giữ nguyên
            sessionService.expireOtherSessions(accountId, request.getSession().getId());
            redirect.addFlashAttribute("successMessage", "Đã đổi mật khẩu. Các thiết bị khác đã được đăng xuất.");
            redirect.addFlashAttribute("activeSubTab", "password");
            return "redirect:/profile";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            model.addAttribute("profileForm", profileService.getForm(user.getCustomerId()));
            return showForm(user, model);
        }
    }

    private String showForm(AccountPrincipal user, Model model) {
        if (!model.containsAttribute("changePasswordForm")) {
            model.addAttribute("changePasswordForm", new ChangePasswordForm());
        }
        model.addAttribute("profile", profileService.getProfile(user.getCustomerId()));
        return "customer/profile";
    }
}
