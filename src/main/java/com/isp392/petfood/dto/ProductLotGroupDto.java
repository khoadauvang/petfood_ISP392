package com.isp392.petfood.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

// Nhóm sản phẩm kèm danh sách các lô hàng theo thứ tự FEFO (cho màn hình Tồn kho giống Figma)
@Getter
@Setter
public class ProductLotGroupDto {
    private Long productId;
    private String sku;
    private String productName;
    private String imageUrl;
    private String categoryName;
    private int lowStockThreshold;
    private long totalReceived;     // Tổng số lượng nhập vào kho (receive)
    private long totalOnHand;       // Tổng số lượng còn lại trong kho (on hand)
    private long reservedQty;      // Giữ chỗ (đơn hàng chưa giao)
    private long sellableQty;      // Tồn khả dụng bán thường (HSD >= 90 ngày)
    private long flashSaleQty;     // Tồn cận hạn Flash Sale (21 <= HSD < 90)
    private long criticalQty;      // Tồn nguy cấp (< 21 ngày hoặc quá hạn)
    private int activeLotCount;    // Số lô còn hàng
    private int totalLotCount;     // Tổng số lô
    private String stockStatus;    // "IN_STOCK", "LOW_STOCK", "OUT_OF_STOCK"
    private String expiryStatus;   // "SAFE", "WARNING", "CRITICAL", "NONE"
    private List<LotRow> lots = new ArrayList<>();

    public ProductLotGroupDto(Long productId, String sku, String productName, String imageUrl,
                             String categoryName, int lowStockThreshold) {
        this.productId = productId;
        this.sku = sku;
        this.productName = productName;
        this.imageUrl = imageUrl;
        this.categoryName = categoryName;
        this.lowStockThreshold = lowStockThreshold;
        this.totalReceived = 0;
        this.totalOnHand = 0;
        this.reservedQty = 0;
        this.sellableQty = 0;
        this.flashSaleQty = 0;
        this.criticalQty = 0;
        this.activeLotCount = 0;
        this.totalLotCount = 0;
    }

    public void addLot(LotRow lot) {
        lots.add(lot);
        totalLotCount++;
        totalReceived += lot.getReceivedQty();
        totalOnHand += lot.getOnHandQty();
        if (lot.getOnHandQty() > 0) {
            activeLotCount++;
            if (lot.getLevel() != null) {
                switch (lot.getLevel()) {
                    case OK -> sellableQty += lot.getOnHandQty();
                    case RED -> flashSaleQty += lot.getOnHandQty();
                    case BLOCKED, EXPIRED -> criticalQty += lot.getOnHandQty();
                }
            }
        }
    }

    public void finalizeStatus() {
        if (totalOnHand <= 0) {
            stockStatus = "OUT_OF_STOCK";
        } else if (sellableQty <= lowStockThreshold) {
            stockStatus = "LOW_STOCK";
        } else {
            stockStatus = "IN_STOCK";
        }

        if (criticalQty > 0) {
            expiryStatus = "CRITICAL";
        } else if (flashSaleQty > 0) {
            expiryStatus = "WARNING";
        } else if (activeLotCount > 0) {
            expiryStatus = "SAFE";
        } else {
            expiryStatus = "NONE";
        }
    }
}
