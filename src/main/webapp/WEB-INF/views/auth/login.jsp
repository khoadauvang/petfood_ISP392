<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="login" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/login.css">
    </head>
    <body>

        <%-- 1. HEADER CHUNG CỦA HỆ THỐNG --%>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <%-- 2. KHU VỰC ĐĂNG NHẬP (FULL MÀN HÌNH, KHUNG TRẮNG NGÀ TỐI GIẢN) --%>
        <main class="login-hero-section" style="background-image: url('${ctx}/images/login.jpg');">
            <div class="login-glass-card">
                <%-- Nút X góc phải trên quay về trang chủ --%>
                <a href="${ctx}/" class="glass-close-btn" title="Về trang chủ">
                    <i class="fi fi-br-cross-small"></i>
                </a>

                <h1 class="glass-title">Đăng nhập</h1>

                <%-- HIỂN THỊ THÔNG BÁO LỖI / THÀNH CÔNG TỪ BACKEND --%>
                <c:if test="${param.error != null}">
                    <div class="login-alert error">
                        <i class="fi fi-rr-exclamation"></i>
                        <span>Email hoặc mật khẩu không đúng.</span>
                    </div>
                </c:if>
                <c:if test="${param.locked != null}">
                    <div class="login-alert error">
                        <i class="fi fi-rr-lock"></i>
                        <span>Tài khoản đã bị khoá. Vui lòng liên hệ quản trị viên.</span>
                    </div>
                </c:if>
                <c:if test="${param.expired != null}">
                    <div class="login-alert error">
                        <i class="fi fi-rr-time-past"></i>
                        <span>Phiên đăng nhập đã kết thúc do tài khoản vừa bị khoá hoặc thay đổi quyền / mật khẩu. Vui lòng đăng nhập lại.</span>
                    </div>
                </c:if>
                <c:if test="${param.googleError != null}">
                    <div class="login-alert error">
                        <i class="fi fi-rr-exclamation"></i>
                        <span>
                            Đăng nhập Google không thành công.
                            <c:out value="${sessionScope.SPRING_SECURITY_LAST_EXCEPTION.message}"/>
                        </span>
                    </div>
                </c:if>

                <c:if test="${param.logout != null}">
                    <div class="login-alert success">
                        <i class="fi fi-rr-check-circle"></i>
                        <span>Bạn đã đăng xuất thành công.</span>
                    </div>
                </c:if>
                <c:if test="${param.reset != null}">
                    <div class="login-alert success">
                        <i class="fi fi-rr-check-circle"></i>
                        <span>Đã đặt lại mật khẩu, mời bạn đăng nhập bằng mật khẩu mới.</span>
                    </div>
                </c:if>
                <c:if test="${param.registered != null}">
                    <div class="login-alert success">
                        <i class="fi fi-rr-check-circle"></i>
                        <span>Đăng ký thành công, mời bạn đăng nhập.</span>
                    </div>
                </c:if>

                <%-- FORM ĐĂNG NHẬP --%>
                <form method="post" action="${ctx}/login" class="glass-form" id="loginForm" novalidate>
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                    <div class="input-underline-group" id="emailGroup">
                        <input type="email" name="email" id="emailInput" placeholder=" " autofocus autocomplete="email">
                        <label for="emailInput">Email</label>
                        <span class="input-right-icon"><i class="fi fi-rr-envelope"></i></span>
                    </div>
                    <div class="field-error-msg" id="emailErrorMsg"></div>

                    <div class="input-underline-group" id="passwordGroup">
                        <input type="password" name="password" id="passwordInput" placeholder=" " autocomplete="current-password">
                        <label for="passwordInput">Mật khẩu</label>
                        <span class="input-right-icon"><i class="fi fi-rr-lock"></i></span>
                    </div>
                    <div class="field-error-msg" id="passwordErrorMsg"></div>

                    <div class="remember-forgot-row">
                        <label class="remember-label">
                            <input type="checkbox" name="remember-me">
                            <span>Ghi nhớ đăng nhập</span>
                        </label>
                        <a href="${ctx}/forgot-password" class="forgot-link">Quên mật khẩu?</a>
                    </div>

                    <button type="submit" class="btn-glass-submit">Đăng nhập</button>
                </form>

                <%-- NÚT ĐĂNG NHẬP GOOGLE --%>
                <c:if test="${googleLoginEnabled != false}">
                    <div class="divider-line">
                        <span>hoặc</span>
                    </div>
                    <a href="${ctx}/oauth2/authorization/google" class="btn-google-login">
                        <svg width="18" height="18" viewBox="0 0 48 48">
                            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                        </svg>
                        <span>Đăng nhập bằng Google</span>
                    </a>
                </c:if>

                <p class="register-prompt">
                    Chưa có tài khoản? <a href="${ctx}/register">Đăng ký</a>
                </p>
            </div>
        </main>

        <%-- NÚT CHAT NỔI --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            (function () {
                const headerEl = document.querySelector('.header');
                if (!headerEl) return;
                function handleScroll() {
                    if (window.scrollY > 40) {
                        headerEl.classList.add('scrolled');
                    } else {
                        headerEl.classList.remove('scrolled');
                    }
                }
                window.addEventListener('scroll', handleScroll, {passive: true});
                handleScroll();
            })();

            // KIỂM TRA ĐỊNH DẠNG NGAY KHI GÕ (CLIENT-SIDE FORMAT VALIDATION)
            document.addEventListener("DOMContentLoaded", function() {
                const emailInput = document.getElementById("emailInput");
                const emailGroup = document.getElementById("emailGroup");
                const emailError = document.getElementById("emailErrorMsg");
                const passwordInput = document.getElementById("passwordInput");
                const passwordGroup = document.getElementById("passwordGroup");
                const passwordError = document.getElementById("passwordErrorMsg");
                const form = document.getElementById("loginForm");

                function validateEmail(val) {
                    if (!val || val.trim() === "") {
                        return { valid: false, msg: "Vui lòng nhập địa chỉ email." };
                    }
                    const trimmed = val.trim();
                    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;
                    if (!emailRegex.test(trimmed)) {
                        return { valid: false, msg: "Email không đúng định dạng (ví dụ: petfood@gmail.com)." };
                    }
                    return { valid: true };
                }

                if (emailInput && emailGroup && emailError) {
                    emailInput.addEventListener("input", function() {
                        const val = emailInput.value;
                        if (!val || val.trim() === "") {
                            emailGroup.classList.remove("has-error");
                            emailError.classList.remove("visible");
                            return;
                        }
                        const res = validateEmail(val);
                        if (!res.valid) {
                            emailGroup.classList.add("has-error");
                            emailError.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                            emailError.classList.add("visible");
                        } else {
                            emailGroup.classList.remove("has-error");
                            emailError.classList.remove("visible");
                        }
                    });

                    emailInput.addEventListener("blur", function() {
                        const val = emailInput.value;
                        if (val && val.trim() !== "") {
                            const res = validateEmail(val);
                            if (!res.valid) {
                                emailGroup.classList.add("has-error");
                                emailError.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                                emailError.classList.add("visible");
                            }
                        }
                    });
                }

                if (passwordInput && passwordGroup && passwordError) {
                    passwordInput.addEventListener("input", function() {
                        if (passwordInput.value.trim() !== "") {
                            passwordGroup.classList.remove("has-error");
                            passwordError.classList.remove("visible");
                        }
                    });
                }

                if (form) {
                    form.addEventListener("submit", function(e) {
                        let hasErr = false;
                        if (emailInput) {
                            const res = validateEmail(emailInput.value);
                            if (!res.valid) {
                                emailGroup.classList.add("has-error");
                                emailError.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                                emailError.classList.add("visible");
                                emailGroup.classList.add("shake");
                                setTimeout(() => emailGroup.classList.remove("shake"), 400);
                                emailInput.focus();
                                hasErr = true;
                            }
                        }
                        if (!hasErr && passwordInput && !passwordInput.value.trim()) {
                            passwordGroup.classList.add("has-error");
                            passwordError.innerHTML = '<i class="fi fi-rr-exclamation"></i> Vui lòng nhập mật khẩu.';
                            passwordError.classList.add("visible");
                            passwordGroup.classList.add("shake");
                            setTimeout(() => passwordGroup.classList.remove("shake"), 400);
                            passwordInput.focus();
                            hasErr = true;
                        }
                        if (hasErr) {
                            e.preventDefault();
                        }
                    });
                }
            });
        </script>
    </body>
</html>
