package com.isp392.petfood.service;

import com.isp392.petfood.dto.AlertSummary;
import com.isp392.petfood.dto.LotRow;
import com.isp392.petfood.dto.LowStockRow;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.repository.LotRepository;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

// Cảnh báo kho cho Staff/Admin (FR-38):
//   - tồn thấp: sản phẩm đang bán có tồn bán thường <= low_stock_threshold (BR-62)
//   - lô sắp hết hạn: lô còn hàng, HSD còn dưới 90 ngày, gồm cả lô < 21 ngày và lô đã quá hạn (BR-59)
// Không cần tác vụ chạy hằng đêm: mỗi lần mở trang là so expiry_date với ngày hiện tại, nên luôn đúng.
@Service
@RequiredArgsConstructor
public class InventoryAlertService {

    private final ProductRepository productRepository;
    private final LotRepository lotRepository;
    private final LotService lotService;
    private final InventoryPolicy inventoryPolicy;

    // Hết hàng đứng đầu, rồi tới tồn ít nhất
    @Transactional(readOnly = true)
    public List<LowStockRow> lowStockProducts() {
        return productRepository.findLowStock(ProductStatus.ACTIVE, inventoryPolicy.minSellableExpiry()).stream()
                .map(LowStockRow::new)
                .sorted(Comparator.comparingLong(LowStockRow::getSellableQty).thenComparing(LowStockRow::getSku))
                .toList();
    }

    // Hết hạn trước đứng đầu (FEFO)
    @Transactional(readOnly = true)
    public List<LotRow> nearExpiryLots() {
        return lotRepository.findInStockExpiringBefore(inventoryPolicy.minSellableExpiry()).stream()
                .map(lotService::toRow)
                .toList();
    }

    @Transactional(readOnly = true)
    public AlertSummary getSummary() {
        int red = 0;
        int blocked = 0;
        int expired = 0;
        for (LotRow lot : nearExpiryLots()) {
            switch (lot.getLevel()) {
                case RED -> red++;
                case BLOCKED -> blocked++;
                case EXPIRED -> expired++;
                default -> {
                    // OK: không thuộc danh sách này
                }
            }
        }
        int totalInStock = (int) lotRepository.countInStock();
        int safe = Math.max(0, totalInStock - (red + blocked + expired));
        return new AlertSummary(lowStockProducts().size(), red, blocked, expired, totalInStock, safe);
    }
}
