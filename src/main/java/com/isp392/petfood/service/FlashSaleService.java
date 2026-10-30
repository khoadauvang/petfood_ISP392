package com.isp392.petfood.service;

import com.isp392.petfood.dto.ActiveFlashSaleProductRow;
import com.isp392.petfood.dto.FlashSaleForm;
import com.isp392.petfood.dto.FlashSaleItemForm;
import com.isp392.petfood.dto.FlashSaleItemRow;
import com.isp392.petfood.dto.FlashSaleOffer;
import com.isp392.petfood.dto.FlashSaleRow;
import com.isp392.petfood.dto.NormalLotOption;
import com.isp392.petfood.dto.RedLotOption;
import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.entity.FlashSaleItem;
import com.isp392.petfood.entity.Lot;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ExpiryLevel;
import com.isp392.petfood.enums.FlashSaleStatus;
import com.isp392.petfood.enums.SaleType;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.FlashSaleItemRepository;
import com.isp392.petfood.repository.FlashSaleRepository;
import com.isp392.petfood.repository.LotRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

// Quản lý Chương trình khuyến mãi (Promotion) & Flash Sale xả hàng cận date
@Service
@RequiredArgsConstructor
public class FlashSaleService {

    private static final Logger log = LoggerFactory.getLogger(FlashSaleService.class);
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final FlashSaleRepository flashSaleRepository;
    private final FlashSaleItemRepository flashSaleItemRepository;
    private final LotRepository lotRepository;
    private final EmployeeRepository employeeRepository;
    private final InventoryPolicy inventoryPolicy;

    // ===== BẢNG 2: Danh sách Chương trình khuyến mãi (Promotion) =====
    @Transactional(readOnly = true)
    public List<FlashSaleRow> list() {
        return flashSaleRepository.findAllForList().stream()
                .filter(s -> s.getSaleType() == SaleType.PROMOTION)
                .map(s -> {
                    SaleType type = s.getSaleType();
                    long itemCount = flashSaleItemRepository.countByFlashSale_Id(s.getId());
                    long remaining = flashSaleItemRepository.remainingOfSale(s.getId());

                    // Tạo mã chiến dịch
                    String code = s.getCode();

                    // Mô tả phụ
                    String desc = s.getDescription();
                    if (desc == null || desc.isBlank()) {
                        desc = "Chương trình ưu đãi giảm giá đặc biệt";
                    }

                    // Phạm vi áp dụng
                    String scopeText = itemCount > 0
                            ? (itemCount + " Lô sản phẩm bình thường (>90 ngày)")
                            : "Toàn bộ sản phẩm chọn lọc";

                    // Hình thức giảm
                    String discountText;
                    if (s.getDiscountPercent() != null && s.getDiscountPercent() > 0) {
                        discountText = "Giảm " + s.getDiscountPercent() + "%";
                    } else {
                        List<FlashSaleItem> items = flashSaleItemRepository.findBySaleId(s.getId());
                        if (!items.isEmpty()) {
                            FlashSaleItem first = items.get(0);
                            BigDecimal orig = first.getLot().getProduct().getSellingPrice();
                            BigDecimal sale = first.getSalePrice();
                            if (orig.signum() > 0 && sale.compareTo(orig) < 0) {
                                int pct = BigDecimal.ONE.subtract(sale.divide(orig, 4, RoundingMode.HALF_UP))
                                        .multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
                                discountText = "Giảm " + pct + "%";
                            } else {
                                discountText = "Giảm giá đặc biệt";
                            }
                        } else {
                            discountText = "Giảm giá đặc biệt";
                        }
                    }

                    String startStr = s.getStartTime().format(DATE_TIME);
                    String endStr = s.getEndTime().format(DATE_TIME);
                    String timeRange = startStr + " – " + endStr;

                    String statusDisplay;
                    LocalDateTime now = VnpayClient.nowVn();
                    if (s.getStatus() == FlashSaleStatus.ACTIVE) {
                        statusDisplay = "Đang diễn ra";
                    } else if (s.getStatus() == FlashSaleStatus.DRAFT) {
                        statusDisplay = now.isBefore(s.getStartTime()) ? "Sắp diễn ra" : "Bản nháp";
                    } else if (s.getStatus() == FlashSaleStatus.PAUSED) {
                        statusDisplay = "Tạm dừng";
                    } else {
                        statusDisplay = "Đã kết thúc";
                    }

                    return new FlashSaleRow(
                            s.getId(),
                            s.getName(),
                            type,
                            code,
                            desc,
                            scopeText,
                            discountText,
                            startStr,
                            endStr,
                            timeRange,
                            s.getStatus(),
                            statusDisplay,
                            s.getCreatedBy() != null ? s.getCreatedBy().getFullName() : "Admin",
                            itemCount,
                            remaining
                    );
                })
                .toList();
    }

