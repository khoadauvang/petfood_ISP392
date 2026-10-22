<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- Bước 1 quên mật khẩu. Model: forgotPasswordForm (email), errorMessage (gửi email lỗi) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quên mật khẩu · PetFood</title>
    <%@ include file="/WEB-INF/views/common/_mask-url.jspf" %>
</head>
<body>
<h1>Quên mật khẩu</h1>
<p>Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP gồm 6 chữ số để bạn đặt mật khẩu mới.</p>

<c:if test="${not empty errorMessage}"><p style="color:#b00020"><c:out value="${errorMessage}"/></p></c:if>

<form:form method="post" action="${pageContext.request.contextPath}/forgot-password" modelAttribute="forgotPasswordForm">
    <p>
        <label>Email
            <form:input path="email" type="email" maxlength="255" autofocus="autofocus"/>
        </label>
        <form:errors path="email" cssStyle="color:#b00020"/>
    </p>
    <button type="submit">Gửi mã OTP</button>
</form:form>

<p><a href="${pageContext.request.contextPath}/login">‹ Quay lại đăng nhập</a></p>
</body>
</html>
