package com.isp392.petfood.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.net.http.HttpClient;
import java.text.Normalizer;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

// Đổi địa chỉ khách gõ thành toạ độ bằng Geoapify Geocoding API (chốt 16/10: gói miễn phí 3.000 request/ngày,
// không cần thẻ; Nominatim/OSM bị nhà mạng chặn, Google cần gắn thanh toán).
// Key đặt trong .env: petfood.geocoding.geoapify-api-key. Không có key / lỗi mạng / không tìm thấy -> Optional.empty().
// Ưu tiên kết quả gần cửa hàng (bias theo gốc toạ độ phí ship) để địa chỉ trùng tên ở tỉnh khác không bị chọn nhầm.
// Kết quả được nhớ lại (tối đa 500 địa chỉ) để bước "Tính phí ship" và "Đặt hàng" không tốn 2 request.
@Component
public class GeoapifyGeocoder {

    private static final Logger log = LoggerFactory.getLogger(GeoapifyGeocoder.class);
    private static final String URL = "https://api.geoapify.com/v1/geocode/search";
    private static final String AUTOCOMPLETE_URL = "https://api.geoapify.com/v1/geocode/autocomplete";
    private static final int MAX_SUGGESTIONS = 6;
    private static final int CACHE_SIZE = 500;

    public record Location(double lat, double lng) {
    }

    private final String apiKey;
    private final String bias;
    private final RestClient restClient;
    private final Map<String, Optional<Location>> cache = new LinkedHashMap<>(16, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, Optional<Location>> eldest) {
            return size() > CACHE_SIZE;
        }
    };

    public GeoapifyGeocoder(@Value("${petfood.geocoding.geoapify-api-key:}") String apiKey,
                            @Value("${petfood.shipping.origin-lat:10.8411}") double originLat,
                            @Value("${petfood.shipping.origin-lng:106.8099}") double originLng) {
        this.apiKey = apiKey == null ? "" : apiKey.trim();
        this.bias = "proximity:" + originLng + "," + originLat;       // Geoapify ghi kinh độ trước
        HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(http);
        factory.setReadTimeout(Duration.ofSeconds(5));
        this.restClient = RestClient.builder().requestFactory(factory).build();
    }

    public boolean isConfigured() {
        return !apiKey.isEmpty();
    }

    public Optional<Location> locate(String address) {
        if (!isConfigured() || address == null || address.isBlank()) {
            return Optional.empty();
        }
        String key = address.trim().replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
        synchronized (cache) {
            Optional<Location> cached = cache.get(key);
            if (cached != null) {
                return cached;
            }
        }
        Optional<Location> result = call(address.trim());
        synchronized (cache) {
            cache.put(key, result);
        }
        return result;
    }

    private Optional<Location> call(String address) {
        try {
            GeocodeResponse response = restClient.get()
                    .uri(URL + "?text={t}&filter=countrycode:vn&bias={b}&lang=vi&limit=1&format=json&apiKey={k}",
                            address, bias, apiKey)
                    .retrieve()
                    .body(GeocodeResponse.class);
            if (response == null || response.results() == null || response.results().isEmpty()) {
                log.info("Geoapify không tìm thấy địa chỉ \"{}\"", address);
                return Optional.empty();
            }
            GeocodeResponse.Result first = response.results().getFirst();
            return Optional.of(new Location(first.lat(), first.lon()));
        } catch (RestClientException e) {
            // 401: key sai; 429: hết 3.000 request/ngày; lỗi mạng
            log.warn("Không gọi được Geoapify: {}", e.getMessage());
            return Optional.empty();
        }
    }

    // Gợi ý tên đường khi khách gõ địa chỉ ở trang đặt hàng (Geoapify Autocomplete).
    // Chỉ giữ các đường nằm trong phường/xã khách đã chọn (tên phường mới sau 01/07/2025, trùng danh mục GHN),
    // để địa chỉ gửi GHN không bị "Địa chỉ nhận không hợp lệ". Ưu tiên kết quả quanh toạ độ của phường.
    // Không có key / lỗi mạng / không có đường nào trong phường -> danh sách rỗng (khách vẫn tự gõ được).
    public List<String> suggestStreets(String text, String ward, String province) {
        if (!isConfigured() || text == null || text.isBlank() || ward == null || ward.isBlank()) {
            return List.of();
        }
        String wardBias = locate(ward + (province == null || province.isBlank() ? "" : ", " + province))
                .map(loc -> "proximity:" + loc.lng() + "," + loc.lat())
                .orElse(bias);
        try {
            AutocompleteResponse response = restClient.get()
                    .uri(AUTOCOMPLETE_URL + "?text={t}&type=street&filter=countrycode:vn&bias={b}&lang=vi&limit=20&format=json&apiKey={k}",
                            text.trim(), wardBias, apiKey)
                    .retrieve()
                    .body(AutocompleteResponse.class);
            if (response == null || response.results() == null) {
                return List.of();
            }
            String wantedWard = normalize(ward);
            // type=street: chỉ lấy đường, không lẫn xã/ấp trùng tên người (Xã Lê Lợi, Ấp Nguyễn Huệ...).
            // Bỏ trùng theo tên không có chữ "Đường" ở đầu ("Đường Lê Lợi" và "Lê Lợi" là một).
            Set<String> seen = new LinkedHashSet<>();
            List<String> streets = new ArrayList<>();
            for (AutocompleteResponse.Result r : response.results()) {
                if (r.street() == null || r.street().isBlank()) {
                    continue;
                }
                boolean inWard = wantedWard.equals(normalize(r.suburb())) || wantedWard.equals(normalize(r.district()));
                if (inWard && seen.add(normalize(r.street()).replaceFirst("^đường\\s+", ""))) {
                    streets.add(r.street().trim());
                }
                if (streets.size() >= MAX_SUGGESTIONS) {
                    break;
                }
            }
            return streets;
        } catch (RestClientException e) {
            log.warn("Không gọi được Geoapify Autocomplete: {}", e.getMessage());
            return List.of();
        }
    }

    private static String normalize(String s) {
        return s == null ? "" : Normalizer.normalize(s.trim(), Normalizer.Form.NFC).toLowerCase(Locale.ROOT);
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record AutocompleteResponse(List<Result> results) {
        @JsonIgnoreProperties(ignoreUnknown = true)
        record Result(String street, String suburb, String district) {
        }
    }

    // Chỉ lấy các trường cần dùng trong JSON Geoapify trả về (format=json)
    @JsonIgnoreProperties(ignoreUnknown = true)
    record GeocodeResponse(List<Result> results) {
        @JsonIgnoreProperties(ignoreUnknown = true)
        record Result(double lat, double lon) {
        }
    }
}
