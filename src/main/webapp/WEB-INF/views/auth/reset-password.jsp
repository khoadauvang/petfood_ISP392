<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="login" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu · PetFood</title>

    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${ctx}/css/forgot-password.css">
</head>
<body>

    <%-- 1. HEADER CHUNG (TRONG SUỐT Ở TRÊN) --%>
    <c:set var="ownFlash" value="true"/>
    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <%-- 2. KHU VỰC ĐẶT LẠI MẬT KHẨU (FULL MÀN HÌNH, KHUNG TRẮNG NGÀ) --%>
    <main class="login-hero-section" style="background-image: url('${ctx}/images/login.jpg');">
        <div class="login-glass-card">
            <%-- Đang đăng nhập (đi từ trang hồ sơ) thì quay lại hồ sơ, Guest quay lại đăng nhập --%>
            <c:set var="backUrl" value="${empty currentUser ? '/login' : (currentUser.role == 'CUSTOMER' ? '/profile#password' : '/')}"/>
            <a href="${ctx}${backUrl}" class="glass-close-btn" title="Quay lại">
                <i class="fi fi-br-cross-small"></i>
            </a>

            <div class="forgot-icon-header">
                <i class="fi fi-rr-shield-check"></i>
            </div>

            <h1 class="glass-title">Đặt lại mật khẩu</h1>
            
            <div style="background:#FFF8F0; border:1px solid #F4E3C9; padding:10px 14px; border-radius:10px; margin-bottom:16px; font-size:12.5px; color:#57483A; line-height:1.5;">
                Mã OTP đã gửi đến <strong><c:out value="${email}"/></strong><c:if test="${empty currentUser}">
                (<a href="${ctx}/forgot-password" style="color:#F47721; font-weight:600; text-decoration:underline;">Đổi email</a>)</c:if>.<br>
                Mã có hiệu lực trong <strong>${otpMinutes} phút</strong>.
            </div>

            <%-- THÔNG BÁO LỖI / THÀNH CÔNG --%>
            <c:if test="${not empty successMessage}">
                <div class="login-alert success" style="margin-bottom:16px;">
                    <i class="fi fi-rr-check-circle"></i>
                    <span><c:out value="${successMessage}"/></span>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="login-alert error" style="margin-bottom:16px;">
                    <i class="fi fi-rr-exclamation"></i>
                    <span><c:out value="${errorMessage}"/></span>
                </div>
            </c:if>

            <%-- FORM NHẬP OTP VÀ ĐẶT LẠI MẬT KHẨU --%>
            <form:form method="post" action="${ctx}/forgot-password/verify" modelAttribute="otpResetForm" class="glass-form" id="resetPasswordForm" novalidate="novalidate">
                
                <div class="input-underline-group" id="otpGroup">
                    <form:input path="otp" id="otpInput" maxlength="6" inputmode="numeric" autocomplete="one-time-code" autofocus="autofocus" placeholder=" "/>
                    <label for="otpInput">Mã OTP (6 chữ số)</label>
                    <span class="input-right-icon"><i class="fi fi-rr-key"></i></span>
                </div>
                <div class="field-error-msg" id="otpErrorMsg"></div>
                <form:errors path="otp" cssClass="error-field-msg"/>

                <div class="input-underline-group" id="newPasswordGroup">
                    <form:password path="newPassword" id="newPasswordInput" maxlength="64" autocomplete="new-password" placeholder=" "/>
                    <label for="newPasswordInput">Mật khẩu mới (tối thiểu 6 ký tự)</label>
                    <span class="input-right-icon"><i class="fi fi-rr-lock"></i></span>
                </div>
                <div class="field-error-msg" id="newPasswordErrorMsg"></div>
                <form:errors path="newPassword" cssClass="error-field-msg"/>

                <div class="input-underline-group" id="confirmPasswordGroup">
                    <form:password path="confirmPassword" id="confirmPasswordInput" maxlength="64" autocomplete="new-password" placeholder=" "/>
                    <label for="confirmPasswordInput">Xác nhận lại mật khẩu</label>
                    <span class="input-right-icon"><i class="fi fi-rr-lock"></i></span>
                </div>
                <div class="field-error-msg" id="confirmPasswordErrorMsg"></div>
                <form:errors path="confirmPassword" cssClass="error-field-msg"/>

                <button type="submit" class="btn-glass-submit">
                    Xác nhận đổi mật khẩu
                </button>
            </form:form>

            <form method="post" action="${ctx}/forgot-password/resend" style="margin-top:16px; text-align:center;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <span style="font-size:13px; color:#8C7E74;">Chưa nhận được mã? </span>
                <button type="submit" id="resendBtn" data-wait="${not empty successMessage ? resendSeconds : 0}" style="background:none; border:none; color:#F47721; font-weight:700; font-size:13px; cursor:pointer; text-decoration:underline;">Gửi lại mã</button>
            </form>

            <p class="register-prompt" style="margin-top:14px;">
                <a href="${ctx}${backUrl}"><i class="fi fi-rr-arrow-left"></i> ${empty currentUser ? 'Quay lại đăng nhập' : 'Quay lại'}</a>
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
            window.addEventListener('scroll', handleScroll, { passive: true });
            handleScroll();

            // Đếm ngược gửi lại mã OTP
            const btn = document.getElementById('resendBtn');
            if (btn) {
                let left = parseInt(btn.dataset.wait, 10) || 0;
                const label = btn.textContent;
                function tick() {
                    if (left <= 0) { btn.disabled = false; btn.textContent = label; return; }
                    btn.disabled = true;
                    btn.textContent = label + ' (' + left + 's)';
                    left--;
                    setTimeout(tick, 1000);
                }
                if (left > 0) tick();
            }
        })();

        // CLIENT-SIDE VALIDATION FOR RESET PASSWORD
        document.addEventListener("DOMContentLoaded", function() {
            const form = document.getElementById("resetPasswordForm");
            const otp = document.getElementById("otpInput");
            const otpGroup = document.getElementById("otpGroup");
            const otpErr = document.getElementById("otpErrorMsg");

            const pwd = document.getElementById("newPasswordInput");
            const pwdGroup = document.getElementById("newPasswordGroup");
            const pwdErr = document.getElementById("newPasswordErrorMsg");

            const confirmPwd = document.getElementById("confirmPasswordInput");
            const confirmPwdGroup = document.getElementById("confirmPasswordGroup");
            const confirmPwdErr = document.getElementById("confirmPasswordErrorMsg");

            if (otp) {
                otp.addEventListener("input", function() {
                    const clean = otp.value.trim();
                    if (!clean) {
                        otpGroup.classList.remove("has-error");
                        otpErr.classList.remove("visible");
                        return;
                    }
                    if (!/^\d{6}$/.test(clean)) {
                        otpGroup.classList.add("has-error");
                        otpErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mã OTP phải gồm 6 chữ số.';
                        otpErr.classList.add("visible");
                    } else {
                        otpGroup.classList.remove("has-error");
                        otpErr.classList.remove("visible");
                    }
                });
            }

            if (pwd) {
                pwd.addEventListener("input", function() {
                    if (pwd.value && pwd.value.length < 6) {
                        pwdGroup.classList.add("has-error");
                        pwdErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mật khẩu phải từ 6 ký tự trở lên.';
                        pwdErr.classList.add("visible");
                    } else {
                        pwdGroup.classList.remove("has-error");
                        pwdErr.classList.remove("visible");
                    }
                    if (confirmPwd && confirmPwd.value) {
                        if (confirmPwd.value !== pwd.value) {
                            confirmPwdGroup.classList.add("has-error");
                            confirmPwdErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mật khẩu xác nhận không khớp.';
                            confirmPwdErr.classList.add("visible");
                        } else {
                            confirmPwdGroup.classList.remove("has-error");
                            confirmPwdErr.classList.remove("visible");
                        }
                    }
                });
            }

            if (confirmPwd) {
                confirmPwd.addEventListener("input", function() {
                    if (confirmPwd.value !== pwd.value) {
                        confirmPwdGroup.classList.add("has-error");
                        confirmPwdErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mật khẩu xác nhận không khớp.';
                        confirmPwdErr.classList.add("visible");
                    } else {
                        confirmPwdGroup.classList.remove("has-error");
                        confirmPwdErr.classList.remove("visible");
                    }
                });
            }

            if (form) {
                form.addEventListener("submit", function(e) {
                    let hasErr = false;
                    if (!/^\d{6}$/.test(otp.value.trim())) {
                        otpGroup.classList.add("has-error");
                        otpErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Vui lòng nhập mã OTP gồm 6 chữ số.';
                        otpErr.classList.add("visible");
                        otpGroup.classList.add("shake");
                        setTimeout(() => otpGroup.classList.remove("shake"), 400);
                        otp.focus();
                        hasErr = true;
                    }
                    if (!hasErr && (!pwd.value || pwd.value.length < 6)) {
                        pwdGroup.classList.add("has-error");
                        pwdErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mật khẩu phải từ 6 ký tự trở lên.';
                        pwdErr.classList.add("visible");
                        pwdGroup.classList.add("shake");
                        setTimeout(() => pwdGroup.classList.remove("shake"), 400);
                        pwd.focus();
                        hasErr = true;
                    }
                    if (!hasErr && confirmPwd.value !== pwd.value) {
                        confirmPwdGroup.classList.add("has-error");
                        confirmPwdErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Mật khẩu xác nhận không khớp.';
                        confirmPwdErr.classList.add("visible");
                        confirmPwdGroup.classList.add("shake");
                        setTimeout(() => confirmPwdGroup.classList.remove("shake"), 400);
                        confirmPwd.focus();
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
