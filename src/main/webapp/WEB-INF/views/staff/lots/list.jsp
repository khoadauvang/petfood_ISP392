<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tồn theo lô · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Tồn theo lô</h1>
<p><a href="${ctx}/staff/lots/new">+ Nhập lô</a></p>
<p class="hint">
    Mức hạn dùng: còn từ ${shelfLifeDays} ngày bán thường; ${quarantineDays} đến dưới ${shelfLifeDays} ngày là cảnh báo đỏ
    (chỉ bán qua Flash Sale); dưới ${quarantineDays} ngày không được bán.
</p>

<%-- Bộ lọc gửi bằng GET: view (ALL, IN_STOCK, NEAR_EXPIRY, DEPLETED), productId, keyword --%>
<form method="get" action="${ctx}/staff/lots" class="filters">
    <select name="view">
        <c:forEach var="v" items="${lotViews}">
            <option value="${v}" ${v == filterView ? 'selected' : ''}>${v.label}</option>
        </c:forEach>
    </select>
    <select name="productId">
        <option value="">Tất cả sản phẩm</option>
        <c:forEach var="p" items="${products}">
            <option value="${p.id}" ${p.id == filterProductId ? 'selected' : ''}><c:out value="${p.sku}"/> - <c:out value="${p.name}"/></option>
        </c:forEach>
    </select>
    <input type="text" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="SKU hoặc tên sản phẩm" size="25">
    <button type="submit">Lọc</button>
    <a href="${ctx}/staff/lots">Bỏ lọc</a>
</form>

<p>${totalItems} lô</p>

<%-- Model: lots = List<LotRow>, sắp theo HSD tăng dần (FEFO) --%>
<c:if test="${not empty lots}">
    <table>
        <thead>
        <tr>
            <th>Lô</th><th>SKU</th><th>Sản phẩm</th><th>Hạn sử dụng</th><th class="num">Còn (ngày)</th><th>Mức</th>
            <th class="num">Nhập</th><th class="num">Còn trong kho</th><th>Ngày nhập</th><th>Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="lot" items="${lots}">
            <tr>
                <td>#${lot.id}</td>
                <td><c:out value="${lot.sku}"/></td>
                <td><a href="${ctx}/staff/products/${lot.productId}"><c:out value="${lot.productName}"/></a></td>
                <td>${lot.expiryDateText}</td>
                <td class="num">${lot.daysLeft}</td>
                <td>
                    <c:choose>
                        <c:when test="${lot.depleted}"><span class="badge">Hết hàng</span></c:when>
                        <c:otherwise><span class="badge lv-${lot.level}">${lot.level.label}</span></c:otherwise>
                    </c:choose>
                </td>
                <td class="num">${lot.receivedQty}</td>
                <td class="num">${lot.onHandQty}</td>
                <td>${lot.receivedAtText}</td>
                <td>
                    <c:if test="${lot.untouched}">
                        <a href="${ctx}/staff/lots/${lot.id}/edit">Sửa</a>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</c:if>

<c:if test="${totalPages > 1}">
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
</body>
</html>
