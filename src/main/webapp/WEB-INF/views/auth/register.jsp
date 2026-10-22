<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký · PetFood</title>
    <%@ include file="/WEB-INF/views/common/_mask-url.jspf" %>
</head>
<body>
<h1>Đăng ký</h1>

<form:form method="post" action="${pageContext.request.contextPath}/register" modelAttribute="registerForm">

    <p>
        <label>Họ tên
            <form:input path="fullName" maxlength="100"/>
        </label>
        <form:errors path="fullName" cssStyle="color:#b00020"/>
    </p>

    <p>
        <label>Email
            <form:input path="email" type="email" maxlength="255"/>
        </label>
        <form:errors path="email" cssStyle="color:#b00020"/>
    </p>

    <p>
        <label>Số điện thoại
            <form:input path="phone" maxlength="12"/>
        </label>
        <form:errors path="phone" cssStyle="color:#b00020"/>
    </p>

    <p>
        <label>Mật khẩu
            <form:password path="password" maxlength="64"/>
        </label>
        <form:errors path="password" cssStyle="color:#b00020"/>
    </p>

    <p>
        <label>Nhập lại mật khẩu
            <form:password path="confirmPassword" maxlength="64"/>
        </label>
        <form:errors path="confirmPassword" cssStyle="color:#b00020"/>
    </p>

    <button type="submit">Đăng ký</button>
</form:form>

<p>Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
</body>
</html>