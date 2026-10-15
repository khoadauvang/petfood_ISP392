package com.isp392.petfood.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.DirectoryNotEmptyException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.UUID;

// Lưu file ảnh sản phẩm ra ổ đĩa và đổi qua lại giữa đường dẫn file <-> URL lưu trong DB.
//
// Vì sao không ghi vào src/main/resources/static/images/products như ảnh mẫu?
//   Lúc chạy, Spring đọc static/ từ classpath (target/classes), không đọc lại thư mục src/, nên ảnh mới sẽ không hiện
//   cho tới khi build lại; còn ghi vào target/ thì "mvn clean" là mất. Vì vậy ảnh nhân viên tải lên nằm ở
//   <petfood.upload-dir>/products/<SKU>/ (mặc định ./uploads/products/...), và WebConfig phục vụ thư mục này
//   ở cùng URL /images/products/** với ảnh mẫu.
//
// Tên file có thêm đoạn ngẫu nhiên (1-3f9a2c1b.jpg): thay ảnh thì URL đổi, trình duyệt không hiện ảnh cũ trong cache,
// và không bao giờ ghi đè lên file đang dùng.
@Component
public class ProductImageStorage {

    public static final String URL_PREFIX = "/images/products/";

    private static final Logger log = LoggerFactory.getLogger(ProductImageStorage.class);

    private final Path root;    // đường dẫn tuyệt đối tới thư mục .../uploads/products

    public ProductImageStorage(@Value("${petfood.upload-dir:uploads}") String uploadDir) {
        this.root = Path.of(uploadDir, "products").toAbsolutePath().normalize();
        try {
            Files.createDirectories(root);
        } catch (IOException e) {
            throw new UncheckedIOException("Không tạo được thư mục lưu ảnh " + root, e);
        }
        log.info("Ảnh sản phẩm tải lên được lưu tại {}", root);
    }

    public Path getRoot() {
        return root;
    }

    // Ghi ảnh (đã chuẩn hoá) của vị trí slot, trả về URL để lưu vào ProductImage.image_url.
    // Nếu transaction đang chạy bị rollback (ví dụ lỗi khi lưu DB) thì file vừa ghi tự bị xoá, không để lại rác.
    public String save(String sku, int slot, byte[] jpeg) {
        Path dir = productDir(sku);
        String fileName = slot + "-" + UUID.randomUUID().toString().substring(0, 8) + ".jpg";
        Path file = dir.resolve(fileName);
        try {
            Files.createDirectories(dir);
            Files.write(file, jpeg, StandardOpenOption.CREATE_NEW);
        } catch (IOException e) {
            throw new UncheckedIOException("Không lưu được ảnh " + file, e);
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCompletion(int status) {
                    if (status != STATUS_COMMITTED) {
                        deleteQuietly(file);
                    }
                }
            });
        }
        return URL_PREFIX + sku + "/" + fileName;
    }

    // Xoá file của URL sau khi transaction commit thành công (rollback thì giữ nguyên vì DB vẫn trỏ tới file).
    // URL không thuộc thư mục upload (ví dụ ảnh mẫu trong static/) thì bỏ qua, không bao giờ xoá ảnh mẫu.
    public void deleteAfterCommit(String url) {
        Path file = toUploadedFile(url);
        if (file == null) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    deleteQuietly(file);
                }
            });
        } else {
            deleteQuietly(file);
        }
    }

    // Thư mục của một SKU; chặn SKU kiểu "../.." thoát ra ngoài thư mục gốc
    private Path productDir(String sku) {
        Path dir = root.resolve(sku).normalize();
        if (!dir.startsWith(root) || dir.equals(root)) {
            throw new IllegalArgumentException("SKU không hợp lệ để làm tên thư mục: " + sku);
        }
        return dir;
    }

    // /images/products/<SKU>/<file>  ->  <root>/<SKU>/<file>; trả null nếu URL không nằm trong thư mục upload
    private Path toUploadedFile(String url) {
        if (url == null || !url.startsWith(URL_PREFIX)) {
            return null;
        }
        Path file = root.resolve(url.substring(URL_PREFIX.length())).normalize();
        if (!file.startsWith(root) || file.equals(root)) {
            return null;
        }
        return file;
    }

    private void deleteQuietly(Path file) {
        try {
            if (!Files.deleteIfExists(file)) {
                return;                                   // không có file (ví dụ ảnh mẫu nằm trong static/)
            }
            Path dir = file.getParent();
            if (dir != null && !dir.equals(root)) {
                try {
                    Files.deleteIfExists(dir);            // chỉ xoá được khi thư mục SKU đã trống
                } catch (DirectoryNotEmptyException ignored) {
                    // thư mục SKU còn ảnh khác: giữ lại
                }
            }
        } catch (IOException e) {
            log.warn("Không xoá được file ảnh {}: {}", file, e.getMessage());
        }
    }
}