    // ===== BẢNG 1: Danh sách mặt hàng đang Flash Sale =====
    @Transactional(readOnly = true)
    public List<ActiveFlashSaleProductRow> listActiveFlashSaleProducts() {
        return flashSaleItemRepository.findActiveFlashSaleProducts().stream()
                .filter(item -> item.getFlashSale().getSaleType() == SaleType.FLASH_SALE)
                .map(item -> {
                    FlashSale fs = item.getFlashSale();
                    Lot lot = item.getLot();
                    Product p = lot.getProduct();

                    long daysLeft = inventoryPolicy.daysLeft(lot.getExpiryDate());
                    BigDecimal originalPrice = p.getSellingPrice();
                    BigDecimal salePrice = item.getSalePrice();

                    int discountPercent;
                    if (originalPrice.signum() > 0 && salePrice.compareTo(originalPrice) < 0) {
                        discountPercent = BigDecimal.ONE.subtract(salePrice.divide(originalPrice, 4, RoundingMode.HALF_UP))
                                .multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
                    } else {
                        discountPercent = (daysLeft < inventoryPolicy.getDeepDiscountDays())
                                ? inventoryPolicy.getDeepDiscountPercent()
                                : inventoryPolicy.getDiscountPercent();
                    }

                    String timeRange = fs.getStartTime().format(DATE_TIME) + " đến " + fs.getEndTime().format(DATE_TIME);
                    boolean isActive = fs.getStatus() == FlashSaleStatus.ACTIVE;
                    String statusDisplay = isActive ? "Đang diễn ra" : "Sắp diễn ra";

                    String lotCode = String.format("#LOT-2026-%02d", lot.getId());

                    return new ActiveFlashSaleProductRow(
                            item.getId(),
                            fs.getId(),
                            fs.getName(),
                            fs.getCode(),
                            p.getId(),
                            p.getName(),
                            p.getFullSku(),
                            p.getImageUrl(),
                            lot.getId(),
                            lotCode,
                            lot.getExpiryDate().format(DATE),
                            daysLeft,
                            originalPrice,
                            salePrice,
                            discountPercent,
                            item.getAllocatedQty(),
                            Math.min(item.getRemainingQty(), lot.getOnHandQty()),
                            timeRange,
                            statusDisplay,
                            isActive
                    );
                })
                .toList();
    }

    // ===== Tạo Flash Sale TỨC THÌ cho 1 sản phẩm từ lô cận date (21-90 ngày) =====
    // Quy tắc: 30 <= x < 90 ngày: Giảm 40%; 21 <= x < 30 ngày: Giảm 70%; < 21 ngày: Tiêu hủy
    @Transactional
    public FlashSale quickCreateFlashSaleForLot(Long lotId, Long employeeId) {
        Lot lot = lotRepository.findWithProductById(lotId)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy lô hàng #" + lotId));
        Product product = lot.getProduct();

        long daysLeft = inventoryPolicy.daysLeft(lot.getExpiryDate());
        if (daysLeft < inventoryPolicy.getQuarantineDays()) {
            throw new BusinessRuleException("Lô #" + lotId + " còn dưới " + inventoryPolicy.getQuarantineDays()
                    + " ngày thuộc diện tiêu hủy (BR-51/63), không được phép mở Flash Sale!");
        }
        if (daysLeft >= inventoryPolicy.getShelfLifeCommitmentDays()) {
            throw new BusinessRuleException("Lô #" + lotId + " còn " + daysLeft + " ngày (>= "
                    + inventoryPolicy.getShelfLifeCommitmentDays()
                    + " ngày) thuộc diện bán thường/khuyến mãi thường, không mở Flash Sale cận hạn (BR-63)!");
        }

        // Kiểm tra tồn kho khả dụng (đã trừ phần giữ chỗ ở các chiến dịch chưa kết thúc khác, BR-68)
        long availableQty = available(lot, 0L);
        if (availableQty <= 0) {
            throw new BusinessRuleException("Lô #" + lotId + " hiện đã hết hàng hoặc đã được phân bổ toàn bộ tồn kho trong một chiến dịch đang chạy/nháp khác (BR-68).");
        }

        int discountPercent = (daysLeft < inventoryPolicy.getDeepDiscountDays())
                ? inventoryPolicy.getDeepDiscountPercent() // 70% nếu 21-29 ngày
                : inventoryPolicy.getDiscountPercent();     // 40% nếu 30-89 ngày

        BigDecimal salePrice = inventoryPolicy.flashSalePrice(product.getSellingPrice(), lot.getExpiryDate());

        LocalDateTime now = VnpayClient.nowVn();
        LocalDateTime endTime = now.plusDays(7); // mặc định Flash Sale 7 ngày

        FlashSale sale = new FlashSale();
        sale.setName("Flash Sale Cận Hạn - " + product.getName() + " (#LOT-" + lot.getId() + ")");
        sale.setSaleType(SaleType.FLASH_SALE);
        sale.setDiscountPercent(discountPercent);
        sale.setDescription("Xả kho cấp tốc theo hạn dùng (" + daysLeft + " ngày còn lại)");
        sale.setStartTime(now);
        sale.setEndTime(endTime);
        sale.setStatus(FlashSaleStatus.ACTIVE); // Thực hiện NGAY LẬP TỨC
        sale.setCreatedBy(employeeRepository.getReferenceById(employeeId));
        sale = flashSaleRepository.save(sale);
        sale.syncMeta();

        FlashSaleItem item = new FlashSaleItem();
        item.setFlashSale(sale);
        item.setLot(lot);
        item.setSalePrice(salePrice);
        item.setAllocatedQty((int) availableQty);
        item.setSoldQty(0);
        flashSaleItemRepository.save(item);

        log.info("Đã kích hoạt Flash Sale tức thì #{} cho sản phẩm {} (lô #{}, giảm {}%, SL {})",
                sale.getId(), product.getName(), lot.getId(), discountPercent, availableQty);
        return sale;
    }

