<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tạo tài khoản nhân viên · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body class="admin-app">
    <%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

    <main class="admin-main">
        <div class="screen-bc">
            <span>QUẢN TRỊ HỆ THỐNG</span> <span class="sep">&gt;</span> <a href="${ctx}/admin/employees" style="color:inherit; text-decoration:none;">QUẢN LÝ TÀI KHOẢN NHÂN VIÊN</a> <span class="sep">&gt;</span> <span class="current">TẠO TÀI KHOẢN MỚI</span>
        </div>

        <div class="page-header-row" style="margin-bottom: 1.25rem;">
            <div>
                <h1 class="page-title" style="margin: 0; font-size: 1.5rem; font-weight: 800; color: #0f172a;">TẠO TÀI KHOẢN NHÂN VIÊN MỚI</h1>
                <p class="page-subtitle" style="margin: 0; color: #64748b; font-size: 0.88rem;">Cấp tài khoản đăng nhập nội bộ cho nhân sự vận hành hoặc quản trị viên.</p>
            </div>
        </div>

        <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); max-width: 780px; padding: 1.5rem;">
            <form:form method="post" action="${ctx}/admin/employees/new" modelAttribute="employeeCreateForm">
                <div style="display: flex; flex-direction: column; gap: 1.1rem;">
                    <div>
                        <label for="fullName" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Họ và tên nhân sự <span style="color: #dc2626;">*</span></label>
                        <form:input path="fullName" maxlength="100" placeholder="Ví dụ: Nguyễn Văn An" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;" required="required"/>
                        <form:errors path="fullName" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div>
                            <label for="email" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Email công việc (Đăng nhập) <span style="color: #dc2626;">*</span></label>
                            <form:input path="email" type="email" maxlength="255" placeholder="ten.nhanvien@petcare.vn" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;" required="required"/>
                            <form:errors path="email" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div>
                            <label for="phone" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Số điện thoại</label>
                            <form:input path="phone" maxlength="15" placeholder="0912 345 678" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;"/>
                            <form:errors path="phone" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>
                    </div>

                    <div>
                        <label for="role" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Vai trò phân quyền <span style="color: #dc2626;">*</span></label>
                        <form:select path="role" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem; background: #fff;">
                            <form:options items="${roles}"/>
                        </form:select>
                        <div style="font-size: 0.76rem; color: #64748b; margin-top: 0.25rem;">
                            <strong>STAFF:</strong> Quản lý kho, FEFO, đơn hàng, trả hàng và CSKH. <strong>ADMIN:</strong> Toàn quyền hệ thống, quản lý nhân viên và báo cáo doanh thu.
                        </div>
                        <form:errors path="role" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div>
                            <label for="password" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Mật khẩu ban đầu <span style="color: #dc2626;">*</span></label>
                            <form:password path="password" maxlength="64" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;" required="required"/>
                            <div style="font-size: 0.74rem; color: #64748b; margin-top: 2px;">Tối thiểu 8 ký tự, bao gồm cả chữ và số.</div>
                            <form:errors path="password" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>

                        <div>
                            <label for="confirmPassword" style="display: block; font-size: 0.8rem; font-weight: 700; color: #334155; margin-bottom: 0.35rem;">Xác nhận mật khẩu <span style="color: #dc2626;">*</span></label>
                            <form:password path="confirmPassword" maxlength="64" style="width: 100%; padding: 0.55rem 0.8rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.88rem;" required="required"/>
                            <form:errors path="confirmPassword" cssClass="err" cssStyle="color: #dc2626; font-size: 0.76rem;"/>
                        </div>
                    </div>

                    <div style="display: flex; gap: 0.75rem; justify-content: flex-end; margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #e2e8f0;">
                        <a href="${ctx}/admin/employees" class="btn btn-secondary" style="background: #fff; border: 1px solid #cbd5e1; color: #475569; padding: 0.55rem 1.1rem; text-decoration: none; border-radius: 6px;">Hủy bỏ</a>
                        <button type="submit" class="btn btn-primary" style="background: #f97316; border: 1px solid #ea580c; color: #fff; font-weight: 700; padding: 0.55rem 1.4rem; border-radius: 6px;">
                            <i class="ti ti-check"></i> Xác nhận tạo tài khoản
                        </button>
                    </div>
                </div>
            </form:form>
        </div>
    </main>
</body>
</html>
