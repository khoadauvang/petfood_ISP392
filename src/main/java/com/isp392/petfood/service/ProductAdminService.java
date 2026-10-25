package com.isp392.petfood.service;

import com.isp392.petfood.dto.ProductAdminRow;
import com.isp392.petfood.dto.ProductDetailDto;
import com.isp392.petfood.dto.ProductForm;
import com.isp392.petfood.dto.ProductGroupDto;
import com.isp392.petfood.dto.ProductOption;
import com.isp392.petfood.dto.ProductVariantDto;
import com.isp392.petfood.dto.StockSummary;
import com.isp392.petfood.entity.Category;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.entity.ProductImage;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.InvalidImageException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.CategoryRepository;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.LotRepository.StockSummaryRow;
import com.isp392.petfood.repository.ProductImageRepository;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.isp392.petfood.dto.ProductForm.IMAGE_COUNT;

// Quản lý sản phẩm của Staff/Admin (FR-10): thêm kèm 5 ảnh, sửa, thay ảnh, ẩn/hiện, xoá sản phẩm chưa phát sinh dữ liệu.
// Khác ProductService: class đó chỉ phục vụ trang khách (chỉ đọc).
@Service
@RequiredArgsConstructor
public class ProductAdminService {

    private static final int PAGE_SIZE = 20;
    private static final long MAX_IMAGE_BYTES = 5L * 1024 * 1024;   // khớp spring.servlet.multipart.max-file-size

    private static final Pattern SPEC_PATTERN = Pattern.compile(
            "(?i)(?:[\\s–-]+(?:vị\\s+[^\\d]+)?[\\s(]*(\\d+(?:[.,]\\d+)?\\s*(?:kg|g|gr|ml|l|hộp|gói|lon|bao|túi|can|viên|miếng|thùng|pcs))[)]?\\s*)$"
    );
    private static final Pattern SKU_VARIANT_PATTERN = Pattern.compile(
            "(?i)-(?:\\d+(?:[.,]\\d+)?[A-Z]*)$"
    );

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ProductImageRepository productImageRepository;
    private final LotRepository lotRepository;
    private final LotService lotService;
    private final InventoryPolicy inventoryPolicy;
    private final ProductImageProcessor imageProcessor;
    private final ProductImageStorage imageStorage;

    // =====================================================================
    // ĐỌC
    // =====================================================================

    // pageNumber tính từ 0. Sản phẩm mới thêm đứng đầu.
    @Transactional(readOnly = true)
    public Page<ProductAdminRow> search(String keyword, Long categoryId, Species species,
                                        ProductStatus status, int pageNumber) {
        Pageable pageable = PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id"));
        Page<Product> products = productRepository.search(keyword, categoryId, species, status, pageable);

        List<Long> ids = products.getContent().stream().map(Product::getId).toList();
        Map<Long, StockSummary> stock = loadStock(ids);
        return products.map(p -> new ProductAdminRow(p, stock.getOrDefault(p.getId(), StockSummary.EMPTY)));
    }