    // ===== Danh sách các lô bình thường (>= 90 ngày) cho form tạo/sửa Chương trình khuyến mãi =====
    @Transactional(readOnly = true)
    public List<NormalLotOption> normalLotsForPromotion() {
        return normalLotsForPromotion(null);
    }

    @Transactional(readOnly = true)
    public List<NormalLotOption> normalLotsForPromotion(Long excludeSaleId) {
        long saleId = excludeSaleId == null ? 0L : excludeSaleId;
        return lotRepository.findNormalLotsInStock(inventoryPolicy.minSellableExpiry()).stream()
                .map(l -> {
                    int avail = (int) Math.max(0L, available(l, saleId));
                    return new NormalLotOption(
                            l.getId(),
                            l.getProduct().getId(),
                            l.getProduct().getFullSku(),
                            l.getProduct().getName(),
                            l.getExpiryDate().format(DATE),
                            inventoryPolicy.daysLeft(l.getExpiryDate()),
                            avail,
                            l.getProduct().getSellingPrice(),
                            l.getProduct().getImageUrl()
                    );
                })
                .filter(o -> o.getOnHandQty() > 0)
                .toList();
    }

    // ===== Tạo Chương trình khuyến mãi (Promotion) dịp lễ / theo mong muốn =====
    // Áp dụng cho các lô bình thường (>= 90 ngày) với chung 1 mức giảm (%)
    @Transactional
    public FlashSale createPromotion(FlashSaleForm form, Long employeeId) {
        checkTimes(form);
        if (form.getDiscountPercent() == null || form.getDiscountPercent() < 1 || form.getDiscountPercent() > 99) {
            throw new BusinessRuleException("discountPercent", "Mức giảm giá chung phải từ 1% đến 99%");
        }
        if (form.getSelectedLotIds() == null || form.getSelectedLotIds().isEmpty()) {
            throw new BusinessRuleException("Vui lòng chọn ít nhất 1 lô sản phẩm bình thường (>90 ngày) để áp dụng chương trình.");
        }

        LocalDateTime now = VnpayClient.nowVn();
        if (!now.isBefore(form.getEndTime())) {
            throw new BusinessRuleException("endTime", "Thời gian kết thúc phải ở tương lai.");
        }

        Set<Long> uniqueLotIds = new LinkedHashSet<>(form.getSelectedLotIds());
        BigDecimal keep = BigDecimal.valueOf(100 - form.getDiscountPercent());
        Map<Lot, Integer> validatedLots = new LinkedHashMap<>();

        for (Long lotId : uniqueLotIds) {
            Lot lot = lotRepository.findWithProductById(lotId)
                    .orElseThrow(() -> new BusinessRuleException("Không tìm thấy lô #" + lotId));

            if (inventoryPolicy.levelOf(lot.getExpiryDate()) != ExpiryLevel.OK) {
                throw new BusinessRuleException("Lô #" + lotId + " (" + lot.getProduct().getName()
                        + ") không đảm bảo hạn dùng >= 90 ngày (BR-12/54)!");
            }

            long avail = available(lot, 0L);
            if (avail <= 0) {
                throw new BusinessRuleException("Lô #" + lotId + " (" + lot.getProduct().getName()
                        + ") đã hết suất khả dụng (đã được phân bổ cho chương trình khác, BR-68).");
            }

            int allocQty = form.getQuantityForLot(lotId, (int) avail);
            if (allocQty <= 0) {
                throw new BusinessRuleException("Số lượng phân bổ cho lô #" + lotId + " phải từ 1 trở lên.");
            }
            if (allocQty > avail) {
                throw new BusinessRuleException("Lô #" + lotId + " chỉ còn khả dụng " + avail + " sản phẩm (BR-68).");
            }
            validatedLots.put(lot, allocQty);
        }

        FlashSale sale = new FlashSale();
        sale.setName(form.getName().trim());
        sale.setDescription(form.getDescription() != null && !form.getDescription().isBlank()
                ? form.getDescription().trim()
                : "Chương trình khuyến mãi ưu đãi đặc biệt");
        sale.setSaleType(SaleType.PROMOTION);
        sale.setDiscountPercent(form.getDiscountPercent());
        sale.setStartTime(form.getStartTime());
        sale.setEndTime(form.getEndTime());
        sale.setStatus(now.isBefore(form.getStartTime()) ? FlashSaleStatus.DRAFT : FlashSaleStatus.ACTIVE);
        sale.setCreatedBy(employeeRepository.getReferenceById(employeeId));
        sale = flashSaleRepository.save(sale);
        sale.syncMeta();

        for (Map.Entry<Lot, Integer> entry : validatedLots.entrySet()) {
            Lot lot = entry.getKey();
            int allocQty = entry.getValue();
            BigDecimal salePrice = lot.getProduct().getSellingPrice()
                    .multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
            if (salePrice.signum() <= 0 || salePrice.compareTo(lot.getProduct().getSellingPrice()) >= 0) {
                throw new BusinessRuleException("discountPercent",
                        "Giá sau giảm của " + lot.getProduct().getName() + " không hợp lệ (BR-67).");
            }

            FlashSaleItem item = new FlashSaleItem();
            item.setFlashSale(sale);
            item.setLot(lot);
            item.setSalePrice(salePrice);
            item.setAllocatedQty(allocQty);
            item.setSoldQty(0);
            flashSaleItemRepository.save(item);
        }

        log.info("Đã tạo chương trình khuyến mãi #{} ({}) với {} lô hàng", sale.getId(), sale.getName(), validatedLots.size());
        return sale;
    }

