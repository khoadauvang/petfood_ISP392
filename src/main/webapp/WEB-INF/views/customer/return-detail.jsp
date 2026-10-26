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
        <title>Yêu cầu trả hàng #${ret.id} · Food Pet Shop</title>
        <style>body {
            font-family: Arial, sans-serif;
            margin: 16px;
            color: #222;
        }</style>
    </head>
    <body>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>
        <p><a href="${ctx}/orders/${ret.orderId}">‹ Đơn #${ret.orderId}</a></p>
        <h1>Yêu cầu trả hàng #${ret.id}</h1>
        <%@ include file="/WEB-INF/views/common/_return-detail.jspf" %>
        <c:if test="${ret.status == 'APPROVED'}">
            <p class="msg ok">Yêu cầu đã được duyệt. Vui lòng gửi hàng về cửa hàng, cửa hàng sẽ thẩm định và hoàn tiền.</p>
        </c:if>
    </body>
</html>
