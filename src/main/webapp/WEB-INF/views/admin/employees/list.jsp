<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: employees (EmployeeRow: employeeId, accountId, email, fullName, phone, role, status, createdAtText),
     currentPage, totalPages, totalItems, roles, statuses, filterRole, filterStatus, filterKeyword, filterQuery --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Nhân viên · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>.badge.LOCKED { background: #fdecea; color: #8a1c13; } .badge.ADMIN { background: #e8eaf6; color: #283593; }</style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<h1>Tài khoản nhân viên</h1>
<p><a href="${ctx}/admin/employees/new">+ Tạo tài khoản nhân viên</a></p>

<form class="filters" method="get" action="${ctx}/admin/employees">
    <select name="role">
        <option value="">Mọi vai trò</option>
        <c:forEach var="r" items="${roles}"><option value="${r}" ${filterRole == r ? 'selected' : ''}>${r}</option></c:forEach>
    </select>
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="s" items="${statuses}"><option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option></c:forEach>
    </select>
    <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Tên, email hoặc SĐT">
    <button type="submit">Lọc</button>
</form>
<p>${totalItems} nhân viên</p>

<table>
    <thead><tr><th>#</th><th>Họ tên</th><th>Email</th><th>SĐT</th><th>Vai trò</th><th>Trạng thái</th><th>Tạo lúc</th><th></th></tr></thead>
    <tbody>
    <c:forEach var="e" items="${employees}">
        <tr>
            <td>${e.employeeId}</td>
            <td><c:out value="${e.fullName}"/><c:if test="${e.employeeId == currentUser.employeeId}"> <span class="hint">(bạn)</span></c:if></td>
            <td><c:out value="${e.email}"/></td>
            <td><c:out value="${e.phone}"/></td>
            <td><span class="badge ${e.role}">${e.role}</span></td>
            <td><span class="badge ${e.status}">${e.status.label}</span></td>
            <td>${e.createdAtText}</td>
            <td>
                <a href="${ctx}/admin/employees/${e.employeeId}/edit">Sửa</a>
                <c:if test="${e.employeeId != currentUser.employeeId}">
                    <form method="post" action="${ctx}/admin/employees/${e.employeeId}/${e.status == 'ACTIVE' ? 'lock' : 'unlock'}" class="inline"
                          <c:if test="${e.status == 'ACTIVE'}">onsubmit="return confirm('Khoá tài khoản này? Nhân viên sẽ bị đăng xuất ngay.');"</c:if>>${csrf}
                        <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
                        <button type="submit">${e.status == 'ACTIVE' ? 'Khoá' : 'Mở khoá'}</button>
                    </form>
                </c:if>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty employees}"><tr><td colspan="8">Không có nhân viên nào.</td></tr></c:if>
    </tbody>
</table>

<c:if test="${totalPages > 1}">
    <nav class="pager">
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
    </nav>
</c:if>
</body>
</html>
