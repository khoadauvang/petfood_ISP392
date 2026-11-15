package com.isp392.petfood.dto;

import com.isp392.petfood.enums.PaymentMethod;
import com.isp392.petfood.enums.PaymentStatus;
import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import com.isp392.petfood.util.CustomerMask;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

// Chi tiết yêu cầu trả hàng (trang của khách và của Staff)
@Getter
@Builder
public class ReturnDetailDto {
    private final Long id;
    private final Long orderId;
    private final ReturnReason reason;
    private final String description;
    private final ReturnStatus status;
    private final String rejectReason;
    private final String refundBankName;
    private final String refundAccountNo;
    private final String refundAccountHolder;
    private final String customerName;
    private final String customerEmail;
    private final String customerPhone;
    private final PaymentMethod paymentMethod;
    private final PaymentStatus paymentStatus;
    private final List<ReturnLineDto> lines;
    private final List<MediaDto> media;
    private final BigDecimal refundTotal;
    private final String createdAtText;
    private final String reviewedText;           // "dd/MM/yyyy HH:mm · tên nhân viên"
    private final String receivedAtText;
    private final String inspectedByName;
    private final String refundedAtText;

    // Bản đã che để hiện cho staff (giống Quản lý đơn hàng & Báo cáo hội viên)
    public String getMaskedCustomerName() {
        return CustomerMask.name(customerName);
    }

    public String getMaskedCustomerEmail() {
        return CustomerMask.email(customerEmail);
    }

    public String getMaskedCustomerPhone() {
        return CustomerMask.phone(customerPhone);
    }

    @Getter
    public static class MediaDto {
        private final boolean video;
        private final String url;

        public MediaDto(boolean video, String url) {
            this.video = video;
            this.url = url;
        }
    }
}
