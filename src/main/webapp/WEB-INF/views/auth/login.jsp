<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập · Food Pet Shop</title>
</head>
<body>
<h1>Đăng nhập</h1>

<c:if test="${param.error != null}">
    <p style="color:#b00020">Email hoặc mật khẩu không đúng.</p>
</c:if>
<c:if test="${param.locked != null}">
    <p style="color:#b00020">Tài khoản đã bị khoá. Vui lòng liên hệ quản trị viên.</p>
</c:if>
<c:if test="${param.expired != null}">
    <p style="color:#b00020">Phiên đăng nhập đã kết thúc do tài khoản vừa bị khoá hoặc thay đổi quyền / mật khẩu. Vui lòng đăng nhập lại.</p>
</c:if>
<c:if test="${param.logout != null}">
    <p style="color:#0a7a2f">Bạn đã đăng xuất.</p>
</c:if>
<c:if test="${param.reset != null}">
    <p style="color:#0a7a2f">Đã đặt lại mật khẩu, mời bạn đăng nhập bằng mật khẩu mới.</p>
</c:if>
<c:if test="${param.registered != null}">
    <p style="color:#0a7a2f">Đăng ký thành công, mời bạn đăng nhập.</p>
</c:if>
<%-- Lỗi đăng nhập Google: lý do do GoogleAccountService ném ra, Spring lưu trong session --%>
<c:if test="${param.googleError != null}">
    <p style="color:#b00020">Đăng nhập Google không thành công.
        <c:out value="${sessionScope.SPRING_SECURITY_LAST_EXCEPTION.message}"/></p>
</c:if>

<form method="post" action="${pageContext.request.contextPath}/login">
    <label>Email <input type="email" name="email" required autofocus></label>
    <label>Mật khẩu <input type="password" name="password" required></label>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <button type="submit">Đăng nhập</button>
</form>
<p><a href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a></p>

<c:if test="${googleLoginEnabled}">
    <%-- Chỉ dành cho khách hàng; nhân viên đăng nhập bằng email + mật khẩu (BR-05) --%>
    <p><a href="${pageContext.request.contextPath}/oauth2/authorization/google">Đăng nhập bằng Google</a></p>
</c:if>

<p>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký</a></p>
</body>
</html>