    // ===== Quản lý chung FlashSale / Promotion =====

    @Transactional(readOnly = true)
    public FlashSale get(Long id) {
        FlashSale sale = find(id);
        if (sale.getCreatedBy() != null) {
            sale.getCreatedBy().getFullName(); // nạp sẵn cho JSP
        }
        return sale;
    }

    @Transactional(readOnly = true)
    public FlashSaleForm getForm(Long id) {
        FlashSale sale = find(id);
        FlashSaleForm form = new FlashSaleForm();
        form.setName(sale.getName());
        form.setDescription(sale.getDescription());

        List<FlashSaleItem> items = flashSaleItemRepository.findBySaleId(id);
        int discountPercent = 20;
        if (sale.getDiscountPercent() != null && sale.getDiscountPercent() > 0) {
            discountPercent = sale.getDiscountPercent();
        } else if (!items.isEmpty()) {
            FlashSaleItem first = items.get(0);
            BigDecimal orig = first.getLot().getProduct().getSellingPrice();
            BigDecimal salePrice = first.getSalePrice();
            if (orig.signum() > 0 && salePrice.compareTo(orig) < 0) {
                discountPercent = BigDecimal.ONE.subtract(salePrice.divide(orig, 4, RoundingMode.HALF_UP))
                        .multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
            }
        }
        form.setDiscountPercent(discountPercent);
        form.setStartTime(sale.getStartTime());
        form.setEndTime(sale.getEndTime());
        form.setSelectedLotIds(new ArrayList<>(items.stream().map(it -> it.getLot().getId()).toList()));

        Map<Long, Integer> qtyMap = new HashMap<>();
        for (FlashSaleItem it : items) {
            qtyMap.put(it.getLot().getId(), it.getAllocatedQty());
        }
        form.setLotQuantities(qtyMap);
        return form;
    }

    @Transactional(readOnly = true)
    public List<FlashSaleItemRow> items(Long saleId) {
        return flashSaleItemRepository.findBySaleId(saleId).stream().map(this::toRow).toList();
    }

    @Transactional(readOnly = true)
    public List<RedLotOption> redLots(Long saleId) {
        return lotRepository.findRedInStock(inventoryPolicy.minFlashSaleExpiry(), inventoryPolicy.minSellableExpiry())
                .stream()
                .map(l -> new RedLotOption(l.getId(), l.getProduct().getFullSku(), l.getProduct().getName(),
                        l.getExpiryDate().format(DATE), inventoryPolicy.daysLeft(l.getExpiryDate()), l.getOnHandQty(),
                        available(l, saleId), l.getProduct().getSellingPrice(),
                        inventoryPolicy.flashSaleDiscountPercent(l.getExpiryDate()),
                        inventoryPolicy.flashSalePrice(l.getProduct().getSellingPrice(), l.getExpiryDate())))
                .filter(o -> o.getAvailableQty() > 0)
                .toList();
    }

