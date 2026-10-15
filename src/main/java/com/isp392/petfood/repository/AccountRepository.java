package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Long> {

    Optional<Account> findByEmail(String email);

    boolean existsByEmail(String email);

    // Đăng nhập Google: "sub" của Google lưu ở Account.google_id (UX_Account_google_id)
    Optional<Account> findByGoogleId(String googleId);
}
