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
    <title>Giỏ hàng · Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .table-wrap { overflow-x: auto; }
        table { border-collapse: collapse; width: 100%; margin: 8px 0 16px; }
        th, td { border-bottom: 1px solid #e5e5e5; padding: 8px; text-align: left; vertical-align: top; }
        th { background: #f6f6f6; }
        .num { text-align: right; white-space: nowrap; }
        .thumb { width: 56px; height: 56px; object-fit: contain; background: #f5f5f5; }
        .badge { display: inline-block; background: #c62828; color: #fff; font-size: 12px; padding: 1px 6px;
                 border-radius: 4px; }
        .old { text-decoration: line-through; color: #888; font-size: 13px; }
        .note { font-size: 13px; color: #555; }
        .problem { color: #b00020; font-size: 13px; }
        tr.bad td { background: #fff5f5; }
        input[type=number] { width: 64px; }
        .total { font-size: 18px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<h1>Giỏ hàng</h1>

<c:choose>
    <c:when test="${empty cart.lines}">
        <p>Giỏ hàng đang trống. <a href="${ctx}/products">Xem sản phẩm</a></p>
    </c:when>
    <c:otherwise>
        <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th></th>
                <th>Sản phẩm</th>
                <th class="num">Đơn giá</th>
                <th>Số lượng</th>
                <th class="num">Thành tiền</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="line" items="${cart.lines}">
                <tr class="${empty line.problem ? '' : 'bad'}">
                    <td>
                        <c:if test="${not empty line.imageUrl}">
                            <img class="thumb" src="${ctx}<c:out value='${line.imageUrl}'/>" alt="">
                        </c:if>
                    </td>
                    <td>
                        <a href="${ctx}/products/${line.productId}"><c:out value="${line.name}"/></a>
                        <%-- Dòng Flash Sale tách riêng dòng giá thường, kèm ghi chú hạn dùng còn lại (BR-65) --%>
                        <c:if test="${line.flashSale}">
                            <div><span class="badge">Flash Sale</span> <c:out value="${line.flashSaleName}"/></div>
                            <div class="note"><c:out value="${line.expiryNote}"/></div>
                        </c:if>
                        <c:if test="${not empty line.problem}">
                            <div class="problem"><c:out value="${line.problem}"/></div>
                        </c:if>
                    </td>
                    <td class="num">
                        <fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫
                        <c:if test="${line.flashSale}">
                            <div class="old"><fmt:formatNumber value="${line.regularPrice}" type="number"/> ₫</div>
                        </c:if>
                    </td>
                    <td>
                        <form method="post" action="${ctx}/cart/items/${line.id}/quantity">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <%-- Không đặt max: dòng đang vượt tồn vẫn phải gửi được số nhỏ hơn; server kiểm tra --%>
                            <input type="number" name="quantity" value="${line.quantity}" min="1" required>
                            <button type="submit">Cập nhật</button>
                        </form>
                        <c:if test="${line.availableQty > 0}"><div class="note">Còn ${line.availableQty}</div></c:if>
                    </td>
                    <td class="num"><fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫</td>
                    <td>
                        <form method="post" action="${ctx}/cart/items/${line.id}/delete">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button type="submit">Xoá</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>

        <p class="total">Tạm tính (${cart.totalQuantity} sản phẩm):
            <strong><fmt:formatNumber value="${cart.subtotal}" type="number"/> ₫</strong></p>
        <p class="note">Giảm giá theo hạng thành viên và phí giao hàng được tính khi đặt hàng.
            Giảm giá hạng không áp dụng cho sản phẩm Flash Sale.</p>
        <c:if test="${cart.hasProblems}">
            <p class="problem">Có sản phẩm hết hàng hoặc vượt số lượng còn lại (dòng tô đỏ), không tính vào tạm tính.
                Vui lòng sửa số lượng hoặc xoá trước khi đặt hàng.</p>
        </c:if>
        <c:choose>
            <c:when test="${cart.hasProblems}"><button type="button" disabled>Tiến hành đặt hàng</button></c:when>
            <c:otherwise><p><a href="${ctx}/checkout"><strong>Tiến hành đặt hàng ›</strong></a></p></c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>

</body>
</html>
