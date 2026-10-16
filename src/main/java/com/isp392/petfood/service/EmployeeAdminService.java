package com.isp392.petfood.service;

import com.isp392.petfood.dto.EmployeeCreateForm;
import com.isp392.petfood.dto.EmployeeEditForm;
import com.isp392.petfood.dto.EmployeeRow;
import com.isp392.petfood.dto.PasswordResetForm;
import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Employee;
import com.isp392.petfood.enums.AccountStatus;
import com.isp392.petfood.enums.Role;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.AccountRepository;
import com.isp392.petfood.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

// Quản lý tài khoản nhân viên cho Admin (module 10):
//   - chỉ Admin tạo tài khoản Staff / Admin (BR-04); email duy nhất (BR-01); mật khẩu BCrypt (BR-02)
//   - Account + Employee tạo trong cùng transaction (ghi chú 2 trong script SQL)
//   - không xoá nhân viên (đơn, lô, phản hồi còn tham chiếu Employee), chỉ khoá (Account.status, mục 9.5)
//   - Admin không tự khoá / tự đổi vai trò của mình; luôn còn ít nhất một Admin đang hoạt động
@Service
@RequiredArgsConstructor
public class EmployeeAdminService {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final int PAGE_SIZE = 20;

    private final EmployeeRepository employeeRepository;
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public Page<EmployeeRow> search(Role role, AccountStatus status, String keyword, int pageNumber) {
        return employeeRepository.search(role, status, keyword == null || keyword.isBlank() ? null : keyword.trim(),
                        PageRequest.of(pageNumber, PAGE_SIZE, Sort.by("id")))
                .map(EmployeeAdminService::toRow);
    }

    @Transactional(readOnly = true)
    public EmployeeRow get(Long employeeId) {
        return toRow(find(employeeId));
    }

    @Transactional(readOnly = true)
    public EmployeeEditForm getForm(Long employeeId) {
        Employee employee = find(employeeId);
        EmployeeEditForm form = new EmployeeEditForm();
        form.setFullName(employee.getFullName());
        form.setPhone(employee.getPhone());
        form.setRole(employee.getAccount().getRole());
        return form;
    }

    @Transactional
    public Employee create(EmployeeCreateForm form) {
        Map<String, String> errors = new LinkedHashMap<>();
        String email = form.getEmail().trim().toLowerCase(Locale.ROOT);
        if (!isEmployeeRole(form.getRole())) {
            errors.put("role", "Chỉ tạo được tài khoản Staff hoặc Admin");
        }
        if (!form.getPassword().equals(form.getConfirmPassword())) {
            errors.put("confirmPassword", "Mật khẩu nhập lại không khớp");
        }
        if (accountRepository.existsByEmail(email)) {
            errors.put("email", "Email đã được dùng cho một tài khoản khác");
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        Account account = new Account();
        account.setEmail(email);
        account.setPasswordHash(passwordEncoder.encode(form.getPassword()));
        account.setRole(form.getRole());
        try {
            accountRepository.saveAndFlush(account);
        } catch (DataIntegrityViolationException e) {
            // hai người tạo cùng email cùng lúc: UQ_Account_email là chốt chặn cuối
            throw new BusinessRuleException("email", "Email đã được dùng cho một tài khoản khác");
        }

        Employee employee = new Employee();
        employee.setAccount(account);
        employee.setFullName(form.getFullName().trim());
        employee.setPhone(blankToNull(form.getPhone()));
        return employeeRepository.save(employee);
    }

    @Transactional
    public Employee update(Long employeeId, EmployeeEditForm form, Long currentEmployeeId) {
        Employee employee = find(employeeId);
        Account account = employee.getAccount();
        if (!isEmployeeRole(form.getRole())) {
            throw new BusinessRuleException("role", "Chỉ chọn được Staff hoặc Admin");
        }
        if (form.getRole() != account.getRole()) {
            if (employeeId.equals(currentEmployeeId)) {
                throw new BusinessRuleException("role", "Bạn không tự đổi vai trò của chính mình được");
            }
            requireAnotherActiveAdmin(account);
            account.setRole(form.getRole());
        }
        employee.setFullName(form.getFullName().trim());
        employee.setPhone(blankToNull(form.getPhone()));
        return employee;
    }

    @Transactional
    public Employee resetPassword(Long employeeId, PasswordResetForm form) {
        if (!form.getNewPassword().equals(form.getConfirmPassword())) {
            throw new BusinessRuleException("confirmPassword", "Mật khẩu nhập lại không khớp");
        }
        Employee employee = find(employeeId);
        employee.getAccount().setPasswordHash(passwordEncoder.encode(form.getNewPassword()));
        return employee;
    }

    // Trả về accountId để controller đăng xuất các phiên đang mở của tài khoản này
    @Transactional
    public Long lock(Long employeeId, Long currentEmployeeId) {
        Employee employee = find(employeeId);
        Account account = employee.getAccount();
        if (employeeId.equals(currentEmployeeId)) {
            throw new BusinessRuleException("Bạn không tự khoá tài khoản của chính mình được.");
        }
        if (account.getStatus() == AccountStatus.LOCKED) {
            throw new BusinessRuleException("Tài khoản " + account.getEmail() + " đã bị khoá từ trước.");
        }
        requireAnotherActiveAdmin(account);
        account.setStatus(AccountStatus.LOCKED);
        return account.getId();
    }

    @Transactional
    public Employee unlock(Long employeeId) {
        Employee employee = find(employeeId);
        employee.getAccount().setStatus(AccountStatus.ACTIVE);
        return employee;
    }

    // Khoá hoặc hạ vai trò một Admin đang hoạt động: phải còn ít nhất một Admin khác đăng nhập được
    private void requireAnotherActiveAdmin(Account account) {
        if (account.getRole() == Role.ADMIN && account.getStatus() == AccountStatus.ACTIVE
                && employeeRepository.countActiveAdmins() <= 1) {
            throw new BusinessRuleException("Đây là Admin cuối cùng đang hoạt động, không khoá hoặc đổi vai trò được.");
        }
    }

    private Employee find(Long employeeId) {
        return employeeRepository.findWithAccount(employeeId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy nhân viên #" + employeeId));
    }

    private static boolean isEmployeeRole(Role role) {
        return role == Role.STAFF || role == Role.ADMIN;
    }

    private static EmployeeRow toRow(Employee e) {
        Account a = e.getAccount();
        return new EmployeeRow(e.getId(), a.getId(), a.getEmail(), e.getFullName(), e.getPhone(), a.getRole(),
                a.getStatus(), a.getCreatedAt().format(DATE_TIME));
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
