package com.isp392.petfood.service;

import com.isp392.petfood.dto.OtpResetForm;
import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.PasswordResetOtp;
import com.isp392.petfood.enums.AccountStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.repository.AccountRepository;
import com.isp392.petfood.repository.PasswordResetOtpRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;

// Quên mật khẩu bằng OTP qua email (mục 9.11, FE-12):
//   - mã 6 số ngẫu nhiên (SecureRandom), chỉ lưu BCrypt; hiệu lực 10 phút, dùng một lần
//   - nhập sai 5 lần thì mã bị huỷ; chỉ mã mới nhất của tài khoản còn dùng được
//   - gửi lại sau ít nhất 60 giây, tối đa 5 mã mỗi giờ cho một tài khoản (chống spam email)
//   - không cho biết email có tài khoản hay không: email lạ, tài khoản bị khoá hay đang chờ gửi lại
//     đều trả về như đã gửi; nhập mã sai, hết hạn hay đã huỷ đều báo cùng một câu
// Các mốc thời gian / số lần đặt trong application.properties (petfood.password-reset.*).
@Service
public class PasswordResetService {

    public static final String INVALID_OTP = "Mã OTP không đúng hoặc đã hết hạn.";

    private static final SecureRandom RANDOM = new SecureRandom();

    private final AccountRepository accountRepository;
    private final PasswordResetOtpRepository otpRepository;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetMailer mailer;
    private final int validMinutes;
    private final int maxAttempts;
    private final int resendSeconds;
    private final int maxPerHour;

    public PasswordResetService(AccountRepository accountRepository, PasswordResetOtpRepository otpRepository,
                                PasswordEncoder passwordEncoder, PasswordResetMailer mailer,
                                @Value("${petfood.password-reset.otp-minutes:10}") int validMinutes,
                                @Value("${petfood.password-reset.max-attempts:5}") int maxAttempts,
                                @Value("${petfood.password-reset.resend-seconds:60}") int resendSeconds,
                                @Value("${petfood.password-reset.max-per-hour:5}") int maxPerHour) {
        this.accountRepository = accountRepository;
        this.otpRepository = otpRepository;
        this.passwordEncoder = passwordEncoder;
        this.mailer = mailer;
        this.validMinutes = validMinutes;
        this.maxAttempts = maxAttempts;
        this.resendSeconds = resendSeconds;
        this.maxPerHour = maxPerHour;
    }

    public static String normalizeEmail(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

    public int getValidMinutes() {
        return validMinutes;
    }

    public int getMaxAttempts() {
        return maxAttempts;
    }

    public int getResendSeconds() {
        return resendSeconds;
    }

    // Tạo và gửi mã mới nếu email thuộc một tài khoản đang hoạt động. Không gửi thì im lặng (không lộ tài khoản).
    // Gửi email lỗi: ném MailException, transaction rollback nên mã không bị tính vào giới hạn gửi.
    @Transactional
    public void requestOtp(String email) throws MailException {
        Optional<Account> found = accountRepository.findByEmail(normalizeEmail(email));
        if (found.isEmpty() || found.get().getStatus() == AccountStatus.LOCKED) {
            return;
        }
        Account account = found.get();
        LocalDateTime now = VnpayClient.nowVn();
        Optional<PasswordResetOtp> latest = otpRepository.findFirstByAccount_IdOrderByCreatedAtDescIdDesc(account.getId());
        if (latest.isPresent() && latest.get().getCreatedAt().isAfter(now.minusSeconds(resendSeconds))) {
            return;   // vừa gửi xong, chờ đủ thời gian mới gửi lại
        }
        if (otpRepository.countByAccount_IdAndCreatedAtAfter(account.getId(), now.minusHours(1)) >= maxPerHour) {
            return;
        }

        String otp = String.format("%06d", RANDOM.nextInt(1_000_000));
        otpRepository.save(new PasswordResetOtp(account, passwordEncoder.encode(otp), now, now.plusMinutes(validMinutes)));
        mailer.sendOtp(account.getEmail(), otp, validMinutes);
    }

    // Đúng mã: đổi mật khẩu, đánh dấu mã đã dùng, trả về accountId để controller đăng xuất các phiên đang mở.
    // Sai mã: tăng số lần sai rồi báo lỗi; noRollbackFor để số lần sai vẫn được lưu.
    @Transactional(noRollbackFor = BusinessRuleException.class)
    public Long resetPassword(String email, OtpResetForm form) {
        if (!form.getNewPassword().equals(form.getConfirmPassword())) {
            throw new BusinessRuleException("confirmPassword", "Mật khẩu nhập lại không khớp");
        }
        Account account = accountRepository.findByEmail(normalizeEmail(email))
                .filter(a -> a.getStatus() == AccountStatus.ACTIVE)
                .orElseThrow(() -> new BusinessRuleException("otp", INVALID_OTP));
        LocalDateTime now = VnpayClient.nowVn();
        PasswordResetOtp otp = otpRepository.findFirstWithLockByAccount_IdOrderByCreatedAtDescIdDesc(account.getId())
                .filter(o -> o.isUsable(now, maxAttempts))
                .orElseThrow(() -> new BusinessRuleException("otp", INVALID_OTP));
        if (!passwordEncoder.matches(form.getOtp(), otp.getOtpHash())) {
            otp.setFailedAttempts(otp.getFailedAttempts() + 1);
            throw new BusinessRuleException("otp", INVALID_OTP);
        }

        otp.setUsedAt(now);
        account.setPasswordHash(passwordEncoder.encode(form.getNewPassword()));
        return account.getId();
    }
}
