<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đơn #${order.id} · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<p><a href="${ctx}/staff/orders">‹ Đơn hàng</a></p>
<h1>Đơn #${order.id}</h1>

<%@ include file="/WEB-INF/views/common/_order-detail.jspf" %>

<h3>Xử lý</h3>
<%-- Mỗi nút chỉ chuyển một bước (BR-17); server kiểm tra lại trạng thái nên bấm trùng không sao --%>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<p>
    <c:choose>
        <c:when test="${order.status == 'PENDING'}">
            <form method="post" action="${ctx}/staff/orders/${order.id}/confirm" class="inline">${csrf}
                <button type="submit">Xác nhận đơn</button></form>
        </c:when>
        <c:when test="${order.status == 'CONFIRMED'}">
            <form method="post" action="${ctx}/staff/orders/${order.id}/pack" class="inline">${csrf}
                <button type="submit">Đóng gói</button></form>
        </c:when>
        <c:when test="${order.status == 'PROCESSING' and order.cancelRequested}">
            <form method="post" action="${ctx}/staff/orders/${order.id}/cancel-request/approve" class="inline">${csrf}
                <button type="submit">Duyệt huỷ (trả hàng về kho)</button></form>
            <form method="post" action="${ctx}/staff/orders/${order.id}/cancel-request/reject" class="inline">${csrf}
                <button type="submit">Từ chối yêu cầu huỷ</button></form>
        </c:when>
        <c:when test="${order.status == 'PROCESSING'}">
            <form method="post" action="${ctx}/staff/orders/${order.id}/ship" class="inline">${csrf}
                <button type="submit">Bắt đầu giao</button></form>
        </c:when>
        <c:when test="${order.status == 'SHIPPED'}">
            <form method="post" action="${ctx}/staff/orders/${order.id}/complete" class="inline">${csrf}
                <button type="submit">Giao thành công</button></form>
            <form method="post" action="${ctx}/staff/orders/${order.id}/returned" class="inline">${csrf}
                <button type="submit">Khách không nhận hàng</button></form>
        </c:when>
        <c:otherwise><span class="hint">Đơn đã kết thúc, không còn bước xử lý.</span></c:otherwise>
    </c:choose>
</p>

<c:if test="${order.needsRefund}">
    <form method="post" action="${ctx}/staff/orders/${order.id}/refunded">${csrf}
        <button type="submit">Đã chuyển khoản hoàn tiền cho khách</button>
        <span class="hint">Hoàn tiền VNPay làm thủ công, bấm sau khi đã chuyển khoản.</span>
    </form>
</c:if>

<%-- Staff huỷ đơn chưa giao (hết hàng, không liên lạc được khách...). Hàng trả về đúng lô đã trừ. --%>
<c:if test="${order.status == 'PENDING' or order.status == 'CONFIRMED' or (order.status == 'PROCESSING' and not order.cancelRequested)}">
    <form method="post" action="${ctx}/staff/orders/${order.id}/cancel">${csrf}
        <label>Lý do huỷ <input type="text" name="cancelReason" maxlength="255" required size="50"></label>
        <button type="submit">Huỷ đơn</button>
    </form>
</c:if>

</body>
</html>
