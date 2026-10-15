<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${pageTitle}"/> · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1><c:out value="${pageTitle}"/></h1>

<h2>Cảnh báo kho</h2>
<ul>
    <li>
        <a href="${ctx}/staff/alerts#low-stock">${alertSummary.lowStockCount} sản phẩm dưới ngưỡng tồn thấp</a>
    </li>
    <li>
        <a href="${ctx}/staff/alerts#near-expiry">${alertSummary.nearExpiryLotCount} lô còn hàng sắp hết hạn</a>:
        ${alertSummary.redLotCount} lô cảnh báo đỏ (chỉ bán qua Flash Sale),
        ${alertSummary.blockedLotCount} lô không còn được bán,
        ${alertSummary.expiredLotCount} lô đã quá hạn
    </li>
</ul>

<h2>Quản lý</h2>
<ul>
    <li><a href="${ctx}/staff/categories">Danh mục</a> · <a href="${ctx}/staff/categories/new">Thêm danh mục</a></li>
    <li><a href="${ctx}/staff/products">Sản phẩm</a> · <a href="${ctx}/staff/products/new">Thêm sản phẩm</a></li>
    <li><a href="${ctx}/staff/lots">Tồn theo lô</a> · <a href="${ctx}/staff/lots/new">Nhập lô</a></li>
</ul>

<p><a href="${ctx}/">Xem trang khách</a></p>
</body>
</html>
