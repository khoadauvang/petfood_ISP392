package com.isp392.petfood.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.multipart.MultipartFile;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class ProductImageSearchService {

    private static final Logger log = LoggerFactory.getLogger(ProductImageSearchService.class);
    private static final String URL = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent";

    private final String apiKey;
    private final String model;
    private final RestClient restClient;

    // Key riêng cho tìm kiếm bằng hình ảnh (tách quota với chatbox); không khai báo thì dùng chung key của chatbox
    public ProductImageSearchService(@Value("${petfood.gemini.vision-api-key:${petfood.gemini.api-key:}}") String apiKey,
                                     @Value("${petfood.gemini.model:gemini-flash-lite-latest}") String model) {
        this.apiKey = apiKey == null ? "" : apiKey.trim();
        this.model = model == null || model.isBlank() ? "gemini-flash-lite-latest" : model.trim();

        HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(15)).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(http);
        factory.setReadTimeout(Duration.ofSeconds(45));
        this.restClient = RestClient.builder().requestFactory(factory).build();
    }

    public boolean isConfigured() {
        return !apiKey.isEmpty();
    }

    public Optional<String> searchKeywordFromImage(MultipartFile file) {
        if (!isConfigured() || file == null || file.isEmpty()) {
            return Optional.empty();
        }

        try {
            byte[] bytes = file.getBytes();
            if (bytes.length == 0) {
                return Optional.empty();
            }

            String base64Data = Base64.getEncoder().encodeToString(bytes);
            String mimeType = file.getContentType();
            if (mimeType == null || !mimeType.startsWith("image/")) {
                mimeType = "image/jpeg";
            }

            String prompt = """
                    Bạn là chuyên gia nhận diện sản phẩm thức ăn và đồ dùng thú cưng (chó, mèo) cho cửa hàng PetFood.
                    Nhiệm vụ: Phân tích ảnh chụp bao bì thức ăn thú cưng được cung cấp.
                    Hãy trích xuất: Tên thương hiệu (ví dụ: Royal Canin, Whiskas, Me-O, Pedigree, SmartHeart, Zenith, Catsrang, Morando, Wanpy, Nutrience...) \
                    kèm theo tên dòng sản phẩm hoặc loại thức ăn chính (ví dụ: Kitten, Adult, Hairball, Fit 32, Pate cá ngừ, Hạt cho chó con...).
                    
                    Quy tắc:
                    1. Chỉ trả về DUY NHẤT một chuỗi từ khóa ngắn gọn gồm 2 đến 4 từ khóa chính để tìm kiếm sản phẩm trong cơ sở dữ liệu.
                    2. TUYỆT ĐỐI KHÔNG thêm bất kỳ câu chào hỏi, lời dẫn, giải thích hay dấu ngoặc kép.
                    3. Nếu ảnh chụp không phải là thức ăn hoặc đồ dùng thú cưng, hãy trả về chữ: UNKNOWN
                    """;

            Map<String, Object> textPart = Map.of("text", prompt);
            Map<String, Object> inlineData = Map.of(
                    "mimeType", mimeType,
                    "data", base64Data
            );
            Map<String, Object> imagePart = Map.of("inlineData", inlineData);

            Map<String, Object> content = Map.of(
                    "role", "user",
                    "parts", List.of(textPart, imagePart)
            );

            Map<String, Object> generationConfig = Map.of(
                    "temperature", 0.2,
                    "maxOutputTokens", 60
            );

            Map<String, Object> requestBody = Map.of(
                    "contents", List.of(content),
                    "generationConfig", generationConfig
            );

            VisionResponse response = restClient.post()
                    .uri(URL, model)
                    .header("x-goog-api-key", apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody)
                    .retrieve()
                    .body(VisionResponse.class);

            return cleanKeyword(response);
        } catch (RestClientException e) {
            log.warn("Lỗi khi gọi Gemini Vision API: {}", e.getMessage());
            return Optional.empty();
        } catch (Exception e) {
            log.error("Lỗi xử lý ảnh tìm kiếm: {}", e.getMessage(), e);
            return Optional.empty();
        }
    }

    private Optional<String> cleanKeyword(VisionResponse response) {
        if (response == null || response.candidates() == null || response.candidates().isEmpty()) {
            return Optional.empty();
        }
        VisionResponse.Candidate candidate = response.candidates().getFirst();
        if (candidate.content() == null || candidate.content().parts() == null) {
            return Optional.empty();
        }

        StringBuilder sb = new StringBuilder();
        for (VisionResponse.Part part : candidate.content().parts()) {
            if (part.text() != null) {
                sb.append(part.text());
            }
        }

        String raw = sb.toString().trim()
                .replaceAll("[\"'\n\r]", " ")
                .replaceAll("\\s+", " ")
                .trim();

        if (raw.isBlank() || raw.equalsIgnoreCase("UNKNOWN")) {
            return Optional.empty();
        }

        return Optional.of(raw);
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record VisionResponse(List<Candidate> candidates) {
        @JsonIgnoreProperties(ignoreUnknown = true)
        record Candidate(Content content) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        record Content(List<Part> parts) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        record Part(String text) {
        }
    }
}
