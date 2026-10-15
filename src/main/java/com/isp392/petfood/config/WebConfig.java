package com.isp392.petfood.config;

import com.isp392.petfood.service.AvatarStorage;
import com.isp392.petfood.service.ProductImageStorage;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final ProductImageStorage productImageStorage;
    private final AvatarStorage avatarStorage;

    // URL /images/products/** tìm file ở hai nơi, theo thứ tự:
    //   1. thư mục upload (ảnh nhân viên tải lên lúc chạy), ví dụ ./uploads/products/RC-KITTEN36-400G/1-3f9a2c1b.jpg
    //   2. static/images/products trong source (ảnh mẫu đi kèm script seed), ví dụ .../RC-KITTEN36-400G/1.jpg
    // Nhờ vậy URL trong DB giữ một kiểu duy nhất, JSP chỉ cần ${ctx}${imageUrl}.
    // URL /images/avatars/** là ảnh đại diện khách tải lên, ví dụ ./uploads/avatars/c12-9b1e4d7a.jpg
    // SecurityConfig đã permitAll "/images/**" nên khách chưa đăng nhập vẫn xem được ảnh.
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler(ProductImageStorage.URL_PREFIX + "**")
                .addResourceLocations(directoryUri(productImageStorage.getRoot()), "classpath:/static/images/products/");
        registry.addResourceHandler(AvatarStorage.URL_PREFIX + "**")
                .addResourceLocations(directoryUri(avatarStorage.getRoot()));
    }

    private static String directoryUri(Path dir) {
        String location = dir.toUri().toString();
        return location.endsWith("/") ? location : location + "/";   // thiếu "/" cuối thì Spring hiểu là file
    }
}
