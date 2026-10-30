package com.isp392.petfood.service;

import com.isp392.petfood.dto.ChangePasswordForm;
import com.isp392.petfood.dto.CustomerProfileDto;
import com.isp392.petfood.dto.ProfileForm;
import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.enums.MembershipTier;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.InvalidImageException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;

// Hồ sơ khách hàng: họ tên, số điện thoại, ảnh đại diện (bảng Customer). Email và hạng chỉ xem.
@Service
@RequiredArgsConstructor
public class CustomerProfileService {

    // Ảnh đại diện hiện nhỏ nên thu về 400px; nhận ảnh từ 100×100 trở lên
    private static final int AVATAR_MAX_SIDE = 400;
    private static final int AVATAR_MIN_SIDE = 100;

    private final CustomerRepository customerRepository;
    private final ProductImageProcessor imageProcessor;
    private final AvatarStorage avatarStorage;
    private final PasswordEncoder passwordEncoder;
    private final MembershipService membershipService;
    private final MembershipPolicy membershipPolicy;

    @Transactional
    public CustomerProfileDto getProfile(Long customerId) {
        Customer customer = find(customerId);
        BigDecimal settledSpend = membershipService.getAndUpdateCustomerSpend(customer);

        MembershipTier currentTier = customer.getMembershipTier();
        BigDecimal nextTierSpend = membershipPolicy.nextTierSpend(currentTier);
        String nextTierLabel = membershipPolicy.nextTierLabel(currentTier);
        int progressPct = nextTierSpend.compareTo(BigDecimal.ZERO) > 0
                ? (int) Math.min(100, settledSpend.multiply(BigDecimal.valueOf(100)).divide(nextTierSpend, 0, RoundingMode.HALF_UP).longValue())
                : 100;

        Account account = customer.getAccount();
        return new CustomerProfileDto(
                account.getEmail(),
                customer.getFullName(),
                customer.getPhone(),
                customer.getAvatarUrl(),
                customer.getMembershipTier().getLabel(),
                membershipPolicy.rateOf(currentTier),
                account.getGoogleId() != null,
                account.getPasswordHash() != null,
                settledSpend,
                nextTierSpend,
                nextTierLabel,
                progressPct);
    }

    @Transactional(readOnly = true)
    public ProfileForm getForm(Long customerId) {
        Customer customer = find(customerId);
        ProfileForm form = new ProfileForm();
        form.setFullName(customer.getFullName());
        form.setPhone(customer.getPhone());
        return form;
    }

    @Transactional
    public CustomerProfileDto update(Long customerId, ProfileForm form) {
        Customer customer = find(customerId);
        String oldAvatar = customer.getAvatarUrl();

        MultipartFile file = form.getAvatar();
        if (file != null && !file.isEmpty()) {
            byte[] jpeg;
            try {
                jpeg = imageProcessor.toJpeg(file.getBytes(), AVATAR_MAX_SIDE, AVATAR_MIN_SIDE);
            } catch (InvalidImageException e) {
                throw new BusinessRuleException("avatar", "Ảnh đại diện: " + e.getMessage());
            } catch (IOException e) {
                throw new BusinessRuleException("avatar", "Không đọc được file ảnh đại diện");
            }
            customer.setAvatarUrl(avatarStorage.save(customerId, jpeg));
        } else if (form.isRemoveAvatar()) {
            customer.setAvatarUrl(null);
        }
        if (oldAvatar != null && !oldAvatar.equals(customer.getAvatarUrl())) {
            avatarStorage.deleteAfterCommit(oldAvatar);       // ảnh cũ không còn dùng
        }

        customer.setFullName(form.getFullName().trim());
        customer.setPhone(form.getPhone());                   // controller đã đổi chuỗi rỗng thành null
        return toDto(customer);
    }

    // Khách tự đổi mật khẩu (BR-02). Trả về accountId để controller đăng xuất các phiên khác.
    // Tài khoản chỉ đăng nhập Google chưa có mật khẩu: đặt mật khẩu bằng OTP qua email (mục 9.11).
    @Transactional
    public Long changePassword(Long customerId, ChangePasswordForm form) {
        Account account = find(customerId).getAccount();
        if (account.getPasswordHash() == null) {
            throw new BusinessRuleException("Tài khoản đăng nhập bằng Google chưa có mật khẩu. "
                    + "Hãy dùng \"Quên mật khẩu\" để nhận mã OTP qua email và tạo mật khẩu.");
        }
        if (!passwordEncoder.matches(form.getCurrentPassword(), account.getPasswordHash())) {
            throw new BusinessRuleException("currentPassword", "Mật khẩu hiện tại không đúng");
        }
        if (!form.getNewPassword().equals(form.getConfirmPassword())) {
            throw new BusinessRuleException("confirmPassword", "Mật khẩu nhập lại không khớp");
        }
        if (form.getNewPassword().equals(form.getCurrentPassword())) {
            throw new BusinessRuleException("newPassword", "Mật khẩu mới phải khác mật khẩu hiện tại");
        }
        account.setPasswordHash(passwordEncoder.encode(form.getNewPassword()));
        return account.getId();
    }

    private Customer find(Long customerId) {
        return customerRepository.findById(customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy khách hàng #" + customerId));
    }

    // Gọi trong transaction: customer.getAccount() là LAZY
    private CustomerProfileDto toDto(Customer customer) {
        Account account = customer.getAccount();
        return new CustomerProfileDto(
                account.getEmail(),
                customer.getFullName(),
                customer.getPhone(),
                customer.getAvatarUrl(),
                customer.getMembershipTier().getLabel(),
                membershipPolicy.rateOf(customer.getMembershipTier()),
                account.getGoogleId() != null,
                account.getPasswordHash() != null);
    }
}
