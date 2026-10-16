package com.isp392.petfood.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// Mã OTP quên mật khẩu (mục 9.11, script FoodPetShop_PasswordResetOtp.sql).
// Chỉ lưu BCrypt của mã; mã hết hạn, đã dùng hoặc sai quá số lần cho phép thì không dùng được nữa.
@Entity
@Table(name = "PasswordResetOtp")
@Getter
@Setter
@NoArgsConstructor
public class PasswordResetOtp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "otp_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "account_id", nullable = false)
    private Account account;

    @Column(name = "otp_hash", nullable = false, length = 255)
    private String otpHash;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "failed_attempts", nullable = false)
    private int failedAttempts;

    @Column(name = "used_at")
    private LocalDateTime usedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public PasswordResetOtp(Account account, String otpHash, LocalDateTime createdAt, LocalDateTime expiresAt) {
        this.account = account;
        this.otpHash = otpHash;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }

    // Còn nhập được: chưa dùng, chưa hết hạn, chưa sai quá số lần
    public boolean isUsable(LocalDateTime now, int maxAttempts) {
        return usedAt == null && now.isBefore(expiresAt) && failedAttempts < maxAttempts;
    }
}
