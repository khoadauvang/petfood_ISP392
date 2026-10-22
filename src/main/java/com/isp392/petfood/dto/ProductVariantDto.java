package com.isp392.petfood.dto;

import com.isp392.petfood.enums.ProductStatus;
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
    private String barcode;
    private String name;
    private String spec; // vd: 400g, 2kg
    private BigDecimal sellingPrice;
    private ProductStatus status;
    private String imageUrl;
    private int lowStockThreshold;
    private long onHandQty;
    private long sellableQty;
    private boolean lowStock;
}
