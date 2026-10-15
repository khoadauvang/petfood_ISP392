<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: categoryForm (name, petType, status), categoryId (null = thêm mới), petTypes, categoryStatuses --%>
<c:choose>
    <c:when test="${empty categoryId}">
        <c:set var="pageHeading" value="Thêm danh mục"/>
        <c:url var="formAction" value="/staff/categories/new"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Sửa danh mục #${categoryId}"/>
        <c:url var="formAction" value="/staff/categories/${categoryId}/edit"/>
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

<%-- form:form tự thêm ô ẩn _csrf --%>
<form:form method="post" action="${formAction}" modelAttribute="categoryForm">
    <div class="grid-form">
        <label for="name">Tên danh mục</label>
        <div>
            <form:input path="name" maxlength="100" size="40" required="required"/>
            <form:errors path="name" cssClass="err"/>
        </div>

        <label for="petType">Loại thú cưng</label>
        <div>
            <form:select path="petType">
                <form:option value="" label="-- Chọn --"/>
                <form:options items="${petTypes}" itemLabel="label"/>
            </form:select>
            <span class="hint">Danh mục Chó / Mèo chỉ chứa sản phẩm đúng loài đó; "Chó và mèo" chứa cả hai.</span>
            <form:errors path="petType" cssClass="err"/>
        </div>

        <label for="status">Trạng thái</label>
        <div>
            <form:select path="status">
                <form:options items="${categoryStatuses}" itemLabel="label"/>
            </form:select>
            <span class="hint">Danh mục ẩn: sản phẩm bên trong không hiện ở trang khách.</span>
            <form:errors path="status" cssClass="err"/>
        </div>
    </div>
    <p>
        <button type="submit">Lưu</button>
        <a href="${ctx}/staff/categories">Huỷ</a>
    </p>
</form:form>
</body>
</html>
