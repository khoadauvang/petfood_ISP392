package com.isp392.petfood.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.stereotype.Component;

// Thay AccountPrincipal trong session sau khi khách sửa hồ sơ, để ${currentUser.fullName} / avatar trên
// thanh đầu trang cập nhật ngay mà không phải đăng xuất rồi đăng nhập lại.
@Component
public class CurrentUserRefresher {

    private final SecurityContextRepository contextRepository = new HttpSessionSecurityContextRepository();

    public void replace(AccountPrincipal updated, HttpServletRequest request, HttpServletResponse response) {
        Authentication current = SecurityContextHolder.getContext().getAuthentication();
        // Giữ đúng kiểu token cũ: đăng nhập Google vẫn là OAuth2AuthenticationToken
        Authentication replaced = current instanceof OAuth2AuthenticationToken oauth
                ? new OAuth2AuthenticationToken(updated, updated.getAuthorities(), oauth.getAuthorizedClientRegistrationId())
                : UsernamePasswordAuthenticationToken.authenticated(updated, null, updated.getAuthorities());

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(replaced);
        SecurityContextHolder.setContext(context);
        contextRepository.saveContext(context, request, response);
    }
}
