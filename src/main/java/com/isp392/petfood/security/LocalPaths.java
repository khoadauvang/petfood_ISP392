package com.isp392.petfood.security;

// Kiểm tra đường dẫn chuyển hướng do trình duyệt gửi lên (returnUrl, redirect sau đăng nhập):
// chỉ nhận đường dẫn trong app ("/products/12"), chặn chuyển hướng ra trang ngoài ("//evil.com", "http://...")
public final class LocalPaths {

    private LocalPaths() {
    }

    public static boolean isLocalPath(String url) {
        return url != null && url.startsWith("/") && !url.startsWith("//") && !url.contains("\\")
                && url.chars().noneMatch(Character::isISOControl);
    }
}
