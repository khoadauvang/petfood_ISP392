package com.isp392.petfood.service;

import com.isp392.petfood.dto.RegisterForm;
import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.enums.Role;
import com.isp392.petfood.exception.EmailAlreadyExistsException;
import com.isp392.petfood.repository.AccountRepository;
import com.isp392.petfood.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final AccountRepository accountRepository;
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;   // bean đã có trong SecurityConfig

    // Account + Customer phải cùng sinh ra hoặc cùng không (ghi chú số 2 trong script tạo bảng)
    @Transactional
    public Customer registerCustomer(RegisterForm form) {
        String email = form.getEmail().trim().toLowerCase(Locale.ROOT);

        // BR-01: email duy nhất
        if (accountRepository.existsByEmail(email)) {
            throw new EmailAlreadyExistsException(email);
        }

        Account account = new Account();
        account.setEmail(email);
        account.setPasswordHash(passwordEncoder.encode(form.getPassword()));
        account.setRole(Role.CUSTOMER);

        try {
            accountRepository.saveAndFlush(account);
        } catch (DataIntegrityViolationException e) {
            // 2 người đăng ký cùng email cùng lúc: UQ_Account_email của DB là chốt chặn cuối
            throw new EmailAlreadyExistsException(email);
        }

        Customer customer = new Customer();
        customer.setAccount(account);
        customer.setFullName(form.getFullName().trim());
        customer.setPhone(form.getPhone().trim());
        // membershipTier: entity đã mặc định BRONZE (FR-01)

        return customerRepository.save(customer);
    }
}