    @Transactional
    public FlashSale create(FlashSaleForm form, Long employeeId) {
        checkTimes(form);
        FlashSale sale = new FlashSale();
        sale.setName(form.getName().trim());
        sale.setDescription(form.getDescription());
        sale.setDiscountPercent(form.getDiscountPercent());
        sale.setStartTime(form.getStartTime());
        sale.setEndTime(form.getEndTime());
        sale.setSaleType(SaleType.PROMOTION);
        sale.setCreatedBy(employeeRepository.getReferenceById(employeeId));
        sale = flashSaleRepository.save(sale);
        sale.syncMeta();
        return sale;
    }

    @Transactional
    public FlashSale update(Long id, FlashSaleForm form) {
        FlashSale sale = find(id);
        requireDraft(sale);
        checkTimes(form);
        SaleType currentType = sale.getSaleType();
        sale.setName(form.getName().trim());
        sale.setSaleType(currentType);
        sale.setDescription(form.getDescription() != null && !form.getDescription().isBlank()
                ? form.getDescription().trim()
                : sale.getDescription());

        int discountPercent = (form.getDiscountPercent() != null && form.getDiscountPercent() > 0)
                ? form.getDiscountPercent() : 20;
        if (discountPercent < 1 || discountPercent > 99) {
            throw new BusinessRuleException("discountPercent", "Mức giảm giá phải từ 1% đến 99%");
        }
        sale.setDiscountPercent(discountPercent);
        sale.setStartTime(form.getStartTime());
        sale.setEndTime(form.getEndTime());

        BigDecimal keep = BigDecimal.valueOf(100 - discountPercent);

        List<FlashSaleItem> existingItems = flashSaleItemRepository.findBySaleId(id);
        Map<Long, FlashSaleItem> itemByLotId = existingItems.stream()
                .collect(Collectors.toMap(it -> it.getLot().getId(), it -> it, (a, b) -> a));

        List<Long> selectedLotIds = form.getSelectedLotIds();
        if (selectedLotIds != null && !selectedLotIds.isEmpty()) {
            Set<Long> uniqueLotIds = new LinkedHashSet<>(selectedLotIds);
            // Xóa các lô bị bỏ chọn
            for (FlashSaleItem it : existingItems) {
                if (!uniqueLotIds.contains(it.getLot().getId())) {
                    flashSaleItemRepository.delete(it);
                }
            }
            // Thêm mới hoặc cập nhật lại giá và số lượng các lô được chọn
            for (Long lotId : uniqueLotIds) {
                Lot lot = lotRepository.findWithProductById(lotId)
                        .orElseThrow(() -> new BusinessRuleException("Không tìm thấy lô #" + lotId));

                ExpiryLevel level = inventoryPolicy.levelOf(lot.getExpiryDate());
                if (currentType == SaleType.PROMOTION && level != ExpiryLevel.OK) {
                    throw new BusinessRuleException("Lô #" + lotId + " không đảm bảo hạn dùng >= 90 ngày cho Chương trình khuyến mãi (BR-12/54).");
                }
                if (currentType == SaleType.FLASH_SALE && level != ExpiryLevel.RED) {
                    throw new BusinessRuleException("Lô #" + lotId + " không nằm trong ngưỡng cận hạn 21-89 ngày cho Flash Sale (BR-63).");
                }

                long avail = available(lot, id);
                if (avail <= 0) {
                    throw new BusinessRuleException("Lô #" + lotId + " đã hết tồn khả dụng (đã phân bổ ở chiến dịch khác, BR-68).");
                }

                BigDecimal newSalePrice = (currentType == SaleType.FLASH_SALE)
                        ? inventoryPolicy.flashSalePrice(lot.getProduct().getSellingPrice(), lot.getExpiryDate())
                        : lot.getProduct().getSellingPrice().multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);

                FlashSaleItem item = itemByLotId.get(lotId);
                int defaultAlloc = item != null ? Math.min(item.getAllocatedQty(), (int) avail) : (int) avail;
                int allocQty = form.getQuantityForLot(lotId, defaultAlloc);
                if (allocQty <= 0) {
                    throw new BusinessRuleException("Số lượng phân bổ cho lô #" + lotId + " phải từ 1 trở lên.");
                }
                if (allocQty > avail) {
                    throw new BusinessRuleException("Lô #" + lotId + " chỉ còn khả dụng tối đa " + avail + " sản phẩm (BR-68).");
                }

                if (item != null) {
                    item.setSalePrice(newSalePrice);
                    item.setAllocatedQty(allocQty);
                    flashSaleItemRepository.save(item);
                } else {
                    item = new FlashSaleItem();
                    item.setFlashSale(sale);
                    item.setLot(lot);
                    item.setSalePrice(newSalePrice);
                    item.setAllocatedQty(allocQty);
                    item.setSoldQty(0);
                    flashSaleItemRepository.save(item);
                }
            }
        } else {
            for (FlashSaleItem it : existingItems) {
                Lot lot = it.getLot();
                long avail = available(lot, id);
                BigDecimal newSalePrice = (currentType == SaleType.FLASH_SALE)
                        ? inventoryPolicy.flashSalePrice(lot.getProduct().getSellingPrice(), lot.getExpiryDate())
                        : lot.getProduct().getSellingPrice().multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                it.setSalePrice(newSalePrice);
                int allocQty = form.getQuantityForLot(lot.getId(), it.getAllocatedQty());
                if (allocQty > 0 && allocQty <= avail) {
                    it.setAllocatedQty(allocQty);
                }
                flashSaleItemRepository.save(it);
            }
        }

