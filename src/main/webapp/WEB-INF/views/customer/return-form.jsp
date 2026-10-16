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
    <title>Yêu cầu trả hàng · Đơn #${orderId} · Food Pet Shop</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        table { border-collapse: collapse; width: 100%; max-width: 760px; }
        th, td { border-bottom: 1px solid #e5e5e5; padding: 6px 8px; text-align: left; }
        input[type=number] { width: 60px; }
        .field { margin: 12px 0; }
        .error { color: #b00020; display: block; }
        .hint { color: #666; font-size: 13px; }
        textarea { width: 100%; max-width: 560px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/_header.jspf" %>
<p><a href="${ctx}/orders/${orderId}">‹ Đơn #${orderId}</a></p>
<h1>Yêu cầu trả hàng · Đơn #${orderId}</h1>
<p class="hint">Trả trong 3 ngày kể từ khi giao thành công. Hàng mua qua Flash Sale không trả với lý do hạn sử dụng.</p>

<form:form method="post" action="${ctx}/orders/${orderId}/returns/new" modelAttribute="returnForm" enctype="multipart/form-data">
    <h3>Sản phẩm muốn trả</h3>
    <form:errors path="lines" cssClass="error"/>
    <table>
        <tr><th>Trả</th><th>Sản phẩm</th><th>Số lượng trả</th><th>Đã mở bao bì</th></tr>
        <c:forEach var="l" items="${returnableLines}" varStatus="s">
            <tr>
                <td><form:hidden path="lines[${s.index}].orderItemId"/><form:checkbox path="lines[${s.index}].selected"/></td>
                <td><c:out value="${l.productName}"/><c:if test="${l.flashSale}"> (Flash Sale)</c:if> · đã mua ${l.quantity}</td>
                <td><form:input path="lines[${s.index}].quantity" type="number" min="1" max="${l.quantity}"/></td>
                <td><form:checkbox path="lines[${s.index}].opened"/></td>
            </tr>
        </c:forEach>
    </table>

    <div class="field">
        <label for="reason">Lý do</label>
        <form:select path="reason">
            <form:option value="">-- Chọn lý do --</form:option>
            <c:forEach var="r" items="${reasons}"><form:option value="${r}">${r.label}</form:option></c:forEach>
        </form:select>
        <form:errors path="reason" cssClass="error"/>
    </div>
    <div class="field">
        <label for="description">Mô tả thêm</label><br>
        <form:textarea path="description" rows="3" maxlength="2000"/>
        <form:errors path="description" cssClass="error"/>
    </div>
    <div class="field">
        <label for="media">Ảnh / video bằng chứng (1 đến 5 file)</label><br>
        <input type="file" id="media" name="media" multiple accept="image/jpeg,image/png,image/webp,video/mp4,video/quicktime,video/webm">
        <span class="hint">Ảnh JPG/PNG/WEBP hoặc video MP4/MOV/WEBM, mỗi file tối đa 5MB.</span>
        <form:errors path="media" cssClass="error"/>
    </div>

    <%-- Đơn COD: khách nhập tài khoản để cửa hàng chuyển khoản hoàn tiền thủ công (LI-05) --%>
    <c:if test="${cod}">
        <h3>Tài khoản nhận tiền hoàn</h3>
        <div class="field"><label>Ngân hàng <form:input path="refundBankName" maxlength="100"/></label></div>
        <div class="field"><label>Số tài khoản <form:input path="refundAccountNo" maxlength="30"/></label></div>
        <div class="field"><label>Chủ tài khoản <form:input path="refundAccountHolder" maxlength="100"/></label></div>
        <form:errors path="refundBankName" cssClass="error"/>
    </c:if>

    <button type="submit">Gửi yêu cầu trả hàng</button>
</form:form>
</body>
</html>
