<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<c:set var="rDetail" value="${selectedReturn}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý trả hàng · PetFood</title>
    <meta name="description" content="Theo dõi yêu cầu đổi trả hàng, xác nhận hàng hoàn và xử lý tái nhập kho.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .split-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 520px;
            gap: 20px;
            align-items: start;
        }
        @media (max-width: 1280px) {
            .split-layout { grid-template-columns: minmax(0, 1fr) 460px; }
        }
        @media (max-width: 1100px) {
            .split-layout { grid-template-columns: 1fr; }
        }
        .split-panel {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: var(--shadow-card);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }
        .return-table-wrapper {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
        }
        .return-table-wrapper::-webkit-scrollbar {
            height: 6px;
            width: 6px;
        }
        .return-table-wrapper::-webkit-scrollbar-track {
            background: #f8fafc;
        }
        .return-table-wrapper::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }
        .return-table-wrapper:hover::-webkit-scrollbar-thumb {
            background: #94a3b8;
        }
        .return-table {
            margin: 0;
            width: 100%;
            min-width: 780px;
            border-collapse: collapse;
            border: 0;
            box-shadow: none;
        }
        .return-table th {
            padding: 12px 10px;
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            font-size: 11px;
            font-weight: 800;
            color: #64748b;
            text-align: left;
            letter-spacing: .04em;
            text-transform: uppercase;
            white-space: nowrap;
        }
        .return-table th:first-child,
        .return-table td:first-child {
            padding-left: 18px;
        }
        .return-table th:last-child,
        .return-table td:last-child {
            padding-right: 18px;
        }
        .return-table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
        }
        .return-table-row {
            transition: all var(--transition);
            cursor: pointer;
        }
        .return-table-row:hover {
            background: #fff8f1 !important;
        }
        .selected-return-row {
            background: #fff7ee !important;
            border-left: 3px solid #ea580c !important;
        }
        .drawer-sticky {
            position: sticky;
            top: calc(var(--topbar-h) + 20px);
        }

        /* Stepper tiến trình 5 bước cân đối */
        .order-stepper {
            display: flex !important;
            align-items: flex-start !important;
            justify-content: space-between !important;
            margin: 14px 0 18px !important;
            position: relative !important;
            width: 100% !important;
        }
        .order-stepper::before {
            content: "" !important;
            position: absolute !important;
            left: 10% !important;
            right: 10% !important;
            top: 16px !important;
            height: 2px !important;
            background: #fed7aa !important;
            z-index: 1 !important;
        }
        .stepper-step {
            position: relative !important;
            z-index: 2 !important;
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            text-align: center !important;
            gap: 4px !important;
            flex: 1 1 0 !important;
            min-width: 0 !important;
            padding: 0 4px !important;
        }
        .stepper-circle {
            width: 32px !important;
            height: 32px !important;
            border-radius: 50% !important;
            background: #ffffff !important;
            border: 2px solid #fed7aa !important;
            display: grid !important;
            place-items: center !important;
            font-size: 13px !important;
            font-weight: 800 !important;
            color: #9a3412 !important;
            transition: all var(--transition) !important;
            flex-shrink: 0 !important;
            margin-bottom: 2px !important;
        }
        .stepper-step.completed .stepper-circle {
            background: #10b981 !important;
            border-color: #10b981 !important;
            color: #ffffff !important;
        }
        .stepper-step.active .stepper-circle {
            background: #ea580c !important;
            border-color: #ea580c !important;
            color: #ffffff !important;
            box-shadow: 0 0 0 4px #ffedd5 !important;
        }
        .stepper-label {
            font-size: 11.5px !important;
            font-weight: 700 !important;
            color: var(--text-main) !important;
            line-height: 1.3 !important;
            text-align: center !important;
            word-break: break-word !important;
            max-width: 100% !important;
            white-space: normal !important;
        }
        .stepper-step.active .stepper-label {
            color: #ea580c !important;
            font-weight: 800 !important;
        }
        .stepper-time {
            font-size: 10.5px !important;
            color: var(--text-placeholder) !important;
            line-height: 1.3 !important;
            text-align: center !important;
            word-break: break-word !important;
            max-width: 100% !important;
            overflow-wrap: anywhere !important;
            white-space: normal !important;
            display: block !important;
        }

        #return-drawer {
            position: sticky;
            top: calc(var(--topbar-h, 70px) + 16px);
            max-height: calc(100vh - var(--topbar-h, 70px) - 24px);
            overflow-y: auto;
            overflow-x: hidden;
            padding: 20px;
            border-radius: 18px;
        }
        #return-drawer::-webkit-scrollbar { width: 6px; }
        #return-drawer::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }

        .action-card {
            background: linear-gradient(180deg, #fffaf5 0%, #ffffff 100%);
            border: 1px solid #ffd8b8;
            border-radius: 14px;
            box-shadow: 0 2px 10px rgba(249, 115, 22, 0.06);
            padding: 16px;
            margin-bottom: 16px;
        }
        .action-card-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #c2410c;
            margin-bottom: 12px;
        }

        .urgent-banner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 14px;
            background: #fff7ed;
            border: 1px solid #fed7aa;
        }
        .urgent-left { display: flex; align-items: center; gap: 10px; }
        .urgent-icon { width: 32px; height: 32px; border-radius: 50%; display: grid; place-items: center; color: #fff; font-size: 16px; flex-shrink: 0; }
        .urgent-tag { display: inline-block; padding: 2px 8px; border-radius: 99px; font-size: 11px; font-weight: 700; margin-bottom: 3px; }
        .urgent-text { font-size: 12px; color: var(--text-main); }

        .info-card {
            background: #ffffff;
            border: 1px solid var(--line);
            border-radius: 14px;
            padding: 16px;
            margin-bottom: 16px;
        }
        .info-card-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: var(--text-logo);
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px dashed var(--line);
        }

        .user-avatar-badge {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: linear-gradient(135deg, #ffedd5 0%, #fed7aa 100%);
            color: #ea580c;
            font-weight: 800;
            font-size: 15px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
        }

        .bank-card {
            background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
            border: 1px solid #fed7aa;
            border-radius: 12px;
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .bank-num {
            font-family: 'Courier New', Courier, monospace;
            font-size: 15px;
            font-weight: 800;
            letter-spacing: 1px;
            color: #9a3412;
        }

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(90px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }
        .gallery-item {
            position: relative;
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid var(--line);
            background: #0f172a;
            aspect-ratio: 1 / 1;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .gallery-item img, .gallery-item video {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .audit-list { list-style: none; padding: 0; margin: 0; position: relative; }
        .audit-list::before { content: ""; position: absolute; left: 13px; top: 8px; bottom: 8px; width: 2px; background: var(--line); }
        .audit-item { position: relative; padding-left: 34px; margin-bottom: 12px; }
        .audit-item:last-child { margin-bottom: 0; }
        .audit-icon { position: absolute; left: 2px; top: 0; width: 22px; height: 22px; border-radius: 50%; background: #fff; border: 2px solid var(--color-primary); color: var(--color-primary); display: grid; place-items: center; font-size: 11px; z-index: 2; }
        .audit-item.done .audit-icon { background: #10b981; border-color: #10b981; color: #fff; }
        .audit-item.rejected .audit-icon { background: #ef4444; border-color: #ef4444; color: #fff; }
        .audit-title { font-size: 12px; font-weight: 700; color: var(--text-main); }
        .audit-time { font-size: 11px; color: var(--text-muted); margin-top: 2px; }

        .inspect-box {
            background: #ffffff;
            border: 1px solid #ffd8b8;
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 10px;
        }

        /* Phân trang dùng cấu trúc chuẩn tương tự Quản lý đơn hàng */
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ KHO &amp; ĐỔI TRẢ</span> <span class="sep">&gt;</span> <span class="current">QUẢN LÝ TRẢ HÀNG</span>
            </div>
            <h1>QUẢN LÝ TRẢ HÀNG</h1>
            <p class="page-sub">Theo dõi yêu cầu đổi trả hàng, xác nhận hàng hoàn và xử lý tái nhập kho.</p>
        </div>


    </div>

    <%-- 6 KPI Cards Screen 11 --%>
    <section class="grid" style="grid-template-columns: repeat(6, minmax(0, 1fr))">
        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Tổng yêu cầu</span><span class="kpi-ico orange"><i class="ti ti-files"></i></span></div>
            <div class="kpi-value">${returnCounts.total != null ? returnCounts.total : 0}</div>
            <div class="kpi-meta"><span class="badge orange">Tất cả kênh</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ duyệt</span><span class="kpi-ico yellow"><i class="ti ti-hourglass"></i></span></div>
            <div class="kpi-value" style="color:#d97706">${returnCounts.requested != null ? returnCounts.requested : 0}</div>
            <div class="kpi-meta"><span class="badge warn">Cần xem xét</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Đã duyệt</span><span class="kpi-ico blue"><i class="ti ti-truck-return"></i></span></div>
            <div class="kpi-value" style="color:#2563eb">${returnCounts.approved != null ? returnCounts.approved : 0}</div>
            <div class="kpi-meta"><span class="badge info">Chờ gửi/nhận hàng</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ kiểm tra hàng</span><span class="kpi-ico purple"><i class="ti ti-box"></i></span></div>
            <div class="kpi-value" style="color:#7c3aed">${returnCounts.received != null ? returnCounts.received : 0}</div>
            <div class="kpi-meta"><span class="badge purple">Đã đến kho · Chờ QC</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ hoàn tiền</span><span class="kpi-ico green"><i class="ti ti-cash"></i></span></div>
            <div class="kpi-value" style="color:#10b981">${returnCounts.inspected != null ? returnCounts.inspected : 0}</div>
            <div class="kpi-meta"><span class="badge ok">Đã kiểm tra đạt</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Đã hoàn tất</span><span class="kpi-ico green"><i class="ti ti-circle-check"></i></span></div>
            <div class="kpi-value" style="color:#10b981">${returnCounts.completed != null ? returnCounts.completed : 0}</div>
            <div class="kpi-meta"><span class="badge ok">Đã hoàn tiền &amp; xử lý kho</span></div>
        </div>
    </section>

    <%-- Filter bar Screen 11 --%>
    <form method="get" action="${ctx}/staff/returns" class="filters" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:200px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo Mã yêu cầu, Mã đơn hàng, Tên khách hàng... (Nhấn / để tìm)"
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="status" style="padding:9px 12px; border-radius:12px; border:1px solid var(--line); font-size:13px; background:#fff">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="s" items="${statuses}">
                <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>

        <select name="reason" style="padding:9px 12px; border-radius:12px; border:1px solid var(--line); font-size:13px; background:#fff">
            <option value="">Tất cả lý do trả hàng</option>
            <c:forEach var="r" items="${reasons}">
                <option value="${r}" ${filterReason == r ? 'selected' : ''}>${r.label}</option>
            </c:forEach>
        </select>

        <div style="display:inline-flex; align-items:center; gap:6px; background:#fff; border:1px solid var(--line); border-radius:12px; padding:5px 10px; font-size:13px">
            <i class="ti ti-calendar" style="color:var(--color-primary)"></i>
            <input type="date" name="from" value="<c:out value='${filterFrom}'/>" style="border:none; outline:none; font-size:12.5px; color:var(--text-main); background:transparent" title="Từ ngày">
            <span style="color:var(--text-muted)">→</span>
            <input type="date" name="to" value="<c:out value='${filterTo}'/>" style="border:none; outline:none; font-size:12.5px; color:var(--text-main); background:transparent" title="Đến ngày">
        </div>

        <div style="display:inline-flex; gap:6px; align-items:center">
            <button type="submit" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c; cursor:pointer"><i class="ti ti-filter"></i> Lọc</button>
            <a href="${ctx}/staff/returns" class="act-icon" title="Đặt lại bộ lọc" style="display:inline-flex; align-items:center; justify-content:center; width:38px; height:38px; border-radius:12px; border:1px solid var(--line); background:#fff; color:var(--text-main); text-decoration:none"><i class="ti ti-rotate"></i></a>
        </div>
    </form>

    <%-- Split Layout: Danh sách yêu cầu & Khung chi tiết tương tự Quản lý đơn hàng --%>
    <div class="split-layout">
        <%-- Trái: Bảng yêu cầu trả hàng --%>
        <div class="split-panel">
            <div class="split-head" style="padding:16px 20px; background:#fff; border-bottom:1px solid var(--line); display:flex; justify-content:space-between; align-items:center">
                <div>
                    <h3 style="margin:0; font-size:15px; font-weight:800; color:var(--text-logo)">
                        <i class="ti ti-list" style="color:var(--color-primary)"></i> DANH SÁCH YÊU CẦU TRẢ HÀNG
                        <span class="pill-badge orange">${totalItems != null ? totalItems : (returnCounts.total != null ? returnCounts.total : 0)} yêu cầu</span>
                    </h3>
                    <small style="color:var(--text-muted)">Hàng đợi thẩm định và hoàn tiền</small>
                </div>
                <div style="font-size:12px; color:var(--text-muted)">
                    Sắp xếp: <b style="color:var(--color-primary)">Mới nhất ↓</b>
                </div>
            </div>

            <div class="return-table-wrapper">
                <table class="return-table">
                    <thead>
                    <tr>
                        <th style="width:100px">MÃ YÊU CẦU</th>
                        <th style="width:100px">ĐƠN HÀNG</th>
                        <th>KHÁCH HÀNG</th>
                        <th style="width:130px">NGÀY GHI NHẬN</th>
                        <th style="width:140px">LÝ DO</th>
                        <th style="width:130px">TRẠNG THÁI</th>
                        <th style="width:50px; text-align:center">XEM</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty returns}">
                            <c:forEach var="r" items="${returns}" varStatus="st">
                                <c:set var="isSel" value="${r.id == selectedReturnId or (empty selectedReturnId and st.first)}"/>
                                <tr id="row-RR-${r.id}" class="return-table-row <c:if test='${isSel}'>selected-return-row</c:if>"
                                    onclick="selectReturnId(${r.id})"
                                    style="<c:if test='${isSel}'>background:#fff7ee;</c:if>">
                                    <td><b style="color:#ea580c; white-space:nowrap">#RR-00${r.id}</b></td>
                                    <td><a href="${ctx}/staff/orders?orderId=${r.orderId}" onclick="event.stopPropagation()" style="font-weight:700">#ORD-${r.orderId}</a></td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px; min-width:140px">
                                            <div class="avatar" style="width:28px; height:28px; font-size:11px; background:#fed7aa; color:#9a3412; flex-shrink:0">
                                                <c:out value="${empty r.customerName ? 'K' : r.customerName.substring(0, 1)}"/>
                                            </div>
                                            <div style="min-width:0">
                                                <b style="display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:140px" title="${r.customerName}">
                                                    <c:out value="${r.customerName}"/>
                                                </b>
                                                <small style="color:var(--text-muted); display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:140px" title="${r.customerEmail}">
                                                    <c:out value="${empty r.customerEmail ? 'N/A' : r.customerEmail}"/>
                                                </small>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="color:#475569; white-space:nowrap; font-size:12.5px">${r.createdAtText}</td>
                                    <td><span style="font-size:12.5px; white-space:nowrap">${r.reason.label}</span></td>
                                    <td style="white-space:nowrap">
                                        <span class="pill-badge ${r.status == 'REFUNDED' ? 'green' : (r.status == 'APPROVED' ? 'blue' : (r.status == 'RECEIVED' ? 'purple' : (r.status == 'INSPECTED' ? 'orange' : (r.status == 'REJECTED' ? 'red' : 'gold'))))}">
                                            ${r.status.label}
                                        </span>
                                    </td>
                                    <td style="text-align:center">
                                        <span class="act-icon" style="<c:if test='${isSel}'>color:#ea580c; border-color:#ea580c; background:#ffedd5;</c:if>" title="Xem chi tiết #RR-00${r.id}">
                                            <i class="ti ti-eye"></i>
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align:center; padding:36px; color:var(--text-muted)">
                                    <i class="ti ti-truck-return" style="font-size:28px; vertical-align:middle; margin-right:8px; color:#cbd5e1"></i>
                                    Không tìm thấy yêu cầu trả hàng nào phù hợp với bộ lọc.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- THANH PHÂN TRANG RÚT GỌN (Tương tự Quản lý đơn hàng) --%>
            <div class="panel-foot" style="padding:14px 20px; background:#fff; border-top:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px">
                <span style="font-size:13px; color:var(--text-muted)">
                    Hiển thị <c:out value="${not empty returns ? returns.size() : 0}"/> trong tổng số <b>${totalItems != null ? totalItems : 0}</b> yêu cầu
                </span>

                <c:if test="${totalPages > 1}">
                    <c:set var="pageUrlPrefix" value="?${not empty filterQuery ? filterQuery += '&' : ''}page="/>
                    <div class="pager" style="margin:0; display:flex; align-items:center; gap:4px; flex-wrap:wrap">
                        <%-- Nút Về trang đầu & Trang trước --%>
                        <c:if test="${currentPage > 1}">
                            <a href="${pageUrlPrefix}1" title="Về trang đầu" style="padding:0 9px; font-size:12px; font-weight:700">« Đầu</a>
                            <a href="${pageUrlPrefix}${currentPage - 1}" title="Trang trước" style="padding:0 9px; font-size:12px; font-weight:700">‹ Trước</a>
                        </c:if>

                        <%-- Giới hạn 3 trang trước và sau currentPage --%>
                        <c:set var="startPage" value="${currentPage - 3 > 1 ? currentPage - 3 : 1}"/>
                        <c:set var="endPage" value="${currentPage + 3 < totalPages ? currentPage + 3 : totalPages}"/>

                        <c:if test="${startPage > 1}">
                            <span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>
                        </c:if>

                        <c:forEach begin="${startPage}" end="${endPage}" var="n">
                            <c:choose>
                                <c:when test="${n == currentPage}">
                                    <strong>${n}</strong>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageUrlPrefix}${n}">${n}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${endPage < totalPages}">
                            <span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>
                        </c:if>

                        <%-- Nút Trang sau & Đến trang cuối --%>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageUrlPrefix}${currentPage + 1}" title="Trang tiếp theo" style="padding:0 9px; font-size:12px; font-weight:700">Sau ›</a>
                            <a href="${pageUrlPrefix}${totalPages}" title="Đến trang cuối" style="padding:0 9px; font-size:12px; font-weight:700">Cuối »</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>

        <%-- Phải: Detail Drawer Đầy đủ Thông tin Yêu cầu Trả hàng --%>
        <c:choose>
            <c:when test="${not empty rDetail}">
                <div class="panel drawer-sticky" id="return-drawer" style="box-shadow:var(--shadow-card); background:#ffffff">
                    <%-- 1. Drawer Header --%>
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px; border-bottom:1px solid var(--line); padding-bottom:14px">
                        <div>
                            <h3 style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin:0 0 4px">
                                <span id="detail-code">#RR-00${rDetail.id}</span>
                                <span id="detail-status" class="pill-badge ${rDetail.status == 'REFUNDED' ? 'green' : (rDetail.status == 'APPROVED' ? 'blue' : (rDetail.status == 'RECEIVED' ? 'purple' : (rDetail.status == 'INSPECTED' ? 'orange' : (rDetail.status == 'REJECTED' ? 'red' : 'gold'))))}">
                                    ● ${rDetail.status.label}
                                </span>
                                <span id="detail-payment-badge" class="pill-badge ${rDetail.paymentMethod.name() == 'VNPAY' ? 'green' : 'orange'}">
                                    ● ${rDetail.paymentMethod.label} (${rDetail.paymentStatus.label})
                                </span>
                            </h3>
                            <div class="detail-sub" id="detail-time" style="font-size:12px; color:var(--text-muted)">
                                Gửi lúc: <b>${rDetail.createdAtText}</b> · Đơn gốc: <a href="${ctx}/staff/orders?orderId=${rDetail.orderId}" style="color:#ea580c; font-weight:700">#ORD-${rDetail.orderId}</a> · Mã phiếu: #RR-00${rDetail.id}
                            </div>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px">
                            <button type="button" class="act-icon" title="Đóng khung" onclick="document.getElementById('return-drawer').style.display='none'"><i class="ti ti-x"></i></button>
                        </div>
                    </div>

                    <%-- 2. Banner trạng thái nghiệp vụ --%>
                    <div id="detail-alerts-container">
                        <c:choose>
                            <c:when test="${rDetail.status == 'REJECTED'}">
                                <div class="urgent-banner" style="background:#fef2f2; border-color:#fecaca">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#dc2626"><i class="ti ti-circle-x"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#fee2e2; color:#991b1b">Yêu cầu đã bị từ chối</span>
                                            <div class="urgent-text" style="color:#991b1b">
                                                Từ chối lúc <b>${rDetail.reviewedText}</b>. Lý do: <strong><c:out value="${rDetail.rejectReason}"/></strong>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${rDetail.status == 'REQUESTED'}">
                                <div class="urgent-banner">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#ea580c"><i class="ti ti-alert-triangle"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#ffedd5; color:#c2410c">Cần xem xét phê duyệt</span>
                                            <div class="urgent-text">
                                                Khách yêu cầu trả hàng: <strong>${rDetail.reason.label}</strong>. Vui lòng kiểm tra mô tả và bằng chứng.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${rDetail.status == 'APPROVED'}">
                                <div class="urgent-banner" style="background:#eff6ff; border-color:#bfdbfe">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#2563eb"><i class="ti ti-truck"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#dbeafe; color:#1e40af">Chờ nhận hàng trả về kho</span>
                                            <div class="urgent-text" style="color:#1e40af">
                                                <c:choose>
                                                    <c:when test="${rDetail.reason == 'REFUSED_DELIVERY'}">
                                                        Đơn hàng giao không thành công (${rDetail.reviewedText}). Kiện hàng đang trên đường chuyển hoàn, bấm "Xác nhận đã nhận hàng tại kho" khi kho nhận lại kiện hàng.
                                                    </c:when>
                                                    <c:otherwise>
                                                        Đã duyệt yêu cầu (${rDetail.reviewedText}). Khi kiện hàng tới sàn kho, bấm "Xác nhận đã nhận hàng".
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${rDetail.status == 'RECEIVED'}">
                                <div class="urgent-banner" style="background:#f5f3ff; border-color:#ddd6fe">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#7c3aed"><i class="ti ti-package"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#ede9fe; color:#5b21b6">Đã nhận hàng – Cần thẩm định tại kho</span>
                                            <div class="urgent-text" style="color:#5b21b6">
                                                Nhận lúc <b>${rDetail.receivedAtText}</b>. Vui lòng thẩm định tình trạng từng món bên dưới.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${rDetail.status == 'INSPECTED'}">
                                <div class="urgent-banner" style="background:#ecfdf5; border-color:#a7f3d0">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#059669"><i class="ti ti-cash"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#d1fae5; color:#065f46">Chờ chuyển khoản hoàn tiền</span>
                                            <div class="urgent-text" style="color:#065f46">
                                                Đã thẩm định hoàn tất. Tổng hoàn: <strong style="color:#047857">₫<fmt:formatNumber value="${rDetail.refundTotal}" type="number"/></strong>.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                            <c:when test="${rDetail.status == 'REFUNDED'}">
                                <div class="urgent-banner" style="background:#f0fdf4; border-color:#bbf7d0">
                                    <div class="urgent-left">
                                        <span class="urgent-icon" style="background:#16a34a"><i class="ti ti-circle-check"></i></span>
                                        <div>
                                            <span class="urgent-tag" style="background:#dcfce7; color:#15803d">Hoàn tất hoàn tiền</span>
                                            <div class="urgent-text" style="color:#15803d">
                                                Đã hoàn tất hoàn trả số tiền <strong>₫<fmt:formatNumber value="${rDetail.refundTotal}" type="number"/></strong> lúc <b>${rDetail.refundedAtText}</b>.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:when>
                        </c:choose>
                    </div>

                    <%-- 3. Stepper 5 bước theo BR-36 --%>
                    <c:set var="isRejected" value="${rDetail.status == 'REJECTED'}"/>
                    <c:set var="step2Cls" value="${isRejected ? 'active' : (rDetail.status == 'REQUESTED' ? 'active' : 'completed')}"/>
                    <c:set var="step3Cls" value="${rDetail.status == 'REQUESTED' or isRejected ? '' : (rDetail.status == 'APPROVED' ? 'active' : 'completed')}"/>
                    <c:set var="step4Cls" value="${rDetail.status == 'INSPECTED' or rDetail.status == 'REFUNDED' or rDetail.status == 'CLOSED' ? 'completed' : (rDetail.status == 'RECEIVED' ? 'active' : '')}"/>
                    <c:set var="step5Cls" value="${rDetail.status == 'REFUNDED' or rDetail.status == 'CLOSED' ? 'completed' : (rDetail.status == 'INSPECTED' ? 'active' : '')}"/>
                    <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:8px">
                        TIẾN TRÌNH XỬ LÝ ĐỔI TRẢ (BR-36)
                    </div>
                    <div class="order-stepper" id="return-stepper" style="margin-bottom:16px">
                        <div class="stepper-step completed">
                            <div class="stepper-circle"><i class="ti ti-send"></i></div>
                            <span class="stepper-label">Gửi yêu cầu</span>
                            <span class="stepper-time">${rDetail.createdAtText}</span>
                        </div>
                        <div class="stepper-step ${step2Cls}">
                            <div class="stepper-circle" style="${isRejected ? 'background:#ef4444; border-color:#ef4444; color:#fff;' : ''}">
                                <i class="ti ${isRejected ? 'ti-x' : 'ti-check'}"></i>
                            </div>
                            <span class="stepper-label">${isRejected ? 'Từ chối' : 'Duyệt yêu cầu'}</span>
                            <span class="stepper-time">
                                <c:choose>
                                    <c:when test="${not empty rDetail.reviewedText}">
                                        <c:choose>
                                            <c:when test="${rDetail.reviewedText.contains(' · ')}">
                                                ${rDetail.reviewedText.substring(0, rDetail.reviewedText.indexOf(' · '))}<br><small style="color:#64748b">${rDetail.reviewedText.substring(rDetail.reviewedText.indexOf(' · ') + 3)}</small>
                                            </c:when>
                                            <c:otherwise>${rDetail.reviewedText}</c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>${rDetail.status == 'REQUESTED' ? 'Đang chờ' : '--'}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="stepper-step ${step3Cls}">
                            <div class="stepper-circle"><i class="ti ti-package-import"></i></div>
                            <span class="stepper-label">Nhận hàng trả</span>
                            <span class="stepper-time">${not empty rDetail.receivedAtText ? rDetail.receivedAtText : (rDetail.status == 'APPROVED' ? (rDetail.reason == 'REFUSED_DELIVERY' ? 'Chờ nhận hàng' : 'Đang chờ gửi') : '--')}</span>
                        </div>
                        <div class="stepper-step ${step4Cls}">
                            <div class="stepper-circle"><i class="ti ti-clipboard-check"></i></div>
                            <span class="stepper-label">Thẩm định kho</span>
                            <span class="stepper-time">${not empty rDetail.inspectedByName ? rDetail.inspectedByName : (rDetail.status == 'RECEIVED' ? 'Đang thẩm định' : '--')}</span>
                        </div>
                        <div class="stepper-step ${step5Cls}">
                            <div class="stepper-circle"><i class="ti ti-cash"></i></div>
                            <span class="stepper-label">${rDetail.status == 'CLOSED' ? 'Đóng' : 'Hoàn tiền'}</span>
                            <span class="stepper-time">${not empty rDetail.refundedAtText ? rDetail.refundedAtText : (rDetail.status == 'INSPECTED' ? 'Chờ hoàn tiền' : '--')}</span>
                        </div>
                    </div>

                    <%-- 4. Thao tác xử lý nghiệp vụ ngay tại chỗ --%>
                    <div class="action-card" id="return-action-card">
                        <div class="action-card-title">
                            <i class="ti ti-settings"></i>
                            <span>THAO TÁC XỬ LÝ YÊU CẦU</span>
                        </div>
                        <div id="return-action-body">
                            <c:choose>
                                <c:when test="${rDetail.status == 'REQUESTED'}">
                                    <div style="margin-bottom:12px">
                                        <form method="post" action="${ctx}/staff/returns/${rDetail.id}/approve">
                                            ${csrf}
                                            <button type="submit" class="btn-flashsale" style="width:100%; font-size:13px; padding:10px; justify-content:center">
                                                <i class="ti ti-check" style="font-size:16px"></i>Duyệt chấp thuận yêu cầu trả hàng
                                            </button>
                                        </form>
                                    </div>
                                    <details style="border-top:1px dashed #ffd8b8; padding-top:10px">
                                        <summary style="font-size:12px; font-weight:700; color:#991b1b; cursor:pointer; list-style:none; display:flex; align-items:center; gap:6px">
                                            <i class="ti ti-ban"></i>Từ chối yêu cầu trả hàng này...
                                        </summary>
                                        <form method="post" action="${ctx}/staff/returns/${rDetail.id}/reject" style="margin-top:8px">
                                            ${csrf}
                                            <div style="margin-bottom:8px">
                                                <textarea name="rejectReason" maxlength="255" rows="2" required placeholder="Nhập lý do từ chối để thông báo đến khách hàng..." style="width:100%; padding:8px 10px; border-radius:8px; border:1px solid #fca5a5; font-size:12px"></textarea>
                                            </div>
                                            <button type="submit" class="btn-pill-danger" style="width:100%; justify-content:center; padding:8px !important; font-size:12px !important">
                                                <i class="ti ti-ban"></i>Xác nhận từ chối yêu cầu
                                            </button>
                                        </form>
                                    </details>
                                </c:when>
                                <c:when test="${rDetail.status == 'APPROVED'}">
                                    <div>
                                        <p style="font-size:12px; color:var(--text-muted); margin-bottom:8px">
                                            <c:choose>
                                                <c:when test="${rDetail.reason == 'REFUSED_DELIVERY'}">
                                                    Đơn hàng giao không thành công, shipper đang chuyển hoàn kiện hàng về kho. Bấm xác nhận khi kho đã nhận được kiện hàng từ đơn vị vận chuyển:
                                                </c:when>
                                                <c:otherwise>
                                                    Khách hàng đang gửi kiện hàng trả về sàn kho. Bấm xác nhận khi kho đã nhận được kiện hàng:
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                        <form method="post" action="${ctx}/staff/returns/${rDetail.id}/receive">
                                            ${csrf}
                                            <button type="submit" class="btn-flashsale" style="width:100%; font-size:13px; padding:10px; justify-content:center; background:linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%) !important">
                                                <i class="ti ti-package-import"></i>Xác nhận đã nhận hàng tại kho
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:when test="${rDetail.status == 'RECEIVED'}">
                                    <div>
                                        <div style="background:#f5f3ff; border:1px solid #ddd6fe; border-radius:10px; padding:10px; margin-bottom:12px; font-size:12px; color:#5b21b6">
                                            <i class="ti ti-info-circle"></i> Vui lòng thực hiện thẩm định từng món bên dưới rồi bấm <b>Lưu thẩm định kho</b>.
                                        </div>
                                        <form method="post" action="${ctx}/staff/returns/${rDetail.id}/inspect">
                                            ${csrf}
                                            <c:forEach var="l" items="${rDetail.lines}" varStatus="s">
                                                <div class="inspect-box">
                                                    <input type="hidden" name="lines[${s.index}].returnItemId" value="${l.returnItemId}">
                                                    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:8px; gap:8px">
                                                        <div>
                                                            <b style="font-size:13px; color:var(--text-main)"><c:out value="${l.productName}"/></b>
                                                            <div style="font-size:11px; color:var(--text-muted)">SL trả: <b>${l.quantity}</b> · Tình trạng: ${l.opened ? 'Đã mở bao bì' : 'Nguyên seal'}</div>
                                                        </div>
                                                        <label style="display:inline-flex; align-items:center; gap:6px; font-size:12px; font-weight:700; color:#065f46; background:#ecfdf5; padding:4px 8px; border-radius:6px; border:1px solid #a7f3d0">
                                                            <input type="checkbox" name="lines[${s.index}].refund" value="true" checked style="accent-color:#10b981">
                                                            Hoàn: ₫<fmt:formatNumber value="${l.maxRefund}" type="number"/>
                                                        </label>
                                                    </div>
                                                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; margin-bottom:6px">
                                                        <c:set var="cannotRestock" value="${l.opened or rDetail.reason == 'DAMAGED'}"/>
                                                        <c:forEach var="res" items="${inspectionResults}">
                                                            <c:set var="isRestockBlocked" value="${res == 'RESTOCKED' and cannotRestock}"/>
                                                            <label style="font-size:12px; font-weight:600; cursor:${isRestockBlocked ? 'not-allowed' : 'pointer'}; opacity:${isRestockBlocked ? '0.5' : '1'}; display:inline-flex; align-items:center; gap:4px"
                                                                   title="${isRestockBlocked ? 'Không được tái nhập kho sản phẩm đã mở bao bì hoặc hàng lỗi/hư hỏng (BR-38)' : ''}">
                                                                <input type="radio" name="lines[${s.index}].result" value="${res}" required
                                                                       ${isRestockBlocked ? 'disabled' : ''}
                                                                       ${cannotRestock and res == 'DISPOSED' ? 'checked' : ''}
                                                                       style="accent-color:#9333ea">
                                                                ${res.label}
                                                            </label>
                                                        </c:forEach>
                                                    </div>
                                                    <input type="text" name="lines[${s.index}].note" maxlength="255" placeholder="Ghi chú kiểm hàng..." style="width:100%; padding:6px 10px; border-radius:6px; border:1px solid var(--line); font-size:12px">
                                                </div>
                                            </c:forEach>
                                            <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px; font-size:13px; background:linear-gradient(135deg, #9333ea 0%, #7e22ce 100%) !important">
                                                <i class="ti ti-check"></i>Lưu kết quả thẩm định kho (QC)
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:when test="${rDetail.status == 'INSPECTED'}">
                                    <div>
                                        <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:10px; padding:12px; text-align:center; margin-bottom:10px">
                                            <span style="font-size:11px; color:#065f46; font-weight:700; text-transform:uppercase">Tổng tiền cần hoàn trả:</span>
                                            <div style="font-size:20px; font-weight:800; color:#047857">₫<fmt:formatNumber value="${rDetail.refundTotal}" type="number"/></div>
                                        </div>
                                        <form method="post" action="${ctx}/staff/returns/${rDetail.id}/refunded">
                                            ${csrf}
                                            <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px; font-size:13px; background:linear-gradient(135deg, #10b981 0%, #059669 100%) !important">
                                                <i class="ti ti-cash"></i>Xác nhận đã chuyển khoản hoàn tiền
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:when test="${rDetail.status == 'REFUNDED'}">
                                    <div style="display:flex; align-items:center; gap:8px; background:#e6f9ed; border:1px solid #bbf7d0; color:#166534; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">
                                        <i class="ti ti-circle-check" style="font-size:18px"></i>Yêu cầu đã hoàn tất hoàn tiền thành công.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="display:flex; align-items:center; gap:8px; background:#f3f4f6; border:1px solid #e5e7eb; color:#4b5563; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">
                                        <i class="ti ti-info-circle" style="font-size:18px"></i>Yêu cầu đã kết thúc quy trình xử lý.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- 5. Thông tin Khách hàng & Đơn hàng gốc --%>
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px">
                        <div class="info-card" style="margin:0">
                            <div class="info-card-title">
                                <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-user"></i>KHÁCH HÀNG</span>
                            </div>
                            <div style="display:flex; align-items:center; gap:10px; margin-bottom:8px">
                                <div class="user-avatar-badge" id="detail-cust-avatar">
                                    <c:out value="${empty rDetail.customerName ? 'K' : rDetail.customerName.substring(0, 1)}"/>
                                </div>
                                <div>
                                    <b style="font-size:13px" id="detail-cust-name"><c:out value="${rDetail.customerName}"/></b><br>
                                    <small style="color:var(--text-muted)">Khách hàng PetFood</small>
                                </div>
                            </div>
                            <div style="font-size:12px; color:var(--text-muted)" id="detail-cust-contact">
                                <div><i class="ti ti-phone"></i> <b><c:out value="${empty rDetail.customerPhone ? 'Chưa cập nhật' : rDetail.customerPhone}"/></b></div>
                                <div><i class="ti ti-mail"></i> <c:out value="${empty rDetail.customerEmail ? 'N/A' : rDetail.customerEmail}"/></div>
                            </div>
                        </div>

                        <div class="info-card" style="margin:0">
                            <div class="info-card-title">
                                <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-receipt"></i>ĐƠN GỐC</span>
                                <a href="${ctx}/staff/orders?orderId=${rDetail.orderId}" id="detail-order-view-link" style="font-size:11px; font-weight:700; color:#ea580c">Xem đơn ›</a>
                            </div>
                            <div style="font-size:13px; font-weight:800; color:#ea580c; margin-bottom:4px" id="detail-order-link">
                                #ORD-${rDetail.orderId}
                            </div>
                            <div style="font-size:12px; color:var(--text-muted)">
                                Thanh toán: <b id="detail-order-pay">${rDetail.paymentMethod.label}</b>
                            </div>
                            <div style="margin-top:6px">
                                <span class="pill-badge orange" style="font-size:11px" id="detail-reason-badge">
                                    ${rDetail.reason.label}
                                </span>
                            </div>
                        </div>
                    </div>

                    <%-- 6. Lý do và Mô tả chi tiết --%>
                    <div class="info-card">
                        <div class="info-card-title">
                            <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-message-2"></i>LÝ DO &amp; MÔ TẢ TRẢ HÀNG</span>
                        </div>
                        <div style="font-size:12.5px; font-style:italic; background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:10px; color:var(--text-main)" id="detail-desc-text">
                            "<c:out value="${empty rDetail.description ? 'Khách hàng không nhập thêm mô tả.' : rDetail.description}"/>"
                        </div>
                    </div>

                    <%-- 7. Tài khoản nhận hoàn tiền (nếu có) --%>
                    <div class="info-card" id="detail-bank-card" style="${empty rDetail.refundBankName ? 'display:none;' : ''}">
                        <div class="info-card-title">
                            <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-building-bank"></i>TÀI KHOẢN NHẬN HOÀN TIỀN</span>
                            <span class="pill-badge green" style="font-size:10px">NGÂN HÀNG</span>
                        </div>
                        <div class="bank-card">
                            <div style="display:flex; justify-content:space-between; align-items:center">
                                <span style="font-size:11px; font-weight:700; color:#c2410c">NGÂN HÀNG:</span>
                                <b style="font-size:13px; color:#7c2d12" id="detail-bank-name"><c:out value="${rDetail.refundBankName}"/></b>
                            </div>
                            <div>
                                <span style="font-size:11px; color:#9a3412">SỐ TÀI KHOẢN:</span>
                                <div class="bank-num" id="detail-bank-acc"><c:out value="${rDetail.refundAccountNo}"/></div>
                            </div>
                            <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px dashed #fed7aa; padding-top:6px">
                                <span style="font-size:11px; color:#9a3412">CHỦ TÀI KHOẢN:</span>
                                <b style="font-size:12px; color:#7c2d12; text-transform:uppercase" id="detail-bank-holder"><c:out value="${rDetail.refundAccountHolder}"/></b>
                            </div>
                        </div>
                    </div>

                    <%-- 8. Danh sách sản phẩm trả --%>
                    <div class="info-card">
                        <div class="info-card-title">
                            <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-box"></i>SẢN PHẨM HOÀN TRẢ (<span id="detail-item-count">${rDetail.lines.size()}</span> MẶT HÀNG)</span>
                        </div>
                        <div id="detail-items-list" style="display:flex; flex-direction:column; gap:10px">
                            <c:forEach var="l" items="${rDetail.lines}">
                                <div style="display:flex; align-items:center; justify-content:space-between; gap:10px; border-bottom:1px solid #f8f1eb; padding-bottom:8px">
                                    <div>
                                        <b style="font-size:13px; color:var(--text-main)"><c:out value="${l.productName}"/></b>
                                        <div style="font-size:11px; color:var(--text-muted); display:flex; gap:6px; align-items:center; margin-top:2px">
                                            <span>SL: <b style="color:#ea580c">${l.quantity}</b>/${l.orderedQty}</span>
                                            <span>·</span>
                                            <span class="pill-badge ${l.opened ? 'gold' : 'green'}" style="font-size:10px; padding:1px 6px">${l.opened ? 'Đã mở' : 'Nguyên seal'}</span>
                                        </div>
                                    </div>
                                    <div style="text-align:right">
                                        <div style="font-size:11px; color:var(--text-muted)">Trần hoàn</div>
                                        <b style="font-size:13px; color:#16a34a">₫<fmt:formatNumber value="${l.maxRefund}" type="number"/></b>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <%-- 9. Hình ảnh / Video bằng chứng --%>
                    <div class="info-card" id="detail-media-card" style="${empty rDetail.media ? 'display:none;' : ''}">
                        <div class="info-card-title">
                            <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-photo"></i>BẰNG CHỨNG HÌNH ẢNH / VIDEO</span>
                            <span class="badge gray" id="detail-media-count">${rDetail.media.size()} tệp</span>
                        </div>
                        <div class="gallery-grid" id="detail-media-grid">
                            <c:forEach var="m" items="${rDetail.media}">
                                <div class="gallery-item">
                                    <c:choose>
                                        <c:when test="${m.video}">
                                            <video src="${ctx}<c:out value='${m.url}'/>" controls preload="metadata"></video>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${ctx}<c:out value='${m.url}'/>" target="_blank" style="display:block; width:100%; height:100%">
                                                <img src="${ctx}<c:out value='${m.url}'/>" alt="Bằng chứng trả hàng">
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <%-- 10. Nhật ký tiến trình --%>
                    <div class="info-card" style="margin-bottom:0">
                        <div class="info-card-title">
                            <span style="display:flex; align-items:center; gap:6px"><i class="ti ti-history"></i>NHẬT KÝ TIẾN TRÌNH</span>
                        </div>
                        <ul class="audit-list" id="detail-audit-list">
                            <li class="audit-item done">
                                <div class="audit-icon"><i class="ti ti-check"></i></div>
                                <div class="audit-title">Khách hàng gửi yêu cầu trả hàng</div>
                                <div class="audit-time">${rDetail.createdAtText}</div>
                            </li>
                            <c:if test="${not empty rDetail.reviewedText}">
                                <li class="audit-item ${rDetail.status == 'REJECTED' ? 'rejected' : 'done'}">
                                    <div class="audit-icon"><i class="ti ${rDetail.status == 'REJECTED' ? 'ti-x' : 'ti-check'}"></i></div>
                                    <div class="audit-title">${rDetail.status == 'REJECTED' ? 'Nhân viên từ chối' : 'Nhân viên phê duyệt'}</div>
                                    <div class="audit-time">${rDetail.reviewedText}</div>
                                </li>
                            </c:if>
                            <c:if test="${not empty rDetail.receivedAtText}">
                                <li class="audit-item done">
                                    <div class="audit-icon"><i class="ti ti-check"></i></div>
                                    <div class="audit-title">Đã nhận kiện hàng tại kho</div>
                                    <div class="audit-time">${rDetail.receivedAtText}</div>
                                </li>
                            </c:if>
                            <c:if test="${not empty rDetail.inspectedByName}">
                                <li class="audit-item done">
                                    <div class="audit-icon"><i class="ti ti-check"></i></div>
                                    <div class="audit-title">Thẩm định kho QC: <b>${rDetail.inspectedByName}</b></div>
                                </li>
                            </c:if>
                            <c:if test="${not empty rDetail.refundedAtText}">
                                <li class="audit-item done">
                                    <div class="audit-icon"><i class="ti ti-cash"></i></div>
                                    <div class="audit-title">Hoàn tất hoàn tiền</div>
                                    <div class="audit-time">${rDetail.refundedAtText}</div>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Trạng thái rỗng khi chưa có yêu cầu nào --%>
                <div class="detail-card" style="display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:40px 24px; min-height:450px; background:#fff; border-radius:14px; border:1px solid var(--line); color:var(--text-muted)">
                    <div class="kpi-ico orange" style="width:54px; height:54px; font-size:24px; margin-bottom:16px"><i class="ti ti-clipboard-list"></i></div>
                    <h3 style="margin:0 0 8px 0; color:var(--text-main); font-size:16px">Quy trình xử lý trả hàng</h3>
                    <p style="font-size:13px; max-width:320px; line-height:1.5; margin:0 0 20px 0">
                        Chọn một yêu cầu trả hàng ở danh sách bên trái để xem đầy đủ chi tiết và thao tác duyệt/thẩm định trực tiếp.
                    </p>
                    <div style="text-align:left; font-size:12px; background:#fffaf5; border:1px solid #fed7aa; border-radius:10px; padding:12px 16px; width:100%; max-width:340px; color:#9a3412">
                        <b style="display:block; margin-bottom:6px">5 Bước xử lý trả hàng:</b>
                        <div>① Duyệt yêu cầu từ khách</div>
                        <div>② Xác nhận nhận kiện hàng hoàn</div>
                        <div>③ Thẩm định chất lượng (QC)</div>
                        <div>④ Xử lý tồn kho (Tái nhập / Tiêu hủy)</div>
                        <div>⑤ Xác nhận hoàn tiền đơn hàng</div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<script>
    const ctx = '${ctx}';
    const csrfToken = '${_csrf.token}';
    const csrfParam = '${_csrf.parameterName}';

    function formatNumber(num) {
        if (!num && num !== 0) return '0';
        return Number(num).toLocaleString('vi-VN');
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function selectReturnId(retId) {
        document.querySelectorAll('.return-table-row').forEach(tr => {
            tr.classList.remove('selected-return-row');
            tr.style.background = '';
            const actIcon = tr.querySelector('.act-icon');
            if (actIcon) {
                actIcon.style.color = '';
                actIcon.style.borderColor = '';
                actIcon.style.background = '';
            }
        });

        const curTr = document.getElementById('row-RR-' + retId);
        if (curTr) {
            curTr.classList.add('selected-return-row');
            curTr.style.background = '#fff7ee';
            const actIcon = curTr.querySelector('.act-icon');
            if (actIcon) {
                actIcon.style.color = '#ea580c';
                actIcon.style.borderColor = '#ea580c';
                actIcon.style.background = '#ffedd5';
            }
        }

        const url = new URL(window.location.href);
        url.searchParams.set('returnId', retId);
        window.history.replaceState({}, '', url.toString());

        const drawer = document.getElementById('return-drawer');
        if (drawer) {
            drawer.style.display = 'block';
            fetch(ctx + '/staff/returns/' + retId + '/data')
                .then(res => {
                    if (!res.ok) throw new Error('Network error');
                    return res.json();
                })
                .then(data => {
                    renderFullReturnDetail(data);
                })
                .catch(err => {
                    console.error('Error fetching return detail:', err);
                });
        }
    }

    function reasonLabel(reason) {
        if (reason === 'DAMAGED') return 'Sản phẩm lỗi / hư hỏng';
        if (reason === 'EXPIRY_ISSUE') return 'Hạn dùng thấp hơn cam kết / hết hạn';
        if (reason === 'WRONG_OR_MISSING') return 'Giao sai / thiếu hàng';
        if (reason === 'REFUSED_DELIVERY') return 'Khách không nhận hàng';
        return reason || '';
    }

    function renderFullReturnDetail(ret) {
        if (!ret) return;
        const csrfInputHtml = csrfParam ? ('<input type="hidden" name="' + escapeHtml(csrfParam) + '" value="' + escapeHtml(csrfToken) + '">') : '';

        // Header
        const codeEl = document.getElementById('detail-code');
        if (codeEl) codeEl.innerText = '#RR-00' + ret.id;

        const statusEl = document.getElementById('detail-status');
        if (statusEl) {
            let pillCls = 'gold';
            let label = ret.status;
            if (ret.status === 'REFUNDED') { pillCls = 'green'; label = 'Đã hoàn tiền'; }
            else if (ret.status === 'APPROVED') { pillCls = 'blue'; label = 'Đã duyệt'; }
            else if (ret.status === 'RECEIVED') { pillCls = 'purple'; label = 'Đã nhận hàng'; }
            else if (ret.status === 'INSPECTED') { pillCls = 'orange'; label = 'Đã thẩm định'; }
            else if (ret.status === 'REJECTED') { pillCls = 'red'; label = 'Từ chối'; }
            else if (ret.status === 'CLOSED') { pillCls = 'gray'; label = 'Đã đóng'; }
            else if (ret.status === 'REQUESTED') { pillCls = 'gold'; label = 'Chờ duyệt'; }
            statusEl.className = 'pill-badge ' + pillCls;
            statusEl.innerText = '● ' + label;
        }

        const payBadgeEl = document.getElementById('detail-payment-badge');
        if (payBadgeEl) {
            let isVnPay = (ret.paymentMethod === 'VNPAY');
            let payLabel = isVnPay ? 'VNPay' : 'COD';
            let payStatusLabel = ret.paymentStatus === 'PAID' ? 'Đã thanh toán' : (ret.paymentStatus === 'REFUNDED' ? 'Đã hoàn tiền' : 'Chưa thanh toán');
            payBadgeEl.className = 'pill-badge ' + (isVnPay ? 'green' : 'orange');
            payBadgeEl.innerText = '● ' + payLabel + ' (' + payStatusLabel + ')';
        }

        const timeEl = document.getElementById('detail-time');
        if (timeEl) {
            timeEl.innerHTML = 'Gửi lúc: <b>' + escapeHtml(ret.createdAtText || '--') + '</b> · Đơn gốc: <a href="' + ctx + '/staff/orders?orderId=' + ret.orderId + '" style="color:#ea580c; font-weight:700">#ORD-' + ret.orderId + '</a> · Mã phiếu: #RR-00' + ret.id;
        }

        // Urgent Banner (#detail-alerts-container)
        const alertsEl = document.getElementById('detail-alerts-container');
        if (alertsEl) {
            let alertHtml = '';
            if (ret.status === 'REJECTED') {
                alertHtml = '<div class="urgent-banner" style="background:#fef2f2; border-color:#fecaca"><div class="urgent-left"><span class="urgent-icon" style="background:#dc2626"><i class="ti ti-circle-x"></i></span><div><span class="urgent-tag" style="background:#fee2e2; color:#991b1b">Yêu cầu đã bị từ chối</span><div class="urgent-text" style="color:#991b1b">Từ chối lúc <b>' + escapeHtml(ret.reviewedText || '') + '</b>. Lý do: <strong>' + escapeHtml(ret.rejectReason || '') + '</strong></div></div></div></div>';
            } else if (ret.status === 'REQUESTED') {
                alertHtml = '<div class="urgent-banner"><div class="urgent-left"><span class="urgent-icon" style="background:#ea580c"><i class="ti ti-alert-triangle"></i></span><div><span class="urgent-tag" style="background:#ffedd5; color:#c2410c">Cần xem xét phê duyệt</span><div class="urgent-text">Khách yêu cầu trả hàng: <strong>' + escapeHtml(reasonLabel(ret.reason)) + '</strong>. Vui lòng kiểm tra mô tả và bằng chứng.</div></div></div></div>';
            } else if (ret.status === 'APPROVED') {
                const bannerMsg = (ret.reason === 'REFUSED_DELIVERY')
                    ? 'Đơn hàng giao không thành công (' + escapeHtml(ret.reviewedText || '') + '). Kiện hàng đang trên đường chuyển hoàn, bấm "Xác nhận đã nhận hàng tại kho" khi kho nhận lại kiện hàng.'
                    : 'Đã duyệt yêu cầu (' + escapeHtml(ret.reviewedText || '') + '). Khi kiện hàng tới sàn kho, bấm "Xác nhận đã nhận hàng".';
                alertHtml = '<div class="urgent-banner" style="background:#eff6ff; border-color:#bfdbfe"><div class="urgent-left"><span class="urgent-icon" style="background:#2563eb"><i class="ti ti-truck"></i></span><div><span class="urgent-tag" style="background:#dbeafe; color:#1e40af">Chờ nhận hàng trả về kho</span><div class="urgent-text" style="color:#1e40af">' + bannerMsg + '</div></div></div></div>';
            } else if (ret.status === 'RECEIVED') {
                alertHtml = '<div class="urgent-banner" style="background:#f5f3ff; border-color:#ddd6fe"><div class="urgent-left"><span class="urgent-icon" style="background:#7c3aed"><i class="ti ti-package"></i></span><div><span class="urgent-tag" style="background:#ede9fe; color:#5b21b6">Đã nhận hàng – Cần thẩm định tại kho</span><div class="urgent-text" style="color:#5b21b6">Nhận lúc <b>' + escapeHtml(ret.receivedAtText || '') + '</b>. Vui lòng thẩm định tình trạng từng món bên dưới.</div></div></div></div>';
            } else if (ret.status === 'INSPECTED') {
                alertHtml = '<div class="urgent-banner" style="background:#ecfdf5; border-color:#a7f3d0"><div class="urgent-left"><span class="urgent-icon" style="background:#059669"><i class="ti ti-cash"></i></span><div><span class="urgent-tag" style="background:#d1fae5; color:#065f46">Chờ chuyển khoản hoàn tiền</span><div class="urgent-text" style="color:#065f46">Đã thẩm định hoàn tất. Tổng hoàn: <strong style="color:#047857">₫' + formatNumber(ret.refundTotal) + '</strong>.</div></div></div></div>';
            } else if (ret.status === 'REFUNDED') {
                alertHtml = '<div class="urgent-banner" style="background:#f0fdf4; border-color:#bbf7d0"><div class="urgent-left"><span class="urgent-icon" style="background:#16a34a"><i class="ti ti-circle-check"></i></span><div><span class="urgent-tag" style="background:#dcfce7; color:#15803d">Hoàn tất hoàn tiền</span><div class="urgent-text" style="color:#15803d">Đã hoàn tất hoàn trả số tiền <strong>₫' + formatNumber(ret.refundTotal) + '</strong> lúc <b>' + escapeHtml(ret.refundedAtText || '') + '</b>.</div></div></div></div>';
            }
            alertsEl.innerHTML = alertHtml;
        }

        // Stepper
        const stepperEl = document.getElementById('return-stepper');
        if (stepperEl) {
            const isRej = (ret.status === 'REJECTED');
            const step2Cls = isRej ? 'active' : (ret.status === 'REQUESTED' ? 'active' : 'completed');
            const step3Cls = (ret.status === 'REQUESTED' || isRej) ? '' : (ret.status === 'APPROVED' ? 'active' : 'completed');
            const step4Cls = (ret.status === 'INSPECTED' || ret.status === 'REFUNDED' || ret.status === 'CLOSED') ? 'completed' : (ret.status === 'RECEIVED' ? 'active' : '');
            const step5Cls = (ret.status === 'REFUNDED' || ret.status === 'CLOSED') ? 'completed' : (ret.status === 'INSPECTED' ? 'active' : '');

            let revTimeFormatted = escapeHtml(ret.reviewedText || (ret.status === 'REQUESTED' ? 'Đang chờ' : '--'));
            if (ret.reviewedText && ret.reviewedText.indexOf(' · ') !== -1) {
                const rParts = ret.reviewedText.split(' · ');
                revTimeFormatted = escapeHtml(rParts[0]) + '<br><small style="color:#64748b">' + escapeHtml(rParts[1]) + '</small>';
            }

            stepperEl.innerHTML = 
                '<div class="stepper-step completed">' +
                '  <div class="stepper-circle"><i class="ti ti-send"></i></div>' +
                '  <span class="stepper-label">Gửi yêu cầu</span>' +
                '  <span class="stepper-time">' + escapeHtml(ret.createdAtText || '--') + '</span>' +
                '</div>' +
                '<div class="stepper-step ' + step2Cls + '">' +
                '  <div class="stepper-circle" style="' + (isRej ? 'background:#ef4444; border-color:#ef4444; color:#fff;' : '') + '">' +
                '    <i class="ti ' + (isRej ? 'ti-x' : 'ti-check') + '"></i>' +
                '  </div>' +
                '  <span class="stepper-label">' + (isRej ? 'Từ chối' : 'Duyệt yêu cầu') + '</span>' +
                '  <span class="stepper-time">' + revTimeFormatted + '</span>' +
                '</div>' +
                '<div class="stepper-step ' + step3Cls + '">' +
                '  <div class="stepper-circle"><i class="ti ti-package-import"></i></div>' +
                '  <span class="stepper-label">Nhận hàng trả</span>' +
                '  <span class="stepper-time">' + escapeHtml(ret.receivedAtText || (ret.status === 'APPROVED' ? (ret.reason === 'REFUSED_DELIVERY' ? 'Chờ nhận hàng' : 'Đang chờ gửi') : '--')) + '</span>' +
                '</div>' +
                '<div class="stepper-step ' + step4Cls + '">' +
                '  <div class="stepper-circle"><i class="ti ti-clipboard-check"></i></div>' +
                '  <span class="stepper-label">Thẩm định kho</span>' +
                '  <span class="stepper-time">' + escapeHtml(ret.inspectedByName || (ret.status === 'RECEIVED' ? 'Đang thẩm định' : '--')) + '</span>' +
                '</div>' +
                '<div class="stepper-step ' + step5Cls + '">' +
                '  <div class="stepper-circle"><i class="ti ti-cash"></i></div>' +
                '  <span class="stepper-label">' + (ret.status === 'CLOSED' ? 'Đóng' : 'Hoàn tiền') + '</span>' +
                '  <span class="stepper-time">' + escapeHtml(ret.refundedAtText || (ret.status === 'INSPECTED' ? 'Chờ hoàn tiền' : '--')) + '</span>' +
                '</div>';
        }

        // Action body (#return-action-body)
        const actionBodyEl = document.getElementById('return-action-body');
        if (actionBodyEl) {
            if (ret.status === 'REQUESTED') {
                actionBodyEl.innerHTML =
                    '<div style="margin-bottom:12px">' +
                    '  <form method="post" action="' + ctx + '/staff/returns/' + ret.id + '/approve">' +
                         csrfInputHtml +
                    '    <button type="submit" class="btn-flashsale" style="width:100%; font-size:13px; padding:10px; justify-content:center">' +
                    '      <i class="ti ti-check" style="font-size:16px"></i>Duyệt chấp thuận yêu cầu trả hàng' +
                    '    </button>' +
                    '  </form>' +
                    '</div>' +
                    '<details style="border-top:1px dashed #ffd8b8; padding-top:10px">' +
                    '  <summary style="font-size:12px; font-weight:700; color:#991b1b; cursor:pointer; list-style:none; display:flex; align-items:center; gap:6px">' +
                    '    <i class="ti ti-ban"></i>Từ chối yêu cầu trả hàng này...' +
                    '  </summary>' +
                    '  <form method="post" action="' + ctx + '/staff/returns/' + ret.id + '/reject" style="margin-top:8px">' +
                         csrfInputHtml +
                    '    <div style="margin-bottom:8px">' +
                    '      <textarea name="rejectReason" maxlength="255" rows="2" required placeholder="Nhập lý do từ chối để thông báo đến khách hàng..." style="width:100%; padding:8px 10px; border-radius:8px; border:1px solid #fca5a5; font-size:12px"></textarea>' +
                    '    </div>' +
                    '    <button type="submit" class="btn-pill-danger" style="width:100%; justify-content:center; padding:8px !important; font-size:12px !important">' +
                    '      <i class="ti ti-ban"></i>Xác nhận từ chối yêu cầu' +
                    '    </button>' +
                    '  </form>' +
                    '</details>';
            } else if (ret.status === 'APPROVED') {
                const receiveNotice = (ret.reason === 'REFUSED_DELIVERY')
                    ? 'Đơn hàng giao không thành công, shipper đang chuyển hoàn kiện hàng về kho. Bấm xác nhận khi kho đã nhận được kiện hàng từ đơn vị vận chuyển:'
                    : 'Khách hàng đang gửi kiện hàng trả về sàn kho. Bấm xác nhận khi kho đã nhận được kiện hàng:';
                actionBodyEl.innerHTML =
                    '<div>' +
                    '  <p style="font-size:12px; color:var(--text-muted); margin-bottom:8px">' +
                         receiveNotice +
                    '  </p>' +
                    '  <form method="post" action="' + ctx + '/staff/returns/' + ret.id + '/receive">' +
                         csrfInputHtml +
                    '    <button type="submit" class="btn-flashsale" style="width:100%; font-size:13px; padding:10px; justify-content:center; background:linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%) !important">' +
                    '      <i class="ti ti-package-import"></i>Xác nhận đã nhận hàng tại kho' +
                    '    </button>' +
                    '  </form>' +
                    '</div>';
            } else if (ret.status === 'RECEIVED') {
                let inspectLinesHtml = '';
                (ret.lines || []).forEach((l, idx) => {
                    const cannotRestock = !!(l.opened || ret.reason === 'DAMAGED');
                    inspectLinesHtml +=
                        '<div class="inspect-box">' +
                        '  <input type="hidden" name="lines[' + idx + '].returnItemId" value="' + l.returnItemId + '">' +
                        '  <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:8px; gap:8px">' +
                        '    <div>' +
                        '      <b style="font-size:13px; color:var(--text-main)">' + escapeHtml(l.productName) + '</b>' +
                        '      <div style="font-size:11px; color:var(--text-muted)">SL trả: <b>' + l.quantity + '</b> · Tình trạng: ' + (l.opened ? 'Đã mở bao bì' : 'Nguyên seal') + '</div>' +
                        '    </div>' +
                        '    <label style="display:inline-flex; align-items:center; gap:6px; font-size:12px; font-weight:700; color:#065f46; background:#ecfdf5; padding:4px 8px; border-radius:6px; border:1px solid #a7f3d0">' +
                        '      <input type="checkbox" name="lines[' + idx + '].refund" value="true" checked style="accent-color:#10b981">' +
                        '      Hoàn: ₫' + formatNumber(l.maxRefund) +
                        '    </label>' +
                        '  </div>' +
                        '  <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; margin-bottom:6px">' +
                        '    <label style="font-size:12px; font-weight:600; cursor:' + (cannotRestock ? 'not-allowed' : 'pointer') + '; opacity:' + (cannotRestock ? '0.5' : '1') + '; display:inline-flex; align-items:center; gap:4px" title="' + (cannotRestock ? 'Không được tái nhập kho sản phẩm đã mở bao bì hoặc hàng lỗi/hư hỏng (BR-38)' : '') + '">' +
                        '      <input type="radio" name="lines[' + idx + '].result" value="RESTOCKED" required ' + (cannotRestock ? 'disabled' : '') + ' style="accent-color:#9333ea">' +
                        '      Tái nhập về lô gốc' +
                        '    </label>' +
                        '    <label style="font-size:12px; font-weight:600; cursor:pointer; display:inline-flex; align-items:center; gap:4px">' +
                        '      <input type="radio" name="lines[' + idx + '].result" value="DISPOSED" required ' + (cannotRestock ? 'checked' : '') + ' style="accent-color:#9333ea">' +
                        '      Tiêu huỷ' +
                        '    </label>' +
                        '  </div>' +
                        '  <input type="text" name="lines[' + idx + '].note" maxlength="255" placeholder="Ghi chú kiểm hàng..." style="width:100%; padding:6px 10px; border-radius:6px; border:1px solid var(--line); font-size:12px">' +
                        '</div>';
                });
                actionBodyEl.innerHTML =
                    '<div>' +
                    '  <div style="background:#f5f3ff; border:1px solid #ddd6fe; border-radius:10px; padding:10px; margin-bottom:12px; font-size:12px; color:#5b21b6">' +
                    '    <i class="ti ti-info-circle"></i> Vui lòng thực hiện thẩm định từng món bên dưới rồi bấm <b>Lưu thẩm định kho</b>.' +
                    '  </div>' +
                    '  <form method="post" action="' + ctx + '/staff/returns/' + ret.id + '/inspect">' +
                         csrfInputHtml +
                         inspectLinesHtml +
                    '    <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px; font-size:13px; background:linear-gradient(135deg, #9333ea 0%, #7e22ce 100%) !important">' +
                    '      <i class="ti ti-check"></i>Lưu kết quả thẩm định kho (QC)' +
                    '    </button>' +
                    '  </form>' +
                    '</div>';
            } else if (ret.status === 'INSPECTED') {
                actionBodyEl.innerHTML =
                    '<div>' +
                    '  <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:10px; padding:12px; text-align:center; margin-bottom:10px">' +
                    '    <span style="font-size:11px; color:#065f46; font-weight:700; text-transform:uppercase">Tổng tiền cần hoàn trả:</span>' +
                    '    <div style="font-size:20px; font-weight:800; color:#047857">₫' + formatNumber(ret.refundTotal) + '</div>' +
                    '  </div>' +
                    '  <form method="post" action="' + ctx + '/staff/returns/' + ret.id + '/refunded">' +
                         csrfInputHtml +
                    '    <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px; font-size:13px; background:linear-gradient(135deg, #10b981 0%, #059669 100%) !important">' +
                    '      <i class="ti ti-cash"></i>Xác nhận đã chuyển khoản hoàn tiền' +
                    '    </button>' +
                    '  </form>' +
                    '</div>';
            } else if (ret.status === 'REFUNDED') {
                actionBodyEl.innerHTML =
                    '<div style="display:flex; align-items:center; gap:8px; background:#e6f9ed; border:1px solid #bbf7d0; color:#166534; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">' +
                    '  <i class="ti ti-circle-check" style="font-size:18px"></i>Yêu cầu đã hoàn tất hoàn tiền thành công.' +
                    '</div>';
            } else {
                actionBodyEl.innerHTML =
                    '<div style="display:flex; align-items:center; gap:8px; background:#f3f4f6; border:1px solid #e5e7eb; color:#4b5563; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">' +
                    '  <i class="ti ti-info-circle" style="font-size:18px"></i>Yêu cầu đã kết thúc quy trình xử lý.' +
                    '</div>';
            }
        }

        // Customer & Order
        const custNameEl = document.getElementById('detail-cust-name');
        if (custNameEl) custNameEl.innerText = ret.customerName || 'Khách hàng';

        const custAvatarEl = document.getElementById('detail-cust-avatar');
        if (custAvatarEl) custAvatarEl.innerText = (ret.customerName ? ret.customerName.charAt(0).toUpperCase() : 'K');

        const custContactEl = document.getElementById('detail-cust-contact');
        if (custContactEl) {
            custContactEl.innerHTML = '<div><i class="ti ti-phone"></i> <b>' + escapeHtml(ret.customerPhone || 'Chưa cập nhật') + '</b></div>' +
                '<div><i class="ti ti-mail"></i> ' + escapeHtml(ret.customerEmail || 'N/A') + '</div>';
        }

        const orderLinkEl = document.getElementById('detail-order-link');
        if (orderLinkEl) orderLinkEl.innerText = '#ORD-' + ret.orderId;

        const orderViewLinkEl = document.getElementById('detail-order-view-link');
        if (orderViewLinkEl) orderViewLinkEl.href = ctx + '/staff/orders?orderId=' + ret.orderId;

        const orderPayEl = document.getElementById('detail-order-pay');
        if (orderPayEl) orderPayEl.innerText = (ret.paymentMethod === 'VNPAY' ? 'VNPay' : 'COD');

        const reasonBadgeEl = document.getElementById('detail-reason-badge');
        if (reasonBadgeEl) reasonBadgeEl.innerText = reasonLabel(ret.reason);

        const descTextEl = document.getElementById('detail-desc-text');
        if (descTextEl) descTextEl.innerText = '"' + (ret.description || 'Khách hàng không nhập thêm mô tả.') + '"';

        // Bank Card
        const bankCardEl = document.getElementById('detail-bank-card');
        if (bankCardEl) {
            if (ret.refundBankName) {
                bankCardEl.style.display = '';
                const bName = document.getElementById('detail-bank-name');
                const bAcc = document.getElementById('detail-bank-acc');
                const bHolder = document.getElementById('detail-bank-holder');
                if (bName) bName.innerText = ret.refundBankName;
                if (bAcc) bAcc.innerText = ret.refundAccountNo || '';
                if (bHolder) bHolder.innerText = ret.refundAccountHolder || '';
            } else {
                bankCardEl.style.display = 'none';
            }
        }

        // Items list
        const itemsListEl = document.getElementById('detail-items-list');
        const itemCountEl = document.getElementById('detail-item-count');
        if (itemsListEl && ret.lines) {
            if (itemCountEl) itemCountEl.innerText = ret.lines.length;
            let linesHtml = '';
            ret.lines.forEach(l => {
                linesHtml += '<div style="display:flex; align-items:center; justify-content:space-between; gap:10px; border-bottom:1px solid #f8f1eb; padding-bottom:8px">' +
                    '<div>' +
                    '  <b style="font-size:13px; color:var(--text-main)">' + escapeHtml(l.productName) + '</b>' +
                    '  <div style="font-size:11px; color:var(--text-muted); display:flex; gap:6px; align-items:center; margin-top:2px">' +
                    '    <span>SL: <b style="color:#ea580c">' + l.quantity + '</b>/' + l.orderedQty + '</span>' +
                    '    <span>·</span>' +
                    '    <span class="pill-badge ' + (l.opened ? 'gold' : 'green') + '" style="font-size:10px; padding:1px 6px">' + (l.opened ? 'Đã mở' : 'Nguyên seal') + '</span>' +
                    '  </div>' +
                    '</div>' +
                    '<div style="text-align:right">' +
                    '  <div style="font-size:11px; color:var(--text-muted)">Trần hoàn</div>' +
                    '  <b style="font-size:13px; color:#16a34a">₫' + formatNumber(l.maxRefund) + '</b>' +
                    '</div>' +
                    '</div>';
            });
            itemsListEl.innerHTML = linesHtml;
        }

        // Media Card
        const mediaCardEl = document.getElementById('detail-media-card');
        const mediaGridEl = document.getElementById('detail-media-grid');
        const mediaCountEl = document.getElementById('detail-media-count');
        if (mediaCardEl && mediaGridEl) {
            if (ret.media && ret.media.length > 0) {
                mediaCardEl.style.display = '';
                if (mediaCountEl) mediaCountEl.innerText = ret.media.length + ' tệp';
                let mHtml = '';
                ret.media.forEach(m => {
                    const mUrl = ctx + escapeHtml(m.url);
                    if (m.video) {
                        mHtml += '<div class="gallery-item"><video src="' + mUrl + '" controls preload="metadata"></video></div>';
                    } else {
                        mHtml += '<div class="gallery-item"><a href="' + mUrl + '" target="_blank" style="display:block; width:100%; height:100%"><img src="' + mUrl + '" alt="Bằng chứng trả hàng"></a></div>';
                    }
                });
                mediaGridEl.innerHTML = mHtml;
            } else {
                mediaCardEl.style.display = 'none';
                mediaGridEl.innerHTML = '';
            }
        }

        // Audit List
        const auditListEl = document.getElementById('detail-audit-list');
        if (auditListEl) {
            let auditHtml = '<li class="audit-item done"><div class="audit-icon"><i class="ti ti-check"></i></div><div class="audit-title">Khách hàng gửi yêu cầu trả hàng</div><div class="audit-time">' + escapeHtml(ret.createdAtText || '') + '</div></li>';
            if (ret.reviewedText) {
                const isRej = (ret.status === 'REJECTED');
                auditHtml += '<li class="audit-item ' + (isRej ? 'rejected' : 'done') + '"><div class="audit-icon"><i class="ti ' + (isRej ? 'ti-x' : 'ti-check') + '"></i></div><div class="audit-title">' + (isRej ? 'Nhân viên từ chối' : 'Nhân viên phê duyệt') + '</div><div class="audit-time">' + escapeHtml(ret.reviewedText) + '</div></li>';
            }
            if (ret.receivedAtText) {
                auditHtml += '<li class="audit-item done"><div class="audit-icon"><i class="ti ti-check"></i></div><div class="audit-title">Đã nhận kiện hàng tại kho</div><div class="audit-time">' + escapeHtml(ret.receivedAtText) + '</div></li>';
            }
            if (ret.inspectedByName) {
                auditHtml += '<li class="audit-item done"><div class="audit-icon"><i class="ti ti-check"></i></div><div class="audit-title">Thẩm định kho QC: <b>' + escapeHtml(ret.inspectedByName) + '</b></div></li>';
            }
            if (ret.refundedAtText) {
                auditHtml += '<li class="audit-item done"><div class="audit-icon"><i class="ti ti-cash"></i></div><div class="audit-title">Hoàn tất hoàn tiền</div><div class="audit-time">' + escapeHtml(ret.refundedAtText) + '</div></li>';
            }
            auditListEl.innerHTML = auditHtml;
        }
    }
</script>

</body>
</html>
