package com.isp392.petfood.service;

import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.text.NumberFormat;
import java.util.Locale;

// Tóm tắt danh sách sản phẩm đang bán thành văn bản ngắn để đưa vào prompt cho Gemini (chatbox AI phía khách).
// Nhớ kết quả 5 phút để mỗi tin nhắn không phải truy vấn lại toàn bộ bảng Product.
@Component
@RequiredArgsConstructor
public class ChatCatalogProvider {

    private static final long TTL_MILLIS = 5 * 60 * 1000L;
    private static final int MAX_PRODUCTS = 150;

    private final ProductRepository productRepository;

    private volatile String cached;
    private volatile long cachedAt;

    @Transactional(readOnly = true)
    public String catalogText() {
        long now = System.currentTimeMillis();
        String snapshot = cached;
        if (snapshot != null && now - cachedAt < TTL_MILLIS) {
            return snapshot;
        }
        NumberFormat money = NumberFormat.getInstance(Locale.of("vi", "VN"));
        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (Product p : productRepository.findAllByOrderBySkuAscVariantAsc()) {
            if (p.getStatus() != ProductStatus.ACTIVE) {
                continue;
            }
            if (++count > MAX_PRODUCTS) {
                break;
            }
            sb.append("- ").append(p.getName());
            if (p.getBrand() != null && !p.getBrand().isBlank()) {
                sb.append(" | Hãng: ").append(p.getBrand());
            }
            sb.append(" | Quy cách: ").append(p.getVariant());
            if (p.getSpecies() != null) {
                sb.append(" | Cho: ").append(p.getSpecies().getLabel());
            }
            if (p.getAgeGroup() != null) {
                sb.append(" | Độ tuổi: ").append(p.getAgeGroup().getLabel());
            }
            if (p.getCategory() != null) {
                sb.append(" | Danh mục: ").append(p.getCategory().getName());
            }
            if (p.getSellingPrice() != null) {
                sb.append(" | Giá: ").append(money.format(p.getSellingPrice())).append("đ");
            }
            sb.append(" | Link: /products/").append(p.getId()).append('\n');
        }
        String text = sb.isEmpty() ? "(Hiện chưa có sản phẩm nào đang bán)" : sb.toString();
        cached = text;
        cachedAt = now;
        return text;
    }
}

