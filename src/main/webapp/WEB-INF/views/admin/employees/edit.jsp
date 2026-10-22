<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="self" value="${employee.employeeId == currentUser.employeeId}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chỉnh sửa nhân sự #${employee.employeeId} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body class="admin-app">
    <%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

    <main class="admin-main">
        <div class="breadcrumb-bar" style="margin-bottom: 0.5rem; font-size: 0.72rem; font-weight: 700; color: #94a3b8; text-transform: uppercase;">
            <a href="${ctx}/admin/employees" style="color: #64748b; text-decoration: none;">‹ QUẢN LÝ TÀI KHOẢN NHÂN VIÊN</a>
        </div>

        <div class="page-header-row" style="margin-bottom: 1.25rem;">
            <div>
                <h1 class="page-title" style="margin: 0; font-size: 1.5rem; font-weight: 800; color: #0f172a;">
                    Nhân viên #${employee.employeeId}: <c:out value="${employee.fullName}"/>
                </h1>
                <p class="page-subtitle" style="margin: 0; color: #64748b; font-size: 0.88rem;">
                    Trạng thái: <span class="badge ${employee.status}">${employee.status.label}</span> • Tạo lúc: ${employee.createdAtText}
                </p>
            </div>
            <div>
                <c:if test="${not self}">
                    <form method="post" action="${ctx}/admin/employees/${employee.employeeId}/${employee.status == 'ACTIVE' ? 'lock' : 'unlock'}" style="display: inline;">${csrf}
                        <button type="submit" class="btn btn-sm" style="background: #fff; border: 1px solid ${employee.status == 'ACTIVE' ? '#fecaca' : '#bbf7d0'}; color: ${employee.status == 'ACTIVE' ? '#dc2626' : '#16a34a'}; font-weight: 700;">
                            <i class="ti ti-${employee.status == 'ACTIVE' ? 'lock' : 'lock-open'}"></i>
                            ${employee.status == 'ACTIVE' ? 'Khóa tài khoản này' : 'Mở khóa tài khoản'}
                        </button>
                    </form>
                </c:if>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; max-width: 1000px;">
            <!-- Form 1: Profile info -->
            <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); padding: 1.5rem;">
                <h2 style="font-size: 1.1rem; font-weight: 800; color: #0f172a; margin-top: 0; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #f1f5f9;">
                    <i class="ti ti-user" style="color: #f97316;"></i> Thông tin tài khoản
                </h2>
                <form:form method="post" action="${ctx}/admin/employees/${employee.employeeId}/edit" modelAttribute="employeeEditForm">
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                        <div>
                            <label style="display: block; font-size: 0.78rem; font-weight: 700; color: #64748b; margin-bottom: 0.25rem;">Email đăng nhập</label>
                            <input type="text" value="<c:out value='${employee.email}'/>" disabled style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 0.88rem; background: #f8fafc; color: #64748b;">
                            <span style="font-size: 0.72rem; color: #94a3b8;">Email không thể thay đổi sau khi tạo.</span>
                        </div>

                        <div>
                            <label for="fullName" style="display: block; font-size: 0.78rem; font-weight: 700; color: #334155; margin-bottom: 0.25rem;">Họ và tên <span style="color: #dc2626;">*</span></label>
                            <form:input path="fullName" maxlength="100" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;" required="required"/>
                            <form:errors path="fullName" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div>
                            <label for="phone" style="display: block; font-size: 0.78rem; font-weight: 700; color: #334155; margin-bottom: 0.25rem;">Số điện thoại</label>
                            <form:input path="phone" maxlength="15" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;"/>
                            <form:errors path="phone" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div>
                            <label for="role" style="display: block; font-size: 0.78rem; font-weight: 700; color: #334155; margin-bottom: 0.25rem;">Vai trò</label>
                            <form:select path="role" disabled="${self}" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem; background: #fff;">
                                <form:options items="${roles}"/>
                            </form:select>
                            <c:if test="${self}">
                                <form:hidden path="role"/>
                                <span style="font-size: 0.72rem; color: #ea580c;">Bạn không tự đổi vai trò của chính mình được.</span>
                            </c:if>
                            <form:errors path="role" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div style="margin-top: 0.5rem;">
                            <button type="submit" class="btn btn-primary" style="background: #f97316; border: 1px solid #ea580c; color: #fff; font-weight: 700; padding: 0.5rem 1.25rem; border-radius: 6px;">
                                <i class="ti ti-device-floppy"></i> Lưu thay đổi
                            </button>
                        </div>
                    </div>
                </form:form>
            </div>

            <!-- Form 2: Password reset -->
            <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); padding: 1.5rem;">
                <h2 style="font-size: 1.1rem; font-weight: 800; color: #0f172a; margin-top: 0; margin-bottom: 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid #f1f5f9;">
                    <i class="ti ti-key" style="color: #f97316;"></i> Đặt lại mật khẩu
                </h2>
                <form:form method="post" action="${ctx}/admin/employees/${employee.employeeId}/password" modelAttribute="passwordResetForm">
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                        <div>
                            <label for="newPassword" style="display: block; font-size: 0.78rem; font-weight: 700; color: #334155; margin-bottom: 0.25rem;">Mật khẩu mới <span style="color: #dc2626;">*</span></label>
                            <form:password path="newPassword" maxlength="64" required="required" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;"/>
                            <span style="font-size: 0.72rem; color: #64748b;">8–64 ký tự, gồm cả chữ và số. Nhân sự sẽ bị đăng xuất khỏi phiên làm việc hiện tại.</span>
                            <form:errors path="newPassword" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div>
                            <label for="confirmPassword" style="display: block; font-size: 0.78rem; font-weight: 700; color: #334155; margin-bottom: 0.25rem;">Nhập lại mật khẩu mới <span style="color: #dc2626;">*</span></label>
                            <form:password path="confirmPassword" maxlength="64" required="required" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;"/>
                            <form:errors path="confirmPassword" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div style="margin-top: 0.5rem;">
                            <button type="submit" class="btn btn-secondary" style="background: #fff; border: 1px solid #cbd5e1; color: #1e293b; font-weight: 700; padding: 0.5rem 1.25rem; border-radius: 6px;">
                                <i class="ti ti-refresh"></i> Xác nhận đổi mật khẩu
                            </button>
                        </div>
                    </div>
                </form:form>
            </div>
        </div>
    </main>
</body>
</html>
