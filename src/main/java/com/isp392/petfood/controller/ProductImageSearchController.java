package com.isp392.petfood.controller;

import com.isp392.petfood.service.ProductImageSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
public class ProductImageSearchController {

    private final ProductImageSearchService imageSearchService;

    @PostMapping("/products/search-by-image")
    public ResponseEntity<Map<String, Object>> searchByImage(@RequestParam(value = "image", required = false) MultipartFile image) {
        if (!imageSearchService.isConfigured()) {
            return ResponseEntity.ok(Map.of(
                    "ok", false,
                    "message", "Chưa cấu hình Gemini API Key cho hệ thống."
            ));
        }

        if (image == null || image.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", "Vui lòng tải lên hoặc chụp một bức ảnh!"
            ));
        }

        // Kiểm tra dung lượng tối đa 10MB
        if (image.getSize() > 10 * 1024 * 1024) {
            return ResponseEntity.badRequest().body(Map.of(
                    "ok", false,
                    "message", "Ảnh quá lớn! Vui lòng chọn ảnh dung lượng dưới 10MB."
            ));
        }

        Optional<String> keywordOpt = imageSearchService.searchKeywordFromImage(image);

        if (keywordOpt.isEmpty()) {
            return ResponseEntity.ok(Map.of(
                    "ok", false,
                    "message", "Không thể nhận diện sản phẩm thú cưng từ ảnh này. Bạn hãy thử chụp rõ góc hoặc chụp trực diện bao bì hơn nhé!"
            ));
        }

        String keyword = keywordOpt.get();
        String encoded = URLEncoder.encode(keyword, StandardCharsets.UTF_8);

        return ResponseEntity.ok(Map.of(
                "ok", true,
                "keyword", keyword,
                "redirectUrl", "/products?keyword=" + encoded
        ));
    }
}
