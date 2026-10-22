package com.isp392.petfood.service;

import com.isp392.petfood.dto.LotForm;
import com.isp392.petfood.dto.LotRow;
import com.isp392.petfood.dto.LotStats;
import com.isp392.petfood.dto.ProductLotGroupDto;
import com.isp392.petfood.entity.Lot;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ExpiryLevel;
import com.isp392.petfood.enums.LotView;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Quản lý lô (MVP: kho chỉ còn bảng Lot): nhập lô, xem tồn theo lô, sửa/xoá lô nhập nhầm
@Service
@RequiredArgsConstructor
public class LotService {

    private static final int PAGE_SIZE = 20;
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final LotRepository lotRepository;
    private final ProductRepository productRepository;
    private final InventoryPolicy inventoryPolicy;

    public LotRow toRow(Lot lot) {
        return new LotRow(lot,
                inventoryPolicy.daysLeft(lot.getExpiryDate()),
                inventoryPolicy.levelOf(lot.getExpiryDate()));
    }

    // ---------- Xem tồn theo lô ----------
    // pageNumber tính từ 0. Sắp theo FEFO: lô hết hạn trước đứng trước (BR-53).
    @Transactional(readOnly = true)
    public Page<LotRow> search(LotView view, Long productId, String keyword, int pageNumber) {
        int minOnHand = 0;
        Integer maxOnHand = null;
        LocalDate expiryBefore = null;
        switch (view) {
            case IN_STOCK -> minOnHand = 1;
            case NEAR_EXPIRY -> {
                minOnHand = 1;
                expiryBefore = inventoryPolicy.minSellableExpiry();
            }
            case DEPLETED -> maxOnHand = 0;
            case ALL -> {
                // không lọc thêm
            }
        }
        Pageable pageable = PageRequest.of(pageNumber, PAGE_SIZE,
                Sort.by(Sort.Order.asc("expiryDate"), Sort.Order.asc("id")));
        return lotRepository.search(productId, keyword, minOnHand, maxOnHand, expiryBefore, pageable)
                .map(this::toRow);
    }

    // Các lô của một sản phẩm (trang chi tiết sản phẩm)
    @Transactional(readOnly = true)
    public List<LotRow> lotsOfProduct(Long productId) {
        return lotRepository.findByProduct_IdOrderByExpiryDateAscIdAsc(productId).stream()
                .map(this::toRow)
                .toList();
    }

    @Transactional(readOnly = true)
    public LotRow getRow(Long id) {
        return toRow(findOrThrow(id));
    }

    @Transactional(readOnly = true)
    public LotForm getForm(Long id) {
        return LotForm.from(findOrThrow(id));
    }

    // ---------- Nhập lô ----------
    @Transactional
    public LotRow create(LotForm form) {
        Product product = productRepository.findById(form.getProductId())
                .orElseThrow(() -> new BusinessRuleException("productId", "Sản phẩm không tồn tại"));
        return toRow(receive(product, form.getExpiryDate(), form.getReceivedQty()));
    }

    // Tạo một lô cho sản phẩm: on_hand_qty = received_qty (hàng vừa về còn nguyên trong kho).
    // Dùng chung cho trang nhập lô và lúc thêm sản phẩm kèm lô đầu tiên (ProductAdminService).
    @Transactional
    public Lot receive(Product product, LocalDate expiryDate, int quantity) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (product.getStatus() != ProductStatus.ACTIVE) {
            errors.put("productId", "Sản phẩm " + product.getSku()
                    + " đang ngừng kinh doanh, hãy mở bán lại trước khi nhập lô");
        }
        String expiryProblem = expiryProblemForNewLot(expiryDate);
        if (expiryProblem != null) {
            errors.put("expiryDate", expiryProblem);
        }
        if (!errors.isEmpty()) {
            throw new BusinessRuleException(errors);
        }

