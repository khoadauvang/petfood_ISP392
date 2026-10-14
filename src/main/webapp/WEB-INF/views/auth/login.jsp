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
<c:if test="${param.logout != null}">
    <p style="color:#0a7a2f">Bạn đã đăng xuất.</p>
</c:if>

<form method="post" action="${pageContext.request.contextPath}/login">
    <label>Email <input type="email" name="email" required autofocus></label>
    <label>Mật khẩu <input type="password" name="password" required></label>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <button type="submit">Đăng nhập</button>
</form>

<p>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký</a></p>
</body>
</html>