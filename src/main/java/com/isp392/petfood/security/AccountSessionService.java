package com.isp392.petfood.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.session.SessionInformation;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.stereotype.Service;

// Đăng xuất mọi phiên đang mở của một tài khoản (Admin khoá tài khoản nhân viên, mục 9.5).
// SessionRegistry ghi lại phiên khi đăng nhập (SecurityConfig.sessionManagement); phiên bị đánh dấu hết hạn
// thì ConcurrentSessionFilter đăng xuất ở request tiếp theo và chuyển về /login?expired.
// Cũng dùng khi Admin đổi vai trò hoặc đặt lại mật khẩu để nhân viên đăng nhập lại với quyền mới.
@Service
@RequiredArgsConstructor
public class AccountSessionService {

    private final SessionRegistry sessionRegistry;

    public int expireSessions(Long accountId) {
        int count = 0;
        for (Object principal : sessionRegistry.getAllPrincipals()) {
            if (principal instanceof AccountPrincipal p && p.getAccountId().equals(accountId)) {
                for (SessionInformation session : sessionRegistry.getAllSessions(principal, false)) {
                    session.expireNow();
                    count++;
                }
            }
        }
        return count;
    }
}
