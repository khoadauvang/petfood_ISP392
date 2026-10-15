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
    <title><c:out value="${product.name}"/> · Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .layout { display: flex; flex-wrap: wrap; gap: 24px; }
        .gallery { flex: 1 1 320px; max-width: 460px; }
        .gallery .main { width: 100%; aspect-ratio: 1; object-fit: contain; background: #f5f5f5; }
        .thumbs { display: flex; gap: 8px; margin-top: 8px; }
        .thumbs img { width: 64px; height: 64px; object-fit: contain; background: #f5f5f5; cursor: pointer;
                      border: 1px solid #ddd; }
        .info { flex: 1 1 320px; }
        .price { font-size: 24px; font-weight: bold; color: #c62828; }
        .in { color: #0a7a2f; } .out { color: #b00020; }
        .expiry { background: #f1f8e9; padding: 8px 12px; border-radius: 6px; }
        .desc { white-space: pre-line; }
        dl { display: grid; grid-template-columns: max-content 1fr; gap: 4px 12px; }
        dt { color: #666; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<p><a href="${ctx}/products?categoryId=${product.categoryId}">‹ <c:out value="${product.categoryName}"/></a></p>

<div class="layout">
    <section class="gallery">
        <c:choose>
            <c:when test="${not empty product.imageUrls}">
                <img class="main" id="mainImage" src="${ctx}<c:out value='${product.imageUrls[0]}'/>"
                     alt="<c:out value='${product.name}'/>">
                <c:if test="${product.imageUrls.size() > 1}">
                    <div class="thumbs">
                        <c:forEach var="url" items="${product.imageUrls}" varStatus="loop">
                            <img src="${ctx}<c:out value='${url}'/>" alt="Ảnh ${loop.index + 1}"
                                 onclick="document.getElementById('mainImage').src = this.src">
                        </c:forEach>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise><div class="main">Chưa có ảnh</div></c:otherwise>
        </c:choose>
    </section>

    <section class="info">
        <h1><c:out value="${product.name}"/></h1>
        <p class="price"><fmt:formatNumber value="${product.price}" type="number"/> ₫</p>

        <c:choose>
            <c:when test="${product.inStock}">
                <p class="in">Còn hàng</p>
                <%-- Hạn dùng theo lô gần nhất: lô bán thường sẽ xuất cho khách trước theo FEFO (BR-53) --%>
                <p class="expiry">
                    Hạn sử dụng lô hiện tại: <strong>${product.nearestExpiryText}</strong>
                    (còn ${product.nearestExpiryDaysLeft} ngày)<br>
                    Cam kết hạn sử dụng còn tối thiểu ${shelfLifeDays} ngày khi giao.
                </p>
            </c:when>
            <c:otherwise><p class="out">Hết hàng</p></c:otherwise>
        </c:choose>

        <dl>
            <dt>Thương hiệu</dt><dd><c:out value="${empty product.brand ? '—' : product.brand}"/></dd>
            <dt>Danh mục</dt><dd><c:out value="${product.categoryName}"/></dd>
            <dt>Dành cho</dt><dd>${product.speciesLabel}</dd>
            <dt>Độ tuổi</dt><dd>${product.ageGroupLabel}</dd>
            <dt>SKU</dt><dd><c:out value="${product.sku}"/></dd>
        </dl>

        <%-- Giỏ hàng (module 3) chưa làm: nút thêm vào giỏ sẽ gắn vào đây --%>
    </section>
</div>

<c:if test="${not empty product.description}">
    <h2>Mô tả sản phẩm</h2>
    <div class="desc"><c:out value="${product.description}"/></div>
</c:if>

</body>
</html>
