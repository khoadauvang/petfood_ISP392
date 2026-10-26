package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import lombok.Getter;

import java.math.BigDecimal;

// Một dòng ở trang quản lý sản phẩm của Staff/Admin
@Getter
public class ProductAdminRow {

    private final Long id;
    private final String sku;
    private final String barcode;
    private final String name;
    private final String brand;
    private final String categoryName;
    private final Species species;
    private final AgeGroup ageGroup;
    private final BigDecimal sellingPrice;
    private final ProductStatus status;
    private final String imageUrl;          // ảnh đại diện (ảnh số 1)
    private final int lowStockThreshold;
    private final long onHandQty;           // tồn thực tế
    private final long sellableQty;         // tồn bán thường
    private final boolean lowStock;         // đang bán và tồn bán thường <= ngưỡng (BR-62)

    // product phải đã có category (query dùng join fetch)
    public ProductAdminRow(Product product, StockSummary stock) {
        this.id = product.getId();
        this.sku = product.getFullSku();
        this.barcode = product.getBarcode();
        this.name = product.getName();
        this.brand = product.getBrand();
        this.categoryName = product.getCategory().getName();
        this.species = product.getSpecies();
        this.ageGroup = product.getAgeGroup();
        this.sellingPrice = product.getSellingPrice();
        this.status = product.getStatus();
        this.imageUrl = product.getImageUrl();
        this.lowStockThreshold = product.getLowStockThreshold();
        this.onHandQty = stock.getOnHandQty();
        this.sellableQty = stock.getSellableQty();
        this.lowStock = product.getStatus() == ProductStatus.ACTIVE
                && stock.getSellableQty() <= product.getLowStockThreshold();
    }
}
