package com.isp392.petfood.dto;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

// Form thêm / sửa sản phẩm (multipart/form-data vì có file ảnh).
// name của các input trên JSP trùng tên field: sku, barcode, name, brand, description, categoryId, species,
// ageGroup, sellingPrice, lowStockThreshold, status, image1..image5, firstLotExpiryDate, firstLotQty.
// Controller đã gắn StringTrimmerEditor: chuỗi được cắt khoảng trắng, ô bỏ trống thành null.
@Getter
@Setter
public class ProductForm {

    public static final int IMAGE_COUNT = 5;

    // Id sản phẩm gốc khi thêm biến thể mới cho dòng sản phẩm (null = thêm sản phẩm bình thường)
    private Long variantOf;

    // SKU dùng làm tên thư mục ảnh nên chỉ cho chữ in hoa, số và dấu gạch ngang (setter tự đổi sang chữ in hoa)
    @NotBlank(message = "Vui lòng nhập SKU")
    @Size(max = 50, message = "SKU tối đa 50 ký tự")
    @Pattern(regexp = "^[A-Z0-9]+(-[A-Z0-9]+)*$",
            message = "SKU chỉ gồm chữ A-Z, số 0-9 và dấu gạch ngang, ví dụ RC-KITTEN36-400G")
    private String sku;

    @Size(max = 50, message = "Mã vạch tối đa 50 ký tự")
    @Pattern(regexp = "^[0-9A-Za-z-]*$", message = "Mã vạch chỉ gồm chữ, số và dấu gạch ngang")
    private String barcode;            // không bắt buộc

    @NotBlank(message = "Vui lòng nhập tên sản phẩm")
    @Size(max = 200, message = "Tên sản phẩm tối đa 200 ký tự")
    private String name;

    @Size(max = 100, message = "Nhãn hàng tối đa 100 ký tự")
    private String brand;

    @Size(max = 4000, message = "Mô tả tối đa 4000 ký tự")
    private String description;

    @NotNull(message = "Vui lòng chọn danh mục")
    private Long categoryId;

    @NotNull(message = "Vui lòng chọn loài")
    private Species species;

    @NotNull(message = "Vui lòng chọn nhóm tuổi")
    private AgeGroup ageGroup;

    @NotNull(message = "Vui lòng nhập giá bán")
    @DecimalMin(value = "1", message = "Giá bán phải lớn hơn 0")
    @Digits(integer = 12, fraction = 0, message = "Giá bán là số nguyên (đồng), tối đa 12 chữ số")
    private BigDecimal sellingPrice;

    @NotNull(message = "Vui lòng nhập ngưỡng tồn thấp")
    @Min(value = 0, message = "Ngưỡng tồn thấp không được âm")
    @Max(value = 1_000_000, message = "Ngưỡng tồn thấp quá lớn")
    private Integer lowStockThreshold = 0;

    @NotNull(message = "Vui lòng chọn trạng thái")
    private ProductStatus status = ProductStatus.ACTIVE;

    // 5 ảnh theo vị trí, ảnh 1 là ảnh đại diện.
    // Thêm mới: bắt buộc đủ 5. Sửa: chỉ chọn ảnh ở vị trí muốn thay, ô bỏ trống thì giữ ảnh cũ.
    private MultipartFile image1;
    private MultipartFile image2;
    private MultipartFile image3;
    private MultipartFile image4;
    private MultipartFile image5;

    // Lô đầu tiên, không bắt buộc, chỉ dùng khi thêm mới (hàng về cùng lúc tạo sản phẩm).
    // Điền thì phải điền cả hai ô.
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate firstLotExpiryDate;

    @Min(value = 1, message = "Số lượng nhập phải lớn hơn 0")
    @Max(value = 1_000_000, message = "Số lượng nhập quá lớn")
    private Integer firstLotQty;

    public void setSku(String sku) {
        this.sku = (sku == null) ? null : sku.toUpperCase(Locale.ROOT);
    }

    // Ảnh theo vị trí: phần tử 0 là image1 ... phần tử 4 là image5 (có thể null hoặc file rỗng)
    public List<MultipartFile> imagesBySlot() {
        return Arrays.asList(image1, image2, image3, image4, image5);
    }

    public boolean hasFirstLot() {
        return firstLotExpiryDate != null || firstLotQty != null;
    }

    // Đổ dữ liệu sản phẩm có sẵn vào form sửa (ảnh thì JSP hiện từ ProductDetailDto)
    public static ProductForm from(Product product) {
        ProductForm form = new ProductForm();
        form.setSku(product.getSku());
        form.setBarcode(product.getBarcode());
        form.setName(product.getName());
        form.setBrand(product.getBrand());
        form.setDescription(product.getDescription());
        form.setCategoryId(product.getCategory().getId());
        form.setSpecies(product.getSpecies());
        form.setAgeGroup(product.getAgeGroup());
        form.setSellingPrice(product.getSellingPrice());
        form.setLowStockThreshold(product.getLowStockThreshold());
        form.setStatus(product.getStatus());
        return form;
    }
}