    // Gom nhóm các sản phẩm thành dòng sản phẩm cha và các biến thể (Master-Detail Accordion)
    @Transactional(readOnly = true)
    public List<ProductGroupDto> getProductGroups(String keyword, Long categoryId, Species species, ProductStatus status) {
        Pageable pageable = PageRequest.of(0, 500, Sort.by(Sort.Direction.DESC, "id"));
        Page<Product> page = productRepository.search(keyword, categoryId, species, status, pageable);
        List<Product> products = page.getContent();

        List<Long> ids = products.stream().map(Product::getId).toList();
        Map<Long, StockSummary> stock = loadStock(ids);

        Map<String, ProductGroupDto> groupMap = new LinkedHashMap<>();

        for (Product p : products) {
            StockSummary ss = stock.getOrDefault(p.getId(), StockSummary.EMPTY);
            ProductAdminRow row = new ProductAdminRow(p, ss);

            // Tách tên gốc và quy cách
            String fullName = p.getName() != null ? p.getName().trim() : "";
            String baseName = baseName(fullName);
            String spec = "Tiêu chuẩn";

            Matcher matcher = SPEC_PATTERN.matcher(fullName);
            if (matcher.find()) {
                spec = matcher.group(1).trim();
            }

            // Tách SKU gốc
            String baseSku = baseSku(p.getSku());

            String groupKey = !baseSku.isEmpty() ? baseSku.toLowerCase() : baseName.toLowerCase();

            ProductGroupDto group = groupMap.get(groupKey);
            if (group == null) {
                group = new ProductGroupDto();
                group.setGroupId(groupKey.replaceAll("[^a-z0-9_-]", "-"));
                group.setBaseName(baseName);
                group.setBaseSku(baseSku);
                group.setBrand(p.getBrand());
                group.setCategoryName(p.getCategory() != null ? p.getCategory().getName() : "");
                group.setSpecies(p.getSpecies());
                group.setAgeGroup(p.getAgeGroup());
                group.setImageUrl(p.getImageUrl());
                groupMap.put(groupKey, group);
            }

            ProductVariantDto variant = ProductVariantDto.builder()
                    .id(p.getId())
                    .sku(p.getSku())
                    .barcode(p.getBarcode())
                    .name(p.getName())
                    .spec(spec)
                    .sellingPrice(p.getSellingPrice())
                    .status(p.getStatus())
                    .imageUrl(p.getImageUrl())
                    .lowStockThreshold(p.getLowStockThreshold())
                    .onHandQty(ss.getOnHandQty())
                    .sellableQty(ss.getSellableQty())
                    .lowStock(row.isLowStock())
                    .build();

            group.getVariants().add(variant);

            // Cập nhật thống kê nhóm
            if (group.getMinPrice() == null || (variant.getSellingPrice() != null && variant.getSellingPrice().compareTo(group.getMinPrice()) < 0)) {
                group.setMinPrice(variant.getSellingPrice());
            }
            if (group.getMaxPrice() == null || (variant.getSellingPrice() != null && variant.getSellingPrice().compareTo(group.getMaxPrice()) > 0)) {
                group.setMaxPrice(variant.getSellingPrice());
            }
            group.setTotalOnHand(group.getTotalOnHand() + variant.getOnHandQty());
            group.setTotalSellable(group.getTotalSellable() + variant.getSellableQty());
            if (variant.getStatus() == ProductStatus.ACTIVE) {
                group.setActiveCount(group.getActiveCount() + 1);
            } else {
                group.setDiscontinuedCount(group.getDiscontinuedCount() + 1);
            }
            if (variant.isLowStock()) {
                group.setAnyLowStock(true);
            }
            if ((group.getImageUrl() == null || group.getImageUrl().isBlank()) && variant.getImageUrl() != null) {
                group.setImageUrl(variant.getImageUrl());
            }
        }

        // Sắp xếp các biến thể trong từng nhóm theo giá tăng dần (vd: 400g trước, 2kg sau)
        for (ProductGroupDto g : groupMap.values()) {
            g.getVariants().sort((v1, v2) -> {
                if (v1.getSellingPrice() == null) return -1;
                if (v2.getSellingPrice() == null) return 1;
                return v1.getSellingPrice().compareTo(v2.getSellingPrice());
            });
        }

        return new ArrayList<>(groupMap.values());
    }


    @Transactional(readOnly = true)
    public ProductDetailDto getDetail(Long id) {
        Product product = productRepository.findWithCategoryById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy sản phẩm #" + id));
        List<ProductImage> images = productImageRepository.findByProduct_IdOrderBySortOrderAsc(id);
        StockSummary stock = loadStock(List.of(id)).getOrDefault(id, StockSummary.EMPTY);
        return new ProductDetailDto(product, images, stock);
    }

