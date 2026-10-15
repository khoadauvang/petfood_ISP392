package com.isp392.petfood.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

// Đổi địa chỉ khách gõ thành toạ độ bằng Google Geocoding API (chốt 15/10: Nominatim/OSM bị nhà mạng chặn).
// Key đặt trong .env: petfood.geocoding.google-api-key. Không có key / lỗi mạng / không tìm thấy -> Optional.empty().
// Kết quả được nhớ lại (tối đa 500 địa chỉ) để bước "Tính phí ship" và "Đặt hàng" không gọi Google 2 lần.
@Component
public class GoogleGeocoder {

    private static final Logger log = LoggerFactory.getLogger(GoogleGeocoder.class);
    private static final String URL = "https://maps.googleapis.com/maps/api/geocode/json";
    private static final int CACHE_SIZE = 500;

    public record Location(double lat, double lng, String formattedAddress) {
    }

    private final String apiKey;
    private final RestClient restClient;
    private final Map<String, Optional<Location>> cache = new LinkedHashMap<>(16, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, Optional<Location>> eldest) {
            return size() > CACHE_SIZE;
        }
    };

    public GoogleGeocoder(@Value("${petfood.geocoding.google-api-key:}") String apiKey) {
        this.apiKey = apiKey == null ? "" : apiKey.trim();
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
                    .uri(URL + "?address={a}&components=country:VN&region=vn&language=vi&key={k}", address, apiKey)
                    .retrieve()
                    .body(GeocodeResponse.class);
            if (response == null || !"OK".equals(response.status()) || response.results() == null
                    || response.results().isEmpty()) {
                // ZERO_RESULTS: không tìm thấy; REQUEST_DENIED: key sai / chưa bật Geocoding API
                log.info("Google Geocoding không ra kết quả cho \"{}\": {} {}", address,
                        response == null ? null : response.status(),
                        response == null ? "" : response.errorMessage());
                return Optional.empty();
            }
            GeocodeResponse.Result first = response.results().getFirst();
            return Optional.of(new Location(first.geometry().location().lat(), first.geometry().location().lng(),
                    first.formattedAddress()));
        } catch (RestClientException e) {
            log.warn("Không gọi được Google Geocoding: {}", e.getMessage());
            return Optional.empty();
        }
    }

    // Chỉ lấy các trường cần dùng trong JSON Google trả về
    @JsonIgnoreProperties(ignoreUnknown = true)
    record GeocodeResponse(String status, @JsonProperty("error_message") String errorMessage,
                           List<Result> results) {
        @JsonIgnoreProperties(ignoreUnknown = true)
        record Result(@JsonProperty("formatted_address") String formattedAddress,
                      Geometry geometry) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        record Geometry(LatLng location) {
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        record LatLng(double lat, double lng) {
        }
    }
}
