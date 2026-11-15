package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.StockStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductVariantDto {
    private Long id;
    private String sku;
    private String name;
    private String spec; // vd: 400g, 2kg
    private BigDecimal sellingPrice;
    private ProductStatus status;
    private String imageUrl;
    private int lowStockThreshold;
    private long onHandQty;          // tồn thực tế (mọi lô), không hiện trên bảng
    private long sellableQty;        // cột "Số lượng": bán thường được (lô còn hạn >= 90 ngày, trừ phần giữ cho khuyến mãi)
    private long flashSaleQty;       // cột "Flash Sale": hàng cận hạn chỉ bán qua Flash Sale
    private StockStatus stockStatus; // còn hàng / gần hết hàng / hết hàng (theo sellableQty)
    private String existingExpiriesIso;     // Danh sách HSD đang còn hàng (yyyy-MM-dd, cách nhau dấu phẩy) để chặn trùng HSD
    private String existingExpiriesDisplay; // Danh sách HSD đang còn hàng để hiển thị trên modal (dd/MM/yyyy - SL sp)
}
