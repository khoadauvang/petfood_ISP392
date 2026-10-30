<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý tài khoản nhân viên · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body class="admin-app">
    <%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

    <main class="admin-main">
        <!-- Breadcrumb Bar -->
        <div class="screen-bc">
            <span>QUẢN TRỊ HỆ THỐNG</span>
            <span class="sep">&gt;</span>
            <span class="current">QUẢN LÝ TÀI KHOẢN NHÂN VIÊN</span>
        </div>

        <!-- Page Header -->
        <div class="page-header-row" style="margin-bottom: 1.25rem;">
            <div>
                <h1 class="page-title" style="margin: 0 0 0.25rem 0; font-size: 1.6rem; font-weight: 800; color: #0f172a;">QUẢN LÝ TÀI KHOẢN NHÂN VIÊN</h1>
                <p class="page-subtitle" style="margin: 0; color: #64748b; font-size: 0.88rem;">Quản lý thông tin tài khoản, vai trò phân quyền và trạng thái nhân sự trong hệ thống PetFood.</p>
            </div>
            <div style="display: flex; align-items: center; gap: 0.75rem;">
                <a href="${ctx}/admin/employees/new" class="btn btn-primary" style="background: #f97316; border: 1px solid #ea580c; color: #fff; font-weight: 700; padding: 0.5rem 1.1rem; border-radius: 6px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                    <i class="ti ti-user-plus"></i> + Tạo tài khoản mới
                </a>
            </div>
        </div>

        <!-- 4 KPI Summary Cards (Screen 16) -->
        <div class="dashboard-kpis" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-bottom: 1.25rem;">
            
            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.4rem;">
                    <div style="font-size: 0.78rem; font-weight: 700; color: #64748b;">Tổng số tài khoản</div>
                    <div style="width: 32px; height: 32px; border-radius: 8px; background: #fff7ed; color: #f97316; display: flex; align-items: center; justify-content: center;">
                        <i class="ti ti-users" style="font-size: 1.1rem;"></i>
                    </div>
                </div>
                <div style="display: flex; align-items: baseline; gap: 6px; margin-bottom: 0.35rem;">
                    <span style="font-size: 1.85rem; font-weight: 800; color: #0f172a; line-height: 1;">${employeeCounts.TOTAL != null ? employeeCounts.TOTAL : 0}</span>
                    <span style="font-size: 0.8rem; color: #64748b;">nhân sự</span>
                </div>
                <div style="display: flex; align-items: center; gap: 6px; font-size: 0.76rem; color: #64748b;">
                    <span>Tổng nhân sự toàn hệ thống</span>
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.4rem;">
                    <div style="font-size: 0.78rem; font-weight: 700; color: #64748b;">Quản trị viên (Admin)</div>
                    <div style="width: 32px; height: 32px; border-radius: 8px; background: #fff7ed; color: #ea580c; display: flex; align-items: center; justify-content: center;">
                        <i class="ti ti-shield-lock" style="font-size: 1.1rem;"></i>
                    </div>
                </div>
                <div style="display: flex; align-items: baseline; gap: 6px; margin-bottom: 0.35rem;">
                    <span style="font-size: 1.85rem; font-weight: 800; color: #0f172a; line-height: 1;">${employeeCounts.ADMIN != null ? employeeCounts.ADMIN : 0}</span>
                    <span style="background: #ffedd5; color: #9a3412; font-size: 0.72rem; font-weight: 700; padding: 0.1rem 0.45rem; border-radius: 999px;">Toàn quyền</span>
                </div>
                <div style="font-size: 0.76rem; color: #64748b;">
                    Quản trị hệ thống, báo cáo và phân quyền
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.4rem;">
                    <div style="font-size: 0.78rem; font-weight: 700; color: #64748b;">Nhân viên (Staff)</div>
                    <div style="width: 32px; height: 32px; border-radius: 8px; background: #fff7ed; color: #f97316; display: flex; align-items: center; justify-content: center;">
                        <i class="ti ti-briefcase" style="font-size: 1.1rem;"></i>
                    </div>
                </div>
                <div style="display: flex; align-items: baseline; gap: 6px; margin-bottom: 0.35rem;">
                    <span style="font-size: 1.85rem; font-weight: 800; color: #0f172a; line-height: 1;">${employeeCounts.STAFF != null ? employeeCounts.STAFF : 0}</span>
                    <span style="background: #f1f5f9; color: #475569; font-size: 0.72rem; font-weight: 700; padding: 0.1rem 0.45rem; border-radius: 999px;">Tác nghiệp</span>
                </div>
                <div style="font-size: 0.76rem; color: #64748b;">
                    Vận hành đơn hàng, kho vận &amp; CSKH
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.4rem;">
                    <div style="font-size: 0.78rem; font-weight: 700; color: #64748b;">Tài khoản bị khóa</div>
                    <div style="width: 32px; height: 32px; border-radius: 8px; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center;">
                        <i class="ti ti-lock-off" style="font-size: 1.1rem;"></i>
                    </div>
                </div>
                <div style="display: flex; align-items: baseline; gap: 6px; margin-bottom: 0.35rem;">
                    <span style="font-size: 1.85rem; font-weight: 800; color: #dc2626; line-height: 1;">${employeeCounts.LOCKED != null ? employeeCounts.LOCKED : 0}</span>
                    <span style="background: #fee2e2; color: #991b1b; font-size: 0.72rem; font-weight: 700; padding: 0.1rem 0.45rem; border-radius: 999px;">Vô hiệu hóa</span>
                </div>
                <div style="font-size: 0.76rem; color: #64748b;">
                    Tài khoản đang bị tạm ngưng truy cập
                </div>
            </div>

        </div>

        <!-- Filter Bar (Screen 16) -->
        <div class="filter-panel" style="background: #fff; border-radius: 10px; padding: 0.85rem 1.1rem; border: 1px solid #eaeaea; margin-bottom: 1.25rem;">
            <form method="get" action="${ctx}/admin/employees" style="display: flex; flex-wrap: wrap; gap: 0.75rem; align-items: center;">
                <div style="flex: 2; min-width: 280px; position: relative;">
                    <i class="ti ti-search" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #94a3b8;"></i>
                    <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Tìm theo họ tên, email, số điện thoại..." style="width: 100%; padding: 0.5rem 1rem 0.5rem 2.2rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.85rem;">
                </div>

                <div style="flex: 1; min-width: 150px;">
                    <select name="role" style="width: 100%; padding: 0.5rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.85rem; background: #fff;">
                        <option value="">Tất cả vai trò</option>
                        <c:forEach var="r" items="${roles}">
                            <option value="${r}" ${filterRole == r ? 'selected' : ''}>${r}</option>
                        </c:forEach>
                    </select>
                </div>

                <div style="flex: 1; min-width: 150px;">
                    <select name="status" style="width: 100%; padding: 0.5rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.85rem; background: #fff;">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach var="s" items="${statuses}">
                            <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
                        </c:forEach>
                    </select>
                </div>

                <div style="display: flex; gap: 0.5rem;">
                    <button type="submit" class="btn btn-primary" style="background: #f97316; border: 1px solid #ea580c; color: #fff; padding: 0.5rem 1rem; border-radius: 6px; font-size: 0.85rem; font-weight: 600;">
                        <i class="ti ti-filter"></i> Lọc
                    </button>
                    <a href="${ctx}/admin/employees" class="btn btn-secondary" style="background: #f8fafc; border: 1px solid #cbd5e1; color: #475569; padding: 0.5rem 0.9rem; text-decoration: none; font-size: 0.85rem; display: inline-flex; align-items: center; gap: 4px;">
                        <i class="ti ti-rotate-2"></i> Đặt lại
                    </a>
                </div>
            </form>
        </div>

        <!-- Employees Table Card (Screen 16) -->
        <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); overflow: hidden; margin-bottom: 1.5rem;">
            <div class="table-responsive">
                <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 0.84rem;">
                    <thead>
                        <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; text-align: left; color: #64748b; font-size: 0.72rem; text-transform: uppercase;">
                            <th style="padding: 0.75rem 0.85rem; width: 40px; text-align: center;">
                                <input type="checkbox" style="cursor: pointer;">
                            </th>
                            <th style="padding: 0.75rem 0.85rem; width: 80px;">MÃ NV</th>
                            <th style="padding: 0.75rem 1rem;">HỌ VÀ TÊN &amp; BỘ PHẬN</th>
                            <th style="padding: 0.75rem 1rem;">EMAIL</th>
                            <th style="padding: 0.75rem 1rem;">SỐ ĐIỆN THOẠI</th>
                            <th style="padding: 0.75rem 0.85rem;">VAI TRÒ</th>
                            <th style="padding: 0.75rem 0.85rem;">NGÀY TẠO</th>
                            <th style="padding: 0.75rem 0.85rem;">TRẠNG THÁI</th>
                            <th style="padding: 0.75rem 0.85rem; text-align: right;">THAO TÁC</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <c:forEach var="e" items="${employees}">
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 0.85rem 0.85rem; text-align: center;">
                                            <input type="checkbox" value="${e.employeeId}">
                                        </td>
                                        <td style="padding: 0.85rem 0.85rem; font-weight: 700; color: #1e293b;">
                                            NV-${e.employeeId < 10 ? '00' : (e.employeeId < 100 ? '0' : '')}${e.employeeId}
                                        </td>
                                        <td style="padding: 0.85rem 1rem;">
                                            <div style="display: flex; align-items: center; gap: 0.75rem;">
                                                <div style="width: 34px; height: 34px; border-radius: 50%; background: #fed7aa; color: #c2410c; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.78rem;">
                                                    ${e.fullName.substring(0, 1)}
                                                </div>
                                                <div>
                                                    <div style="font-weight: 700; color: #0f172a;">
                                                        <c:out value="${e.fullName}"/>
                                                        <c:if test="${e.employeeId == currentUser.employeeId}">
                                                            <span style="font-size: 0.72rem; color: #ea580c; font-weight: 600;">(bạn)</span>
                                                        </c:if>
                                                    </div>
                                                    <div style="font-size: 0.74rem; color: #64748b;">
                                                        Nhân viên vận hành
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td style="padding: 0.85rem 1rem; color: #475569;">
                                            <c:out value="${e.email}"/>
                                        </td>
                                        <td style="padding: 0.85rem 1rem; color: #475569;">
                                            <c:out value="${empty e.phone ? '---' : e.phone}"/>
                                        </td>
                                        <td style="padding: 0.85rem 0.85rem;">
                                            <c:choose>
                                                <c:when test="${e.role == 'ADMIN'}">
                                                    <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.72rem; padding: 0.2rem 0.5rem; border-radius: 4px; font-weight: 700; display: inline-flex; align-items: center; gap: 3px;">
                                                        <i class="ti ti-shield"></i> Admin
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background: #f1f5f9; color: #334155; font-size: 0.72rem; padding: 0.2rem 0.5rem; border-radius: 4px; font-weight: 700; display: inline-flex; align-items: center; gap: 3px;">
                                                        <i class="ti ti-briefcase"></i> Staff
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 0.85rem 0.85rem; color: #64748b; font-size: 0.8rem;">
                                            ${e.createdAtText}
                                        </td>
                                        <td style="padding: 0.85rem 0.85rem;">
                                            <c:choose>
                                                <c:when test="${e.status == 'ACTIVE'}">
                                                    <span class="badge" style="background: #dcfce7; color: #166534; font-size: 0.74rem; font-weight: 700; padding: 0.2rem 0.55rem; border-radius: 999px;">
                                                        <span style="display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: #16a34a; margin-right: 4px;"></span>
                                                        Đang hoạt động
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 0.74rem; font-weight: 700; padding: 0.2rem 0.55rem; border-radius: 999px;">
                                                        <span style="display: inline-block; width: 6px; height: 6px; border-radius: 50%; background: #dc2626; margin-right: 4px;"></span>
                                                        Đã khóa
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 0.85rem 0.85rem; text-align: right;">
                                            <div style="display: flex; gap: 0.4rem; justify-content: flex-end;">
                                                <a href="${ctx}/admin/employees/${e.employeeId}/edit" class="btn btn-xs" style="background: #fff; border: 1px solid #cbd5e1; color: #475569; padding: 0.25rem 0.5rem; text-decoration: none;" title="Sửa thông tin">
                                                    <i class="ti ti-edit"></i>
                                                </a>
                                                <c:if test="${e.employeeId != currentUser.employeeId}">
                                                    <form method="post" action="${ctx}/admin/employees/${e.employeeId}/${e.status == 'ACTIVE' ? 'lock' : 'unlock'}" style="display: inline;"
                                                          <c:if test="${e.status == 'ACTIVE'}">onsubmit="return confirm('Khoá tài khoản này? Nhân viên sẽ bị đăng xuất ngay.');"</c:if>>${csrf}
                                                        <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
                                                        <button type="submit" class="btn btn-xs" style="background: #fff; border: 1px solid #cbd5e1; color: ${e.status == 'ACTIVE' ? '#dc2626' : '#16a34a'}; padding: 0.25rem 0.5rem;" title="${e.status == 'ACTIVE' ? 'Khoá' : 'Mở khoá'}">
                                                            <i class="ti ti-${e.status == 'ACTIVE' ? 'lock' : 'lock-open'}"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>

                            <c:otherwise>
                                <tr>
                                    <td colspan="9" style="text-align: center; padding: 48px 20px; color: #94a3b8;">
                                        <i class="ti ti-users" style="font-size: 2.2rem; display: block; margin-bottom: 8px;"></i>
                                        Không tìm thấy nhân viên nào phù hợp
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Table Pagination Footer -->
            <c:if test="${totalPages > 0}">
                <div style="padding: 0.9rem 1.25rem; background: #fff; border-top: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; font-size: 0.82rem; color: #64748b;">
                    <span>Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong> (Tổng cộng <strong>${totalItems}</strong> nhân sự)</span>
                    <div style="display: flex; gap: 4px; align-items: center;">
                        <c:if test="${currentPage > 1}">
                            <a href="${ctx}/admin/employees?page=${currentPage - 1}${not empty filterQuery ? '&' : ''}${filterQuery}" class="btn btn-xs" style="padding: 0.35rem 0.75rem; border: 1px solid #cbd5e1; background: #fff; color: #475569; border-radius: 4px; text-decoration: none;">‹ Trước</a>
                        </c:if>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <c:choose>
                                <c:when test="${p == currentPage}">
                                    <span class="btn btn-xs" style="padding: 0.35rem 0.75rem; background: #ea580c; color: #fff; border: 1px solid #ea580c; font-weight: 700; border-radius: 4px;">${p}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="${ctx}/admin/employees?page=${p}${not empty filterQuery ? '&' : ''}${filterQuery}" class="btn btn-xs" style="padding: 0.35rem 0.75rem; border: 1px solid #cbd5e1; background: #fff; color: #475569; border-radius: 4px; text-decoration: none;">${p}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${ctx}/admin/employees?page=${currentPage + 1}${not empty filterQuery ? '&' : ''}${filterQuery}" class="btn btn-xs" style="padding: 0.35rem 0.75rem; border: 1px solid #cbd5e1; background: #fff; color: #475569; border-radius: 4px; text-decoration: none;">Sau ›</a>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Floating Toast Notification (Hiển thị khi có thông báo thực tế) -->
        <c:if test="${not empty successMessage}">
            <div id="toastNotification" class="toast-notification" style="position: fixed; bottom: 24px; right: 24px; z-index: 9999; background: #fff; border: 1px solid #bbf7d0; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); border-radius: 8px; padding: 0.85rem 1.1rem; display: flex; align-items: center; gap: 0.75rem; min-width: 320px;">
                <div style="width: 28px; height: 28px; border-radius: 50%; background: #dcfce7; color: #16a34a; display: flex; align-items: center; justify-content: center; font-size: 1rem;">
                    <i class="ti ti-check"></i>
                </div>
                <div style="flex: 1;">
                    <div style="font-weight: 700; color: #166534; font-size: 0.86rem;">Thông báo</div>
                    <div style="font-size: 0.76rem; color: #475569;"><c:out value="${successMessage}"/></div>
                </div>
                <button type="button" onclick="document.getElementById('toastNotification').style.display='none'" style="background: transparent; border: none; color: #94a3b8; font-size: 1.1rem; cursor: pointer; padding: 0;">
                    <i class="ti ti-x"></i>
                </button>
            </div>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div id="toastErrorNotification" class="toast-notification" style="position: fixed; bottom: 24px; right: 24px; z-index: 9999; background: #fff; border: 1px solid #fecaca; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1); border-radius: 8px; padding: 0.85rem 1.1rem; display: flex; align-items: center; gap: 0.75rem; min-width: 320px;">
                <div style="width: 28px; height: 28px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 1rem;">
                    <i class="ti ti-alert-circle"></i>
                </div>
                <div style="flex: 1;">
                    <div style="font-weight: 700; color: #991b1b; font-size: 0.86rem;">Lỗi</div>
                    <div style="font-size: 0.76rem; color: #475569;"><c:out value="${errorMessage}"/></div>
                </div>
                <button type="button" onclick="document.getElementById('toastErrorNotification').style.display='none'" style="background: transparent; border: none; color: #94a3b8; font-size: 1.1rem; cursor: pointer; padding: 0;">
                    <i class="ti ti-x"></i>
                </button>
            </div>
        </c:if>

    </main>

    <script>
        setTimeout(function() {
            var toast = document.getElementById('toastNotification') || document.getElementById('toastErrorNotification');
            if (toast) {
                toast.style.transition = 'opacity 0.5s ease';
                toast.style.opacity = '0';
                setTimeout(function() { toast.style.display = 'none'; }, 500);
            }
        }, 6000);
    </script>
</body>
</html>
