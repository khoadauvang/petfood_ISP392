<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Trả hàng · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<h1>Yêu cầu trả hàng</h1>

<form class="filters" method="get" action="${ctx}/staff/returns">
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="s" items="${statuses}">
            <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
        </c:forEach>
    </select>
    <button type="submit">Lọc</button>
</form>

<p>${totalItems} yêu cầu</p>
<table>
    <thead><tr><th>#</th><th>Đơn</th><th>Ngày gửi</th><th>Khách</th><th>Lý do</th><th>Trạng thái</th></tr></thead>
    <tbody>
    <c:forEach var="r" items="${returns}">
        <tr>
            <td><a href="${ctx}/staff/returns/${r.id}">#${r.id}</a></td>
            <td><a href="${ctx}/staff/orders/${r.orderId}">#${r.orderId}</a></td>
            <td>${r.createdAtText}</td>
            <td><c:out value="${r.customerName}"/><br><span class="hint"><c:out value="${r.customerEmail}"/></span></td>
            <td>${r.reason.label}</td>
            <td><span class="badge">${r.status.label}</span></td>
        </tr>
    </c:forEach>
    <c:if test="${empty returns}"><tr><td colspan="6">Không có yêu cầu nào.</td></tr></c:if>
    </tbody>
</table>
<c:if test="${totalPages > 1}">
    <nav class="pager">
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
    </nav>
</c:if>
</body>
</html>
