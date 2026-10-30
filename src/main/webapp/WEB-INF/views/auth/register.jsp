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
    <title>Đăng ký tài khoản · PetFood</title>

    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${ctx}/css/register.css">
</head>
<body>

    <%-- 1. HEADER CHUNG --%>
    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <%-- 2. KHU VỰC ĐĂNG KÝ (FULL MÀN HÌNH, KHUNG TRẮNG NGÀ) --%>
    <main class="login-hero-section" style="background-image: url('${ctx}/images/login.jpg');">
        <div class="login-glass-card register-wide-card">
            <%-- Nút X quay lại login --%>
            <a href="${ctx}/login" class="glass-close-btn" title="Quay lại đăng nhập">
                <i class="fi fi-br-cross-small"></i>
            </a>

            <div class="forgot-icon-header">
                <i class="fi fi-rr-user-add"></i>
            </div>

            <h1 class="glass-title">Đăng ký tài khoản</h1>
            <p class="glass-subtitle">Tham gia PetFood để chăm sóc thú cưng với dinh dưỡng chuẩn FEFO.</p>

            <%-- FORM ĐĂNG KÝ --%>
            <form:form method="post" action="${ctx}/register" modelAttribute="registerForm" class="glass-form" id="registerForm" novalidate="novalidate">

                <!-- Họ và tên -->
                <div class="input-field-block">
                    <div class="input-underline-group" id="regFullNameGroup">
                        <form:input path="fullName" id="regFullName" maxlength="100" placeholder="Họ và Tên" autofocus="autofocus"/>
                        <span class="input-right-icon"><i class="fi fi-rr-user"></i></span>
                    </div>
                    <div class="field-error-msg" id="regFullNameError"></div>
                    <form:errors path="fullName" cssClass="error-field-msg"/>
                </div>

                <!-- Địa chỉ email -->
                <div class="input-field-block">
                    <div class="input-underline-group" id="regEmailGroup">
                        <form:input path="email" type="email" id="regEmail" maxlength="255" placeholder="Địa chỉ email"/>
                        <span class="input-right-icon"><i class="fi fi-rr-envelope"></i></span>
                    </div>
                    <div class="field-error-msg" id="regEmailError"></div>
                    <form:errors path="email" cssClass="error-field-msg"/>
                </div>

                <!-- Số điện thoại (+84 và ô input) -->
                <div class="input-field-block">
                    <div class="phone-row-flex" id="regPhoneRow">
                        <div class="phone-prefix-box">
                            <span>🇻🇳</span> +84
                        </div>
                        <div class="input-underline-group flex-grow" id="regPhoneGroup" style="margin-bottom: 0;">
                            <form:input path="phone" id="regPhone" maxlength="12" placeholder="90 123 4567"/>
                            <span class="input-right-icon"><i class="fi fi-rr-phone-call"></i></span>
                        </div>
                    </div>
                    <div class="field-error-msg" id="regPhoneError"></div>
                    <form:errors path="phone" cssClass="error-field-msg"/>
                </div>

                <!-- 2 Ô Mật khẩu và Xác nhận mật khẩu (2 cột) -->
                <div class="password-row-grid">
                    <div class="input-field-block">
                        <div class="input-underline-group" id="regPasswordGroup">
                            <form:password path="password" id="regPassword" maxlength="64" placeholder="Mật khẩu (từ 6 ký tự)"/>
                            <button type="button" class="toggle-password-btn" onclick="togglePassword('regPassword', this)" title="Ẩn/hiện mật khẩu">
                                <i class="fi fi-rr-eye"></i>
                            </button>
                        </div>
                        <div class="field-error-msg" id="regPasswordError"></div>
                    </div>

                    <div class="input-field-block">
                        <div class="input-underline-group" id="regConfirmPasswordGroup">
                            <form:password path="confirmPassword" id="regConfirmPassword" maxlength="64" placeholder="Xác nhận lại mật khẩu"/>
                            <button type="button" class="toggle-password-btn" onclick="togglePassword('regConfirmPassword', this)" title="Ẩn/hiện mật khẩu">
                                <i class="fi fi-rr-eye"></i>
                            </button>
                        </div>
                        <div class="field-error-msg" id="regConfirmPasswordError"></div>
                    </div>
                </div>
                <form:errors path="password" cssClass="error-field-msg"/>
                <form:errors path="confirmPassword" cssClass="error-field-msg"/>

                <!-- Checkbox đồng ý điều khoản -->
                <div class="terms-group">
                    <label class="terms-label">
                        <input type="checkbox" required="required" checked="checked" id="termsCheckbox">
                        <span>Tôi đồng ý với <a href="${ctx}/policies" target="_blank" style="color:#F47721; font-weight:700;">Chính sách khách hàng</a> và bảo mật của PetFood.</span>
                    </label>
                </div>

                <button type="submit" class="btn-glass-submit">
                    Đăng ký ngay &rarr;
                </button>
            </form:form>

            <p class="register-prompt">
                Bạn đã có tài khoản? <a href="${ctx}/login">Đăng nhập</a>
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

        function togglePassword(fieldId, btnEl) {
            const input = document.getElementById(fieldId);
            const icon = btnEl.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fi fi-rr-eye-crossed';
            } else {
                input.type = 'password';
                icon.className = 'fi fi-rr-eye';
            }
        }

        // CLIENT-SIDE VALIDATION FOR REGISTRATION
        document.addEventListener("DOMContentLoaded", function() {
            const form = document.getElementById("registerForm");
            const fullName = document.getElementById("regFullName");
            const fullNameGroup = document.getElementById("regFullNameGroup");
            const fullNameErr = document.getElementById("regFullNameError");

            const email = document.getElementById("regEmail");
            const emailGroup = document.getElementById("regEmailGroup");
            const emailErr = document.getElementById("regEmailError");

            const phone = document.getElementById("regPhone");
            const phoneRow = document.getElementById("regPhoneRow");
            const phoneGroup = document.getElementById("regPhoneGroup");
            const phoneErr = document.getElementById("regPhoneError");

            const pwd = document.getElementById("regPassword");
            const pwdGroup = document.getElementById("regPasswordGroup");
            const pwdErr = document.getElementById("regPasswordError");

            const confirmPwd = document.getElementById("regConfirmPassword");
            const confirmPwdGroup = document.getElementById("regConfirmPasswordGroup");
            const confirmPwdErr = document.getElementById("regConfirmPasswordError");

            function checkEmail(val) {
                if (!val || !val.trim()) return { ok: false, msg: "Vui lòng nhập email." };
                const re = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;
                if (!re.test(val.trim())) return { ok: false, msg: "Email không đúng định dạng (ví dụ: petfood@gmail.com)." };
                return { ok: true };
            }

            function checkPhone(val) {
                if (!val || !val.trim()) return { ok: false, msg: "Vui lòng nhập số điện thoại." };
                const clean = val.replace(/\s+/g, '');
                // 9 to 11 digits
                const re = /^(0|\+84)?[3|5|7|8|9][0-9]{8}$/;
                if (!re.test(clean) && !/^[0-9]{9,10}$/.test(clean)) {
                    return { ok: false, msg: "Số điện thoại không đúng định dạng (9-10 chữ số)." };
                }
                return { ok: true };
            }

            if (email) {
                email.addEventListener("input", function() {
                    if (!email.value.trim()) {
                        emailGroup.classList.remove("has-error");
                        emailErr.classList.remove("visible");
                        return;
                    }
                    const res = checkEmail(email.value);
                    if (!res.ok) {
                        emailGroup.classList.add("has-error");
                        emailErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                        emailErr.classList.add("visible");
                    } else {
                        emailGroup.classList.remove("has-error");
                        emailErr.classList.remove("visible");
                    }
                });
            }

            if (phone) {
                phone.addEventListener("input", function() {
                    if (!phone.value.trim()) {
                        phoneGroup.classList.remove("has-error");
                        phoneErr.classList.remove("visible");
                        return;
                    }
                    const res = checkPhone(phone.value);
                    if (!res.ok) {
                        phoneGroup.classList.add("has-error");
                        phoneErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + res.msg;
                        phoneErr.classList.add("visible");
                    } else {
                        phoneGroup.classList.remove("has-error");
                        phoneErr.classList.remove("visible");
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
                    if (!fullName.value.trim()) {
                        fullNameGroup.classList.add("has-error");
                        fullNameErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> Vui lòng nhập họ và tên.';
                        fullNameErr.classList.add("visible");
                        fullNameGroup.classList.add("shake");
                        setTimeout(() => fullNameGroup.classList.remove("shake"), 400);
                        fullName.focus();
                        hasErr = true;
                    }
                    if (!hasErr) {
                        const emailRes = checkEmail(email.value);
                        if (!emailRes.ok) {
                            emailGroup.classList.add("has-error");
                            emailErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + emailRes.msg;
                            emailErr.classList.add("visible");
                            emailGroup.classList.add("shake");
                            setTimeout(() => emailGroup.classList.remove("shake"), 400);
                            email.focus();
                            hasErr = true;
                        }
                    }
                    if (!hasErr) {
                        const phoneRes = checkPhone(phone.value);
                        if (!phoneRes.ok) {
                            phoneGroup.classList.add("has-error");
                            phoneErr.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + phoneRes.msg;
                            phoneErr.classList.add("visible");
                            phoneGroup.classList.add("shake");
                            setTimeout(() => phoneGroup.classList.remove("shake"), 400);
                            phone.focus();
                            hasErr = true;
                        }
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
