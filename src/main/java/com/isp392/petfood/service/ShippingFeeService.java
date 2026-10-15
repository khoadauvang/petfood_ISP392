package com.isp392.petfood.service;

import com.isp392.petfood.dto.ShippingQuote;
import com.isp392.petfood.service.GoogleGeocoder.Location;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

// Phí giao hàng (chốt 15/10, thay bảng ShippingFeeRule đã bỏ):
//   địa chỉ giao cách gốc (Đại học FPT TP.HCM) <= 5km  VÀ  tiền hàng sau giảm giá hạng >= 150.000đ  -> miễn phí
//   còn lại -> 30.000đ (gồm cả trường hợp không xác định được vị trí)
// Khoảng cách là đường chim bay (công thức Haversine), đúng nghĩa "bán kính".
// Server luôn tự tính, không nhận phí ship do trình duyệt gửi lên.
@Service
public class ShippingFeeService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    private final GoogleGeocoder geocoder;
    private final BigDecimal flatFee;
    private final BigDecimal freeMinSubtotal;
    private final double freeRadiusKm;
    private final double originLat;
    private final double originLng;

    public ShippingFeeService(GoogleGeocoder geocoder,
                              @Value("${petfood.shipping.flat-fee:30000}") BigDecimal flatFee,
                              @Value("${petfood.shipping.free-min-subtotal:150000}") BigDecimal freeMinSubtotal,
                              @Value("${petfood.shipping.free-radius-km:5}") double freeRadiusKm,
                              @Value("${petfood.shipping.origin-lat:10.8411}") double originLat,
                              @Value("${petfood.shipping.origin-lng:106.8099}") double originLng) {
        this.geocoder = geocoder;
        this.flatFee = flatFee;
        this.freeMinSubtotal = freeMinSubtotal;
        this.freeRadiusKm = freeRadiusKm;
        this.originLat = originLat;
        this.originLng = originLng;
    }

    // goodsTotal: tiền hàng sau giảm giá hạng, chưa gồm phí ship
    public ShippingQuote quote(String address, BigDecimal goodsTotal) {
        Optional<Location> location = geocoder.locate(address);
        if (location.isEmpty()) {
            String reason = geocoder.isConfigured()
                    ? "Không tìm thấy địa chỉ trên bản đồ nên không xét miễn phí giao hàng. Hãy ghi rõ số nhà, đường, phường, thành phố."
                    : "Chưa cấu hình dịch vụ bản đồ nên không xét miễn phí giao hàng.";
            return new ShippingQuote(flatFee, null, null, reason);
        }
        Location loc = location.get();
        double km = distanceKm(originLat, originLng, loc.lat(), loc.lng());
        boolean nearby = km <= freeRadiusKm;
        boolean bigEnough = goodsTotal.compareTo(freeMinSubtotal) >= 0;
        if (nearby && bigEnough) {
            return new ShippingQuote(BigDecimal.ZERO, km, loc.formattedAddress(), "Miễn phí giao hàng (trong "
                    + format(freeRadiusKm) + "km, đơn từ " + money(freeMinSubtotal) + ")");
        }
        String reason = nearby
                ? "Đơn chưa đủ " + money(freeMinSubtotal) + " tiền hàng để được miễn phí giao hàng"
                : "Địa chỉ ngoài bán kính " + format(freeRadiusKm) + "km nên không được miễn phí giao hàng";
        return new ShippingQuote(flatFee, km, loc.formattedAddress(), reason);
    }

    // Khoảng cách đường chim bay giữa 2 toạ độ (Haversine)
    static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(a));
    }

    private static String format(double km) {
        return km == Math.rint(km) ? String.valueOf((long) km) : String.valueOf(km);
    }

    private static String money(BigDecimal amount) {
        return String.format("%,d", amount.longValue()).replace(',', '.') + "đ";
    }
}