    @Transactional(readOnly = true)
    public ProductForm getForm(Long id) {
        return ProductForm.from(findOrThrow(id));
    }

    // Form "Thêm biến thể" (/staff/products/new?variantOf=..): điền sẵn thông tin chung của sản phẩm gốc,
    // tên / SKU chỉ còn phần gốc để nhân viên gõ thêm quy cách. Ảnh để trống thì lấy ảnh sản phẩm gốc (xem create).
    @Transactional(readOnly = true)
    public ProductForm buildVariantForm(Long parentId) {
        Product parent = findOrThrow(parentId);
        ProductForm form = new ProductForm();
        form.setVariantOf(parentId);
        String baseName = baseName(parent.getName());
        String baseSku = baseSku(parent.getSku());
        form.setName(baseName.isEmpty() ? "" : baseName + " ");
        form.setSku(baseSku.isEmpty() ? "" : baseSku + "-");
        form.setCategoryId(parent.getCategory() != null ? parent.getCategory().getId() : null);
        form.setBrand(parent.getBrand());
        form.setSpecies(parent.getSpecies());
        form.setAgeGroup(parent.getAgeGroup());
        form.setDescription(parent.getDescription());
        form.setSellingPrice(parent.getSellingPrice());
        form.setLowStockThreshold(parent.getLowStockThreshold());
        form.setStatus(ProductStatus.ACTIVE);
        return form;
    }

    @Transactional(readOnly = true)
    public List<ProductOption> listOptions() {
        return productRepository.findAllByOrderBySkuAsc().stream().map(ProductOption::new).toList();
    }

