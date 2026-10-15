package com.isp392.petfood.service;

import com.isp392.petfood.enums.ExpiryLevel;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

// Các mốc hạn dùng của kho, đọc từ application.properties (Admin cấu hình được, theo ghi chú đầu mục 4 Business Rules):
//   petfood.shelf-life-commitment-days = 90  -> lô còn >= 90 ngày mới bán thường (BR-12, BR-54); dưới 90 là cảnh báo đỏ (BR-59)
//   petfood.quarantine-days            = 21  -> lô còn < 21 ngày không được bán dưới mọi hình thức (BR-51, BR-63)
// ProductService (trang chủ) đọc cùng khoá shelf-life-commitment-days nên hai nơi luôn tính tồn bán thường giống nhau.
@Component
@Getter
public class InventoryPolicy {

    private final int shelfLifeCommitmentDays;
    private final int quarantineDays;

    public InventoryPolicy(@Value("${petfood.shelf-life-commitment-days:90}") int shelfLifeCommitmentDays,
                           @Value("${petfood.quarantine-days:21}") int quarantineDays) {
        this.shelfLifeCommitmentDays = shelfLifeCommitmentDays;
        this.quarantineDays = quarantineDays;
    }

    public LocalDate today() {
        return LocalDate.now();
    }

    // Lô có HSD từ ngày này trở đi mới tính vào tồn bán thường
    public LocalDate minSellableExpiry() {
        return today().plusDays(shelfLifeCommitmentDays);
    }

    // Số ngày còn lại tới HSD (âm = đã quá hạn)
    public long daysLeft(LocalDate expiryDate) {
        return ChronoUnit.DAYS.between(today(), expiryDate);
    }

    public ExpiryLevel levelOf(LocalDate expiryDate) {
        long days = daysLeft(expiryDate);
        if (days < 0) {
            return ExpiryLevel.EXPIRED;
        }
        if (days < quarantineDays) {
            return ExpiryLevel.BLOCKED;
        }
        if (days < shelfLifeCommitmentDays) {
            return ExpiryLevel.RED;
        }
        return ExpiryLevel.OK;
    }
}
