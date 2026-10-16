package com.isp392.petfood.service;

import com.isp392.petfood.enums.MediaType;
import com.isp392.petfood.exception.BusinessRuleException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;
import java.util.UUID;

// Lưu ảnh / video khách gửi kèm yêu cầu trả hàng: <petfood.upload-dir>/returns/<returnId>/<ngẫu nhiên>.<đuôi>,
// phục vụ ở URL /images/returns/** (WebConfig). Tên file ngẫu nhiên dài nên không đoán được link của người khác.
// Loại file xét theo nội dung (vài byte đầu), không tin đuôi file hay Content-Type trình duyệt gửi.
// Ảnh / video giữ nguyên bản gốc (không nén lại) để làm bằng chứng khi thẩm định.
@Component
public class ReturnMediaStorage {

    public static final String URL_PREFIX = "/images/returns/";

    public record Detected(MediaType type, String extension) {
    }

    private static final Logger log = LoggerFactory.getLogger(ReturnMediaStorage.class);

    private final Path root;

    public ReturnMediaStorage(@Value("${petfood.upload-dir:uploads}") String uploadDir) {
        this.root = Path.of(uploadDir, "returns").toAbsolutePath().normalize();
        try {
            Files.createDirectories(root);
        } catch (IOException e) {
            throw new UncheckedIOException("Không tạo được thư mục lưu file trả hàng " + root, e);
        }
    }

    public Path getRoot() {
        return root;
    }

    // Nhận JPG, PNG, WEBP, MP4 / MOV, WEBM
    public Detected detect(byte[] data, String fieldLabel) {
        if (startsWith(data, 0, 0xFF, 0xD8, 0xFF)) {
            return new Detected(MediaType.IMAGE, "jpg");
        }
        if (startsWith(data, 0, 0x89, 'P', 'N', 'G')) {
            return new Detected(MediaType.IMAGE, "png");
        }
        if (startsWith(data, 0, 'R', 'I', 'F', 'F') && startsWith(data, 8, 'W', 'E', 'B', 'P')) {
            return new Detected(MediaType.IMAGE, "webp");
        }
        if (startsWith(data, 4, 'f', 't', 'y', 'p')) {
            String brand = data.length >= 12 ? new String(Arrays.copyOfRange(data, 8, 12), StandardCharsets.US_ASCII) : "";
            return new Detected(MediaType.VIDEO, brand.startsWith("qt") ? "mov" : "mp4");
        }
        if (startsWith(data, 0, 0x1A, 0x45, 0xDF, 0xA3)) {
            return new Detected(MediaType.VIDEO, "webm");
        }
        throw new BusinessRuleException("media", fieldLabel + " không phải ảnh (JPG, PNG, WEBP) hoặc video (MP4, MOV, WEBM)");
    }

    // Ghi file, trả về URL lưu vào ReturnMedia.media_url. Transaction rollback thì file vừa ghi tự bị xoá.
    public String save(Long returnId, byte[] data, String extension) {
        Path dir = root.resolve(String.valueOf(returnId));
        Path file = dir.resolve(UUID.randomUUID().toString().replace("-", "") + "." + extension);
        try {
            Files.createDirectories(dir);
            Files.write(file, data, StandardOpenOption.CREATE_NEW);
        } catch (IOException e) {
            throw new UncheckedIOException("Không lưu được file " + file, e);
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCompletion(int status) {
                    if (status != STATUS_COMMITTED) {
                        try {
                            Files.deleteIfExists(file);
                            try (var rest = Files.list(dir)) {
                                if (rest.findAny().isEmpty()) {
                                    Files.deleteIfExists(dir);      // thư mục của yêu cầu không còn file nào
                                }
                            }
                        } catch (IOException e) {
                            log.warn("Không xoá được file {}: {}", file, e.getMessage());
                        }
                    }
                }
            });
        }
        return URL_PREFIX + returnId + "/" + file.getFileName();
    }

    private static boolean startsWith(byte[] data, int offset, int... expected) {
        if (data.length < offset + expected.length) {
            return false;
        }
        for (int i = 0; i < expected.length; i++) {
            if ((data[offset + i] & 0xFF) != expected[i]) {
                return false;
            }
        }
        return true;
    }
}
