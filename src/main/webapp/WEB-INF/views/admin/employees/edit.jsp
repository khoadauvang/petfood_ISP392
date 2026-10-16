<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: employee (EmployeeRow), employeeEditForm (fullName, phone, role), passwordResetForm (newPassword, confirmPassword), roles --%>
<c:set var="self" value="${employee.employeeId == currentUser.employeeId}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Sửa nhân viên #${employee.employeeId} · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<p><a href="${ctx}/admin/employees">‹ Danh sách nhân viên</a></p>
<h1>Nhân viên #${employee.employeeId}: <c:out value="${employee.email}"/></h1>
<p>Trạng thái: <span class="badge ${employee.status}">${employee.status.label}</span> · Tạo lúc ${employee.createdAtText}
    <c:if test="${not self}">
        <form method="post" action="${ctx}/admin/employees/${employee.employeeId}/${employee.status == 'ACTIVE' ? 'lock' : 'unlock'}" class="inline">${csrf}
            <button type="submit">${employee.status == 'ACTIVE' ? 'Khoá tài khoản' : 'Mở khoá'}</button>
        </form>
    </c:if>
</p>

<h2>Thông tin</h2>
<form:form method="post" action="${ctx}/admin/employees/${employee.employeeId}/edit" modelAttribute="employeeEditForm">
    <div class="grid-form">
        <label>Email</label>
        <div><c:out value="${employee.email}"/> <span class="hint">(không đổi được)</span></div>

        <label for="fullName">Họ tên</label>
        <div><form:input path="fullName" maxlength="100" size="40" required="required"/><form:errors path="fullName" cssClass="err"/></div>

        <label for="phone">Số điện thoại</label>
        <div><form:input path="phone" maxlength="15"/><form:errors path="phone" cssClass="err"/></div>

        <label for="role">Vai trò</label>
        <div>
            <form:select path="role" disabled="${self}"><form:options items="${roles}"/></form:select>
            <c:if test="${self}"><form:hidden path="role"/><span class="hint">Bạn không tự đổi vai trò của mình được.</span></c:if>
            <c:if test="${not self}"><span class="hint">Đổi vai trò thì nhân viên bị đăng xuất để nhận quyền mới.</span></c:if>
            <form:errors path="role" cssClass="err"/>
        </div>
    </div>
    <p><button type="submit">Lưu</button></p>
</form:form>

<h2>Đặt lại mật khẩu</h2>
<form:form method="post" action="${ctx}/admin/employees/${employee.employeeId}/password" modelAttribute="passwordResetForm">
    <div class="grid-form">
        <label for="newPassword">Mật khẩu mới</label>
        <div><form:password path="newPassword" maxlength="64" required="required"/>
            <span class="hint">8–64 ký tự, gồm cả chữ và số. Nhân viên bị đăng xuất khỏi các phiên đang mở.</span>
            <form:errors path="newPassword" cssClass="err"/></div>

        <label for="confirmPassword">Nhập lại mật khẩu</label>
        <div><form:password path="confirmPassword" maxlength="64" required="required"/><form:errors path="confirmPassword" cssClass="err"/></div>
    </div>
    <p><button type="submit">Đặt lại mật khẩu</button></p>
</form:form>
</body>
</html>
