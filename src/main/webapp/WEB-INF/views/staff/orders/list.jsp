<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đơn hàng · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Đơn hàng</h1>

<c:if test="${cancelRequestCount > 0}">
    <p class="msg warn"><a href="${ctx}/staff/orders?cancelRequested=true">${cancelRequestCount} đơn đang chờ duyệt yêu cầu huỷ</a></p>
</c:if>

<%-- Bộ lọc gửi bằng GET: status, cancelRequested, keyword (mã đơn, email hoặc tên khách) --%>
<form class="filters" method="get" action="${ctx}/staff/orders">
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="s" items="${statuses}">
            <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
        </c:forEach>
    </select>
    <label><input type="checkbox" name="cancelRequested" value="true" ${filterCancelRequested ? 'checked' : ''}> Chỉ đơn khách yêu cầu huỷ</label>
    <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Mã đơn, email, tên khách">
    <button type="submit">Lọc</button>
    <a href="${ctx}/staff/orders">Xoá lọc</a>
</form>

<p>${totalItems} đơn</p>
<table>
    <thead>
    <tr><th>Mã</th><th>Ngày đặt</th><th>Khách</th><th>Sản phẩm</th><th class="num">Tổng tiền</th><th>Trạng thái</th><th>Thanh toán</th></tr>
    </thead>
    <tbody>
    <c:forEach var="o" items="${orders}">
        <tr>
            <td><a href="${ctx}/staff/orders/${o.id}">#${o.id}</a></td>
            <td>${o.createdAtText}</td>
            <td><c:out value="${o.customerName}"/><br><span class="hint"><c:out value="${o.customerEmail}"/></span></td>
            <td>${o.totalQuantity} sp</td>
            <td class="num"><fmt:formatNumber value="${o.totalAmount}" type="number"/> ₫</td>
            <td><span class="badge">${o.status.label}</span>
                <c:if test="${o.cancelRequested}"><span class="badge low">Yêu cầu huỷ</span></c:if></td>
            <td>${o.paymentMethodLabel}<br><span class="hint">${o.paymentStatusLabel}</span></td>
        </tr>
    </c:forEach>
    <c:if test="${empty orders}"><tr><td colspan="7">Không có đơn nào.</td></tr></c:if>
    </tbody>
</table>

<c:if test="${totalPages > 1}">
    <%-- Phân trang giữ nguyên bộ lọc: filterQuery do controller ghép sẵn (đã mã hoá) --%>
    <nav class="pager">
        <c:if test="${currentPage > 1}"><a href="?${filterQuery}&page=${currentPage - 1}">‹ Trước</a></c:if>
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}"><a href="?${filterQuery}&page=${currentPage + 1}">Sau ›</a></c:if>
    </nav>
</c:if>

<%-- Hạng thành viên tự tính lại hằng ngày; Admin chạy ngay được (ví dụ khi demo) --%>
<c:if test="${currentUser.role == 'ADMIN'}">
    <form method="post" action="${ctx}/admin/membership/recalculate">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit">Tính lại hạng thành viên ngay</button>
        <span class="hint">Tính theo tiền hàng các đơn đã hoàn tất quá 3 ngày, trừ phần đã hoàn tiền.</span>
    </form>
</c:if>

</body>
</html>
