<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: tickets (SupportTicketRow), currentPage, totalPages, totalItems, statuses, filterStatus, filterKeyword, filterQuery --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Yêu cầu hỗ trợ · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>.badge.NEW { background: #fff4e5; color: #7a4a00; } .badge.RESPONDED { background: #e7f6ec; color: #0a5c26; }
        .badge.SPAM { background: #fdecea; color: #8a1c13; }</style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<h1>Yêu cầu hỗ trợ</h1>

<form class="filters" method="get" action="${ctx}/staff/support">
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="s" items="${statuses}"><option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option></c:forEach>
    </select>
    <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Mã HT-..., email hoặc tên">
    <button type="submit">Lọc</button>
</form>
<p>${totalItems} yêu cầu</p>

<table>
    <thead><tr><th>Mã</th><th>Người gửi</th><th>Nội dung</th><th>Trạng thái</th><th>Người xử lý</th><th>Gửi lúc</th></tr></thead>
    <tbody>
    <c:forEach var="t" items="${tickets}">
        <tr>
            <td><a href="${ctx}/staff/support/${t.id}">${t.ticketCode}</a></td>
            <td><c:out value="${t.contactName}"/><div class="hint"><c:out value="${t.contactEmail}"/></div></td>
            <td><c:out value="${t.contentPreview}"/></td>
            <td><span class="badge ${t.status}">${t.status.label}</span></td>
            <td><c:out value="${t.handledByName}"/></td>
            <td>${t.createdAtText}</td>
        </tr>
    </c:forEach>
    <c:if test="${empty tickets}"><tr><td colspan="6">Không có yêu cầu nào.</td></tr></c:if>
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
