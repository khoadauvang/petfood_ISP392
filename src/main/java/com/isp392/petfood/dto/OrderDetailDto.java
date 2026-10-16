package com.isp392.petfood.dto;

import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentStatus;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Chi tiết một đơn (trang của khách và của Staff dùng chung)
@Getter
@Builder
public class OrderDetailDto {
    private final Long id;
    private final OrderStatus status;
    private final PaymentMethod paymentMethod;
    private final PaymentStatus paymentStatus;
    private final String shippingAddress;
    private final String customerName;
    private final String customerEmail;
    private final String customerPhone;       // SĐT người nhận = SĐT trong hồ sơ khách (chốt 15/10)
    private final List<OrderLineDto> lines;
    private final BigDecimal subtotal;
    private final BigDecimal tierDiscountRate;
    private final BigDecimal discountTotal;
    private final BigDecimal shippingFee;
    private final BigDecimal totalAmount;
    private final String createdAtText;
    private final String confirmedAtText;
    private final String confirmedByName;
    private final String packedByName;
    private final String shippedAtText;
    private final String completedAtText;
    private final String cancelledAtText;
    private final String returnedAtText;
    private final String cancelReason;
    private final boolean cancelRequested;    // đang PROCESSING và khách đã gửi yêu cầu huỷ
    private final boolean needsRefund;        // đơn VNPay đã trả tiền nhưng bị huỷ: staff phải hoàn tiền
    private final List<String> payments;      // các lần thanh toán (bảng Payment)
    private final String vnpayHoldUntil;      // đơn VNPay chờ thanh toán: hạn giữ hàng; null nếu không áp dụng

    // BR-19: khách tự huỷ khi PENDING / CONFIRMED; khi PROCESSING chỉ gửi yêu cầu cho staff duyệt
    public boolean isCustomerCanCancel() {
        return status == OrderStatus.PENDING || status == OrderStatus.CONFIRMED;
    }

    public boolean isAwaitingVnpay() {
        return paymentMethod == PaymentMethod.VNPAY && status == OrderStatus.PENDING
                && paymentStatus == PaymentStatus.UNPAID && vnpayHoldUntil != null;
    }

    public boolean isCustomerCanRequestCancel() {
        return status == OrderStatus.PROCESSING && !cancelRequested;
    }
}
