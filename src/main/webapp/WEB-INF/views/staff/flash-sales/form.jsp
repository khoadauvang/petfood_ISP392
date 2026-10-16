<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${saleId == null ? 'Tạo' : 'Sửa'} chiến dịch Flash Sale · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<c:choose>
    <c:when test="${saleId == null}">
        <p><a href="${ctx}/staff/flash-sales">‹ Quay lại</a></p>
        <h1>Tạo chiến dịch Flash Sale</h1>
        <c:set var="action" value="/staff/flash-sales/new"/>
    </c:when>
    <c:otherwise>
        <p><a href="${ctx}/staff/flash-sales/${saleId}">‹ Quay lại</a></p>
        <h1>Sửa chiến dịch #${saleId}</h1>
        <c:set var="action" value="/staff/flash-sales/${saleId}/edit"/>
    </c:otherwise>
</c:choose>
<form:form method="post" action="${ctx}${action}" modelAttribute="flashSaleForm" cssClass="grid-form">
    <label for="name">Tên chiến dịch</label>
    <div><form:input path="name" maxlength="150" size="50"/><form:errors path="name" cssClass="err"/></div>

    <label for="startTime">Bắt đầu</label>
    <div><form:input path="startTime" type="datetime-local"/><form:errors path="startTime" cssClass="err"/></div>

    <label for="endTime">Kết thúc</label>
    <div><form:input path="endTime" type="datetime-local"/><form:errors path="endTime" cssClass="err"/></div>

    <span></span>
    <div><button type="submit">Lưu</button>
        <span class="hint">Lưu xong chiến dịch ở trạng thái "Nháp", thêm suất ở trang chi tiết.</span></div>
</form:form>
</body>
</html>
