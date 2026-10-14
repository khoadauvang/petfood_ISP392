<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${pageTitle}"/></title>
</head>
<body>
<h1><c:out value="${pageTitle}"/></h1>

<c:choose>
    <c:when test="${currentUser != null}">
        <p>Xin chào <c:out value="${currentUser.fullName}"/> (<c:out value="${currentUser.role}"/>)</p>
        <form method="post" action="${pageContext.request.contextPath}/logout">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit">Đăng xuất</button>
        </form>
    </c:when>
    <c:otherwise>
        <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
    </c:otherwise>
</c:choose>
</body>
</html>