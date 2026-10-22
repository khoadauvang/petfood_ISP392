<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Yêu cầu hỗ trợ CSKH · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body class="admin-app">
    <%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

    <main class="admin-main">
        <!-- Top Title Bar -->
        <div class="page-header-row" style="margin-bottom: 1.25rem;">
            <div>
                <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.25rem;">
                    <h1 class="page-title" style="margin: 0;">YÊU CẦU HỖ TRỢ</h1>
                    <span class="badge" style="background: #fff0eb; color: #ff6a00; font-weight: 700; border: 1px solid #ffd8cc; font-size: 0.72rem; padding: 0.2rem 0.55rem;">PHÂN HỆ CSKH</span>
                </div>
                <p class="page-subtitle" style="margin: 0; color: #6c757d; font-size: 0.88rem;">Xem, phản hồi và quản lý các yêu cầu hỗ trợ khách hàng gửi qua hệ thống.</p>
            </div>
            <div style="display: flex; align-items: center; gap: 0.75rem;">
                <span class="badge" style="background: #fff8f3; color: #c05621; border: 1px solid #fed7aa; padding: 0.45rem 0.8rem; font-size: 0.82rem; font-weight: 600;">
                    <span style="display: inline-block; width: 7px; height: 7px; border-radius: 50%; background: #e53e3e; margin-right: 5px;"></span>
                    ${(supportCounts.NEW != null ? supportCounts.NEW : 0) + (supportCounts.IN_PROGRESS != null ? supportCounts.IN_PROGRESS : 0)} Yêu cầu chưa hoàn tất
                </span>
                <button type="button" class="btn btn-secondary btn-sm" onclick="location.reload()" style="background: #fff; border: 1px solid #dcdfe4; color: #4b5563;">
                    <i class="ti ti-refresh" style="margin-right: 4px;"></i> Làm mới
                </button>
            </div>
        </div>

        <!-- 4 KPI Cards -->
        <div class="dashboard-kpis" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-bottom: 1.25rem;">
            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                    <div style="font-size: 0.75rem; font-weight: 700; color: #64748b; letter-spacing: 0.5px; text-transform: uppercase;">YÊU CẦU MỚI</div>
                    <span style="background: #fee2e2; color: #dc2626; font-size: 0.72rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-weight: 700;">${supportCounts.NEW != null ? supportCounts.NEW : 0} mới</span>
                </div>
                <div style="font-size: 1.85rem; font-weight: 800; color: #1e293b; line-height: 1.1; margin-bottom: 0.4rem;">
                    ${supportCounts.NEW != null ? supportCounts.NEW : 0}
                </div>
                <div style="font-size: 0.78rem; color: #eab308; display: flex; align-items: center; gap: 4px; font-weight: 500;">
                    <i class="ti ti-clock"></i> Đang chờ tiếp nhận ban đầu
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                    <div style="font-size: 0.75rem; font-weight: 700; color: #64748b; letter-spacing: 0.5px; text-transform: uppercase;">ĐANG XỬ LÝ</div>
                    <span style="background: #ffedd5; color: #ea580c; font-size: 0.72rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-weight: 700;">Đang xử lý</span>
                </div>
                <div style="font-size: 1.85rem; font-weight: 800; color: #1e293b; line-height: 1.1; margin-bottom: 0.4rem;">
                    ${supportCounts.IN_PROGRESS != null ? supportCounts.IN_PROGRESS : 0}
                </div>
                <div style="font-size: 0.78rem; color: #64748b; display: flex; align-items: center; gap: 4px;">
                    <i class="ti ti-user-check"></i> Nhân viên đang tiếp nhận xử lý
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                    <div style="font-size: 0.75rem; font-weight: 700; color: #64748b; letter-spacing: 0.5px; text-transform: uppercase;">ĐÃ PHẢN HỒI</div>
                    <span style="background: #fef3c7; color: #b45309; font-size: 0.72rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-weight: 700;">Đã gửi phản hồi</span>
                </div>
                <div style="font-size: 1.85rem; font-weight: 800; color: #1e293b; line-height: 1.1; margin-bottom: 0.4rem;">
                    ${supportCounts.RESPONDED != null ? supportCounts.RESPONDED : 0}
                </div>
                <div style="font-size: 0.78rem; color: #64748b; display: flex; align-items: center; gap: 4px;">
                    <i class="ti ti-mail-forward"></i> Đã gửi email phản hồi khách
                </div>
            </div>

            <div class="kpi-card" style="background: #fff; border-radius: 10px; padding: 1.1rem; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                    <div style="font-size: 0.75rem; font-weight: 700; color: #64748b; letter-spacing: 0.5px; text-transform: uppercase;">ĐÃ ĐÓNG / SPAM</div>
                    <span style="background: #dcfce7; color: #15803d; font-size: 0.72rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-weight: 700;">Hoàn tất</span>
                </div>
                <div style="font-size: 1.85rem; font-weight: 800; color: #1e293b; line-height: 1.1; margin-bottom: 0.4rem;">
                    ${(supportCounts.CLOSED != null ? supportCounts.CLOSED : 0) + (supportCounts.SPAM != null ? supportCounts.SPAM : 0)}
                </div>
                <div style="font-size: 0.78rem; color: #15803d; display: flex; align-items: center; gap: 4px;">
                    <i class="ti ti-circle-check"></i> Đã đóng (${supportCounts.CLOSED != null ? supportCounts.CLOSED : 0}) · Spam (${supportCounts.SPAM != null ? supportCounts.SPAM : 0})
                </div>
            </div>
        </div>

        <!-- Filter Bar -->
        <div class="filter-panel" style="background: #fff; border-radius: 10px; padding: 1rem; border: 1px solid #eaeaea; margin-bottom: 1.25rem;">
            <form method="get" action="${ctx}/staff/support" style="display: flex; flex-wrap: wrap; gap: 0.75rem; align-items: flex-end;">
                <div style="flex: 2; min-width: 260px;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 0.35rem;">Tìm kiếm yêu cầu</label>
                    <div style="position: relative;">
                        <i class="ti ti-search" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: #94a3b8;"></i>
                        <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Tìm theo Mã yêu cầu, Khách hàng hoặc Email..." style="width: 100%; padding: 0.5rem 0.75rem 0.5rem 2.2rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.85rem;">
                    </div>
                </div>

                <div style="flex: 1; min-width: 160px;">
                    <label style="display: block; font-size: 0.72rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 0.35rem;">Trạng thái</label>
                    <select name="status" style="width: 100%; padding: 0.5rem; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.85rem; background: #fff;">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach var="s" items="${statuses}">
                            <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
                        </c:forEach>
                    </select>
                </div>

                <div style="display: flex; gap: 0.5rem;">
                    <button type="submit" class="btn btn-primary" style="background: #f59e0b; border-color: #d97706; color: #fff; font-weight: 600; padding: 0.5rem 1.2rem;">
                        <i class="ti ti-filter"></i> Lọc
                    </button>
                    <a href="${ctx}/staff/support" class="btn btn-secondary" style="background: #fff; border: 1px solid #cbd5e1; color: #64748b; padding: 0.5rem 0.75rem;" title="Đặt lại bộ lọc">
                        <i class="ti ti-rotate-2"></i>
                    </a>
                </div>
            </form>
        </div>

        <!-- Master-Detail Split Grid -->
        <div class="master-detail-grid" style="display: grid; grid-template-columns: 580px 1fr; gap: 1.25rem; align-items: start;">
            
            <!-- LEFT PANEL: Ticket Queue -->
            <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); overflow: hidden;">
                <div style="padding: 0.9rem 1.1rem; background: #fffcf8; border-bottom: 1px solid #f1e6d6; display: flex; justify-content: space-between; align-items: center;">
                    <div style="font-weight: 700; color: #1e293b; font-size: 0.92rem; display: flex; align-items: center; gap: 6px;">
                        <span>Hàng đợi yêu cầu hỗ trợ</span>
                        <span class="badge" style="background: #fef3c7; color: #92400e; font-size: 0.72rem; padding: 0.15rem 0.45rem;">${totalItems != null ? totalItems : 0} yêu cầu</span>
                    </div>
                </div>

                <div class="table-responsive" style="max-height: 650px; overflow-y: auto;">
                    <table class="data-table" style="width: 100%; border-collapse: collapse; font-size: 0.82rem;">
                        <thead>
                            <tr style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; text-align: left; color: #64748b; font-size: 0.72rem; text-transform: uppercase;">
                                <th style="padding: 0.65rem 0.85rem;">MÃ YÊU CẦU</th>
                                <th style="padding: 0.65rem 0.85rem;">KHÁCH HÀNG</th>
                                <th style="padding: 0.65rem 0.85rem;">NỘI DUNG</th>
                                <th style="padding: 0.65rem 0.6rem;">TRẠNG THÁI</th>
                                <th style="padding: 0.65rem 0.85rem; text-align: right;">THAO TÁC</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty tickets}">
                                    <c:forEach var="t" items="${tickets}">
                                        <tr style="border-bottom: 1px solid #f1f5f9; cursor: pointer;" onclick="window.location.href='${ctx}/staff/support/${t.id}'">
                                            <td style="padding: 0.75rem 0.85rem; font-weight: 700; color: #2563eb; white-space: nowrap;">
                                                #${t.ticketCode}
                                            </td>
                                            <td style="padding: 0.75rem 0.85rem;">
                                                <div style="font-weight: 600; color: #1e293b;"><c:out value="${empty t.contactName ? 'Khách vãng lai' : t.contactName}"/></div>
                                                <div style="font-size: 0.72rem; color: #94a3b8;"><c:out value="${t.contactEmail}"/></div>
                                            </td>
                                            <td style="padding: 0.75rem 0.85rem;">
                                                <div style="max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #334155;">
                                                    <c:out value="${t.contentPreview}"/>
                                                </div>
                                                <div style="font-size: 0.72rem; color: #94a3b8; margin-top: 2px;">
                                                    <i class="ti ti-clock"></i> ${t.createdAtText}
                                                </div>
                                            </td>
                                            <td style="padding: 0.75rem 0.6rem; white-space: nowrap;">
                                                <span class="badge ${t.status}" style="font-size: 0.7rem; padding: 0.15rem 0.4rem;">${t.status.label}</span>
                                            </td>
                                            <td style="padding: 0.75rem 0.85rem; text-align: right;">
                                                <a href="${ctx}/staff/support/${t.id}" class="btn btn-xs btn-primary" style="background: #f59e0b; border: none; color: #fff; font-size: 0.72rem; padding: 0.25rem 0.6rem; border-radius: 4px;">Xem</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 48px 20px; color: #94a3b8;">
                                            <i class="ti ti-inbox" style="font-size: 2.2rem; display: block; margin-bottom: 8px;"></i>
                                            <div style="font-weight: 600; color: #475569;">Không có yêu cầu hỗ trợ nào</div>
                                            <p style="font-size: 0.82rem; margin: 4px 0 0 0;">Hiện tại chưa có yêu cầu nào phù hợp với bộ lọc tìm kiếm.</p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination footer -->
                <div style="padding: 0.75rem 1rem; background: #fffcf8; border-top: 1px solid #f1e6d6; display: flex; justify-content: space-between; align-items: center; font-size: 0.78rem; color: #64748b;">
                    <span>Trang <b>${currentPage}</b> / <b>${totalPages > 0 ? totalPages : 1}</b> (Tổng <b>${totalItems != null ? totalItems : 0}</b>)</span>
                    <div style="display: flex; gap: 4px;">
                        <c:if test="${totalPages > 1}">
                            <c:if test="${currentPage > 1}"><a href="?${filterQuery}&page=${currentPage - 1}" class="btn btn-xs" style="padding: 0.2rem 0.5rem; border: 1px solid #cbd5e1; background: #fff; text-decoration: none; color: inherit;">‹</a></c:if>
                            <c:forEach begin="1" end="${totalPages}" var="n">
                                <c:choose>
                                    <c:when test="${n == currentPage}"><span class="btn btn-xs" style="padding: 0.2rem 0.5rem; background: #f59e0b; color: #fff; border: 1px solid #d97706; font-weight: 700;">${n}</span></c:when>
                                    <c:otherwise><a href="?${filterQuery}&page=${n}" class="btn btn-xs" style="padding: 0.2rem 0.5rem; border: 1px solid #cbd5e1; background: #fff; text-decoration: none; color: inherit;">${n}</a></c:otherwise>
                                </c:choose>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}"><a href="?${filterQuery}&page=${currentPage + 1}" class="btn btn-xs" style="padding: 0.2rem 0.5rem; border: 1px solid #cbd5e1; background: #fff; text-decoration: none; color: inherit;">›</a></c:if>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- RIGHT PANEL: Guidance & Detail Handler Card -->
            <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); padding: 32px 24px; text-align: center; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 480px;">
                <div style="width: 54px; height: 54px; border-radius: 50%; background: #fff7ed; color: #ea580c; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-bottom: 1rem;">
                    <i class="ti ti-messages"></i>
                </div>
                <h3 style="margin: 0 0 0.5rem 0; font-size: 1.1rem; font-weight: 700; color: #1e293b;">Quy trình xử lý Yêu cầu Hỗ trợ</h3>
                <p style="font-size: 0.85rem; color: #64748b; max-width: 380px; line-height: 1.5; margin: 0 0 1.5rem 0;">
                    Chọn một yêu cầu trong hàng đợi bên trái hoặc nhấn <b>Xem</b> để mở màn hình chi tiết, tiếp nhận và phản hồi email trực tiếp cho khách hàng.
                </p>

                <div style="text-align: left; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem 1.25rem; width: 100%; max-width: 380px; font-size: 0.8rem; line-height: 1.6; color: #334155;">
                    <div style="font-weight: 700; color: #0f172a; margin-bottom: 0.5rem; display: flex; align-items: center; gap: 6px;">
                        <i class="ti ti-info-circle" style="color: #f59e0b;"></i> Các bước xử lý CSKH:
                    </div>
                    <div><b>1. Tiếp nhận (NEW):</b> Khách hàng gửi yêu cầu hỗ trợ qua form chatbox.</div>
                    <div><b>2. Nhận xử lý (IN_PROGRESS):</b> Nhân viên bấm nhận phụ trách yêu cầu.</div>
                    <div><b>3. Phản hồi email (RESPONDED):</b> Soạn thảo nội dung và gửi qua SMTP.</div>
                    <div><b>4. Hoàn tất (CLOSED / SPAM):</b> Đóng yêu cầu khi đã giải quyết xong hoặc báo spam.</div>
                </div>

                <div style="margin-top: 1rem; font-size: 0.78rem; color: #94a3b8; max-width: 360px;">
                    <i class="ti ti-shield-check" style="color: #10b981;"></i> Mọi email gửi đi đều được lưu vết trong lịch sử trao đổi của hệ thống.
                </div>
            </div>

        </div>

    </main>
</body>
</html>
