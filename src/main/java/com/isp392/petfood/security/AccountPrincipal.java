package com.isp392.petfood.security;

import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.entity.Employee;
import com.isp392.petfood.enums.Role;
import lombok.AccessLevel;
import lombok.Getter;
import org.springframework.security.core.CredentialsContainer;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.OidcUserInfo;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

import java.util.Collection;
import java.util.List;
import java.util.Map;

// Người dùng nằm trong Session. Dùng chung cho cả 2 cách đăng nhập:
//   - email + mật khẩu (UserDetails)
//   - Google (OidcUser, cũng là OAuth2User)
// nhờ vậy controller / JSP chỉ cần biết một kiểu: @AuthenticationPrincipal AccountPrincipal, ${currentUser}.
@Getter
public class AccountPrincipal implements UserDetails, OidcUser, CredentialsContainer {

    private final Long accountId;
    private final String email;
    private final Role role;
    private final String fullName;
    private final String avatarUrl;   // chỉ khách hàng có; null nếu chưa tải ảnh
    private final Long customerId; //khi role = CUSTOMER
    private final Long employeeId; //khi role = STAFF | ADMIN

    @Getter(AccessLevel.NONE)
    private String  passwordHash; //Bi xoa ngay sau khi dang nhap xong

    // Chỉ có khi đăng nhập bằng Google; đăng nhập mật khẩu thì rỗng / null
    private final Map<String, Object> attributes;
    private final OidcIdToken idToken;
    private final OidcUserInfo userInfo;

    private AccountPrincipal(Long accountId, String email, Role role, String passwordHash,
                             String fullName, String avatarUrl, Long customerId, Long employeeId,
                             Map<String, Object> attributes, OidcIdToken idToken, OidcUserInfo userInfo) {
        this.accountId = accountId;
        this.email = email;
        this.role = role;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.avatarUrl = avatarUrl;
        this.customerId = customerId;
        this.employeeId = employeeId;
        this.attributes = attributes == null ? Map.of() : Map.copyOf(attributes);
        this.idToken = idToken;
        this.userInfo = userInfo;
    }

    public static AccountPrincipal ofCustomer(Account account, Customer customer) {
        return new AccountPrincipal(account.getId(), account.getEmail(), account.getRole(), account.getPasswordHash(),
                customer.getFullName(), customer.getAvatarUrl(), customer.getId(), null, null, null, null);
    }

    public static AccountPrincipal ofEmployee(Account account, Employee employee) {
        return new AccountPrincipal(account.getId(), account.getEmail(), account.getRole(), account.getPasswordHash(),
                employee.getFullName(), null, null, employee.getId(), null, null, null);
    }

    // Khách đăng nhập bằng Google: giữ lại thông tin Google trả về (Spring Security cần cho OidcUser)
    public static AccountPrincipal ofGoogleCustomer(Account account, Customer customer, Map<String, Object> attributes,
                                                    OidcIdToken idToken, OidcUserInfo userInfo) {
        return new AccountPrincipal(account.getId(), account.getEmail(), account.getRole(), null,
                customer.getFullName(), customer.getAvatarUrl(), customer.getId(), null,
                attributes, idToken, userInfo);
    }

    // Bản sao sau khi khách sửa hồ sơ: tên / ảnh trên thanh đầu trang đổi ngay, không cần đăng nhập lại
    public AccountPrincipal withProfile(String newFullName, String newAvatarUrl) {
        return new AccountPrincipal(accountId, email, role, null, newFullName, newAvatarUrl,
                customerId, employeeId, attributes, idToken, userInfo);
    }

    public boolean isGoogleLogin() {
        return !attributes.isEmpty();
    }

    //Implementing interfaces UserDetails & CredentialsContainer
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() { //Cung cấp list các quyền mà user này có
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name())); //Quy ước "ROLE_"
    }

    @Override public String getPassword() { return passwordHash; }
    @Override public String getUsername() { return email;}

    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return true; }

    @Override
    public void eraseCredentials() {
        this.passwordHash = null;
    }

    // ===== OidcUser / OAuth2User =====
    @Override
    public Map<String, Object> getClaims() {
        return attributes;
    }

    @Override
    public String getName() {
        return email;
    }
}
