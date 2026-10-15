<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Danh mục · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1>Danh mục</h1>
<p><a href="${ctx}/staff/categories/new">+ Thêm danh mục</a></p>

<%-- Model: categories = List<CategoryRow> (id, name, petType, status, productCount) --%>
<c:choose>
    <c:when test="${empty categories}">
        <p>Chưa có danh mục nào.</p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
            <tr>
                <th>#</th><th>Tên danh mục</th><th>Loại thú cưng</th><th>Trạng thái</th>
                <th class="num">Số sản phẩm</th><th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="cat" items="${categories}">
                <tr>
                    <td>${cat.id}</td>
                    <td><c:out value="${cat.name}"/></td>
                    <td>${cat.petType.label}</td>
                    <td><span class="badge ${cat.status}">${cat.status.label}</span></td>
                    <td class="num">
                        <a href="${ctx}/staff/products?categoryId=${cat.id}">${cat.productCount}</a>
                    </td>
                    <td>
                        <a href="${ctx}/staff/categories/${cat.id}/edit">Sửa</a>
                        <form method="post" action="${ctx}/staff/categories/${cat.id}/toggle-status" class="inline">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button type="submit">${cat.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}</button>
                        </form>
                        <%-- Chỉ xoá được danh mục chưa có sản phẩm; có sản phẩm thì chỉ ẩn --%>
                        <c:if test="${cat.productCount == 0}">
                            <form method="post" action="${ctx}/staff/categories/${cat.id}/delete" class="inline"
                                  onsubmit="return confirm('Xoá hẳn danh mục này?');">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit">Xoá</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>
</body>
</html>
