<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Trang lỗi chung (ErrorPages, ErrorPageAdvice, AppErrorViewResolver, /403).
     Model: status (số), errorTitle, errorDetail.
     Không include _header.jspf: trang này phải hiện được cả khi lỗi do CSDL, nên không dựa vào model của
     CurrentUserAdvice / CartCountAdvice; vai trò lấy thẳng từ request (Spring Security). --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${status} · <c:out value="${errorTitle}"/> · PetFood</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; color: #222; background: #fafafa; }
        main { max-width: 560px; margin: 12vh auto 0; padding: 24px 16px; text-align: center; }
        .code { font-size: 64px; font-weight: bold; color: #b00020; margin: 0; }
        h1 { font-size: 22px; margin: 8px 0 12px; }
        p.detail { color: #555; line-height: 1.5; }
        nav { margin-top: 24px; display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
        nav a, nav button { padding: 8px 14px; border: 1px solid #ccc; border-radius: 6px; background: #fff;
                            color: #222; text-decoration: none; font: inherit; cursor: pointer; }
    </style>
</head>
<body>
<main>
    <p class="code">${status}</p>
    <h1><c:out value="${errorTitle}"/></h1>
    <p class="detail"><c:out value="${errorDetail}"/></p>
    <nav>
        <button type="button" onclick="history.back()">‹ Quay lại</button>
        <a href="${ctx}/">Trang chủ</a>
        <c:choose>
            <c:when test="${pageContext.request.isUserInRole('ADMIN')}">
                <a href="${ctx}/admin">Trang quản trị</a>
            </c:when>
            <c:when test="${pageContext.request.isUserInRole('STAFF')}">
                <a href="${ctx}/staff">Trang quản lý</a>
            </c:when>
            <c:when test="${pageContext.request.userPrincipal == null}">
                <a href="${ctx}/login">Đăng nhập</a>
            </c:when>
        </c:choose>
        <a href="${ctx}/support">Hỗ trợ</a>
    </nav>
</main>
</body>
</html>
