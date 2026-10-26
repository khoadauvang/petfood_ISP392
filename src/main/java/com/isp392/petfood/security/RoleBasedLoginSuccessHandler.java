package com.isp392.petfood.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class RoleBasedLoginSuccessHandler implements AuthenticationSuccessHandler {
    //class direct based on ROLE

    // Trang khách muốn quay lại sau khi đăng nhập (/login?redirect=/products/12, AuthController cất vào session).
    // Để trong session thay vì trên URL để vẫn còn sau khi gõ sai mật khẩu (/login?error) hoặc đăng nhập Google.
    public static final String SESSION_REDIRECT = "loginRedirect";

    private final RequestCache requestCache = new HttpSessionRequestCache();

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        AccountPrincipal user = (AccountPrincipal) authentication.getPrincipal();
        String ctx = request.getContextPath();

        String targetUrl = switch (user.getRole()) {
            case ADMIN -> ctx + "/admin";
            case STAFF -> ctx + "/staff";
            case CUSTOMER -> {
                // Guest bấm "Thêm vào giỏ" ở trang chi tiết -> đăng nhập xong quay lại đúng trang sản phẩm đó
                String redirect = sessionRedirect(request);
                if (redirect != null) {
                    yield ctx + redirect;
                }
                //Khách đang mở /orders thì bị bắt đăng nhập -> Login xong qlại đúng trang đó
                SavedRequest saved = requestCache.getRequest(request, response);
                yield (saved != null) ? saved.getRedirectUrl() : ctx + "/";
                //yield trả kết quả cho switch expression
            }
        };
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(SESSION_REDIRECT);
        }

        requestCache.removeRequest(request, response);
        response.sendRedirect(targetUrl);
    }

    private static String sessionRedirect(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object redirect = session == null ? null : session.getAttribute(SESSION_REDIRECT);
        return redirect instanceof String url && LocalPaths.isLocalPath(url) ? url : null;
    }
}
