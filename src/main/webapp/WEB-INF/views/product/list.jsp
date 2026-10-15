<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; }
        form.filter { display: flex; flex-wrap: wrap; gap: 8px; align-items: end; margin-bottom: 12px; }
        form.filter label { display: flex; flex-direction: column; font-size: 13px; }
        form.filter input[type=number] { width: 110px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; }
        .card { border: 1px solid #ddd; border-radius: 8px; padding: 12px; }
        .card a { color: inherit; text-decoration: none; }
        .card img, .noimg { width: 100%; height: 160px; object-fit: contain; background: #f5f5f5; }
        .noimg { display: flex; align-items: center; justify-content: center; color: #999; }
        .price { font-weight: bold; color: #c62828; }
        .in { color: #0a7a2f; } .out { color: #b00020; }
        .expiry { font-size: 13px; color: #555; }
        .pager a, .pager strong { margin-right: 8px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<%-- Tìm kiếm + lọc: GET để URL giữ bộ lọc (chia sẻ link, bấm Back được). Tham số khớp ProductFilter. --%>
<form class="filter" method="get" action="${ctx}/products">
    <label>Tìm kiếm
        <input type="search" name="keyword" value="<c:out value='${filter.keyword}'/>" placeholder="Tên, thương hiệu, SKU">
    </label>
    <label>Danh mục
        <select name="categoryId">
            <option value="">Tất cả</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" ${filter.categoryId == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option>
            </c:forEach>
        </select>
    </label>
    <label>Loài
        <select name="species">
            <option value="">Chó và mèo</option>
            <c:forEach var="s" items="${speciesList}">
                <option value="${s}" ${filter.species == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>
    </label>
    <label>Độ tuổi
        <select name="ageGroup">
            <option value="">Mọi độ tuổi</option>
            <c:forEach var="a" items="${ageGroups}">
                <option value="${a}" ${filter.ageGroup == a ? 'selected' : ''}>${a.label}</option>
            </c:forEach>
        </select>
    </label>
    <label>Thương hiệu
        <select name="brand">
            <option value="">Tất cả</option>
            <c:forEach var="b" items="${brands}">
                <option value="<c:out value='${b}'/>" ${filter.brand == b ? 'selected' : ''}><c:out value="${b}"/></option>
            </c:forEach>
        </select>
    </label>
    <label>Giá từ (₫)
        <input type="number" name="minPrice" min="0" step="1000" value="${filter.minPrice}">
    </label>
    <label>đến (₫)
        <input type="number" name="maxPrice" min="0" step="1000" value="${filter.maxPrice}">
    </label>
    <button type="submit">Lọc</button>
    <a href="${ctx}/products">Xoá bộ lọc</a>
</form>

<p>${totalItems} sản phẩm · Cam kết hạn sử dụng còn tối thiểu ${shelfLifeDays} ngày khi giao</p>

<c:if test="${empty products}">
    <p>Không tìm thấy sản phẩm phù hợp.</p>
</c:if>

<div class="grid">
    <c:forEach var="p" items="${products}">
        <article class="card">
            <a href="${ctx}/products/${p.id}">
                <c:choose>
                    <c:when test="${not empty p.imageUrl}">
                        <img src="${ctx}${p.imageUrl}" alt="<c:out value='${p.name}'/>">
                    </c:when>
                    <c:otherwise>
                        <div class="noimg">Chưa có ảnh</div>
                    </c:otherwise>
                </c:choose>
                <h3><c:out value="${p.name}"/></h3>
            </a>
            <p><c:out value="${p.brand}"/></p>
            <p class="price"><fmt:formatNumber value="${p.price}" type="number"/> ₫</p>
            <c:choose>
                <c:when test="${p.inStock}">
                    <span class="in">Còn hàng</span>
                    <div class="expiry">HSD lô gần nhất: ${p.nearestExpiryText}</div>
                </c:when>
                <c:otherwise><span class="out">Hết hàng</span></c:otherwise>
            </c:choose>
        </article>
    </c:forEach>
</div>

<c:if test="${totalPages > 1}">
    <%-- Phân trang giữ nguyên bộ lọc: filterQuery do controller ghép sẵn (đã mã hoá) --%>
    <nav class="pager">
        <c:if test="${currentPage > 1}"><a href="${ctx}/products?${filterQuery}&page=${currentPage - 1}">‹ Trước</a></c:if>
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="${ctx}/products?${filterQuery}&page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}"><a href="${ctx}/products?${filterQuery}&page=${currentPage + 1}">Sau ›</a></c:if>
    </nav>
</c:if>

</body>
</html>
