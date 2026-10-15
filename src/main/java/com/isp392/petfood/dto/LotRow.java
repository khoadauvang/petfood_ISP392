package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Lot;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ExpiryLevel;
import com.isp392.petfood.enums.ProductStatus;
import lombok.Getter;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

// Một lô ở trang "Tồn theo lô", trang chi tiết sản phẩm và trang cảnh báo.
// Ngày đã định dạng sẵn dd/MM/yyyy vì <fmt:formatDate> của JSTL không nhận LocalDate.
@Getter
public class LotRow {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final Long id;
    private final Long productId;
    private final String sku;
    private final String productName;
    private final ProductStatus productStatus;
    private final LocalDate expiryDate;
    private final String expiryDateText;
    private final long daysLeft;            // âm = đã quá hạn
    private final ExpiryLevel level;        // OK / RED / BLOCKED / EXPIRED, tính theo hôm nay
    private final int receivedQty;
    private final int onHandQty;
    private final String receivedAtText;
    private final boolean untouched;        // chưa xuất đơn vị nào -> còn được sửa / xoá khi nhập nhầm

    // lot.getProduct() phải lấy được (query join fetch hoặc đang trong transaction).
    // daysLeft, level do LotService tính theo InventoryPolicy (mốc 90 / 21 ngày đọc từ cấu hình).
    public LotRow(Lot lot, long daysLeft, ExpiryLevel level) {
        Product product = lot.getProduct();
        this.id = lot.getId();
        this.productId = product.getId();
        this.sku = product.getSku();
        this.productName = product.getName();
        this.productStatus = product.getStatus();
        this.expiryDate = lot.getExpiryDate();
        this.expiryDateText = lot.getExpiryDate().format(DATE);
        this.daysLeft = daysLeft;
        this.level = level;
        this.receivedQty = lot.getReceivedQty();
        this.onHandQty = lot.getOnHandQty();
        this.receivedAtText = lot.getReceivedAt() == null ? "" : lot.getReceivedAt().format(DATE_TIME);
        this.untouched = lot.isUntouched();
    }

    public boolean isDepleted() {
        return onHandQty == 0;
    }
}
