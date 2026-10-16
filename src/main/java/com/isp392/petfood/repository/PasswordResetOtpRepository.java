package com.isp392.petfood.repository;

import com.isp392.petfood.entity.PasswordResetOtp;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.time.LocalDateTime;
import java.util.Optional;

public interface PasswordResetOtpRepository extends JpaRepository<PasswordResetOtp, Long> {

    // Mã mới nhất của tài khoản (chỉ mã này còn dùng được)
    Optional<PasswordResetOtp> findFirstByAccount_IdOrderByCreatedAtDescIdDesc(Long accountId);

    // Như trên nhưng khoá dòng: hai lần nhập mã cùng lúc không vượt được giới hạn số lần sai
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<PasswordResetOtp> findFirstWithLockByAccount_IdOrderByCreatedAtDescIdDesc(Long accountId);

    // Số mã đã gửi từ một thời điểm (giới hạn số email mỗi giờ)
    long countByAccount_IdAndCreatedAtAfter(Long accountId, LocalDateTime since);
}
