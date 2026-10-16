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

        <%-- Thêm vào giỏ: chỉ khách đã đăng nhập (BR-07). Số lượng tối đa = tồn bán thường (BR-13),
             server vẫn kiểm tra lại vì tồn có thể đổi giữa lúc xem và lúc bấm. --%>
        <c:if test="${product.inStock}">
            <c:choose>
                <c:when test="${currentUser.role == 'CUSTOMER'}">
                    <form method="post" action="${ctx}/cart/add">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <input type="hidden" name="productId" value="${product.id}">
                        <label>Số lượng
                            <input type="number" name="quantity" value="1" min="1" max="${product.sellableQty}" required>
                        </label>
                        <button type="submit">Thêm vào giỏ</button>
                    </form>
                </c:when>
                <c:when test="${currentUser == null}">
                    <p><a href="${ctx}/login">Đăng nhập</a> để thêm vào giỏ hàng.</p>
                </c:when>
            </c:choose>
        </c:if>
    </section>
</div>

<%-- Flash Sale đang chạy của sản phẩm này: dòng riêng trong giỏ, kèm hạn dùng còn lại (BR-65) --%>
<c:if test="${not empty flashSaleOffers}">
    <h2>Flash Sale</h2>
    <c:forEach var="o" items="${flashSaleOffers}">
        <div class="expiry" style="background:#fdecea">
            <strong><fmt:formatNumber value="${o.salePrice}" type="number"/> ₫</strong>
            (−${o.discountPercent}%) · HSD ${o.expiryText} (còn ${o.daysLeft} ngày) · còn ${o.remainingQty} suất · kết thúc ${o.endText}
            <c:if test="${currentUser.role == 'CUSTOMER'}">
                <form method="post" action="${ctx}/cart/add" style="display:inline">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <input type="hidden" name="flashSaleItemId" value="${o.flashSaleItemId}">
                    <input type="number" name="quantity" value="1" min="1" max="${o.remainingQty}" style="width:60px" required>
                    <button type="submit">Mua giá Flash Sale</button>
                </form>
            </c:if>
        </div>
    </c:forEach>
</c:if>

<c:if test="${not empty product.description}">
    <h2>Mô tả sản phẩm</h2>
    <div class="desc"><c:out value="${product.description}"/></div>
</c:if>

<%-- Đánh giá (module 8): chỉ đánh giá đang hiện, kèm phản hồi của cửa hàng --%>
<h2>Đánh giá<c:if test="${reviewSummary.count > 0}"> · ${reviewSummary.averageText}/5 ★ (${reviewSummary.count})</c:if></h2>
<c:if test="${reviewSummary.count == 0}"><p>Chưa có đánh giá nào.</p></c:if>
<c:forEach var="r" items="${reviewSummary.reviews}">
    <div style="border-bottom:1px solid #eee; padding:8px 0">
        <span style="color:#e6a700"><c:forEach begin="1" end="${r.rating}">★</c:forEach></span>
        <strong><c:out value="${r.title}"/></strong> · <c:out value="${r.customerName}"/> · ${r.createdAtText}
        <c:if test="${not empty r.content}"><div class="desc"><c:out value="${r.content}"/></div></c:if>
        <c:if test="${not empty r.replyContent}">
            <div style="background:#f6f6f6; padding:6px 10px; margin-top:4px">Phản hồi từ cửa hàng: <c:out value="${r.replyContent}"/></div>
        </c:if>
    </div>
</c:forEach>

</body>
</html>
