package com.isp392.petfood.service;

import com.isp392.petfood.enums.MembershipTier;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

// Ngưỡng và mức giảm của các hạng thành viên, đọc từ application.properties (requirements 7.6):
//   Đồng từ 0đ giảm 0,1% · Bạc từ 1.200.000đ giảm 3% · Vàng từ 4.000.000đ giảm 5% · Kim cương từ 10.000.000đ giảm 10%
@Component
public class MembershipPolicy {

    @Getter
    private final int returnWindowDays;
    private final BigDecimal silverMin;
    private final BigDecimal goldMin;
    private final BigDecimal diamondMin;
    private final BigDecimal bronzeRate;
    private final BigDecimal silverRate;
    private final BigDecimal goldRate;
    private final BigDecimal diamondRate;

    public MembershipPolicy(@Value("${petfood.membership.return-window-days:3}") int returnWindowDays,
                            @Value("${petfood.membership.silver-min-spend:1200000}") BigDecimal silverMin,
                            @Value("${petfood.membership.gold-min-spend:4000000}") BigDecimal goldMin,
                            @Value("${petfood.membership.diamond-min-spend:10000000}") BigDecimal diamondMin,
                            @Value("${petfood.membership.bronze-rate:0.10}") BigDecimal bronzeRate,
                            @Value("${petfood.membership.silver-rate:3}") BigDecimal silverRate,
                            @Value("${petfood.membership.gold-rate:5}") BigDecimal goldRate,
                            @Value("${petfood.membership.diamond-rate:10}") BigDecimal diamondRate) {
        this.returnWindowDays = returnWindowDays;
        this.silverMin = silverMin;
        this.goldMin = goldMin;
        this.diamondMin = diamondMin;
        this.bronzeRate = bronzeRate;
        this.silverRate = silverRate;
        this.goldRate = goldRate;
        this.diamondRate = diamondRate;
    }

    // Hạng ứng với tổng chi tiêu tích luỹ
    public MembershipTier tierFor(BigDecimal spend) {
        if (spend.compareTo(diamondMin) >= 0) {
            return MembershipTier.DIAMOND;
        }
        if (spend.compareTo(goldMin) >= 0) {
            return MembershipTier.GOLD;
        }
        if (spend.compareTo(silverMin) >= 0) {
            return MembershipTier.SILVER;
        }
        return MembershipTier.BRONZE;
    }

    // Phần trăm giảm của hạng, đúng đơn vị cột Orders.tier_discount_rate (0.10 = 0,1%)
    public BigDecimal rateOf(MembershipTier tier) {
        return switch (tier) {
            case BRONZE -> bronzeRate;
            case SILVER -> silverRate;
            case GOLD -> goldRate;
            case DIAMOND -> diamondRate;
        };
    }
}
