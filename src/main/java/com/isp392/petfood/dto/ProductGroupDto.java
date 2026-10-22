package com.isp392.petfood.dto;

import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class ProductGroupDto {
    private String groupId;
    private String baseName;
    private String brand;
    private String categoryName;
    private Species species;
    private AgeGroup ageGroup;
    private String imageUrl;
    private String baseSku;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private long totalOnHand;
    private long totalSellable;
    private int activeCount;
    private int discontinuedCount;
    private boolean anyLowStock;
    private List<ProductVariantDto> variants = new ArrayList<>();

    public int getVariantCount() {
        return variants.size();
    }

    public boolean isSinglePrice() {
        return minPrice != null && maxPrice != null && minPrice.compareTo(maxPrice) == 0;
    }

    public String getSpecsSummary() {
        if (variants == null || variants.isEmpty()) return "";
        return String.join(", ", variants.stream().map(ProductVariantDto::getSpec).toList());
    }
}
