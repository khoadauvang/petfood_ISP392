<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đánh giá sản phẩm · Food Pet Shop</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .field { margin: 12px 0; }
        .error { color: #b00020; display: block; }
        textarea, input[type=text] { width: 100%; max-width: 560px; }
        .stars label { margin-right: 8px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/_header.jspf" %>
<p><a href="${ctx}/orders/${orderId}">‹ Đơn #${orderId}</a></p>
<h1>Đánh giá: <c:out value="${productName}"/></h1>

<form:form method="post" action="${ctx}/orders/${orderId}/items/${itemId}/review" modelAttribute="reviewForm">
    <div class="field stars">Số sao<br>
        <c:forEach begin="1" end="5" var="n"><label><form:radiobutton path="rating" value="${n}"/> ${n} ★</label></c:forEach>
        <form:errors path="rating" cssClass="error"/>
    </div>
    <div class="field"><label for="title">Tiêu đề (không bắt buộc)</label><br>
        <form:input path="title" maxlength="150"/><form:errors path="title" cssClass="error"/></div>
    <div class="field"><label for="content">Nội dung (không bắt buộc)</label><br>
        <form:textarea path="content" rows="4" maxlength="2000"/><form:errors path="content" cssClass="error"/></div>
    <button type="submit">Gửi đánh giá</button>
</form:form>
</body>
</html>
