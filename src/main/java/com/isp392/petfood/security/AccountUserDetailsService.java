package com.isp392.petfood.security;

import com.isp392.petfood.entity.Account;
import com.isp392.petfood.repository.AccountRepository;
import com.isp392.petfood.repository.CustomerRepository;
import com.isp392.petfood.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AccountUserDetailsService implements UserDetailsService {

    private final AccountRepository accountRepository;
    private final CustomerRepository customerRepository;
    private final EmployeeRepository employeeRepository;
    //final: moi field phai dc gan gia tri dung 1 lan!

    @Override
    @Transactional (readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // Email lưu chữ thường (RegistrationService, GoogleAccountService) nên đổi về chữ thường trước khi tìm
        String normalized = email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
        Account account = accountRepository.findByEmail(normalized)
                .orElseThrow(() -> new UsernameNotFoundException(("Email not found")));

        if (account.getPasswordHash() == null) {
            // Tk login by Goggle, no password to compare
            throw new UsernameNotFoundException("Account has no password");
        }

        return switch (account.getRole()) {
            case CUSTOMER -> customerRepository.findByAccountId((account.getId()))
                    .map(customer -> AccountPrincipal.ofCustomer(account, customer))
                    .orElseThrow(() -> missingProfile(account));
            case STAFF, ADMIN -> employeeRepository.findByAccountId(account.getId())
                    .map(employee -> AccountPrincipal.ofEmployee(account, employee))
                    .orElseThrow(() -> missingProfile(account));
        };
    }

    private static IllegalStateException missingProfile(Account account) {
        return new IllegalStateException(
                "Account " + account.getId() + " (" + account.getRole() + ") has no profile row"
        );
    }

}
