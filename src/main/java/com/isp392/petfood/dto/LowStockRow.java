package com.isp392.petfood.dto;

import com.isp392.petfood.repository.ProductRepository.LowStockView;
import lombok.Getter;

// Một sản phẩm đang bán có tồn bán thường <= ngưỡng tồn thấp (BR-62)
@Getter
public class LowStockRow {

    private final Long productId;
    private final String sku;
    private final String name;
    private final String imageUrl;
    private final int threshold;
    private final long sellableQty;    // tồn bán thường (lô còn >= 90 ngày)
    private final long onHandQty;      // tồn thực tế mọi lô, kể cả lô cận hạn

    public LowStockRow(LowStockView view) {
        this.productId = view.getProductId();
        this.sku = view.getSku();
        this.name = view.getName();
        this.imageUrl = view.getImageUrl();
        this.threshold = view.getThreshold();
        this.sellableQty = view.getSellableQty() == null ? 0 : view.getSellableQty();
        this.onHandQty = view.getOnHandQty() == null ? 0 : view.getOnHandQty();
    }

    public boolean isOutOfStock() {
        return sellableQty == 0;
    }
}
