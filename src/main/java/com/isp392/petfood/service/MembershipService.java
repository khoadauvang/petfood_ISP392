package com.isp392.petfood.service;

import com.isp392.petfood.entity.Customer;
import com.isp392.petfood.enums.MembershipTier;
import com.isp392.petfood.repository.CustomerRepository;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.OrderRepository.CustomerAmountRow;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

// Cập nhật Customer.membership_tier theo chi tiêu tích luỹ (requirements 7.6, chốt 15/10 theo BR-40, BR-41):
//   chi tiêu = tiền hàng (total_amount − shipping_fee) các đơn COMPLETED đã qua hạn trả hàng 3 ngày
//            − tiền đã hoàn của yêu cầu trả hàng REFUNDED
// Đơn huỷ / khách không nhận không được tính. Hạng mới áp cho đơn đặt sau đó (BR-44) vì mức giảm chốt lúc đặt.
// Không lưu bảng điểm: mỗi lần chạy tính lại từ đơn hàng.
@Service
@RequiredArgsConstructor
public class MembershipService {

    private static final Logger log = LoggerFactory.getLogger(MembershipService.class);

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final MembershipPolicy membershipPolicy;

    // Chạy định kỳ tự động mỗi phút ở chế độ nền để nâng/hạ hạng hội viên ngay khi đủ điều kiện
    @Scheduled(fixedDelayString = "${petfood.membership.recalc-delay-ms:60000}", initialDelay = 15_000)
    public void scheduledRecalculate() {
        int changed = recalculateAll();
        if (changed > 0) {
            log.info("Tự động cập nhật hạng thành viên: {} khách đổi hạng", changed);
        }
    }

    // Tính lại ngay lúc khởi động: máy không chạy lúc 00:05 thì hạng vẫn được cập nhật
    @EventListener(ApplicationReadyEvent.class)
    public void recalculateOnStartup() {
        int changed = recalculateAll();
        log.info("Đồng bộ hạng thành viên lúc khởi động: {} khách đổi hạng", changed);
    }

    // Trả về số khách đổi hạng
    @Transactional
    public int recalculateAll() {
        LocalDateTime cutoff = VnpayClient.nowVn().minusDays(membershipPolicy.getReturnWindowDays());
        Map<Long, BigDecimal> spend = toMap(orderRepository.sumSettledGoodsByCustomer(cutoff));
        Map<Long, BigDecimal> refunds = toMap(orderRepository.sumRefundsByCustomer(cutoff));

        int changed = 0;
        for (Customer customer : customerRepository.findAll()) {
            BigDecimal total = spend.getOrDefault(customer.getId(), BigDecimal.ZERO)
                    .subtract(refunds.getOrDefault(customer.getId(), BigDecimal.ZERO));
            MembershipTier tier = membershipPolicy.tierFor(total);
            if (tier != customer.getMembershipTier()) {
                customer.setMembershipTier(tier);
                changed++;
            }
        }
        return changed;
    }

    // Tính chi tiêu thực tế đã chốt của 1 khách hàng và tự động cập nhật hạng nếu đủ điều kiện
    @Transactional
    public BigDecimal getAndUpdateCustomerSpend(Customer customer) {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(membershipPolicy.getReturnWindowDays());
        Map<Long, BigDecimal> spend = toMap(orderRepository.sumSettledGoodsByCustomer(cutoff));
        Map<Long, BigDecimal> refunds = toMap(orderRepository.sumRefundsByCustomer(cutoff));

        BigDecimal total = spend.getOrDefault(customer.getId(), BigDecimal.ZERO)
                .subtract(refunds.getOrDefault(customer.getId(), BigDecimal.ZERO))
                .max(BigDecimal.ZERO);
        MembershipTier tier = membershipPolicy.tierFor(total);
        if (tier != customer.getMembershipTier()) {
            customer.setMembershipTier(tier);
        }
        return total;
    }

    private static Map<Long, BigDecimal> toMap(List<CustomerAmountRow> rows) {
        return rows.stream().collect(Collectors.toMap(CustomerAmountRow::getCustomerId, CustomerAmountRow::getAmount));
    }
}
