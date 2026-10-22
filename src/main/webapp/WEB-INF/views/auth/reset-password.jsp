<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Bước 2 quên mật khẩu. Model: otpResetForm (otp, newPassword, confirmPassword), email,
     otpMinutes, maxAttempts, resendSeconds; flash successMessage / errorMessage --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt lại mật khẩu · PetFood</title>
    <%@ include file="/WEB-INF/views/common/_mask-url.jspf" %>
</head>
<body>
<h1>Đặt lại mật khẩu</h1>

<c:if test="${not empty successMessage}"><p style="color:#0a7a2f"><c:out value="${successMessage}"/></p></c:if>
<c:if test="${not empty errorMessage}"><p style="color:#b00020"><c:out value="${errorMessage}"/></p></c:if>

<p>Email: <strong><c:out value="${email}"/></strong>
    (<a href="${ctx}/forgot-password">đổi email</a>)</p>
<p style="color:#666">Mã OTP có hiệu lực ${otpMinutes} phút và chỉ dùng được một lần.
    Nhập sai ${maxAttempts} lần thì mã bị huỷ, bạn cần gửi lại mã mới.</p>

<form:form method="post" action="${ctx}/forgot-password/verify" modelAttribute="otpResetForm">
    <p>
        <label>Mã OTP
            <form:input path="otp" maxlength="6" inputmode="numeric" autocomplete="one-time-code" autofocus="autofocus"/>
        </label>
        <form:errors path="otp" cssStyle="color:#b00020"/>
    </p>
    <p>
        <label>Mật khẩu mới
            <form:password path="newPassword" maxlength="64" autocomplete="new-password"/>
        </label>
        <form:errors path="newPassword" cssStyle="color:#b00020"/>
    </p>
    <p>
        <label>Nhập lại mật khẩu mới
            <form:password path="confirmPassword" maxlength="64" autocomplete="new-password"/>
        </label>
        <form:errors path="confirmPassword" cssStyle="color:#b00020"/>
    </p>
    <button type="submit">Đặt lại mật khẩu</button>
</form:form>

<form method="post" action="${ctx}/forgot-password/resend">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <p>Không nhận được mã?
        <button type="submit" id="resendBtn" data-wait="${not empty successMessage ? resendSeconds : 0}">Gửi lại mã</button></p>
</form>

<p><a href="${ctx}/login">‹ Quay lại đăng nhập</a></p>

<%-- Server chỉ gửi lại sau resendSeconds giây: vừa gửi mã (có successMessage) thì khoá nút trong thời gian chờ --%>
<script>
    (function () {
        var btn = document.getElementById('resendBtn');
        var left = parseInt(btn.dataset.wait, 10) || 0;
        var label = btn.textContent;
        function tick() {
            if (left <= 0) { btn.disabled = false; btn.textContent = label; return; }
            btn.disabled = true;
            btn.textContent = label + ' (' + left + 's)';
            left--;
            setTimeout(tick, 1000);
        }
        tick();
    })();
</script>
</body>
</html>
