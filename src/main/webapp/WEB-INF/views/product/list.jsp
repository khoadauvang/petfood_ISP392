<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; }
        .card { border: 1px solid #ddd; border-radius: 8px; padding: 12px; }
        .card img, .noimg { width: 100%; height: 160px; object-fit: contain; background: #f5f5f5; }
        .noimg { display: flex; align-items: center; justify-content: center; color: #999; }
        .price { font-weight: bold; color: #c62828; }
        .in { color: #0a7a2f; } .out { color: #b00020; }
        .pager a, .pager strong { margin-right: 8px; }
    </style>
</head>
<body>

<header>
    <h1>Food Pet Shop</h1>
    <c:choose>
        <c:when test="${currentUser != null}">
            Xin chào <c:out value="${currentUser.fullName}"/>
            <form method="post" action="${ctx}/logout" style="display:inline">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button type="submit">Đăng xuất</button>
            </form>
        </c:when>
        <c:otherwise>
            <a href="${ctx}/login">Đăng nhập</a> | <a href="${ctx}/register">Đăng ký</a>
        </c:otherwise>
    </c:choose>
</header>

<p>${totalItems} sản phẩm · Cam kết hạn sử dụng còn tối thiểu ${shelfLifeDays} ngày khi giao</p>

<c:if test="${empty products}">
    <p>Không có sản phẩm nào để hiển thị.</p>
</c:if>

<div class="grid">
    <c:forEach var="p" items="${products}">
        <article class="card">
            <c:choose>
                <c:when test="${not empty p.imageUrl}">
                    <img src="${ctx}${p.imageUrl}" alt="<c:out value='${p.name}'/>">
                </c:when>
                <c:otherwise>
                    <div class="noimg">Chưa có ảnh</div>
                </c:otherwise>
            </c:choose>
            <h3><c:out value="${p.name}"/></h3>
            <p><c:out value="${p.brand}"/></p>
            <p class="price"><fmt:formatNumber value="${p.price}" type="number"/> ₫</p>
            <c:choose>
                <c:when test="${p.inStock}"><span class="in">Còn hàng</span></c:when>
                <c:otherwise><span class="out">Hết hàng</span></c:otherwise>
            </c:choose>
        </article>
    </c:forEach>
</div>

<c:if test="${totalPages > 1}">
    <nav class="pager">
            <%-- href="?page=2" là link tương đối: giữ nguyên "/" hoặc "/products" đang đứng --%>
        <c:if test="${currentPage > 1}"><a href="?page=${currentPage - 1}">‹ Trước</a></c:if>
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="?page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
        <c:if test="${currentPage < totalPages}"><a href="?page=${currentPage + 1}">Sau ›</a></c:if>
    </nav>
</c:if>

</body>
</html>