package com.isp392.petfood.controller;

import com.isp392.petfood.dto.EmployeeCreateForm;
import com.isp392.petfood.dto.EmployeeEditForm;
import com.isp392.petfood.dto.EmployeeRow;
import com.isp392.petfood.dto.PasswordResetForm;
import com.isp392.petfood.entity.Employee;
import com.isp392.petfood.enums.AccountStatus;
import com.isp392.petfood.enums.Role;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.security.AccountSessionService;
import com.isp392.petfood.service.EmployeeAdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Quản lý tài khoản nhân viên, chỉ ADMIN (/admin/**, module 10, BR-04).
//   GET  /admin/employees                     lọc vai trò, trạng thái, tìm tên / email / SĐT
//   GET  /admin/employees/new                 form tạo Staff / Admin          POST cùng URL
//   GET  /admin/employees/{id}/edit           sửa họ tên, SĐT, vai trò + form đặt lại mật khẩu   POST cùng URL
//   POST /admin/employees/{id}/password       đặt lại mật khẩu
//   POST /admin/employees/{id}/lock | unlock  khoá / mở khoá (mục 9.5)
// Khoá, đổi vai trò hoặc đặt lại mật khẩu thì đăng xuất các phiên đang mở của nhân viên đó.
@Controller
@RequestMapping("/admin/employees")
@RequiredArgsConstructor
public class AdminEmployeeController {

    private static final Role[] EMPLOYEE_ROLES = {Role.STAFF, Role.ADMIN};

    private final EmployeeAdminService employeeService;
    private final AccountSessionService sessionService;

    // Không cắt khoảng trắng của mật khẩu; chỉ ô trống thì thành null
    @InitBinder({"employeeCreateForm", "employeeEditForm"})
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, "fullName", new StringTrimmerEditor(true));
        binder.registerCustomEditor(String.class, "email", new StringTrimmerEditor(true));
        binder.registerCustomEditor(String.class, "phone", new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(@RequestParam(name = "role", required = false) Role role,
                       @RequestParam(name = "status", required = false) AccountStatus status,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page, Model model) {
        Page<EmployeeRow> result = employeeService.search(role, status, keyword, Math.max(page, 1) - 1);
        model.addAttribute("employees", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("roles", EMPLOYEE_ROLES);
        model.addAttribute("statuses", AccountStatus.values());
        model.addAttribute("filterRole", role);
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of("role", role, "status", status, "keyword", keyword));
        return "admin/employees/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("employeeCreateForm", new EmployeeCreateForm());
        model.addAttribute("roles", EMPLOYEE_ROLES);
        return "admin/employees/create";
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("employeeCreateForm") EmployeeCreateForm form, BindingResult result,
                         Model model, RedirectAttributes redirect) {
        model.addAttribute("roles", EMPLOYEE_ROLES);
        if (result.hasErrors()) {
            return "admin/employees/create";
        }
        try {
            Employee employee = employeeService.create(form);
            redirect.addFlashAttribute("successMessage", "Đã tạo tài khoản " + employee.getAccount().getEmail()
                    + " (" + employee.getAccount().getRole() + ").");
            return "redirect:/admin/employees";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return "admin/employees/create";
        }
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("employeeEditForm", employeeService.getForm(id));
        model.addAttribute("passwordResetForm", new PasswordResetForm());
        return showEdit(id, model);
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id, @Valid @ModelAttribute("employeeEditForm") EmployeeEditForm form,
                         BindingResult result, @AuthenticationPrincipal AccountPrincipal user, Model model,
                         RedirectAttributes redirect) {
        model.addAttribute("passwordResetForm", new PasswordResetForm());
        if (result.hasErrors()) {
            return showEdit(id, model);
        }
        try {
            Role oldRole = employeeService.get(id).getRole();
            Employee employee = employeeService.update(id, form, user.getEmployeeId());
            String message = "Đã lưu thông tin " + employee.getAccount().getEmail() + ".";
            if (oldRole != form.getRole()) {
                // quyền nằm trong phiên đăng nhập: buộc đăng nhập lại để nhận vai trò mới
                sessionService.expireSessions(employee.getAccount().getId());
                message += " Vai trò mới có hiệu lực từ lần đăng nhập tiếp theo.";
            }
            redirect.addFlashAttribute("successMessage", message);
            return "redirect:/admin/employees";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showEdit(id, model);
        }
    }

    @PostMapping("/{id}/password")
    public String resetPassword(@PathVariable("id") Long id,
                                @Valid @ModelAttribute("passwordResetForm") PasswordResetForm form,
                                BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            model.addAttribute("employeeEditForm", employeeService.getForm(id));
            return showEdit(id, model);
        }
        try {
            Employee employee = employeeService.resetPassword(id, form);
            sessionService.expireSessions(employee.getAccount().getId());
            redirect.addFlashAttribute("successMessage", "Đã đặt lại mật khẩu cho " + employee.getAccount().getEmail()
                    + ". Hãy báo mật khẩu mới cho nhân viên.");
            return "redirect:/admin/employees";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            model.addAttribute("employeeEditForm", employeeService.getForm(id));
            return showEdit(id, model);
        }
    }

    @PostMapping("/{id}/lock")
    public String lock(@PathVariable("id") Long id, @RequestParam(name = "back", required = false) String back,
                       @AuthenticationPrincipal AccountPrincipal user, RedirectAttributes redirect) {
        try {
            Long accountId = employeeService.lock(id, user.getEmployeeId());
            int sessions = sessionService.expireSessions(accountId);
            redirect.addFlashAttribute("successMessage", "Đã khoá tài khoản nhân viên #" + id
                    + (sessions > 0 ? " và đăng xuất " + sessions + " phiên đang mở." : "."));
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return redirectBack(back);
    }

    @PostMapping("/{id}/unlock")
    public String unlock(@PathVariable("id") Long id, @RequestParam(name = "back", required = false) String back,
                         RedirectAttributes redirect) {
        Employee employee = employeeService.unlock(id);
        redirect.addFlashAttribute("successMessage", "Đã mở khoá tài khoản " + employee.getAccount().getEmail() + ".");
        return redirectBack(back);
    }

    private String showEdit(Long id, Model model) {
        model.addAttribute("employee", employeeService.get(id));
        model.addAttribute("roles", EMPLOYEE_ROLES);
        return "admin/employees/edit";
    }

    // Quay lại đúng trang danh sách (giữ bộ lọc); chỉ nhận query string, không nhận URL khác
    private static String redirectBack(String back) {
        return back == null || back.isBlank() || back.contains("://") || back.contains("\n")
                ? "redirect:/admin/employees" : "redirect:/admin/employees?" + back;
    }
}
