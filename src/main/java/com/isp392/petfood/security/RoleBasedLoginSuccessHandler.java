package com.isp392.petfood.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
                //Khách đang mở /orders thì bị bắt đăng nhập -> Login xong qlại đúng trang đó
                SavedRequest saved = requestCache.getRequest(request, response);
                yield (saved != null) ? saved.getRedirectUrl() : ctx + "/";
                //yield trả kết quả cho switch expression
            }
        };

        requestCache.removeRequest(request, response);
        response.sendRedirect(targetUrl);
    }
}
