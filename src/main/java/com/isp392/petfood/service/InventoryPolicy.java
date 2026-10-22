package com.isp392.petfood.service;

import com.isp392.petfood.enums.ExpiryLevel;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

// Các mốc hạn dùng của kho, đọc từ application.properties (Admin cấu hình được, theo ghi chú đầu mục 4 Business Rules):
//   petfood.shelf-life-commitment-days = 90  -> lô còn >= 90 ngày mới bán thường (BR-12, BR-54); dưới 90 là cảnh báo đỏ (BR-59)
//   petfood.quarantine-days            = 21  -> lô còn < 21 ngày không được bán dưới mọi hình thức (BR-51, BR-63)
//   petfood.flash-sale.*                       -> mức giảm Flash Sale theo HSD: 30-89 ngày giảm 40%, 21-29 ngày giảm 70%
// ProductService (trang chủ) đọc cùng khoá shelf-life-commitment-days nên hai nơi luôn tính tồn bán thường giống nhau.
@Component
@Getter
public class InventoryPolicy {

    private final int shelfLifeCommitmentDays;
    private final int quarantineDays;
    private final int deepDiscountDays;
    private final int discountPercent;
    private final int deepDiscountPercent;

    public InventoryPolicy(@Value("${petfood.shelf-life-commitment-days:90}") int shelfLifeCommitmentDays,
                           @Value("${petfood.quarantine-days:21}") int quarantineDays,
                           @Value("${petfood.flash-sale.deep-discount-days:30}") int deepDiscountDays,
                           @Value("${petfood.flash-sale.discount-percent:40}") int discountPercent,
                           @Value("${petfood.flash-sale.deep-discount-percent:70}") int deepDiscountPercent) {
        this.shelfLifeCommitmentDays = shelfLifeCommitmentDays;
        this.quarantineDays = quarantineDays;
        this.deepDiscountDays = deepDiscountDays;
        this.discountPercent = discountPercent;
        this.deepDiscountPercent = deepDiscountPercent;
    }

    public LocalDate today() {
        return LocalDate.now();
    }

    // Lô có HSD từ ngày này trở đi mới tính vào tồn bán thường
    public LocalDate minSellableExpiry() {
        return today().plusDays(shelfLifeCommitmentDays);
    }

    // Lô có HSD từ ngày này trở đi mới được bán qua Flash Sale (dưới 21 ngày thì không bán, BR-63).
    // Lô RED = HSD trong [minFlashSaleExpiry, minSellableExpiry).
    public LocalDate minFlashSaleExpiry() {
        return today().plusDays(quarantineDays);
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

    // Mức giảm Flash Sale (%) theo số ngày còn lại của lô RED: còn dưới 30 ngày giảm sâu hơn
    public int flashSaleDiscountPercent(LocalDate expiryDate) {
        return daysLeft(expiryDate) < deepDiscountDays ? deepDiscountPercent : discountPercent;
    }

    // Giá Flash Sale = giá thường trừ mức giảm theo HSD, làm tròn tới đồng
    public BigDecimal flashSalePrice(BigDecimal sellingPrice, LocalDate expiryDate) {
        BigDecimal keep = BigDecimal.valueOf(100 - flashSaleDiscountPercent(expiryDate));
        return sellingPrice.multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
    }
}
