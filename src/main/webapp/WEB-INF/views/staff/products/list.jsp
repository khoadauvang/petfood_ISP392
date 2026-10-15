<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Sản phẩm · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Sản phẩm</h1>
<p><a href="${ctx}/staff/products/new">+ Thêm sản phẩm</a></p>

<%-- Bộ lọc gửi bằng GET: keyword, categoryId, species, status (bỏ trống = tất cả) --%>
<form method="get" action="${ctx}/staff/products" class="filters">
    <input type="text" name="keyword" value="<c:out value='${filterKeyword}'/>"
           placeholder="Tên, SKU, mã vạch, nhãn hàng" size="30">
    <select name="categoryId">
        <option value="">Tất cả danh mục</option>
        <c:forEach var="cat" items="${categories}">
            <option value="${cat.id}" ${cat.id == filterCategoryId ? 'selected' : ''}><c:out value="${cat.name}"/></option>
        </c:forEach>
    </select>
    <select name="species">
        <option value="">Tất cả loài</option>
        <c:forEach var="sp" items="${speciesList}">
            <option value="${sp}" ${sp == filterSpecies ? 'selected' : ''}>${sp.label}</option>
        </c:forEach>
    </select>
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="st" items="${productStatuses}">
            <option value="${st}" ${st == filterStatus ? 'selected' : ''}>${st.label}</option>
        </c:forEach>
    </select>
    <button type="submit">Lọc</button>
    <a href="${ctx}/staff/products">Bỏ lọc</a>
</form>

<p>${totalItems} sản phẩm</p>

<%-- Model: products = List<ProductAdminRow> --%>
<c:if test="${not empty products}">
    <table>
        <thead>
        <tr>
            <th>Ảnh</th><th>SKU</th><th>Tên sản phẩm</th><th>Danh mục</th><th>Loài · Tuổi</th>
            <th class="num">Giá bán</th><th class="num">Tồn thực tế</th><th class="num">Tồn bán thường</th>
            <th class="num">Ngưỡng</th><th>Trạng thái</th><th>Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="p" items="${products}">
            <tr>
                <td>
                    <c:choose>
                        <c:when test="${not empty p.imageUrl}">
                            <img class="thumb" src="${ctx}<c:out value='${p.imageUrl}'/>" alt="">
                        </c:when>
                        <c:otherwise><span class="hint">Chưa có ảnh</span></c:otherwise>
                    </c:choose>
                </td>
                <td><c:out value="${p.sku}"/></td>
                <td>
                    <a href="${ctx}/staff/products/${p.id}"><c:out value="${p.name}"/></a>
                    <c:if test="${not empty p.brand}"><br><span class="hint"><c:out value="${p.brand}"/></span></c:if>
                </td>
                <td><c:out value="${p.categoryName}"/></td>
                <td>${p.species.label} · ${p.ageGroup.label}</td>
                <td class="num"><fmt:formatNumber value="${p.sellingPrice}" type="number"/> ₫</td>
                <td class="num">${p.onHandQty}</td>
                <td class="num">
                    ${p.sellableQty}
                    <c:if test="${p.lowStock}"><br><span class="badge low">Tồn thấp</span></c:if>
                </td>
                <td class="num">${p.lowStockThreshold}</td>
                <td><span class="badge ${p.status}">${p.status.label}</span></td>
                <td>
                    <a href="${ctx}/staff/products/${p.id}">Xem</a> ·
                    <a href="${ctx}/staff/products/${p.id}/edit">Sửa</a>
                    <c:if test="${p.status == 'ACTIVE'}"> · <a href="${ctx}/staff/lots/new?productId=${p.id}">Nhập lô</a></c:if>
                    <form method="post" action="${ctx}/staff/products/${p.id}/toggle-status" class="inline">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <input type="hidden" name="from" value="list">
                        <button type="submit">${p.status == 'ACTIVE' ? 'Ẩn' : 'Mở bán'}</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</c:if>

<%-- Phân trang giữ nguyên bộ lọc: filterQuery do controller ghép sẵn (đã mã hoá) --%>
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