        Lot lot = new Lot();
        lot.setProduct(product);
        lot.setExpiryDate(expiryDate);
        lot.setReceivedQty(quantity);
        lot.setOnHandQty(quantity);
        // received_at: @PrePersist gán thời điểm hiện tại
        return lotRepository.save(lot);
    }

    // Lô nhập hôm nay phải có HSD sau hôm nay (BR-51; DB cũng chặn bằng CK_Lot_expiry_after_received).
    // Trả về câu báo lỗi, hoặc null nếu hợp lệ.
    public String expiryProblemForNewLot(LocalDate expiryDate) {
        if (expiryDate != null && !expiryDate.isAfter(inventoryPolicy.today())) {
            return "Hạn sử dụng phải sau ngày nhập kho (sau hôm nay)";
        }
        return null;
    }

    // ---------- Sửa / xoá lô nhập nhầm ----------
    // Chỉ cho khi lô chưa xuất đơn vị nào (on_hand = received): sửa lô đã bán sẽ làm sai số liệu tồn và truy vết.
    // Khi làm Flash Sale: chặn thêm lô đang nằm trong FlashSaleItem (allocated_qty không được vượt tồn của lô, BR-68).
    @Transactional
    public LotRow update(Long id, LotForm form) {
        Lot lot = findOrThrow(id);
        requireUntouched(lot, "sửa");

        LocalDate receivedDate = lot.getReceivedAt().toLocalDate();
        if (!form.getExpiryDate().isAfter(receivedDate)) {
            throw new BusinessRuleException("expiryDate",
                    "Hạn sử dụng phải sau ngày nhập kho (" + receivedDate.format(DATE) + ")");
        }
        lot.setExpiryDate(form.getExpiryDate());
        lot.setReceivedQty(form.getReceivedQty());
        lot.setOnHandQty(form.getReceivedQty());
        return toRow(lot);
    }

    @Transactional
    public LotRow delete(Long id) {
        Lot lot = findOrThrow(id);
        requireUntouched(lot, "xoá");
        LotRow deleted = toRow(lot);
        lotRepository.delete(lot);
        try {
            lotRepository.flush();
        } catch (DataIntegrityViolationException e) {
            // Còn bảng khác trỏ tới lô (ví dụ FlashSaleItem)
            throw new BusinessRuleException("Lô #" + id + " đang được dùng ở chương trình Flash Sale nên không xoá được.");
        }
        return deleted;
    }

    @Transactional(readOnly = true)
    public LotStats getLotStats() {
        List<Lot> allLots = lotRepository.findAll();
        long totalLots = allLots.size();

        long totalOnHand = 0;
        long activeLots = 0;
        long warningLots = 0;
        long criticalLots = 0;

        for (Lot l : allLots) {
            if (l.getOnHandQty() > 0) {
                totalOnHand += l.getOnHandQty();
                activeLots++;
                ExpiryLevel level = inventoryPolicy.levelOf(l.getExpiryDate());
                if (level == ExpiryLevel.RED) {
                    warningLots++;
                } else if (level == ExpiryLevel.BLOCKED || level == ExpiryLevel.EXPIRED) {
                    criticalLots++;
                }
            }
        }

        return new LotStats(totalOnHand, activeLots, totalLots, warningLots, criticalLots);
    }

    @Transactional(readOnly = true)
    public List<ProductLotGroupDto> getProductLotGroups(LotView view, Long filterProductId, String keyword) {
        List<Product> products = productRepository.findAll(Sort.by("name"));
        Map<Long, ProductLotGroupDto> groupMap = new LinkedHashMap<>();

        for (Product p : products) {
            String catName = p.getCategory() != null ? p.getCategory().getName() : "Chưa phân loại";
            ProductLotGroupDto dto = new ProductLotGroupDto(
                    p.getId(), p.getSku(), p.getName(), p.getImageUrl(), catName, p.getLowStockThreshold());
            groupMap.put(p.getId(), dto);
        }

        List<Lot> lots = lotRepository.findAll(Sort.by(Sort.Order.asc("expiryDate"), Sort.Order.asc("id")));
        for (Lot l : lots) {
            ProductLotGroupDto dto = groupMap.get(l.getProduct().getId());
            if (dto != null) {
                dto.addLot(toRow(l));
            }
        }

        groupMap.values().forEach(ProductLotGroupDto::finalizeStatus);

        String kw = keyword != null ? keyword.trim().toLowerCase() : null;
        return groupMap.values().stream()
                .filter(g -> {
                    if (filterProductId != null && !g.getProductId().equals(filterProductId)) {
                        return false;
                    }
                    if (kw != null && !kw.isEmpty()) {
                        boolean matchName = g.getProductName().toLowerCase().contains(kw);
                        boolean matchSku = g.getSku().toLowerCase().contains(kw);
                        boolean matchCat = g.getCategoryName() != null && g.getCategoryName().toLowerCase().contains(kw);
                        boolean matchLot = g.getLots().stream()
                                .anyMatch(l -> ("lot-" + l.getId()).toLowerCase().contains(kw)
                                        || ("#lot-" + l.getId()).toLowerCase().contains(kw)
                                        || String.valueOf(l.getId()).equals(kw));
                        if (!matchName && !matchSku && !matchCat && !matchLot) {
                            return false;
                        }
                    }
                    if (view != null) {
                        switch (view) {
                            case IN_STOCK -> {
                                if (g.getTotalOnHand() <= 0) return false;
                            }
                            case NEAR_EXPIRY -> {
                                if (g.getFlashSaleQty() <= 0 && g.getCriticalQty() <= 0) return false;
                            }
                            case DEPLETED -> {
                                if (g.getTotalOnHand() > 0) return false;
                            }
                            case ALL -> {}
                        }
                    }
                    return true;
                })
                .toList();
    }

    private void requireUntouched(Lot lot, String action) {
        if (!lot.isUntouched()) {
            int shipped = lot.getReceivedQty() - lot.getOnHandQty();
            throw new BusinessRuleException("Lô #" + lot.getId() + " đã xuất " + shipped
                    + " sản phẩm nên không " + action + " được. Chỉ " + action + " được lô nhập nhầm, chưa xuất hàng.");
        }
    }

    private Lot findOrThrow(Long id) {
        return lotRepository.findWithProductById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy lô #" + id));
    }
}
