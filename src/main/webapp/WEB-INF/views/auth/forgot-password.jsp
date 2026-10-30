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
    <title>Quên mật khẩu · PetFood</title>

    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${ctx}/css/forgot-password.css">
</head>
<body>

    <%-- 1. HEADER CHUNG --%>
    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <%-- 2. KHU VỰC QUÊN MẬT KHẨU (FULL MÀN HÌNH, KHUNG TRẮNG NGÀ) --%>
    <main class="login-hero-section" style="background-image: url('${ctx}/images/login.jpg');">
        <div class="login-glass-card">
            <%-- Nút X quay lại login --%>
            <a href="${ctx}/login" class="glass-close-btn" title="Quay lại đăng nhập">
                <i class="fi fi-br-cross-small"></i>
            </a>

            <div class="forgot-icon-header">
                <i class="fi fi-rr-key"></i>
            </div>

            <h1 class="glass-title">Quên mật khẩu</h1>
            <p class="glass-subtitle">Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP gồm 6 chữ số để bạn đặt mật khẩu mới.</p>

            <%-- THÔNG BÁO LỖI NẾU CÓ --%>
            <c:if test="${not empty errorMessage}">
                <div class="login-alert error">
                    <i class="fi fi-rr-exclamation"></i>
                    <span><c:out value="${errorMessage}"/></span>
                </div>
            </c:if>

            <%-- FORM QUÊN MẬT KHẨU --%>
            <form:form method="post" action="${ctx}/forgot-password" modelAttribute="forgotPasswordForm" class="glass-form" id="forgotForm" novalidate="novalidate">
                
                <div class="input-underline-group" id="forgotEmailGroup">
                    <form:input path="email" type="email" id="forgotEmailInput" maxlength="255" autofocus="autofocus" placeholder=" "/>
                    <label for="forgotEmailInput">Email đăng ký</label>
                    <span class="input-right-icon"><i class="fi fi-rr-envelope"></i></span>
                </div>
                <div class="field-error-msg" id="forgotEmailError"></div>
                <form:errors path="email" cssClass="error-field-msg"/>

                <button type="submit" class="btn-glass-submit">
                    <i class="fi fi-rr-paper-plane"></i> Gửi mã OTP
                </button>
            </form:form>

            <p class="register-prompt">
                <a href="${ctx}/login"><i class="fi fi-rr-arrow-left"></i> Quay lại đăng nhập</a>
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
        })();

        // CLIENT-SIDE VALIDATION FOR FORGOT PASSWORD
        document.addEventListener("DOMContentLoaded", function() {
            const emailInput = document.getElementById("forgotEmailInput");
            const emailGroup = document.getElementById("forgotEmailGroup");
            const emailError = document.getElementById("forgotEmailError");
            const form = document.getElementById("forgotForm");

            function checkEmail(val) {
                if (!val || !val.trim()) return { ok: false, msg: "Vui lòng nhập địa chỉ email." };
                const re = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;
                if (!re.test(val.trim())) return { ok: false, msg: "Email không đúng định dạng (ví dụ: petfood@gmail.com)." };
                return { ok: true };
            }

            if (emailInput) {
                emailInput.addEventListener("input", function() {
                    if (!emailInput.value.trim()) {
                        emailGroup.classList.remove("has-error");
                        emailError.classList.remove("visible");
                        return;
                    }
                    const res = checkEmail(emailInput.value);
                    if (!res.ok) {
                        emailGroup.classList.add("has-error");
                        emailError.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                        emailError.classList.add("visible");
                    } else {
                        emailGroup.classList.remove("has-error");
                        emailError.classList.remove("visible");
                    }
                });
            }

            if (form) {
                form.addEventListener("submit", function(e) {
                    const res = checkEmail(emailInput.value);
                    if (!res.ok) {
                        e.preventDefault();
                        emailGroup.classList.add("has-error");
                        emailError.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                        emailError.classList.add("visible");
                        emailGroup.classList.add("shake");
                        setTimeout(() => emailGroup.classList.remove("shake"), 400);
                        emailInput.focus();
                    }
                });
            }
        });
    </script>
</body>
</html>
