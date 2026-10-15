package com.isp392.petfood.service;

import com.isp392.petfood.dto.CustomerProfileDto;
import com.isp392.petfood.dto.ProfileForm;
import com.isp392.petfood.entity.Account;
import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.InvalidImageException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

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

    @Transactional(readOnly = true)
    public CustomerProfileDto getProfile(Long customerId) {
        return toDto(find(customerId));
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

    private Customer find(Long customerId) {
        return customerRepository.findById(customerId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy khách hàng #" + customerId));
    }

    // Gọi trong transaction: customer.getAccount() là LAZY
    private static CustomerProfileDto toDto(Customer customer) {
        Account account = customer.getAccount();
        return new CustomerProfileDto(
                account.getEmail(),
                customer.getFullName(),
                customer.getPhone(),
                customer.getAvatarUrl(),
                customer.getMembershipTier().getLabel(),
                account.getGoogleId() != null,
                account.getPasswordHash() != null);
    }
}
