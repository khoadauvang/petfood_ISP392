<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng · Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .layout { display: flex; flex-wrap: wrap; gap: 24px; }
        .layout > section { flex: 1 1 340px; }
        .table-wrap { overflow-x: auto; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border-bottom: 1px solid #e5e5e5; padding: 6px 8px; text-align: left; vertical-align: top; }
        .num { text-align: right; white-space: nowrap; }
        .fs { display: inline-block; background: #c62828; color: #fff; font-size: 11px; padding: 0 5px; border-radius: 3px; }
        textarea { width: 100%; }
        .error { color: #b00020; display: block; }
        .note { color: #555; font-size: 13px; }
        .total { font-size: 18px; }
        .free { color: #0a7a2f; font-weight: bold; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<p><a href="${ctx}/cart">‹ Giỏ hàng</a></p>
<h1>Đặt hàng</h1>

<div class="layout">
<section>
    <h2>Giao hàng</h2>
    <dl>
        <dt>Người nhận</dt><dd><c:out value="${currentUser.fullName}"/></dd>
        <dt>Số điện thoại</dt>
        <dd>
            <c:choose>
                <c:when test="${not empty summary.customerPhone}"><c:out value="${summary.customerPhone}"/></c:when>
                <c:otherwise><span class="error">Chưa có số điện thoại.
                    <a href="${ctx}/profile">Cập nhật hồ sơ</a> để shipper liên hệ khi giao hàng.</span></c:otherwise>
            </c:choose>
        </dd>
    </dl>

    <%-- Hai nút cùng một form: "Tính phí giao hàng" gửi tới /checkout/quote, "Đặt hàng" gửi tới /checkout --%>
    <form:form method="post" action="${ctx}/checkout" modelAttribute="checkoutForm">
        <p>
            <label for="shippingAddress">Địa chỉ giao hàng (số nhà, đường, phường, thành phố)</label>
            <form:textarea path="shippingAddress" rows="3" maxlength="500"/>
            <form:errors path="shippingAddress" cssClass="error"/>
        </p>
        <p>Thanh toán<br>
            <c:forEach var="m" items="${paymentMethods}">
                <label>
                    <form:radiobutton path="paymentMethod" value="${m}" disabled="${m == 'VNPAY'}"/>
                    ${m.label}<c:if test="${m == 'VNPAY'}"> (sắp có)</c:if>
                </label><br>
            </c:forEach>
            <form:errors path="paymentMethod" cssClass="error"/>
        </p>
        <button type="submit" formaction="${ctx}/checkout/quote">Tính phí giao hàng</button>
        <c:if test="${summary.shipping != null and not empty summary.customerPhone}">
            <button type="submit">Đặt hàng</button>
        </c:if>
    </form:form>
    <p class="note">Miễn phí giao hàng cho địa chỉ trong bán kính 5km quanh cửa hàng và đơn từ 150.000đ tiền hàng;
        các trường hợp khác phí 30.000đ.</p>
</section>

<section>
    <h2>Đơn hàng</h2>
    <div class="table-wrap">
    <table>
        <c:forEach var="line" items="${summary.lines}">
            <tr>
                <td><c:out value="${line.name}"/> × ${line.quantity}
                    <c:if test="${line.flashSale}"><span class="fs">Flash Sale</span></c:if></td>
                <td class="num"><fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫</td>
            </tr>
        </c:forEach>
        <tr><td>Tạm tính</td><td class="num"><fmt:formatNumber value="${summary.subtotal}" type="number"/> ₫</td></tr>
        <tr><td>Giảm giá hạng ${summary.tierLabel} (${summary.tierRate}%, không áp cho Flash Sale)</td>
            <td class="num">−<fmt:formatNumber value="${summary.discountTotal}" type="number"/> ₫</td></tr>
        <tr><td>Phí giao hàng</td>
            <td class="num">
                <c:choose>
                    <c:when test="${summary.shipping == null}">Nhập địa chỉ rồi bấm "Tính phí giao hàng"</c:when>
                    <c:when test="${summary.shipping.fee == 0}"><span class="free">Miễn phí</span></c:when>
                    <c:otherwise><fmt:formatNumber value="${summary.shipping.fee}" type="number"/> ₫</c:otherwise>
                </c:choose>
            </td></tr>
        <c:if test="${summary.shipping != null}">
            <tr><td colspan="2" class="note">
                <c:out value="${summary.shipping.note}"/>
                <c:if test="${summary.shipping.distanceKm != null}">
                    <br>Khoảng cách tới cửa hàng: ${summary.shipping.distanceText} km
                    · Bản đồ hiểu địa chỉ là: <c:out value="${summary.shipping.matchedAddress}"/>
                </c:if>
            </td></tr>
            <tr class="total"><td><strong>Tổng cộng</strong></td>
                <td class="num"><strong><fmt:formatNumber value="${summary.total}" type="number"/> ₫</strong></td></tr>
        </c:if>
    </table>
    </div>
</section>
</div>

</body>
</html>
