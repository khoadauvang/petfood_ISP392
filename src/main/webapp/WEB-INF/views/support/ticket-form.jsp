<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: supportTicketForm (nodeId, contactName, contactEmail, content), nodeLabel (null nếu bấm "Khác" ở danh sách chủ đề) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gửi yêu cầu hỗ trợ · Food Pet Shop</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .field { margin: 12px 0; }
        .error { color: #b00020; display: block; }
        .hint { color: #666; font-size: 13px; }
        textarea, input[type=text], input[type=email] { width: 100%; max-width: 560px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/_header.jspf" %>
<c:url var="backUrl" value="/support"><c:if test="${supportTicketForm.nodeId != null}"><c:param name="node" value="${supportTicketForm.nodeId}"/></c:if></c:url>
<p><a href="${backUrl}">‹ Quay lại chatbox</a></p>
<h1>Gửi yêu cầu hỗ trợ</h1>
<c:if test="${not empty nodeLabel}"><p>Chủ đề: <strong><c:out value="${nodeLabel}"/></strong></p></c:if>
<p class="hint">Nhân viên sẽ trả lời qua email. Tiêu đề email có mã yêu cầu dạng HT-000123.</p>

<form:form method="post" action="${ctx}/support/ticket" modelAttribute="supportTicketForm">
    <form:hidden path="nodeId"/>
    <div class="field"><label for="contactEmail">Email nhận trả lời (bắt buộc)</label><br>
        <form:input path="contactEmail" type="email" maxlength="255" required="required"/>
        <form:errors path="contactEmail" cssClass="error"/></div>
    <div class="field"><label for="contactName">Họ tên (không bắt buộc)</label><br>
        <form:input path="contactName" maxlength="100"/>
        <form:errors path="contactName" cssClass="error"/></div>
    <div class="field"><label for="content">Vấn đề của bạn</label><br>
        <form:textarea path="content" rows="5" maxlength="2000" required="required"/>
        <form:errors path="content" cssClass="error"/></div>
    <button type="submit">Gửi yêu cầu</button>
</form:form>
</body>
</html>
