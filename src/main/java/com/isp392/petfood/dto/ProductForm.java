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
// name của các input trên JSP trùng tên field: sku, variant, name, brand, description, categoryId, species,
// ageGroup, sellingPrice, lowStockThreshold, status, image1..image5, firstLotExpiryDate, firstLotQty.
// Controller đã gắn StringTrimmerEditor: chuỗi được cắt khoảng trắng, ô bỏ trống thành null.
@Getter
@Setter
public class ProductForm {

    public static final int IMAGE_COUNT = 5;

    // Id sản phẩm gốc khi thêm biến thể mới cho dòng sản phẩm (null = thêm sản phẩm bình thường)
    private Long variantOf;

    // Mã sản phẩm (cột sku) = số thứ tự của dòng sản phẩm, chung cho các quy cách: 01, 02, 03...
    // Hệ thống tự cấp, nhân viên không nhập: thêm mới thì lấy số kế tiếp, thêm biến thể thì dùng mã của sản phẩm gốc,
    // sửa thì giữ mã cũ (ProductAdminService). Giá trị gửi lên từ form bị bỏ qua, chỉ dùng để hiện lại.
    private String sku;

    // Không có dấu gạch ngang: phần sau dấu '-' cuối của mã đầy đủ luôn là biến thể
    @NotBlank(message = "Vui lòng nhập biến thể (quy cách)")
    @Size(max = 20, message = "Biến thể tối đa 20 ký tự")
    @Pattern(regexp = "^[A-Z0-9.]+$",
            message = "Biến thể chỉ gồm chữ A-Z, số 0-9 và dấu chấm, ví dụ 400G, 1.5KG")
    private String variant;

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

    // Ngưỡng cảnh báo "Gần hết hàng": số lượng có thể bán <= mức này thì sản phẩm bị đánh dấu (BR-62)
    @NotNull(message = "Vui lòng nhập ngưỡng cảnh báo gần hết hàng")
    @Min(value = 0, message = "Ngưỡng cảnh báo không được âm")
    @Max(value = 1_000_000, message = "Ngưỡng cảnh báo quá lớn")
    private Integer lowStockThreshold = Product.DEFAULT_LOW_STOCK_THRESHOLD;   // form thêm mới điền sẵn 10

    @NotNull(message = "Vui lòng chọn trạng thái")
    private ProductStatus status = ProductStatus.ACTIVE;

    // Tối đa 5 ảnh theo vị trí, ảnh 1 là ảnh đại diện.
    // Thêm mới: bắt buộc ảnh 1, ảnh 2–5 tuỳ chọn. Sửa: chỉ chọn ảnh ở vị trí muốn thay, ô bỏ trống thì giữ ảnh cũ.
    private MultipartFile image1;
    private MultipartFile image2;
    private MultipartFile image3;
    private MultipartFile image4;
    private MultipartFile image5;

    // Số lượng + hạn sử dụng của hàng nhận cùng lúc thêm sản phẩm (tạo lô đầu tiên). Chỉ có ở form thêm mới
    // và bắt buộc ở đó; ProductAdminService.create kiểm tra (form sửa không gửi 2 ô này nên không đặt @NotNull).
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate firstLotExpiryDate;

    @Min(value = 1, message = "Số lượng phải lớn hơn 0")
    @Max(value = 1_000_000, message = "Số lượng quá lớn")
    private Integer firstLotQty;

    public void setSku(String sku) {
        this.sku = (sku == null) ? null : sku.toUpperCase(Locale.ROOT);
    }

    public void setVariant(String variant) {
        this.variant = (variant == null) ? null : variant.toUpperCase(Locale.ROOT);
    }

    // Mã đầy đủ để báo lỗi / hiện lại cho nhân viên: 05-400G
    public String getFullSku() {
        return sku + "-" + variant;
    }

    // Ảnh theo vị trí: phần tử 0 là image1 ... phần tử 4 là image5 (có thể null hoặc file rỗng)
    public List<MultipartFile> imagesBySlot() {
        return Arrays.asList(image1, image2, image3, image4, image5);
    }

    // Đổ dữ liệu sản phẩm có sẵn vào form sửa (ảnh thì JSP hiện từ ProductDetailDto)
    public static ProductForm from(Product product) {
        ProductForm form = new ProductForm();
        form.setSku(product.getSku());
        form.setVariant(product.getVariant());
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
