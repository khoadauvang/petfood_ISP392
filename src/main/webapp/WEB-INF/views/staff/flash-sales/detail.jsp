<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${sale.name}"/> · Flash Sale · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<c:set var="draft" value="${sale.status == 'DRAFT'}"/>

<p><a href="${ctx}/staff/flash-sales">‹ Flash Sale</a></p>
<h1>#${sale.id} · <c:out value="${sale.name}"/> <span class="badge">${sale.status.label}</span></h1>
<p>Từ ${saleStartText} đến ${saleEndText} · Người tạo: <c:out value="${sale.createdBy.fullName}"/></p>

<%-- Chuyển trạng thái: DRAFT -> ACTIVE <-> PAUSED -> ENDED (BR-64) --%>
<p>
    <c:if test="${draft}">
        <a href="${ctx}/staff/flash-sales/${sale.id}/edit">Sửa tên / thời gian</a>
        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/activate" class="inline">${csrf}<button type="submit">Chạy ngay</button></form>
        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/delete" class="inline">${csrf}<button type="submit">Xoá chiến dịch nháp</button></form>
    </c:if>
    <c:if test="${sale.status == 'ACTIVE'}">
        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/pause" class="inline">${csrf}<button type="submit">Tạm dừng</button></form>
    </c:if>
    <c:if test="${sale.status == 'PAUSED'}">
        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/resume" class="inline">${csrf}<button type="submit">Chạy lại</button></form>
    </c:if>
    <c:if test="${sale.status != 'ENDED'}">
        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/end" class="inline">${csrf}<button type="submit">Kết thúc</button></form>
    </c:if>
</p>

<h2>Các suất</h2>
<table>
    <thead>
    <tr><th>Lô</th><th>Sản phẩm</th><th>HSD</th><th class="num">Giá thường</th><th class="num">Giá Flash Sale</th>
        <th class="num">Dành riêng</th><th class="num">Đã bán</th><th class="num">Còn</th><th></th></tr>
    </thead>
    <tbody>
    <c:forEach var="i" items="${items}">
        <tr>
            <td>#${i.lotId}</td>
            <td><c:out value="${i.sku}"/> · <c:out value="${i.productName}"/></td>
            <td>${i.expiryText} <span class="badge lv-${i.level}">còn ${i.daysLeft} ngày</span></td>
            <td class="num"><fmt:formatNumber value="${i.sellingPrice}" type="number"/> ₫</td>
            <td class="num"><fmt:formatNumber value="${i.salePrice}" type="number"/> ₫</td>
            <td class="num">${i.allocatedQty}</td>
            <td class="num">${i.soldQty}</td>
            <td class="num">${i.remainingQty}</td>
            <td><c:if test="${draft}">
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/items/${i.id}/delete" class="inline">${csrf}<button type="submit">Xoá</button></form>
            </c:if></td>
        </tr>
    </c:forEach>
    <c:if test="${empty items}"><tr><td colspan="9">Chưa có suất nào.</td></tr></c:if>
    </tbody>
</table>

<c:if test="${draft}">
    <h2>Thêm suất từ lô cận hạn</h2>
    <p class="hint">Chỉ lô còn ${quarantineDays} đến dưới ${shelfLifeDays} ngày (cảnh báo đỏ). Giá Flash Sale phải thấp hơn giá thường;
        số lượng không vượt tồn của lô trừ phần đang dành cho chiến dịch khác.</p>
    <c:choose>
        <c:when test="${empty redLots}"><p>Hiện không có lô cận hạn nào còn hàng để đưa vào Flash Sale.</p></c:when>
        <c:otherwise>
            <form:form method="post" action="${ctx}/staff/flash-sales/${sale.id}/items" modelAttribute="itemForm" cssClass="grid-form">
                <label for="lotId">Lô</label>
                <div>
                    <form:select path="lotId">
                        <form:option value="">-- Chọn lô --</form:option>
                        <c:forEach var="l" items="${redLots}">
                            <form:option value="${l.lotId}">#${l.lotId} · ${l.sku} · ${l.productName} · HSD ${l.expiryText} (còn ${l.daysLeft} ngày) · dành được ${l.availableQty} · giá thường ${l.sellingPrice}</form:option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="lotId" cssClass="err"/>
                </div>
                <label for="salePrice">Giá Flash Sale (₫)</label>
                <div><form:input path="salePrice" type="number" min="1" step="1000"/><form:errors path="salePrice" cssClass="err"/></div>
                <label for="allocatedQty">Số lượng dành riêng</label>
                <div><form:input path="allocatedQty" type="number" min="1"/><form:errors path="allocatedQty" cssClass="err"/></div>
                <span></span>
                <div><button type="submit">Thêm suất</button></div>
            </form:form>
        </c:otherwise>
    </c:choose>
</c:if>
</body>
</html>
