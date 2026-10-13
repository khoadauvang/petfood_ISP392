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

import java.util.Collection;
import java.util.List;

@Getter
public class AccountPrincipal implements UserDetails, CredentialsContainer { //Người dùng nằm trong Session

    private final Long accountId;
    private final String email;
    private final Role role;
    private final String fullName;
    private final Long customerId; //khi role = CUSTOMER
    private final Long employeeId; //khi role = STAFF | ADMIN

    @Getter(AccessLevel.NONE)
    private String  passwordHash; //Bi xoa ngay sau khi dang nhap xong

    public AccountPrincipal(Account account, String fullName, Long customerId, Long employeeId) {
        this.employeeId = employeeId;
        this.customerId = customerId;
        this.passwordHash = account.getPasswordHash();
        this.fullName = fullName;
        this.role = account.getRole();
        this.email = account.getEmail();
        this.accountId = account.getId();
    }

    public static AccountPrincipal ofCustomer(Account account, Customer customer) {
        return new AccountPrincipal(account, customer.getFullName(), customer.getId(), null);
        //Gọi method Constructor ở trên
    }
    public static AccountPrincipal ofEmployee(Account account, Employee employee) {
        return new AccountPrincipal(account, employee.getFullName(), null, employee.getId());
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

}
