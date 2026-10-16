<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Trả hàng #${ret.id} · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<p><a href="${ctx}/staff/returns">‹ Trả hàng</a></p>
<h1>Yêu cầu trả hàng #${ret.id}</h1>
<%@ include file="/WEB-INF/views/common/_return-detail.jspf" %>

<h3>Xử lý</h3>
<c:choose>
    <c:when test="${ret.status == 'REQUESTED'}">
        <form method="post" action="${ctx}/staff/returns/${ret.id}/approve" class="inline">${csrf}<button type="submit">Duyệt</button></form>
        <form method="post" action="${ctx}/staff/returns/${ret.id}/reject">${csrf}
            <label>Lý do từ chối <input type="text" name="rejectReason" maxlength="255" size="50" required></label>
            <button type="submit">Từ chối</button>
        </form>
    </c:when>
    <c:when test="${ret.status == 'APPROVED'}">
        <form method="post" action="${ctx}/staff/returns/${ret.id}/receive">${csrf}<button type="submit">Đã nhận hàng trả</button></form>
    </c:when>
    <c:when test="${ret.status == 'RECEIVED'}">
        <%-- Thẩm định từng dòng (BR-38). Bỏ tick "Hoàn tiền" khi dòng không được chấp nhận (ví dụ đã mở mà không phải lỗi sản phẩm, BR-34) --%>
        <form:form method="post" action="${ctx}/staff/returns/${ret.id}/inspect" modelAttribute="inspectForm">
            <table>
                <tr><th>Sản phẩm</th><th>Kết quả</th><th>Ghi chú</th><th>Hoàn tiền</th></tr>
                <c:forEach var="l" items="${ret.lines}" varStatus="s">
                    <tr>
                        <td><form:hidden path="lines[${s.index}].returnItemId"/><c:out value="${l.productName}"/> × ${l.quantity}</td>
                        <td><c:forEach var="r" items="${inspectionResults}">
                            <label><form:radiobutton path="lines[${s.index}].result" value="${r}"/> ${r.label}</label>
                        </c:forEach></td>
                        <td><form:input path="lines[${s.index}].note" maxlength="255"/></td>
                        <td><label><form:checkbox path="lines[${s.index}].refund"/> <fmt:formatNumber value="${l.maxRefund}" type="number"/> ₫</label></td>
                    </tr>
                </c:forEach>
            </table>
            <p class="hint">"Tái nhập" cộng hàng về đúng lô đã xuất. Đơn chưa thanh toán (COD khách không nhận) thì không có tiền hoàn.</p>
            <button type="submit">Lưu thẩm định</button>
        </form:form>
    </c:when>
    <c:when test="${ret.status == 'INSPECTED'}">
        <form method="post" action="${ctx}/staff/returns/${ret.id}/refunded">${csrf}
            <button type="submit">Đã chuyển khoản hoàn <fmt:formatNumber value="${ret.refundTotal}" type="number"/> ₫</button>
            <span class="hint">Hoàn tiền làm thủ công, bấm sau khi đã chuyển khoản.</span>
        </form>
    </c:when>
    <c:otherwise><span class="hint">Yêu cầu đã kết thúc.</span></c:otherwise>
</c:choose>
</body>
</html>
