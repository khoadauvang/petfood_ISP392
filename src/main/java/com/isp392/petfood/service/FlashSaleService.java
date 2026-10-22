package com.isp392.petfood.service;

import com.isp392.petfood.dto.FlashSaleForm;
import com.isp392.petfood.dto.FlashSaleItemForm;
import com.isp392.petfood.dto.FlashSaleItemRow;
import com.isp392.petfood.dto.FlashSaleOffer;
import com.isp392.petfood.dto.FlashSaleRow;
import com.isp392.petfood.dto.RedLotOption;
import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.entity.FlashSaleItem;
import com.isp392.petfood.entity.Lot;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ExpiryLevel;
import com.isp392.petfood.enums.FlashSaleStatus;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

// Flash Sale xả hàng cận hạn (module 6). Chỉ Admin tạo / sửa / chuyển trạng thái; Staff chỉ xem (chốt 22/10, mục 9.7).
//   - chỉ lấy lô mức RED, còn 21 đến dưới 90 ngày (BR-63)
//   - sale_price tự tính theo HSD lô (InventoryPolicy): còn 30-89 ngày giảm 40%, dưới 30 ngày giảm 70%; chốt lúc thêm suất.
//     Vẫn phải < giá bán thường (BR-67); allocated_qty không vượt tồn của lô trừ phần đang dành cho chiến dịch
//     khác (BR-66, BR-68); một lô một lần mỗi chiến dịch (UQ_FlashSaleItem_sale_lot)
//   - DRAFT -> ACTIVE <-> PAUSED -> ENDED (BR-64). Chỉ sửa chiến dịch / suất khi còn DRAFT.
//   - scheduler: DRAFT có ít nhất 1 suất tự ACTIVE khi tới start_time; quá end_time hoặc bán hết thì ENDED
//   - bán: giỏ hàng tách dòng Flash Sale (BR-65), đặt hàng tăng sold_qty bằng UPDATE có điều kiện (CheckoutService)
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

    // ===== Phía Staff =====

    @Transactional(readOnly = true)
    public List<FlashSaleRow> list() {
        return flashSaleRepository.findAllForList().stream()
                .map(s -> new FlashSaleRow(s.getId(), s.getName(), s.getStartTime().format(DATE_TIME),
                        s.getEndTime().format(DATE_TIME), s.getStatus(), s.getCreatedBy().getFullName(),
                        flashSaleItemRepository.countByFlashSale_Id(s.getId()),
                        flashSaleItemRepository.remainingOfSale(s.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public FlashSale get(Long id) {
        FlashSale sale = find(id);
        sale.getCreatedBy().getFullName();               // nạp sẵn cho JSP
        return sale;
    }

    @Transactional(readOnly = true)
    public FlashSaleForm getForm(Long id) {
        FlashSale sale = find(id);
        FlashSaleForm form = new FlashSaleForm();
        form.setName(sale.getName());
        form.setStartTime(sale.getStartTime());
        form.setEndTime(sale.getEndTime());
        return form;
    }

    @Transactional(readOnly = true)
    public List<FlashSaleItemRow> items(Long saleId) {
        return flashSaleItemRepository.findBySaleId(saleId).stream().map(this::toRow).toList();
    }

    // Lô RED còn hàng để chọn khi thêm suất, kèm số lượng còn dành được cho chiến dịch này
    @Transactional(readOnly = true)
    public List<RedLotOption> redLots(Long saleId) {
        return lotRepository.findRedInStock(inventoryPolicy.minFlashSaleExpiry(), inventoryPolicy.minSellableExpiry())
                .stream()
                .map(l -> new RedLotOption(l.getId(), l.getProduct().getSku(), l.getProduct().getName(),
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
        apply(sale, form);
        sale.setCreatedBy(employeeRepository.getReferenceById(employeeId));
        return flashSaleRepository.save(sale);
    }

    @Transactional
    public FlashSale update(Long id, FlashSaleForm form) {
        FlashSale sale = find(id);
        requireDraft(sale);
        checkTimes(form);
        apply(sale, form);
        return sale;
    }

    // Xoá chiến dịch nháp (chưa bán gì vì DRAFT không hiện cho khách)
    @Transactional
    public void delete(Long id) {
        FlashSale sale = find(id);
        requireDraft(sale);
        flashSaleItemRepository.deleteAll(flashSaleItemRepository.findBySaleId(id));
        flashSaleRepository.delete(sale);
    }

    @Transactional
    public FlashSaleItem addItem(Long saleId, FlashSaleItemForm form) {
        FlashSale sale = find(saleId);
        requireDraft(sale);
        Lot lot = lotRepository.findWithProductById(form.getLotId())
                .orElseThrow(() -> new BusinessRuleException("lotId", "Không tìm thấy lô #" + form.getLotId()));
        Product product = lot.getProduct();

        Map<String, String> errors = new LinkedHashMap<>();
        if (inventoryPolicy.levelOf(lot.getExpiryDate()) != ExpiryLevel.RED) {
            errors.put("lotId", "Chỉ lô còn " + inventoryPolicy.getQuarantineDays() + " đến dưới "
                    + inventoryPolicy.getShelfLifeCommitmentDays() + " ngày mới đưa vào Flash Sale (BR-63)");
        }
        if (flashSaleItemRepository.existsByFlashSale_IdAndLot_Id(saleId, lot.getId())) {
            errors.put("lotId", "Lô này đã có trong chiến dịch");
        }
        BigDecimal salePrice = inventoryPolicy.flashSalePrice(product.getSellingPrice(), lot.getExpiryDate());
        if (salePrice.signum() <= 0 || salePrice.compareTo(product.getSellingPrice()) >= 0) {
            errors.put("lotId", "Không tính được giá Flash Sale thấp hơn giá bán thường "
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

    // DRAFT -> ACTIVE ngay (không chờ scheduler), nếu đang trong khung giờ
    @Transactional
    public FlashSale activate(Long id) {
        FlashSale sale = find(id);
        requireDraft(sale);
        requireHasItems(sale);
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(sale.getStartTime())) {
            throw new BusinessRuleException("Chưa tới giờ bắt đầu: chiến dịch sẽ tự chạy lúc "
                    + sale.getStartTime().format(DATE_TIME) + ".");
        }
        if (!now.isBefore(sale.getEndTime())) {
            throw new BusinessRuleException("Chiến dịch đã quá giờ kết thúc.");
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
        if (!LocalDateTime.now().isBefore(sale.getEndTime())) {
            throw new BusinessRuleException("Chiến dịch đã quá giờ kết thúc, không chạy lại được.");
        }
        return sale;
    }

    // Kết thúc sớm: phần chưa bán của lô không còn bị dành riêng nữa
    @Transactional
    public FlashSale end(Long id) {
        FlashSale sale = find(id);
        if (sale.getStatus() == FlashSaleStatus.ENDED) {
            throw new BusinessRuleException("Chiến dịch đã kết thúc.");
        }
        sale.setStatus(FlashSaleStatus.ENDED);
        return sale;
    }

    // ===== Scheduler (FlashSaleScheduler gọi mỗi phút) =====
    @Transactional
    public void tick(LocalDateTime now) {
        for (FlashSale sale : flashSaleRepository.findOverdue(now)) {
            sale.setStatus(FlashSaleStatus.ENDED);
            log.info("Flash Sale #{} tự kết thúc (hết giờ)", sale.getId());
        }
        for (FlashSale sale : flashSaleRepository.findByStatusIn(Set.of(FlashSaleStatus.DRAFT, FlashSaleStatus.ACTIVE))) {
            if (sale.getStatus() == FlashSaleStatus.DRAFT
                    && !now.isBefore(sale.getStartTime()) && now.isBefore(sale.getEndTime())
                    && flashSaleItemRepository.countByFlashSale_Id(sale.getId()) > 0) {
                sale.setStatus(FlashSaleStatus.ACTIVE);
                log.info("Flash Sale #{} tự bắt đầu", sale.getId());
            } else if (sale.getStatus() == FlashSaleStatus.ACTIVE
                    && flashSaleItemRepository.remainingOfSale(sale.getId()) == 0) {
                sale.setStatus(FlashSaleStatus.ENDED);       // bán hết suất
                log.info("Flash Sale #{} tự kết thúc (bán hết)", sale.getId());
            }
        }
    }

    // ===== Phía khách =====

    // productId null: mọi suất đang mở bán (trang /flash-sale); có giá trị: suất của một sản phẩm (trang chi tiết)
    @Transactional(readOnly = true)
    public List<FlashSaleOffer> runningOffers(Long productId) {
        return flashSaleItemRepository.findRunningOffers(LocalDateTime.now(), inventoryPolicy.minFlashSaleExpiry(),
                        inventoryPolicy.minSellableExpiry(), productId).stream()
                .map(this::toOffer)
                .toList();
    }

    // ===== Phụ trợ =====

    private long available(Lot lot, Long saleId) {
        return lot.getOnHandQty() - flashSaleItemRepository.reservedByOtherSales(lot.getId(), saleId);
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

    private static void apply(FlashSale sale, FlashSaleForm form) {
        sale.setName(form.getName().trim());
        sale.setStartTime(form.getStartTime());
        sale.setEndTime(form.getEndTime());
    }

    private FlashSale find(Long id) {
        return flashSaleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy chiến dịch #" + id));
    }

    private FlashSaleItemRow toRow(FlashSaleItem item) {
        Lot lot = item.getLot();
        Product p = lot.getProduct();
        return new FlashSaleItemRow(item.getId(), lot.getId(), p.getId(), p.getSku(), p.getName(),
                lot.getExpiryDate().format(DATE), inventoryPolicy.daysLeft(lot.getExpiryDate()),
                inventoryPolicy.levelOf(lot.getExpiryDate()), p.getSellingPrice(), item.getSalePrice(),
                item.getAllocatedQty(), item.getSoldQty());
    }

    private FlashSaleOffer toOffer(FlashSaleItem item) {
        Lot lot = item.getLot();
        Product p = lot.getProduct();
        int percent = BigDecimal.ONE.subtract(item.getSalePrice().divide(p.getSellingPrice(), 4, RoundingMode.HALF_UP))
                .multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).intValue();
        return new FlashSaleOffer(item.getId(), item.getFlashSale().getName(),
                item.getFlashSale().getEndTime().format(DATE_TIME), p.getId(), p.getName(), p.getBrand(),
                p.getImageUrl(), p.getSellingPrice(), item.getSalePrice(), percent,
                Math.min(item.getRemainingQty(), lot.getOnHandQty()),
                lot.getExpiryDate().format(DATE), inventoryPolicy.daysLeft(lot.getExpiryDate()));
    }
}
