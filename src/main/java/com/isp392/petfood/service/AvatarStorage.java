package com.isp392.petfood.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.UUID;

// Lưu ảnh đại diện khách hàng ra <petfood.upload-dir>/avatars/ (cùng lý do với ProductImageStorage:
// không ghi vào src/ hay target/). WebConfig phục vụ thư mục này ở URL /images/avatars/**.
// Tên file c<customerId>-<ngẫu nhiên>.jpg: đổi ảnh thì URL đổi, trình duyệt không hiện ảnh cũ trong cache.
@Component
public class AvatarStorage {

    public static final String URL_PREFIX = "/images/avatars/";

    private static final Logger log = LoggerFactory.getLogger(AvatarStorage.class);

    private final Path root;

    public AvatarStorage(@Value("${petfood.upload-dir:uploads}") String uploadDir) {
        this.root = Path.of(uploadDir, "avatars").toAbsolutePath().normalize();
        try {
            Files.createDirectories(root);
        } catch (IOException e) {
            throw new UncheckedIOException("Không tạo được thư mục lưu ảnh đại diện " + root, e);
        }
    }

    public Path getRoot() {
        return root;
    }

    // Ghi ảnh (đã chuẩn hoá JPG), trả về URL để lưu vào Customer.avatar_url.
    // Transaction đang chạy bị rollback thì file vừa ghi tự bị xoá.
    public String save(Long customerId, byte[] jpeg) {
        String fileName = "c" + customerId + "-" + UUID.randomUUID().toString().substring(0, 8) + ".jpg";
        Path file = root.resolve(fileName);
        try {
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
        return URL_PREFIX + fileName;
    }

    // Xoá ảnh cũ sau khi transaction commit (rollback thì giữ, vì DB vẫn trỏ tới nó).
    // URL không thuộc thư mục avatars thì bỏ qua.
    public void deleteAfterCommit(String url) {
        if (url == null || !url.startsWith(URL_PREFIX)) {
            return;
        }
        Path file = root.resolve(url.substring(URL_PREFIX.length())).normalize();
        if (!file.startsWith(root) || file.equals(root)) {
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

    private void deleteQuietly(Path file) {
        try {
            Files.deleteIfExists(file);
        } catch (IOException e) {
            log.warn("Không xoá được ảnh đại diện {}: {}", file, e.getMessage());
        }
    }
}
