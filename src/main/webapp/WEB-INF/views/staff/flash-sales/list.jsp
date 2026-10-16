<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Flash Sale · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Flash Sale</h1>
<p><a href="${ctx}/staff/flash-sales/new">+ Tạo chiến dịch</a></p>
<p class="hint">Chiến dịch "Nháp" có ít nhất một suất sẽ tự chạy khi tới giờ bắt đầu, tự kết thúc khi hết giờ hoặc bán hết.</p>

<table>
    <thead>
    <tr><th>#</th><th>Tên</th><th>Bắt đầu</th><th>Kết thúc</th><th>Trạng thái</th><th class="num">Số suất</th><th class="num">Còn lại</th><th>Người tạo</th></tr>
    </thead>
    <tbody>
    <c:forEach var="s" items="${sales}">
        <tr>
            <td>${s.id}</td>
            <td><a href="${ctx}/staff/flash-sales/${s.id}"><c:out value="${s.name}"/></a></td>
            <td>${s.startText}</td>
            <td>${s.endText}</td>
            <td><span class="badge ${s.status == 'ACTIVE' ? 'ACTIVE' : ''}">${s.status.label}</span></td>
            <td class="num">${s.itemCount}</td>
            <td class="num">${s.remainingQty}</td>
            <td><c:out value="${s.createdByName}"/></td>
        </tr>
    </c:forEach>
    <c:if test="${empty sales}"><tr><td colspan="8">Chưa có chiến dịch nào.</td></tr></c:if>
    </tbody>
</table>
</body>
</html>
