package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Category;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.entity.ProductImage;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.PetType;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

// Dữ liệu trang chi tiết sản phẩm (và phần ảnh hiện tại ở form sửa) cho Staff/Admin
@Getter
public class ProductDetailDto {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final Long id;
    private final String sku;
    private final String barcode;
    private final String name;
    private final String brand;
    private final String description;
    private final Long categoryId;
    private final String categoryName;
    private final PetType categoryPetType;
    private final CategoryStatus categoryStatus;
    private final Species species;
    private final AgeGroup ageGroup;
    private final BigDecimal sellingPrice;
    private final int lowStockThreshold;
    private final ProductStatus status;
    private final String imageUrl;
    private final String createdAtText;

    // URL ảnh theo vị trí: phần tử 0 là ảnh số 1 ... phần tử 4 là ảnh số 5; null nếu vị trí đó chưa có ảnh.
    // JSP: ${product.imageSlots[0]} (dùng List thay cho Map<Integer,...> vì EL đổi số 1 thành Long, tra Map sẽ trượt)
    private final List<String> imageSlots;
    private final int imageCount;

    private final StockSummary stock;
    private final boolean lowStock;

    // Gọi bên trong transaction: product.getCategory() là LAZY
    public ProductDetailDto(Product product, List<ProductImage> images, StockSummary stock) {
        Category category = product.getCategory();
        this.id = product.getId();
        this.sku = product.getFullSku();
        this.barcode = product.getBarcode();
        this.name = product.getName();
        this.brand = product.getBrand();
        this.description = product.getDescription();
        this.categoryId = category.getId();
        this.categoryName = category.getName();
        this.categoryPetType = category.getPetType();
        this.categoryStatus = category.getStatus();
        this.species = product.getSpecies();
        this.ageGroup = product.getAgeGroup();
        this.sellingPrice = product.getSellingPrice();
        this.lowStockThreshold = product.getLowStockThreshold();
        this.status = product.getStatus();
        this.imageUrl = product.getImageUrl();
        this.createdAtText = product.getCreatedAt() == null ? "" : product.getCreatedAt().format(DATE_TIME);

        List<String> slots = new ArrayList<>(Collections.nCopies(ProductForm.IMAGE_COUNT, (String) null));
        int count = 0;
        for (ProductImage image : images) {
            int slot = image.getSortOrder();
            if (slot >= 1 && slot <= ProductForm.IMAGE_COUNT) {
                slots.set(slot - 1, image.getImageUrl());
                count++;
            }
        }
        String fallbackUrl = (slots.get(0) != null && !slots.get(0).isBlank()) ? slots.get(0) : this.imageUrl;
        if (fallbackUrl != null && !fallbackUrl.isBlank()) {
            for (int i = 0; i < ProductForm.IMAGE_COUNT; i++) {
                if (slots.get(i) == null || slots.get(i).isBlank()) {
                    slots.set(i, fallbackUrl);
                    count++;
                }
            }
        }
        this.imageSlots = Collections.unmodifiableList(slots);
        this.imageCount = count;

        this.stock = stock;
        this.lowStock = product.getStatus() == ProductStatus.ACTIVE
                && stock.getSellableQty() <= product.getLowStockThreshold();
    }
}
