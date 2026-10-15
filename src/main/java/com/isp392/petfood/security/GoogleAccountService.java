package com.isp392.petfood.security;

import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.enums.Role;
import com.isp392.petfood.repository.AccountRepository;
import com.isp392.petfood.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.Map;

// Đăng nhập Google cho KHÁCH HÀNG (BR-05). Google xác thực xong trả về sub / email / name, service này đổi
// thành tài khoản trong DB:
//   1. Đã có Account với google_id = sub          -> đăng nhập luôn
//   2. Chưa có, nhưng có Account cùng email        -> gắn google_id vào tài khoản đó (khách từng đăng ký bằng mật khẩu)
//   3. Chưa có gì                                   -> tạo Account (không mật khẩu, CK_Account_login_method) + Customer hạng BRONZE
// Tài khoản STAFF / ADMIN không được đăng nhập bằng Google, chỉ dùng email + mật khẩu (BR-05).
@Service
@RequiredArgsConstructor
public class GoogleAccountService {

    private final AccountRepository accountRepository;
    private final CustomerRepository customerRepository;

    @Transactional
    public AccountPrincipal loadOrRegister(OAuth2User googleUser) {
        Map<String, Object> attrs = googleUser.getAttributes();
        String googleId = stringAttr(attrs, "sub");
        String email = stringAttr(attrs, "email");
        if (googleId == null || email == null) {
            throw fail("Google không trả về email của tài khoản. Hãy cấp quyền xem email rồi thử lại.");
        }
        // Chỉ tin email Google đã xác minh, nếu không ai đó có thể chiếm tài khoản cùng email trong shop
        if (!isTrue(attrs.get("email_verified"))) {
            throw fail("Email Google chưa được xác minh, không dùng để đăng nhập được.");
        }
        email = email.trim().toLowerCase(Locale.ROOT);

        Account account = accountRepository.findByGoogleId(googleId).orElse(null);
        if (account == null) {
            account = accountRepository.findByEmail(email).orElse(null);
            if (account != null && account.getRole() == Role.CUSTOMER) {
                if (account.getGoogleId() != null) {
                    // Email này đã gắn với một tài khoản Google khác
                    throw fail("Email này đã liên kết với một tài khoản Google khác.");
                }
                account.setGoogleId(googleId);
            }
        }
        if (account != null && account.getRole() != Role.CUSTOMER) {
            throw fail("Tài khoản nhân viên chỉ đăng nhập bằng email và mật khẩu.");
        }
        if (account == null) {
            account = createAccount(email, googleId);
        }

        Account saved = account;
        Customer customer = customerRepository.findByAccountId(saved.getId())
                .orElseGet(() -> createCustomer(saved, stringAttr(attrs, "name")));

        if (googleUser instanceof OidcUser oidc) {
            return AccountPrincipal.ofGoogleCustomer(saved, customer, attrs, oidc.getIdToken(), oidc.getUserInfo());
        }
        return AccountPrincipal.ofGoogleCustomer(saved, customer, attrs, null, null);
    }

    private Account createAccount(String email, String googleId) {
        Account account = new Account();
        account.setEmail(email);
        account.setGoogleId(googleId);       // password_hash để null: chỉ đăng nhập bằng Google
        account.setRole(Role.CUSTOMER);
        try {
            return accountRepository.saveAndFlush(account);
        } catch (DataIntegrityViolationException e) {
            // Bấm đăng nhập 2 lần cùng lúc: UQ_Account_email / UX_Account_google_id chặn bản thứ hai
            throw fail("Không tạo được tài khoản, vui lòng thử đăng nhập lại.");
        }
    }

    // Account + Customer luôn đi cùng nhau (giống RegistrationService); hạng mặc định BRONZE
    private Customer createCustomer(Account account, String googleName) {
        String fullName = googleName == null || googleName.isBlank()
                ? account.getEmail().substring(0, account.getEmail().indexOf('@'))
                : googleName.trim();
        Customer customer = new Customer();
        customer.setAccount(account);
        customer.setFullName(fullName.length() > 100 ? fullName.substring(0, 100) : fullName);
        return customerRepository.save(customer);
    }

    private static String stringAttr(Map<String, Object> attrs, String name) {
        Object value = attrs.get(name);
        return value == null ? null : value.toString();
    }

    private static boolean isTrue(Object value) {
        return Boolean.TRUE.equals(value) || "true".equalsIgnoreCase(String.valueOf(value));
    }

    // Lỗi này làm đăng nhập thất bại; câu báo hiện ở trang /login?googleError
    private static OAuth2AuthenticationException fail(String message) {
        return new OAuth2AuthenticationException(new OAuth2Error("google_login_rejected"), message);
    }
}
