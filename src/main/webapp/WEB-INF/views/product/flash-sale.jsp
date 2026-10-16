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
    <title>Flash Sale · Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
        .card { border: 2px solid #c62828; border-radius: 8px; padding: 12px; }
        .card img { width: 100%; height: 160px; object-fit: contain; background: #f5f5f5; }
        .sale { font-size: 20px; font-weight: bold; color: #c62828; }
        .old { text-decoration: line-through; color: #888; }
        .off { background: #c62828; color: #fff; padding: 0 6px; border-radius: 4px; font-size: 13px; }
        .expiry { background: #fff4e5; color: #7a4a00; padding: 4px 6px; border-radius: 4px; font-size: 13px; }
        .note { color: #555; font-size: 13px; }
        input[type=number] { width: 60px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<h1>Flash Sale</h1>
<%-- BR-65: hiện kèm hạn dùng còn lại; giảm giá hạng thành viên không áp cho hàng Flash Sale (BR-43) --%>
<p class="note">Sản phẩm cận hạn giá tốt, ghi rõ hạn sử dụng còn lại. Giảm giá hạng thành viên không áp dụng cho hàng Flash Sale.</p>

<c:if test="${empty offers}"><p>Hiện chưa có chương trình Flash Sale nào đang diễn ra.</p></c:if>

<div class="grid">
    <c:forEach var="o" items="${offers}">
        <article class="card">
            <a href="${ctx}/products/${o.productId}">
                <c:if test="${not empty o.imageUrl}"><img src="${ctx}<c:out value='${o.imageUrl}'/>" alt=""></c:if>
                <h3><c:out value="${o.productName}"/></h3>
            </a>
            <p><span class="sale"><fmt:formatNumber value="${o.salePrice}" type="number"/> ₫</span>
                <span class="old"><fmt:formatNumber value="${o.sellingPrice}" type="number"/> ₫</span>
                <span class="off">−${o.discountPercent}%</span></p>
            <p class="expiry">HSD ${o.expiryText} (còn ${o.daysLeft} ngày)</p>
            <p class="note">Còn ${o.remainingQty} suất · <c:out value="${o.saleName}"/> · kết thúc ${o.endText}</p>
            <c:choose>
                <c:when test="${currentUser.role == 'CUSTOMER'}">
                    <form method="post" action="${ctx}/cart/add">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <input type="hidden" name="flashSaleItemId" value="${o.flashSaleItemId}">
                        <input type="number" name="quantity" value="1" min="1" max="${o.remainingQty}" required>
                        <button type="submit">Thêm vào giỏ</button>
                    </form>
                </c:when>
                <c:when test="${currentUser == null}"><p><a href="${ctx}/login">Đăng nhập</a> để mua.</p></c:when>
            </c:choose>
        </article>
    </c:forEach>
</div>
</body>
</html>
