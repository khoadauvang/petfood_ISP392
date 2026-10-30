package com.isp392.petfood.entity;

import com.isp392.petfood.enums.FlashSaleStatus;
import com.isp392.petfood.enums.SaleType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;

// Chiến dịch Flash Sale (module 6). Giỏ hàng chỉ đọc bảng này để biết suất Flash Sale còn bán được không.
@Entity
@Table(name = "FlashSale")
@Getter
@Setter
@NoArgsConstructor
public class FlashSale {

    private static final Path META_FILE = Paths.get("uploads", "flash-sale-meta.properties");
    private static final Map<Long, Meta> META_STORE = new ConcurrentHashMap<>();

    public record Meta(SaleType saleType, Integer discountPercent, String description) {}

    static {
        loadMetaFromDisk();
    }

    private static synchronized void loadMetaFromDisk() {
        if (!Files.exists(META_FILE)) {
            return;
        }
        Properties props = new Properties();
        try (InputStream in = Files.newInputStream(META_FILE)) {
            props.load(in);
            for (String key : props.stringPropertyNames()) {
                if (key.endsWith(".type")) {
                    String idStr = key.substring(0, key.length() - 5);
                    try {
                        Long saleId = Long.parseLong(idStr);
                        SaleType type = SaleType.valueOf(props.getProperty(idStr + ".type", "PROMOTION"));
                        String discStr = props.getProperty(idStr + ".discount", "");
                        Integer disc = discStr.isBlank() ? null : Integer.parseInt(discStr);
                        String desc = props.getProperty(idStr + ".desc", null);
                        META_STORE.put(saleId, new Meta(type, disc, desc));
                    } catch (Exception ignored) {
                    }
                }
            }
        } catch (IOException ignored) {
        }
    }

    private static synchronized void saveMetaToDisk() {
        try {
            if (META_FILE.getParent() != null) {
                Files.createDirectories(META_FILE.getParent());
            }
            Properties props = new Properties();
            for (Map.Entry<Long, Meta> entry : META_STORE.entrySet()) {
                String prefix = String.valueOf(entry.getKey());
                Meta m = entry.getValue();
                if (m.saleType() != null) {
                    props.setProperty(prefix + ".type", m.saleType().name());
                }
                if (m.discountPercent() != null) {
                    props.setProperty(prefix + ".discount", String.valueOf(m.discountPercent()));
                }
                if (m.description() != null) {
                    props.setProperty(prefix + ".desc", m.description());
                }
            }
            try (OutputStream out = Files.newOutputStream(META_FILE)) {
                props.store(out, "FlashSale & Promotion metadata (no-DB-schema-change store)");
            }
        } catch (IOException ignored) {
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flash_sale_id")
    private Long id;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    // DB chặn: end_time > start_time (CK_FlashSale_time)
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private FlashSaleStatus status = FlashSaleStatus.DRAFT;

    @Transient
    private SaleType saleType;

    @Transient
    private Integer discountPercent;

    @Transient
    private String description;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by", nullable = false)
    private Employee createdBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    @PostLoad
    void onLoad() {
        if (id != null) {
            Meta meta = META_STORE.get(id);
            if (meta != null) {
                this.saleType = meta.saleType();
                this.discountPercent = meta.discountPercent();
                this.description = meta.description();
            }
        }
    }

    @PostPersist
    @PostUpdate
    public void syncMeta() {
        if (id != null && (saleType != null || discountPercent != null || description != null)) {
            Meta existing = META_STORE.get(id);
            SaleType resolvedType = saleType != null ? saleType : (existing != null ? existing.saleType() : getSaleType());
            Integer resolvedDisc = discountPercent != null ? discountPercent : (existing != null ? existing.discountPercent() : null);
            String resolvedDesc = description != null ? description : (existing != null ? existing.description() : null);
            META_STORE.put(id, new Meta(resolvedType, resolvedDisc, resolvedDesc));
            saveMetaToDisk();
        }
    }

    public static void removeMeta(Long saleId) {
        if (saleId != null && META_STORE.remove(saleId) != null) {
            saveMetaToDisk();
        }
    }

    public SaleType getSaleType() {
        if (saleType != null) {
            return saleType;
        }
        if (id != null) {
            Meta meta = META_STORE.get(id);
            if (meta != null && meta.saleType() != null) {
                this.saleType = meta.saleType();
                return this.saleType;
            }
        }
        if (name != null) {
            String lower = name.toLowerCase();
            if (lower.contains("flash sale") || lower.contains("flashsale")
                    || lower.contains("cận hạn") || lower.contains("cận date")
                    || lower.contains("xả hàng") || lower.contains("xả tồn")) {
                return SaleType.FLASH_SALE;
            }
        }
        return SaleType.PROMOTION;
    }

    public Integer getDiscountPercent() {
        if (discountPercent != null) {
            return discountPercent;
        }
        if (id != null) {
            Meta meta = META_STORE.get(id);
            if (meta != null && meta.discountPercent() != null) {
                this.discountPercent = meta.discountPercent();
                return this.discountPercent;
            }
        }
        return null;
    }

    public String getDescription() {
        if (description != null) {
            return description;
        }
        if (id != null) {
            Meta meta = META_STORE.get(id);
            if (meta != null && meta.description() != null) {
                this.description = meta.description();
                return this.description;
            }
        }
        return null;
    }

    // Đang mở bán: ACTIVE và thời điểm "now" nằm trong khung giờ (phòng khi scheduler chưa kịp chuyển trạng thái)
    public boolean isRunningAt(LocalDateTime now) {
        return status == FlashSaleStatus.ACTIVE && !now.isBefore(startTime) && now.isBefore(endTime);
    }

    public String getCode() {
        if (getSaleType() == SaleType.PROMOTION) {
            return String.format("#KM-2026-%02d", id);
        }
        return String.format("#FS-2026-%02d", id);
    }
}
