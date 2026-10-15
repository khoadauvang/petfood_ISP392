<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: lotForm (productId, expiryDate, receivedQty), lotId (null = nhập lô mới),
            products (List<ProductOption>, chỉ khi nhập mới), lot (LotRow, chỉ khi sửa),
            shelfLifeDays, quarantineDays --%>
<c:choose>
    <c:when test="${empty lotId}">
        <c:set var="pageHeading" value="Nhập lô"/>
        <c:url var="formAction" value="/staff/lots/new"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Sửa lô #${lotId} (nhập nhầm)"/>
        <c:url var="formAction" value="/staff/lots/${lotId}/edit"/>
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${pageHeading} · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>${pageHeading}</h1>

<form:form method="post" action="${formAction}" modelAttribute="lotForm">
    <div class="grid-form">
        <label for="productId">Sản phẩm</label>
        <div>
            <c:choose>
                <c:when test="${empty lotId}">
                    <form:select path="productId">
                        <form:option value="" label="-- Chọn sản phẩm --"/>
                        <c:forEach var="p" items="${products}">
                            <%-- Sản phẩm ngừng kinh doanh không nhập lô được (service chặn) --%>
                            <form:option value="${p.id}" disabled="${p.status != 'ACTIVE'}"><c:out value="${p.sku}"/> - <c:out value="${p.name}"/><c:if test="${p.status != 'ACTIVE'}"> (ngừng kinh doanh)</c:if></form:option>
                        </c:forEach>
                    </form:select>
                </c:when>
                <c:otherwise>
                    <form:hidden path="productId"/>
                    <a href="${ctx}/staff/products/${lot.productId}"><c:out value="${lot.sku}"/> - <c:out value="${lot.productName}"/></a>
                    <span class="hint">Nhập ngày ${lot.receivedAtText}. Nhầm sản phẩm thì xoá lô này rồi nhập lại.</span>
                </c:otherwise>
            </c:choose>
            <form:errors path="productId" cssClass="err"/>
        </div>

        <label for="expiryDate">Hạn sử dụng</label>
        <div>
            <form:input path="expiryDate" type="date" required="required"/>
            <span class="hint">Phải sau ngày nhập kho. Còn dưới ${shelfLifeDays} ngày thì lô chỉ bán qua Flash Sale,
                dưới ${quarantineDays} ngày thì không được bán.</span>
            <form:errors path="expiryDate" cssClass="err"/>
        </div>

        <label for="receivedQty">Số lượng nhập</label>
        <div>
            <form:input path="receivedQty" type="number" min="1" step="1" required="required"/>
            <span class="hint">Số lượng còn trong kho của lô tự bằng số lượng nhập.</span>
            <form:errors path="receivedQty" cssClass="err"/>
        </div>
    </div>
    <p>
        <button type="submit">Lưu</button>
        <a href="${ctx}/staff/lots">Huỷ</a>
    </p>
</form:form>
</body>
</html>
