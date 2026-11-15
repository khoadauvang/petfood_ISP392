package com.isp392.petfood.enums;

// Tình trạng hàng của một sản phẩm, tính từ số lượng bán giá thường (lô còn hạn >= 90 ngày, BR-54)
// so với ngưỡng cảnh báo của sản phẩm, và số hàng cận hạn chỉ bán qua Flash Sale (BR-59).
// Dùng cho bộ lọc và nhãn ở trang quản lý sản phẩm.
public enum StockStatus {
    IN_STOCK("Còn hàng"),
    LOW_STOCK("Gần hết hàng"),                       // 0 < giá thường <= ngưỡng (BR-62)
    FLASH_SALE_ONLY("Chỉ còn hàng Flash Sale"),      // giá thường hết, còn hàng cận hạn bán qua Flash Sale
    OUT_OF_STOCK("Hết hàng");                        // không còn gì bán được

    private final String label;

    StockStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static StockStatus of(long sellableQty, long flashSaleQty, int lowStockThreshold) {
        if (sellableQty <= 0) {
            return flashSaleQty > 0 ? FLASH_SALE_ONLY : OUT_OF_STOCK;
        }
        return sellableQty <= lowStockThreshold ? LOW_STOCK : IN_STOCK;
    }
}