        sale = flashSaleRepository.save(sale);
        sale.syncMeta();
        log.info("Đã cập nhật chương trình #{} với mức giảm {}%, cập nhật lại giá và số lượng các sản phẩm thành công", id, discountPercent);
        return sale;
    }

    @Transactional
    public void delete(Long id) {
        FlashSale sale = find(id);
        requireDraft(sale);
        flashSaleItemRepository.deleteAll(flashSaleItemRepository.findBySaleId(id));
        flashSaleRepository.delete(sale);
        FlashSale.removeMeta(id);
    }

    @Transactional
    public FlashSaleItem addItem(Long saleId, FlashSaleItemForm form) {
        FlashSale sale = find(saleId);
        requireDraft(sale);
        Lot lot = lotRepository.findWithProductById(form.getLotId())
                .orElseThrow(() -> new BusinessRuleException("lotId", "Không tìm thấy lô #" + form.getLotId()));
        Product product = lot.getProduct();

        Map<String, String> errors = new LinkedHashMap<>();
        if (sale.getSaleType() == SaleType.FLASH_SALE && inventoryPolicy.levelOf(lot.getExpiryDate()) != ExpiryLevel.RED) {
            errors.put("lotId", "Chỉ lô còn " + inventoryPolicy.getQuarantineDays() + " đến dưới "
                    + inventoryPolicy.getShelfLifeCommitmentDays() + " ngày mới đưa vào Flash Sale (BR-63)");
        } else if (sale.getSaleType() == SaleType.PROMOTION && inventoryPolicy.levelOf(lot.getExpiryDate()) != ExpiryLevel.OK) {
            errors.put("lotId", "Chỉ lô còn từ " + inventoryPolicy.getShelfLifeCommitmentDays()
                    + " ngày trở lên mới đưa vào Chương trình khuyến mãi (BR-12/54)");
        }
        if (flashSaleItemRepository.existsByFlashSale_IdAndLot_Id(saleId, lot.getId())) {
            errors.put("lotId", "Lô này đã có trong chiến dịch");
        }

        BigDecimal salePrice;
        if (sale.getSaleType() == SaleType.PROMOTION && sale.getDiscountPercent() != null && sale.getDiscountPercent() > 0) {
            BigDecimal keep = BigDecimal.valueOf(100 - sale.getDiscountPercent());
            salePrice = product.getSellingPrice().multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        } else {
            salePrice = inventoryPolicy.flashSalePrice(product.getSellingPrice(), lot.getExpiryDate());
        }

        if (salePrice.signum() <= 0 || salePrice.compareTo(product.getSellingPrice()) >= 0) {
            errors.put("lotId", "Không tính được giá giảm thấp hơn giá bán thường "
                    + product.getSellingPrice().toPlainString() + "đ (BR-67)");
        }
        long available = available(lot, saleId);
        if (form.getAllocatedQty() > available) {
            errors.put("allocatedQty", "Lô chỉ còn dành được " + available + " sản phẩm (BR-68)");
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        FlashSaleItem item = new FlashSaleItem();
        item.setFlashSale(sale);
        item.setLot(lot);
        item.setSalePrice(salePrice);
        item.setAllocatedQty(form.getAllocatedQty());
        try {
            return flashSaleItemRepository.saveAndFlush(item);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessRuleException("lotId", "Lô này đã có trong chiến dịch");
        }
    }

    @Transactional
    public void removeItem(Long saleId, Long itemId) {
        FlashSale sale = find(saleId);
        requireDraft(sale);
        FlashSaleItem item = flashSaleItemRepository.findById(itemId)
                .filter(i -> i.getFlashSale().getId().equals(saleId))
                .orElseThrow(() -> new NotFoundException("Không tìm thấy suất #" + itemId));
        flashSaleItemRepository.delete(item);
    }

    @Transactional
    public FlashSale activate(Long id) {
        FlashSale sale = find(id);
        requireDraft(sale);
        requireHasItems(sale);
        LocalDateTime now = VnpayClient.nowVn();
        if (!now.isBefore(sale.getEndTime())) {
            throw new BusinessRuleException("Chiến dịch đã quá giờ kết thúc.");
        }
        if (now.isBefore(sale.getStartTime())) {
            sale.setStartTime(now);
        }
        sale.setStatus(FlashSaleStatus.ACTIVE);
        return sale;
    }

    @Transactional
    public FlashSale pause(Long id) {
        return transition(id, FlashSaleStatus.ACTIVE, FlashSaleStatus.PAUSED, "tạm dừng");
    }

    @Transactional
    public FlashSale resume(Long id) {
        FlashSale sale = transition(id, FlashSaleStatus.PAUSED, FlashSaleStatus.ACTIVE, "chạy lại");
        if (!VnpayClient.nowVn().isBefore(sale.getEndTime())) {
            throw new BusinessRuleException("Chiến dịch đã quá giờ kết thúc, không chạy lại được.");
        }
        return sale;
    }

    @Transactional
    public FlashSale end(Long id) {
        FlashSale sale = find(id);
        if (sale.getStatus() == FlashSaleStatus.ENDED) {
            throw new BusinessRuleException("Chiến dịch đã kết thúc.");
        }
        sale.setStatus(FlashSaleStatus.ENDED);
        return sale;
    }

    // ===== Scheduler =====
    @Transactional
    public void tick(LocalDateTime now) {
        for (FlashSale sale : flashSaleRepository.findOverdue(now)) {
            sale.setStatus(FlashSaleStatus.ENDED);
            log.info("Chiến dịch #{} tự kết thúc (hết giờ)", sale.getId());
        }
        for (FlashSale sale : flashSaleRepository.findByStatusIn(Set.of(FlashSaleStatus.DRAFT, FlashSaleStatus.ACTIVE))) {
            if (sale.getStatus() == FlashSaleStatus.DRAFT
                    && !now.isBefore(sale.getStartTime()) && now.isBefore(sale.getEndTime())
                    && flashSaleItemRepository.countByFlashSale_Id(sale.getId()) > 0) {
                sale.setStatus(FlashSaleStatus.ACTIVE);
                log.info("Chiến dịch #{} tự bắt đầu", sale.getId());
            } else if (sale.getStatus() == FlashSaleStatus.ACTIVE
                    && flashSaleItemRepository.remainingOfSale(sale.getId()) == 0) {
                sale.setStatus(FlashSaleStatus.ENDED);
                log.info("Chiến dịch #{} tự kết thúc (bán hết)", sale.getId());
            }
        }
    }

    // ===== Phía khách =====
    // Trả về cả các suất Flash Sale cận hạn (RED: 21-89 ngày) VÀ các suất Chương trình khuyến mãi (PROMOTION: >= 90 ngày)
    @Transactional(readOnly = true)
    public List<FlashSaleOffer> runningOffers(Long productId) {
        return flashSaleItemRepository.findRunningOffers(VnpayClient.nowVn(), inventoryPolicy.minFlashSaleExpiry(),
                        inventoryPolicy.minSellableExpiry(), productId).stream()
                .filter(item -> {
                    ExpiryLevel level = inventoryPolicy.levelOf(item.getLot().getExpiryDate());
                    if (item.getFlashSale().getSaleType() == SaleType.PROMOTION) {
                        return level == ExpiryLevel.OK;
                    }
                    return level == ExpiryLevel.RED;
                })
                .filter(item -> Math.min(item.getRemainingQty(), item.getLot().getOnHandQty()) > 0)
                .map(this::toOffer)
                .sorted(java.util.Comparator.comparing((FlashSaleOffer o) -> !o.isPromotion()))
                .filter(o -> o.getRemainingQty() > 0)
                .toList();
    }

    // Tự động sửa dữ liệu seed cũ của Chiến dịch #2 và #4 nếu đang trỏ nhầm vào lô cận hạn (< 90 ngày)
    @org.springframework.context.event.EventListener(org.springframework.context.event.ContextRefreshedEvent.class)
    @Transactional
    public void repairSeededPromotionLots() {
        Set<Long> wrongSeedLotIds = Set.of(14L, 22L, 25L, 27L, 15L, 20L, 29L);
        List<Lot> normalLots = lotRepository.findNormalLotsInStock(inventoryPolicy.minSellableExpiry());
        if (normalLots.isEmpty()) {
            return;
        }
        for (Long saleId : List.of(2L, 4L)) {
            flashSaleRepository.findById(saleId).ifPresent(sale -> {
                List<FlashSaleItem> items = flashSaleItemRepository.findBySaleId(saleId);
                Set<Long> usedLotIds = items.stream()
                        .map(it -> it.getLot().getId())
                        .collect(Collectors.toCollection(LinkedHashSet::new));
                int discountPct = saleId == 4L ? 30 : 20;
                BigDecimal keep = BigDecimal.valueOf(100 - discountPct);

                for (FlashSaleItem item : items) {
                    Lot currentLot = item.getLot();
                    if (!wrongSeedLotIds.contains(currentLot.getId())) {
                        continue;
                    }
                    Long targetProductId = currentLot.getProduct().getId();
                    Lot replacement = normalLots.stream()
                            .filter(l -> !usedLotIds.contains(l.getId()))
                            .filter(l -> l.getProduct().getId().equals(targetProductId))
                            .filter(l -> available(l, saleId) > 0)
                            .findFirst()
                            .orElseGet(() -> normalLots.stream()
                                    .filter(l -> !usedLotIds.contains(l.getId()))
                                    .filter(l -> available(l, saleId) > 0)
                                    .sorted(java.util.Comparator.comparing((Lot l) ->
                                            l.getProduct().getImageUrl() == null || l.getProduct().getImageUrl().isBlank()))
                                    .findFirst()
                                    .orElse(null));

                    if (replacement != null) {
                        usedLotIds.remove(currentLot.getId());
                        usedLotIds.add(replacement.getId());
                        int maxAvail = (int) Math.max(1L, available(replacement, saleId));
                        int alloc = Math.min(Math.max(item.getAllocatedQty(), 10), maxAvail);
                        BigDecimal newSalePrice = replacement.getProduct().getSellingPrice()
                                .multiply(keep).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
                        item.setLot(replacement);
                        item.setSalePrice(newSalePrice);
                        item.setAllocatedQty(alloc);
                        if (item.getSoldQty() >= alloc) {
                            item.setSoldQty(0);
                        }
                        flashSaleItemRepository.save(item);
                        log.info("Đã cập nhật dữ liệu Chiến dịch #{}: đổi lô cận hạn #{} sang lô chuẩn >90 ngày #{} ({} - HSD {})",
                                saleId, currentLot.getId(), replacement.getId(),
                                replacement.getProduct().getName(), replacement.getExpiryDate());
                    }
                }
            });
        }
    }

    // ===== Phụ trợ =====

    private long available(Lot lot, Long saleId) {
        return Math.max(0L, lot.getOnHandQty() - flashSaleItemRepository.reservedByOtherSales(lot.getId(), saleId == null ? 0L : saleId));
    }

    private FlashSale transition(Long id, FlashSaleStatus from, FlashSaleStatus to, String action) {
        FlashSale sale = find(id);
        if (sale.getStatus() != from) {
            throw new BusinessRuleException("Chỉ " + action + " được chiến dịch \"" + from.getLabel() + "\".");
        }
        sale.setStatus(to);
        return sale;
    }

    private static void requireDraft(FlashSale sale) {
        if (sale.getStatus() != FlashSaleStatus.DRAFT) {
            throw new BusinessRuleException("Chiến dịch đã chạy, không sửa được nữa (chỉ sửa khi còn \"Nháp\").");
        }
    }

    private void requireHasItems(FlashSale sale) {
        if (flashSaleItemRepository.countByFlashSale_Id(sale.getId()) == 0) {
            throw new BusinessRuleException("Chiến dịch phải có ít nhất 1 suất trước khi chạy.");
        }
    }

    private static void checkTimes(FlashSaleForm form) {
        if (!form.getEndTime().isAfter(form.getStartTime())) {
            throw new BusinessRuleException("endTime", "Thời gian kết thúc phải sau thời gian bắt đầu");
        }
    }

    private FlashSale find(Long id) {
        return flashSaleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy chiến dịch #" + id));
    }

    private FlashSaleItemRow toRow(FlashSaleItem item) {
        Lot lot = item.getLot();
        Product p = lot.getProduct();
        return new FlashSaleItemRow(item.getId(), lot.getId(), p.getId(), p.getFullSku(), p.getName(),
                lot.getExpiryDate().format(DATE), inventoryPolicy.daysLeft(lot.getExpiryDate()),
                inventoryPolicy.levelOf(lot.getExpiryDate()), p.getSellingPrice(), item.getSalePrice(),
                item.getAllocatedQty(), item.getSoldQty());
    }

    private FlashSaleOffer toOffer(FlashSaleItem item) {
        Lot lot = item.getLot();
        Product p = lot.getProduct();
        int percent = BigDecimal.ONE.subtract(item.getSalePrice().divide(p.getSellingPrice(), 4, RoundingMode.HALF_UP))
                .multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
        boolean isPromo = item.getFlashSale().getSaleType() == SaleType.PROMOTION;
        return new FlashSaleOffer(item.getId(), item.getFlashSale().getName(),
                item.getFlashSale().getEndTime().format(DATE_TIME), p.getId(), p.getName(), p.getBrand(),
                p.getImageUrl(), p.getSellingPrice(), item.getSalePrice(), percent,
                Math.min(item.getRemainingQty(), lot.getOnHandQty()),
                lot.getExpiryDate().format(DATE), inventoryPolicy.daysLeft(lot.getExpiryDate()),
                p.getSpecies().name(), soldPercent(item), item.getFlashSale().getEndTime().withNano(0).toString(),
                isPromo);
    }

    private static int soldPercent(FlashSaleItem item) {
        return item.getAllocatedQty() <= 0 ? 0 : Math.min(100, item.getSoldQty() * 100 / item.getAllocatedQty());
    }
}
