<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: employeeCreateForm (fullName, email, phone, role, password, confirmPassword), roles (STAFF, ADMIN) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tạo tài khoản nhân viên · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<h1>Tạo tài khoản nhân viên</h1>

<form:form method="post" action="${ctx}/admin/employees/new" modelAttribute="employeeCreateForm">
    <div class="grid-form">
        <label for="fullName">Họ tên</label>
        <div><form:input path="fullName" maxlength="100" size="40" required="required"/><form:errors path="fullName" cssClass="err"/></div>

        <label for="email">Email đăng nhập</label>
        <div><form:input path="email" type="email" maxlength="255" size="40" required="required"/><form:errors path="email" cssClass="err"/></div>

        <label for="phone">Số điện thoại</label>
        <div><form:input path="phone" maxlength="15"/><span class="hint">Không bắt buộc</span><form:errors path="phone" cssClass="err"/></div>

        <label for="role">Vai trò</label>
        <div>
            <form:select path="role"><form:options items="${roles}"/></form:select>
            <span class="hint">STAFF: quản lý sản phẩm, kho, đơn, trả hàng, hỗ trợ. ADMIN: thêm quản lý nhân viên và thống kê.</span>
            <form:errors path="role" cssClass="err"/>
        </div>

        <label for="password">Mật khẩu</label>
        <div><form:password path="password" maxlength="64" required="required"/>
            <span class="hint">8–64 ký tự, gồm cả chữ và số</span><form:errors path="password" cssClass="err"/></div>

        <label for="confirmPassword">Nhập lại mật khẩu</label>
        <div><form:password path="confirmPassword" maxlength="64" required="required"/><form:errors path="confirmPassword" cssClass="err"/></div>
    </div>
    <p>
        <button type="submit">Tạo tài khoản</button>
        <a href="${ctx}/admin/employees">Huỷ</a>
    </p>
</form:form>
</body>
</html>