    // =====================================================================
    // THÊM: Product + 5 ProductImage (+ lô đầu tiên nếu có) trong CÙNG một transaction.
    // Thiếu/lỗi ảnh nào thì không lưu gì cả (ghi chú 1 trong FoodPetShop_ProductImage.sql).
    // =====================================================================
    @Transactional
    public Product create(ProductForm form) {
        // 1. Kiểm tra hết rồi báo lỗi một lần, nhân viên sửa một lượt là xong
        Map<String, String> errors = new LinkedHashMap<>();
        Category category = checkCategory(form, errors);
        checkUnique(form, null, errors);
        checkFirstLot(form, errors);
        // Bắt buộc đủ 5 ảnh; riêng biến thể thì ô bỏ trống lấy ảnh cùng vị trí của sản phẩm gốc
        boolean variant = form.getVariantOf() != null;
        Map<Integer, byte[]> images = processImages(form, !variant, errors);
        if (variant) {
            inheritImages(form.getVariantOf(), images, errors);
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        // 2. Lưu Product trước để có product_id. saveAndFlush đẩy INSERT xuống DB ngay,
        //    nếu SKU/mã vạch vừa bị người khác dùng thì UNIQUE báo lỗi ở đây, trước khi ghi file ảnh.
        Product product = new Product();
        copy(form, category, product);
        saveAndFlush(product);

        // 3. Ghi 5 file ảnh + 5 dòng ProductImage. Nếu bước sau lỗi, transaction rollback
        //    và ProductImageStorage tự xoá các file vừa ghi.
        List<ProductImage> rows = new ArrayList<>();
        for (int slot = 1; slot <= IMAGE_COUNT; slot++) {
            String url = imageStorage.save(product.getSku(), slot, images.get(slot));
            rows.add(new ProductImage(product, slot, url));
        }
        productImageRepository.saveAll(rows);
        product.setImageUrl(rows.get(0).getImageUrl());     // ảnh đại diện = ảnh số 1

        // 4. Lô đầu tiên (nếu hàng về cùng lúc)
        if (form.hasFirstLot()) {
            lotService.receive(product, form.getFirstLotExpiryDate(), form.getFirstLotQty());
        }
        return product;
    }

    // =====================================================================
    // SỬA: cập nhật thông tin; ảnh nào được chọn lại thì thay đúng vị trí đó (UPDATE image_url, không xoá dòng).
    // =====================================================================
    @Transactional
    public Product update(Long id, ProductForm form) {
        Product product = findOrThrow(id);

        Map<String, String> errors = new LinkedHashMap<>();
        Category category = checkCategory(form, errors);
        checkUnique(form, id, errors);
        Map<Integer, byte[]> newImages = processImages(form, false, errors);  // chỉ các ô có chọn file

        // Sau khi sửa vẫn phải đủ 5 ảnh (dữ liệu cũ có thể thiếu: vị trí trống bắt buộc chọn ảnh)
        Map<Integer, ProductImage> currentBySlot = new HashMap<>();
        for (ProductImage image : productImageRepository.findByProduct_IdOrderBySortOrderAsc(id)) {
            currentBySlot.put(image.getSortOrder(), image);
        }
        for (int slot = 1; slot <= IMAGE_COUNT; slot++) {
            String field = "image" + slot;
            if (!currentBySlot.containsKey(slot) && !newImages.containsKey(slot) && !errors.containsKey(field)) {
                errors.put(field, "Sản phẩm phải đủ 5 ảnh: vị trí " + slot + " đang trống, hãy chọn ảnh");
            }
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        copy(form, category, product);
        saveAndFlush(product);

        for (Map.Entry<Integer, byte[]> entry : newImages.entrySet()) {
            int slot = entry.getKey();
            String url = imageStorage.save(product.getSku(), slot, entry.getValue());
            ProductImage row = currentBySlot.get(slot);
            if (row == null) {
                currentBySlot.put(slot, productImageRepository.save(new ProductImage(product, slot, url)));
            } else {
                imageStorage.deleteAfterCommit(row.getImageUrl());   // file cũ chỉ xoá khi đã commit thành công
                row.setImageUrl(url);
            }
        }
        product.setImageUrl(currentBySlot.get(1).getImageUrl());  // luôn đồng bộ với ảnh số 1
        return product;
    }

    // Ẩn / hiện: ACTIVE <-> DISCONTINUED. Sản phẩm ngừng kinh doanh không hiện ở trang khách.
    @Transactional
    public Product toggleStatus(Long id) {
        Product product = findOrThrow(id);
        product.setStatus(product.getStatus() == ProductStatus.ACTIVE
                ? ProductStatus.DISCONTINUED
                : ProductStatus.ACTIVE);
        return product;
    }

    // Xoá hẳn: chỉ cho sản phẩm tạo nhầm, chưa có lô / đơn hàng / giỏ hàng / đánh giá (BR-11).
    // Trả về SKU để controller báo lại.
    @Transactional
    public String delete(Long id) {
        Product product = findOrThrow(id);
        if (lotRepository.existsByProduct_Id(id)) {
            throw new BusinessRuleException("Sản phẩm " + product.getSku()
                    + " đã có lô hàng nên không xoá được (BR-11). Hãy chuyển sang Ngừng kinh doanh.");
        }
        List<ProductImage> images = productImageRepository.findByProduct_IdOrderBySortOrderAsc(id);
        productImageRepository.deleteAll(images);       // bảng con trước, bảng cha sau
        productRepository.delete(product);
        try {
            productRepository.flush();
        } catch (DataIntegrityViolationException e) {
            // CartItem / OrderItem / ProductReview... còn trỏ tới sản phẩm (khoá ngoại NO ACTION)
            throw new BusinessRuleException("Sản phẩm " + product.getSku()
                    + " đã phát sinh dữ liệu khác (giỏ hàng, đơn hàng, đánh giá...) nên không xoá được. "
                    + "Hãy chuyển sang Ngừng kinh doanh.");
        }
        images.forEach(image -> imageStorage.deleteAfterCommit(image.getImageUrl()));
        return product.getSku();
    }

    // =====================================================================
    // KIỂM TRA
    // =====================================================================

    // Danh mục phải tồn tại; danh mục DOG/CAT chỉ chứa sản phẩm đúng loài đó, ALL chứa cả hai
    private Category checkCategory(ProductForm form, Map<String, String> errors) {
        Category category = categoryRepository.findById(form.getCategoryId()).orElse(null);
        if (category == null) {
            errors.put("categoryId", "Danh mục không tồn tại");
            return null;
        }
        if (!category.getPetType().accepts(form.getSpecies())) {
            errors.put("species", "Danh mục \"" + category.getName() + "\" chỉ dành cho "
                    + category.getPetType().getLabel().toLowerCase(Locale.ROOT)
                    + ", hãy chọn đúng loài hoặc đổi danh mục");
        }
        return category;
    }

    // SKU duy nhất; mã vạch duy nhất nếu có nhập (BR-08). excludeId = id sản phẩm đang sửa.
    private void checkUnique(ProductForm form, Long excludeId, Map<String, String> errors) {
        boolean skuTaken = (excludeId == null)
                ? productRepository.existsBySku(form.getSku())
                : productRepository.existsBySkuAndIdNot(form.getSku(), excludeId);
        if (skuTaken) {
            errors.put("sku", "SKU " + form.getSku() + " đã được dùng cho sản phẩm khác");
        }
        if (form.getBarcode() != null) {
            boolean barcodeTaken = (excludeId == null)
                    ? productRepository.existsByBarcode(form.getBarcode())
                    : productRepository.existsByBarcodeAndIdNot(form.getBarcode(), excludeId);
            if (barcodeTaken) {
                errors.put("barcode", "Mã vạch " + form.getBarcode() + " đã được dùng cho sản phẩm khác");
            }
        }
    }

    // Lô đầu tiên: điền thì phải điền đủ HSD + số lượng; sản phẩm phải đang bán
    private void checkFirstLot(ProductForm form, Map<String, String> errors) {
        if (!form.hasFirstLot()) {
            return;
        }
        if (form.getFirstLotExpiryDate() == null) {
            errors.put("firstLotExpiryDate", "Nhập lô đầu tiên thì cần cả hạn sử dụng");
        } else {
            String problem = lotService.expiryProblemForNewLot(form.getFirstLotExpiryDate());
            if (problem != null) {
                errors.put("firstLotExpiryDate", problem);
            }
        }
        if (form.getFirstLotQty() == null) {
            errors.put("firstLotQty", "Nhập lô đầu tiên thì cần cả số lượng");
        }
        if (form.getStatus() != ProductStatus.ACTIVE) {
            errors.put("status", "Sản phẩm ngừng kinh doanh thì không nhập lô đầu tiên");
        }
    }

    // Chuẩn hoá từng ảnh. Trả về Map vị trí -> nội dung JPG; ảnh lỗi được ghi vào errors với tên ô image1..image5.
    private Map<Integer, byte[]> processImages(ProductForm form, boolean requireAll, Map<String, String> errors) {
        Map<Integer, byte[]> result = new TreeMap<>();
        List<MultipartFile> files = form.imagesBySlot();
        for (int slot = 1; slot <= IMAGE_COUNT; slot++) {
            MultipartFile file = files.get(slot - 1);
            String field = "image" + slot;
            if (file == null || file.isEmpty()) {
                if (requireAll) {
                    errors.put(field, "Chưa chọn ảnh số " + slot);
                }
                continue;
            }
            if (file.getSize() > MAX_IMAGE_BYTES) {
                errors.put(field, "Ảnh số " + slot + " lớn hơn 5MB");
                continue;
            }
            try {
                result.put(slot, imageProcessor.toJpeg(file.getBytes()));
            } catch (InvalidImageException e) {
                errors.put(field, "Ảnh số " + slot + ": " + e.getMessage());
            } catch (IOException e) {
                errors.put(field, "Không đọc được file ảnh số " + slot);
            }
        }
        return result;
    }

    // Chép nội dung ảnh của sản phẩm gốc vào các vị trí nhân viên chưa chọn file. Ghi thành file mới theo SKU
    // của biến thể (không dùng chung URL): sửa / thay ảnh sản phẩm gốc sau này không ảnh hưởng biến thể.
    private void inheritImages(Long parentId, Map<Integer, byte[]> images, Map<String, String> errors) {
        findOrThrow(parentId);                                  // sản phẩm gốc phải còn tồn tại
        Map<Integer, String> parentUrls = new HashMap<>();
        for (ProductImage image : productImageRepository.findByProduct_IdOrderBySortOrderAsc(parentId)) {
            parentUrls.put(image.getSortOrder(), image.getImageUrl());
        }
        for (int slot = 1; slot <= IMAGE_COUNT; slot++) {
            String field = "image" + slot;
            if (images.containsKey(slot) || errors.containsKey(field)) {
                continue;
            }
            byte[] bytes = imageStorage.readBytes(parentUrls.get(slot));
            if (bytes == null) {
                errors.put(field, "Sản phẩm gốc không có ảnh số " + slot + ", hãy chọn ảnh");
            } else {
                images.put(slot, bytes);
            }
        }
    }

    // Tên gốc của dòng sản phẩm: bỏ phần quy cách ở cuối (vd "... 400g")
    private static String baseName(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "";
        }
        String name = fullName.trim();
        Matcher matcher = SPEC_PATTERN.matcher(name);
        return matcher.find() ? name.substring(0, matcher.start()).trim() : name;
    }

    // SKU gốc của dòng sản phẩm: bỏ đuôi quy cách (vd "-400G")
    private static String baseSku(String sku) {
        if (sku == null || sku.isBlank()) {
            return "";
        }
        String baseSku = SKU_VARIANT_PATTERN.matcher(sku.trim()).replaceAll("").trim();
        return baseSku.isEmpty() ? sku.trim() : baseSku;
    }

    // =====================================================================
    // HỖ TRỢ
    // =====================================================================

    private void saveAndFlush(Product product) {
        try {
            productRepository.saveAndFlush(product);
        } catch (DataIntegrityViolationException e) {
            // Hai người lưu cùng SKU / mã vạch gần như cùng lúc: kiểm tra exists đã qua nhưng UNIQUE của DB chặn lại
            throw new BusinessRuleException("SKU hoặc mã vạch vừa được dùng cho sản phẩm khác, hãy kiểm tra lại");
        }
    }

    private Product findOrThrow(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy sản phẩm #" + id));
    }

    private static void copy(ProductForm form, Category category, Product product) {
        product.setSku(form.getSku());
        product.setBarcode(form.getBarcode());          // null nếu bỏ trống (UNIQUE có lọc chỉ xét dòng khác NULL)
        product.setName(form.getName());
        product.setBrand(form.getBrand());
        product.setDescription(form.getDescription());
        product.setCategory(category);
        product.setSpecies(form.getSpecies());
        product.setAgeGroup(form.getAgeGroup());
        product.setSellingPrice(form.getSellingPrice());
        product.setLowStockThreshold(form.getLowStockThreshold());
        product.setStatus(form.getStatus());
    }

    // productId -> (tồn thực tế, tồn bán thường), 1 câu query cho cả danh sách
    private Map<Long, StockSummary> loadStock(List<Long> productIds) {
        if (productIds.isEmpty()) {
            return Map.of();
        }
        return lotRepository.summarizeStock(productIds, inventoryPolicy.minSellableExpiry()).stream()
                .collect(Collectors.toMap(StockSummaryRow::getProductId,
                        row -> new StockSummary(orZero(row.getOnHandQty()), orZero(row.getSellableQty()))));
    }

    private static long orZero(Long value) {
        return value == null ? 0 : value;
    }
}
