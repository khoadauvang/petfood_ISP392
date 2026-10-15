<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: lowStockProducts (List<LowStockRow>), nearExpiryLots (List<LotRow>), shelfLifeDays, quarantineDays --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cảnh báo kho · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Cảnh báo kho</h1>

<h2 id="low-stock">Sản phẩm dưới ngưỡng tồn thấp (${lowStockProducts.size()})</h2>
<p class="hint">Sản phẩm đang bán có tồn bán thường (tổng các lô còn từ ${shelfLifeDays} ngày) bằng hoặc thấp hơn ngưỡng tồn thấp.</p>
<c:choose>
    <c:when test="${empty lowStockProducts}">
        <p>Không có sản phẩm nào dưới ngưỡng.</p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
            <tr>
                <th>Ảnh</th><th>SKU</th><th>Sản phẩm</th><th class="num">Tồn bán thường</th>
                <th class="num">Ngưỡng</th><th class="num">Tồn thực tế</th><th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="p" items="${lowStockProducts}">
                <tr>
                    <td>
                        <c:if test="${not empty p.imageUrl}"><img class="thumb" src="${ctx}<c:out value='${p.imageUrl}'/>" alt=""></c:if>
                    </td>
                    <td><c:out value="${p.sku}"/></td>
                    <td><a href="${ctx}/staff/products/${p.productId}"><c:out value="${p.name}"/></a></td>
                    <td class="num">
                        ${p.sellableQty}
                        <c:if test="${p.outOfStock}"><br><span class="badge low">Hết hàng</span></c:if>
                    </td>
                    <td class="num">${p.threshold}</td>
                    <td class="num">${p.onHandQty}</td>
                    <td><a href="${ctx}/staff/lots/new?productId=${p.productId}">Nhập lô</a></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>

<h2 id="near-expiry">Lô còn hàng sắp hết hạn (${nearExpiryLots.size()})</h2>
<p class="hint">
    Lô còn hàng có hạn dùng dưới ${shelfLifeDays} ngày. Cảnh báo đỏ (${quarantineDays} đến dưới ${shelfLifeDays} ngày):
    chỉ bán qua Flash Sale. Dưới ${quarantineDays} ngày hoặc đã quá hạn: không được bán, cần cách ly.
</p>
<c:choose>
    <c:when test="${empty nearExpiryLots}">
        <p>Không có lô nào sắp hết hạn.</p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
            <tr>
                <th>Lô</th><th>SKU</th><th>Sản phẩm</th><th>Hạn sử dụng</th><th class="num">Còn (ngày)</th>
                <th>Mức</th><th class="num">Còn trong kho</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="lot" items="${nearExpiryLots}">
                <tr>
                    <td>#${lot.id}</td>
                    <td><c:out value="${lot.sku}"/></td>
                    <td><a href="${ctx}/staff/products/${lot.productId}"><c:out value="${lot.productName}"/></a></td>
                    <td>${lot.expiryDateText}</td>
                    <td class="num">${lot.daysLeft}</td>
                    <td><span class="badge lv-${lot.level}">${lot.level.label}</span></td>
                    <td class="num">${lot.onHandQty}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>
</body>
</html>
