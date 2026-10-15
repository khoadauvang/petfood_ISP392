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
    <title>Đơn #${order.id} · Food Pet Shop</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        textarea { width: 100%; max-width: 480px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<p><a href="${ctx}/orders">‹ Đơn hàng của tôi</a></p>
<h1>Đơn #${order.id}</h1>

<%@ include file="/WEB-INF/views/common/_order-detail.jspf" %>

<%-- Huỷ đơn (BR-19): PENDING / CONFIRMED huỷ ngay; PROCESSING gửi yêu cầu cho cửa hàng; từ SHIPPED không huỷ được --%>
<c:if test="${order.customerCanCancel or order.customerCanRequestCancel}">
    <h3>${order.customerCanCancel ? 'Huỷ đơn' : 'Yêu cầu huỷ đơn'}</h3>
    <c:if test="${order.customerCanRequestCancel}">
        <p class="hint">Đơn đang được đóng gói nên cần cửa hàng xác nhận mới huỷ được.</p>
    </c:if>
    <form method="post" action="${ctx}/orders/${order.id}/cancel">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <p><label>Lý do<br><textarea name="cancelReason" rows="2" maxlength="255" required></textarea></label></p>
        <button type="submit">${order.customerCanCancel ? 'Huỷ đơn' : 'Gửi yêu cầu huỷ'}</button>
    </form>
</c:if>
<c:if test="${order.cancelRequested}">
    <p>Yêu cầu huỷ của bạn đang chờ cửa hàng xử lý.</p>
</c:if>

</body>
</html>
