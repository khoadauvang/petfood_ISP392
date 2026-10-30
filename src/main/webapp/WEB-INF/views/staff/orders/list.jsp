<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý đơn hàng · PetFood</title>
    <meta name="description" content="Xem và quản lý các đơn hàng của khách hàng trên toàn bộ các kênh bán lẻ.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .split-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 480px;
            gap: 20px;
            align-items: start;
            margin-top: 20px;
        }
        @media (max-width: 1280px) {
            .split-layout { grid-template-columns: minmax(0, 1fr) 440px; }
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
        .order-table-wrapper {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .order-table-wrapper::-webkit-scrollbar {
            height: 4px;
        }
        .order-table-wrapper::-webkit-scrollbar-track {
            background: transparent;
        }
        .order-table-wrapper::-webkit-scrollbar-thumb {
            background: transparent;
            border-radius: 4px;
        }
        .order-table-wrapper:hover::-webkit-scrollbar-thumb {
            background: #cbd5e1;
        }
        .order-table-wrapper:hover {
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
        }
        .order-table {
            margin: 0;
            width: 100%;
            min-width: 680px;
            border-collapse: collapse;
            border: 0;
            box-shadow: none;
        }
        .order-table th {
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
        .order-table th:first-child,
        .order-table td:first-child {
            padding-left: 18px;
        }
        .order-table th:last-child,
        .order-table td:last-child {
            padding-right: 18px;
        }
        .order-table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
        }
        .order-table-row {
            transition: all var(--transition);
            cursor: pointer;
        }
        .order-table-row:hover {
            background: #fff8f1 !important;
        }
        .selected-order-row {
            background: #fff7ee !important;
            border-left: 3px solid #ea580c !important;
        }
        .order-drawer-pane {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: var(--shadow-card);
            padding: 20px 24px;
            position: sticky;
            top: calc(var(--topbar-h) + 20px);
        }
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
            background: #fff !important;
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
            color: #fff !important;
        }
        .stepper-step.active .stepper-circle {
            background: #ea580c !important;
            border-color: #ea580c !important;
            color: #fff !important;
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
        .info-box-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }
        @media (max-width: 640px) {
            .info-box-grid { grid-template-columns: 1fr; }
        }
        .info-box {
            background: var(--surface-soft);
            border: 1px solid var(--line);
            border-radius: 14px;
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .info-box-title {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: var(--text-muted);
        }
        .info-box-title .ti {
            font-size: 15px;
            color: var(--color-primary);
        }
        .info-box-name {
            font-size: 13.5px;
            font-weight: 800;
            color: var(--text-logo);
        }
        .info-box-desc {
            font-size: 12px;
            color: var(--text-muted);
            line-height: 1.4;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head" style="display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:12px">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <span class="current">QUẢN LÝ ĐƠN HÀNG</span>
            </div>
            <h1>QUẢN LÝ ĐƠN HÀNG <span class="pill-badge orange">ĐỒNG BỘ THỜI GIAN THỰC</span></h1>
            <p class="page-sub">Xem danh sách và xử lý chi tiết đơn hàng trực tiếp ngay tại chỗ trên một màn hình.</p>
        </div>
    </div>

    <%-- 4 KPI Cards Screen 4 --%>
    <section class="grid g-4" style="margin-bottom:20px">
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Tổng đơn hàng</span>
                <span class="kpi-ico orange"><i class="ti ti-shopping-bag"></i></span>
            </div>
            <div class="kpi-value">
                <c:choose>
                    <c:when test="${totalAllOrders != null}">${totalAllOrders}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge orange">Đơn hàng trên toàn hệ thống</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Chờ xác nhận</span>
                <span class="kpi-ico yellow"><i class="ti ti-hourglass"></i></span>
            </div>
            <div class="kpi-value" style="color:#d97706">
                <c:choose>
                    <c:when test="${pendingOrdersCount != null}">${pendingOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge warn">Cần xử lý · Chờ xác nhận</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Đang xử lý &amp; Đóng gói</span>
                <span class="kpi-ico blue"><i class="ti ti-package"></i></span>
            </div>
            <div class="kpi-value" style="color:#2563eb">
                <c:choose>
                    <c:when test="${processingOrdersCount != null}">${processingOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge info">Trong hàng đợi đóng gói</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Đã giao thành công</span>
                <span class="kpi-ico green"><i class="ti ti-circle-check"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">
                <c:choose>
                    <c:when test="${completedOrdersCount != null}">${completedOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge ok">Hoàn tất trên toàn hệ thống</span></div>
        </div>
    </section>

    <%-- Có đơn khách xin huỷ đang chờ duyệt: nút bấm lọc nhanh --%>
    <c:if test="${cancelRequestCount > 0}">
        <div style="margin-bottom:14px; display:flex; align-items:center; gap:8px">
            <a href="${ctx}/staff/orders?cancelRequested=true" class="pill-badge red" style="padding:8px 14px; font-size:13px; text-decoration:none; display:inline-flex; align-items:center; gap:6px; ${filterCancelRequested ? 'outline: 2px solid #dc2626;' : ''}">
                <i class="ti ti-alert-triangle"></i> ${cancelRequestCount} đơn đang chờ duyệt yêu cầu huỷ
            </a>
            <c:if test="${filterCancelRequested}">
                <a href="${ctx}/staff/orders" class="pill-badge gray" style="text-decoration:none; padding:6px 12px; font-size:12px" title="Bỏ lọc yêu cầu huỷ">
                    <i class="ti ti-x"></i> Xem tất cả đơn
                </a>
            </c:if>
        </div>
    </c:if>

    <%-- Bộ lọc tìm kiếm đơn hàng --%>
    <form method="get" action="${ctx}/staff/orders" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <c:if test="${filterCancelRequested}"><input type="hidden" name="cancelRequested" value="true"></c:if>
        <div style="flex:1; min-width:240px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo Mã đơn (#12), SĐT, Email hoặc Tên khách... (/)"
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="status" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="s" items="${statuses}">
                <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>

        <button type="submit" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c; cursor:pointer"><i class="ti ti-filter"></i> Lọc</button>
        <a href="${ctx}/staff/orders" class="act-icon" title="Đặt lại bộ lọc"><i class="ti ti-rotate"></i></a>
    </form>

    <%-- BỐ CỤC MASTER-DETAIL (Trái: Danh sách đơn hàng | Phải: Chi tiết đơn hàng & Thao tác) --%>
    <div class="split-layout">
        <%-- CỘT TRÁI: BẢNG DANH SÁCH ĐƠN HÀNG --%>
        <div class="split-panel">
            <div class="split-head" style="padding:16px 20px; background:#fff; border-bottom:1px solid var(--line); display:flex; justify-content:space-between; align-items:center">
                <div>
                    <h3 style="margin:0; font-size:15px; font-weight:800; color:var(--text-logo)">
                        <i class="ti ti-list" style="color:var(--color-primary)"></i> DANH SÁCH ĐƠN HÀNG
                    </h3>
                    <small style="color:var(--text-muted)">Bấm vào dòng để xem chi tiết và xử lý ở khung bên phải</small>
                </div>
                <div style="font-size:12px; color:var(--text-muted)">
                    Sắp xếp: <b style="color:var(--color-primary)">Mới nhất ↓</b>
                </div>
            </div>

            <div class="order-table-wrapper">
                <table class="order-table">
                    <thead>
                    <tr>
                        <th style="width:85px">MÃ ĐƠN</th>
                        <th>KHÁCH HÀNG</th>
                        <th style="width:130px">NGÀY ĐẶT</th>
                        <th style="width:105px; text-align:right;" class="num">TỔNG TIỀN</th>
                        <th style="width:100px">THANH TOÁN</th>
                        <th style="width:115px">TRẠNG THÁI</th>
                        <th style="width:50px; text-align:center;">XEM</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty orders}">
                            <c:forEach var="o" items="${orders}" varStatus="oStatus">
                                <c:set var="isSel" value="${o.id == selectedOrderId or (empty selectedOrderId and oStatus.first)}"/>
                                <tr id="row-ORD-${o.id}" class="order-table-row <c:if test='${isSel}'>selected-order-row</c:if>"
                                    onclick="selectOrderId(${o.id})"
                                    style="<c:if test='${isSel}'>background:#fff7ee;</c:if>">
                                    <td><b style="color:#ea580c; white-space:nowrap">#ORD-${o.id}</b></td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px; min-width:140px">
                                            <div class="avatar" style="width:28px; height:28px; font-size:11px; background:#fed7aa; color:#9a3412; flex-shrink:0">
                                                <c:out value="${empty o.customerName ? 'K' : o.customerName.substring(0, 1)}"/>
                                            </div>
                                            <div style="min-width:0">
                                                <b style="display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:140px" title="${o.customerName}">
                                                    <c:out value="${empty o.customerName ? 'Khách hàng #' += o.id : o.customerName}"/>
                                                </b>
                                                <small style="color:var(--text-muted); display:block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:140px" title="${o.customerEmail}">
                                                    <c:out value="${empty o.customerEmail ? 'N/A' : o.customerEmail}"/>
                                                </small>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="color:#475569; white-space:nowrap; font-size:12.5px">${o.createdAtText}</td>
                                    <td style="text-align:right; white-space:nowrap" class="num">
                                        <b style="color:var(--text-logo)"><fmt:formatNumber value="${o.totalAmount}" type="number"/>₫</b>
                                    </td>
                                    <td style="white-space:nowrap">
                                        <span class="pill-badge ${o.paymentMethodLabel == 'VNPay' ? 'blue' : 'orange'}">
                                            ● ${o.paymentMethodLabel}
                                        </span>
                                    </td>
                                    <td style="white-space:nowrap">
                                        <span class="pill-badge ${o.status == 'COMPLETED' ? 'green' : (o.status == 'SHIPPED' ? 'blue' : (o.status == 'PROCESSING' ? 'blue' : (o.status == 'CONFIRMED' ? 'green' : (o.status == 'CANCELLED' ? 'red' : 'gray'))))}">
                                            ${o.status.label}
                                        </span>
                                        <c:if test="${o.cancelRequested}"><span class="pill-badge red" style="margin-left:4px">Yêu cầu huỷ</span></c:if>
                                    </td>
                                    <td style="text-align:center">
                                        <span class="act-icon" style="<c:if test='${isSel}'>color:#ea580c; border-color:#ea580c; background:#ffedd5;</c:if>" title="Xem chi tiết đơn #${o.id}">
                                            <i class="ti ti-eye"></i>
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align:center; padding:36px; color:var(--text-muted)">
                                    <i class="ti ti-inbox" style="font-size:28px; vertical-align:middle; margin-right:8px; color:#cbd5e1"></i>
                                    Không tìm thấy đơn hàng nào phù hợp với bộ lọc.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- THANH PHÂN TRANG RÚT GỌN (Giới hạn 3 trang trước/sau, nút về Đầu & Cuối) --%>
            <div class="panel-foot" style="padding:14px 20px; background:#fff; border-top:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px">
                <span style="font-size:13px; color:var(--text-muted)">
                    Hiển thị <c:out value="${not empty orders ? orders.size() : 0}"/> trong tổng số <b>${totalItems != null ? totalItems : 0}</b> đơn
                </span>

                <c:if test="${totalPages > 1}">
                    <div class="pager" style="margin:0; display:flex; align-items:center; gap:4px; flex-wrap:wrap">
                        <%-- Nút Về trang đầu & Trang trước --%>
                        <c:if test="${currentPage > 1}">
                            <a href="?${filterQuery}&page=1" title="Về trang đầu" style="padding:0 9px; font-size:12px; font-weight:700">« Đầu</a>
                            <a href="?${filterQuery}&page=${currentPage - 1}" title="Trang trước" style="padding:0 9px; font-size:12px; font-weight:700">‹ Trước</a>
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
                                    <a href="?${filterQuery}&page=${n}">${n}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${endPage < totalPages}">
                            <span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>
                        </c:if>

                        <%-- Nút Trang sau & Đến trang cuối --%>
                        <c:if test="${currentPage < totalPages}">
                            <a href="?${filterQuery}&page=${currentPage + 1}" title="Trang tiếp theo" style="padding:0 9px; font-size:12px; font-weight:700">Sau ›</a>
                            <a href="?${filterQuery}&page=${totalPages}" title="Đến trang cuối" style="padding:0 9px; font-size:12px; font-weight:700">Cuối »</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>

        <%-- CỘT PHẢI: KHUNG CHI TIẾT ĐƠN HÀNG & THAO TÁC NGHIỆP VỤ TẠI CHỖ --%>
        <div class="order-drawer-pane">
            <c:choose>
                <c:when test="${not empty selectedOrder}">
                    <%-- Đầu khung chi tiết --%>
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:14px; padding-bottom:12px; border-bottom:1px solid var(--line)">
                        <div>
                            <h3 style="margin:0 0 4px 0; font-size:18px; font-weight:800; color:var(--text-logo); display:flex; align-items:center; gap:8px">
                                <span>#ORD-${selectedOrder.id}</span>
                                <span class="pill-badge ${selectedOrder.status == 'COMPLETED' ? 'green' : (selectedOrder.status == 'SHIPPED' ? 'blue' : (selectedOrder.status == 'PROCESSING' ? 'blue' : (selectedOrder.status == 'CONFIRMED' ? 'green' : (selectedOrder.status == 'CANCELLED' ? 'red' : 'gray'))))}">
                                    ${selectedOrder.status.label}
                                </span>
                            </h3>
                            <div style="font-size:12px; color:var(--text-muted)">
                                Đặt lúc: <b>${selectedOrder.createdAtText}</b> · Kênh: Bán lẻ trực tuyến
                            </div>
                        </div>
                    </div>

                    <%-- Cảnh báo khẩn cấp: Khách yêu cầu huỷ đơn --%>
                    <c:if test="${selectedOrder.cancelRequested}">
                        <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:12px; padding:12px 14px; margin-bottom:14px">
                            <div style="display:flex; align-items:center; gap:8px; color:#991b1b; font-weight:700; font-size:13px; margin-bottom:6px">
                                <i class="ti ti-alert-triangle" style="font-size:18px"></i> Khách hàng gửi yêu cầu huỷ đơn hàng
                            </div>
                            <div style="font-size:12px; color:#7f1d1d; margin-bottom:10px">
                                Lý do: "<strong><c:out value="${selectedOrder.cancelReason}"/></strong>"
                            </div>
                            <div style="display:flex; gap:8px; flex-wrap:wrap">
                                <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/cancel-request/approve" style="display:inline">${csrf}
                                    <button type="submit" class="btn-pill-danger" style="padding:6px 14px; font-size:12px"><i class="ti ti-check"></i>Duyệt huỷ (trả kho)</button>
                                </form>
                                <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/cancel-request/reject" style="display:inline">${csrf}
                                    <button type="submit" class="btn-pill-outline" style="padding:6px 14px; font-size:12px"><i class="ti ti-x"></i>Từ chối yêu cầu</button>
                                </form>
                            </div>
                        </div>
                    </c:if>

                    <%-- Cảnh báo: Chờ hoàn tiền VNPay --%>
                    <c:if test="${selectedOrder.needsRefund}">
                        <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:12px; padding:12px 14px; margin-bottom:14px">
                            <div style="display:flex; align-items:center; gap:8px; color:#92400e; font-weight:700; font-size:13px; margin-bottom:4px">
                                <i class="ti ti-cash" style="font-size:18px"></i> Chờ hoàn tiền VNPay
                            </div>
                            <p style="font-size:12px; color:#78350f; margin:0 0 10px 0">Đơn VNPay đã thanh toán nhưng bị huỷ. Nhân viên cần chuyển khoản hoàn tiền thủ công cho khách.</p>
                            <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/refunded">${csrf}
                                <button type="submit" class="btn-flashsale" style="padding:6px 14px; font-size:12px"><i class="ti ti-check"></i>Đã hoàn tiền cho khách</button>
                            </form>
                        </div>
                    </c:if>

                    <%-- Thông báo: Đơn đã huỷ --%>
                    <c:if test="${selectedOrder.status == 'CANCELLED'}">
                        <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:12px; padding:10px 14px; margin-bottom:14px; font-size:12.5px; color:#991b1b">
                            <i class="ti ti-circle-x" style="vertical-align:middle; font-size:16px"></i> Đơn đã huỷ lúc ${selectedOrder.cancelledAtText}. Lý do: <b><c:out value="${selectedOrder.cancelReason}"/></b>
                        </div>
                    </c:if>

                    <%-- Stepper tiến trình xử lý đơn hàng (5 bước) --%>
                    <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:8px">
                        TIẾN TRÌNH XỬ LÝ ĐƠN HÀNG
                    </div>
                    <c:set var="sIdx" value="${selectedOrder.status == 'PENDING' ? 1 : (selectedOrder.status == 'CONFIRMED' ? 2 : (selectedOrder.status == 'PROCESSING' ? 3 : (selectedOrder.status == 'SHIPPED' ? 4 : 5)))}"/>
                    <div class="order-stepper" style="margin-bottom:18px">
                        <div class="stepper-step ${sIdx >= 1 ? (sIdx > 1 or selectedOrder.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                            <div class="stepper-circle"><i class="ti ${sIdx > 1 or selectedOrder.status == 'COMPLETED' ? 'ti-check' : 'ti-shopping-cart'}"></i></div>
                            <span class="stepper-label">Đặt hàng</span>
                            <span class="stepper-time">${selectedOrder.createdAtText}</span>
                        </div>
                        <div class="stepper-step ${sIdx >= 2 ? (sIdx > 2 or selectedOrder.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                            <div class="stepper-circle"><i class="ti ${sIdx > 2 or selectedOrder.status == 'COMPLETED' ? 'ti-check' : 'ti-check'}"></i></div>
                            <span class="stepper-label">Xác nhận</span>
                            <span class="stepper-time">${not empty selectedOrder.confirmedAtText ? selectedOrder.confirmedAtText : '--:--'}</span>
                        </div>
                        <div class="stepper-step ${sIdx >= 3 ? (sIdx > 3 or selectedOrder.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                            <div class="stepper-circle"><i class="ti ${sIdx > 3 or selectedOrder.status == 'COMPLETED' ? 'ti-check' : 'ti-package'}"></i></div>
                            <span class="stepper-label">Đóng gói</span>
                            <span class="stepper-time">${not empty selectedOrder.packedByName ? selectedOrder.packedByName : '--:--'}</span>
                        </div>
                        <div class="stepper-step ${sIdx >= 4 ? (sIdx > 4 or selectedOrder.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                            <div class="stepper-circle"><i class="ti ${sIdx > 4 or selectedOrder.status == 'COMPLETED' ? 'ti-check' : 'ti-truck'}"></i></div>
                            <span class="stepper-label">Đang giao</span>
                            <span class="stepper-time">${not empty selectedOrder.shippedAtText ? selectedOrder.shippedAtText : '--:--'}</span>
                        </div>
                        <div class="stepper-step ${selectedOrder.status == 'COMPLETED' ? 'completed active' : ''}">
                            <div class="stepper-circle"><i class="ti ti-circle-check"></i></div>
                            <span class="stepper-label">Hoàn tất</span>
                            <span class="stepper-time">${not empty selectedOrder.completedAtText ? selectedOrder.completedAtText : '--:--'}</span>
                        </div>
                    </div>

                    <%-- THAO TÁC XỬ LÝ NGHIỆP VỤ TRỰC TIẾP --%>
                    <div style="background:#fffaf5; border:1px solid #fed7aa; border-radius:14px; padding:14px 16px; margin-bottom:16px">
                        <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.08em; color:var(--color-primary); margin-bottom:10px; display:flex; align-items:center; gap:6px">
                            <i class="ti ti-player-play"></i>THAO TÁC XỬ LÝ ĐƠN HÀNG
                        </div>
                        <c:choose>
                            <c:when test="${selectedOrder.status == 'PENDING'}">
                                <p style="font-size:12.5px; color:var(--text-muted); margin:0 0 10px 0">
                                    Đơn hàng mới từ khách. Hãy kiểm tra lượng hàng khả dụng và xác nhận:
                                </p>
                                <div style="display:flex; gap:8px; flex-wrap:wrap">
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/confirm" style="flex:1">${csrf}
                                        <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px 16px; font-size:13px">
                                            <i class="ti ti-check"></i>Xác nhận đơn ngay
                                        </button>
                                    </form>
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/cancel" onsubmit="return promptCancelReason(this)" style="display:inline">${csrf}
                                        <input type="hidden" name="cancelReason" value="">
                                        <button type="submit" class="btn-pill-outline" style="padding:10px 16px; font-size:13px; color:#dc2626; border-color:#fca5a5" title="Huỷ đơn hàng này">
                                            <i class="ti ti-trash"></i>Huỷ đơn
                                        </button>
                                    </form>
                                </div>
                            </c:when>

                            <c:when test="${selectedOrder.status == 'CONFIRMED'}">
                                <p style="font-size:12.5px; color:var(--text-muted); margin:0 0 10px 0">
                                    Đơn đã duyệt. Chuyển sang bộ phận kho để chuẩn bị &amp; đóng gói sản phẩm:
                                </p>
                                <div style="display:flex; gap:8px; flex-wrap:wrap">
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/pack" style="flex:1">${csrf}
                                        <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px 16px; font-size:13px">
                                            <i class="ti ti-package"></i>Tiến hành đóng gói hàng
                                        </button>
                                    </form>
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/cancel" onsubmit="return promptCancelReason(this)" style="display:inline">${csrf}
                                        <input type="hidden" name="cancelReason" value="">
                                        <button type="submit" class="btn-pill-outline" style="padding:10px 16px; font-size:13px; color:#dc2626; border-color:#fca5a5" title="Huỷ đơn hàng này">
                                            <i class="ti ti-trash"></i>Huỷ đơn
                                        </button>
                                    </form>
                                </div>
                            </c:when>

                            <c:when test="${selectedOrder.status == 'PROCESSING' and not selectedOrder.cancelRequested}">
                                <p style="font-size:12.5px; color:var(--text-muted); margin:0 0 10px 0">
                                    Kiện hàng đã đóng gói hoàn tất. Bàn giao cho shipper để bắt đầu giao hàng:
                                </p>
                                <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/ship">${csrf}
                                    <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px 16px; font-size:13px; background:linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%) !important">
                                        <i class="ti ti-truck"></i>Bàn giao vận chuyển (Bắt đầu giao)
                                    </button>
                                </form>
                            </c:when>

                            <c:when test="${selectedOrder.status == 'SHIPPED'}">
                                <p style="font-size:12.5px; color:var(--text-muted); margin:0 0 10px 0">
                                    Đơn đang được giao đến khách hàng. Cập nhật kết quả giao nhận bên dưới:
                                </p>
                                <div style="display:flex; gap:8px; flex-direction:column">
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/complete">${csrf}
                                        <button type="submit" class="btn-flashsale" style="width:100%; justify-content:center; padding:10px 16px; font-size:13px; background:linear-gradient(135deg, #10b981 0%, #059669 100%) !important">
                                            <i class="ti ti-circle-check"></i>Giao hàng thành công (Thu tiền COD)
                                        </button>
                                    </form>
                                    <form method="post" action="${ctx}/staff/orders/${selectedOrder.id}/returned">${csrf}
                                        <button type="submit" class="btn-pill-outline" style="width:100%; justify-content:center; padding:9px 16px; font-size:13px; color:#991b1b; border-color:#fca5a5"
                                                onclick="return confirm('Xác nhận khách không nhận hàng và hoàn đơn về kho?')">
                                            <i class="ti ti-arrow-back-up"></i>Khách không nhận hàng (Hoàn trả kho)
                                        </button>
                                    </form>
                                </div>
                            </c:when>

                            <c:when test="${selectedOrder.status == 'COMPLETED'}">
                                <div style="display:flex; align-items:center; gap:8px; background:#e6f9ed; border:1px solid #bbf7d0; color:#166534; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">
                                    <i class="ti ti-check-double" style="font-size:18px"></i>Đơn hàng đã hoàn tất thành công.
                                </div>
                            </c:when>

                            <c:otherwise>
                                <div style="display:flex; align-items:center; gap:8px; background:#f3f4f6; border:1px solid #e5e7eb; color:#4b5563; padding:10px 14px; border-radius:10px; font-weight:700; font-size:13px">
                                    <i class="ti ti-info-circle" style="font-size:18px"></i>Đơn hàng: ${selectedOrder.status.label}
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:set var="orderTierName" value="${selectedOrder.tierDiscountRate >= 10 ? 'Hạng Kim Cương' : (selectedOrder.tierDiscountRate >= 5 ? 'Hạng Vàng' : (selectedOrder.tierDiscountRate >= 3 ? 'Hạng Bạc' : 'Hạng Đồng'))}"/>
                    <c:set var="orderTierBadge" value="${selectedOrder.tierDiscountRate >= 10 ? '💎 Kim Cương' : (selectedOrder.tierDiscountRate >= 5 ? '🥇 Vàng' : (selectedOrder.tierDiscountRate >= 3 ? '🥈 Bạc' : '🥉 Đồng'))}"/>
                    <c:set var="orderTierStyle" value="${selectedOrder.tierDiscountRate >= 10 ? 'background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd' : (selectedOrder.tierDiscountRate >= 5 ? 'background:#fef3c7; color:#b45309; border:1px solid #fde68a' : (selectedOrder.tierDiscountRate >= 3 ? 'background:#f1f5f9; color:#334155; border:1px solid #cbd5e1' : 'background:#ffedd5; color:#9a3412; border:1px solid #fed7aa'))}"/>

                    <%-- Thông tin khách hàng & Địa chỉ giao hàng --%>
                    <div class="info-box-grid">
                        <div class="info-box">
                            <div class="info-box-title"><i class="ti ti-user"></i>Khách nhận hàng</div>
                            <div class="info-box-name" style="display:flex; align-items:center; gap:6px; flex-wrap:wrap">
                                <span><c:out value="${selectedOrder.customerName}"/></span>
                                <span style="display:inline-flex; align-items:center; padding:1px 7px; border-radius:999px; font-size:10.5px; font-weight:700; ${orderTierStyle}">
                                    ${orderTierBadge}
                                </span>
                            </div>
                            <div class="info-box-desc">
                                <c:if test="${not empty selectedOrder.customerPhone}">
                                    <div><i class="ti ti-phone"></i> <b><c:out value="${selectedOrder.customerPhone}"/></b></div>
                                </c:if>
                                <c:if test="${not empty selectedOrder.customerEmail}">
                                    <div><i class="ti ti-mail"></i> <c:out value="${selectedOrder.customerEmail}"/></div>
                                </c:if>
                            </div>
                        </div>

                        <div class="info-box">
                            <div class="info-box-title"><i class="ti ti-map-pin"></i>Địa chỉ &amp; Thanh toán</div>
                            <div class="info-box-name" style="font-size:13px; line-height:1.4"><c:out value="${empty selectedOrder.shippingAddress ? 'Địa chỉ theo hồ sơ đăng ký' : selectedOrder.shippingAddress}"/></div>
                            <div style="margin-top:4px">
                                <span class="pill-badge ${selectedOrder.paymentMethod == 'VNPAY' ? 'blue' : 'orange'}" style="font-size:11px">
                                    ● ${selectedOrder.paymentMethod.label} (${selectedOrder.paymentStatus.label})
                                </span>
                            </div>
                        </div>
                    </div>

                    <%-- Danh sách sản phẩm trong đơn hàng --%>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin:16px 0 8px 0">
                        <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted)">
                            SẢN PHẨM TRONG ĐƠN HÀNG (${selectedOrder.lines.size()} mặt hàng)
                        </div>
                    </div>

                    <div class="order-items-list" style="display:flex; flex-direction:column; gap:8px; max-height:360px; overflow-y:auto; padding-right:2px">
                        <c:forEach var="line" items="${selectedOrder.lines}">
                            <div class="order-item-row" style="padding:10px 12px; background:var(--surface-soft); border-radius:12px; border:1px solid var(--line); display:flex; align-items:flex-start; justify-content:space-between; gap:10px">
                                <div style="display:flex; align-items:flex-start; gap:10px; flex:1">
                                    <img src="${empty line.imageUrl ? 'https://placehold.co/44x44?text=Pet' : line.imageUrl}"
                                         onerror="this.src='https://placehold.co/44x44?text=Pet'" alt=""
                                         style="width:44px; height:44px; border-radius:10px; object-fit:contain; background:#fff; border:1px solid var(--line); flex-shrink:0">
                                    <div style="flex:1">
                                        <div style="font-size:13px; font-weight:700; color:var(--text-main); line-height:1.3">
                                            <c:out value="${line.name}"/>
                                        </div>
                                        <c:if test="${line.flashSale}">
                                            <span class="pill-badge red" style="font-size:10px; padding:1px 6px; margin-top:2px">
                                                <c:set var="fsNameLower" value="${fn:toLowerCase(line.flashSaleName)}"/>
                                                <c:set var="isPromoLine" value="${not (fn:contains(fsNameLower, 'flash sale') or fn:contains(fsNameLower, 'flashsale') or fn:contains(fsNameLower, 'cận hạn') or fn:contains(fsNameLower, 'cận date') or fn:contains(fsNameLower, 'xả hàng') or fn:contains(fsNameLower, 'xả tồn'))}"/>
                                                <i class="ti ${isPromoLine ? 'ti-discount-2' : 'ti-bolt'}"></i>${isPromoLine ? 'Chương trình' : 'Flash Sale'}
                                            </span>
                                        </c:if>
                                        <c:forEach var="lot" items="${line.lots}">
                                            <div style="font-size:11px; color:#475569; background:#f1f5f9; border-radius:6px; padding:2px 6px; display:inline-flex; align-items:center; gap:4px; margin-top:3px">
                                                <i class="ti ti-building-warehouse" style="color:#0284c7"></i> <c:out value="${lot}"/>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div style="text-align:right; flex-shrink:0">
                                    <div style="font-size:13px; font-weight:800; color:var(--text-logo)">
                                        <fmt:formatNumber value="${line.lineTotal}" type="number"/>₫
                                    </div>
                                    <div style="font-size:11px; color:var(--text-muted)">
                                        <fmt:formatNumber value="${line.unitPrice}" type="number"/>₫ × ${line.quantity}
                                    </div>
                                    <c:if test="${line.discountAmount > 0}">
                                        <div style="font-size:10px; color:#dc2626; font-weight:700">
                                            −<fmt:formatNumber value="${line.discountAmount}" type="number"/>₫
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <%-- Bảng tổng kết thanh toán --%>
                    <div style="background:var(--surface-soft); border-radius:12px; border:1px solid var(--line); padding:12px 14px; margin-top:14px">
                        <div style="display:flex; justify-content:space-between; font-size:12px; color:var(--text-muted); margin-bottom:4px">
                            <span>Tạm tính ban đầu:</span>
                            <b><fmt:formatNumber value="${selectedOrder.subtotal}" type="number"/>₫</b>
                        </div>
                        <c:if test="${selectedOrder.discountTotal > 0}">
                            <div style="display:flex; justify-content:space-between; align-items:center; font-size:12px; color:#dc2626; margin-bottom:4px">
                                <span style="display:inline-flex; align-items:center; gap:6px; flex-wrap:wrap">
                                    <span>Giảm giá hạng thành viên (${orderTierName} · <fmt:formatNumber value="${selectedOrder.tierDiscountRate}" maxFractionDigits="2"/>%):</span>
                                </span>
                                <b>−<fmt:formatNumber value="${selectedOrder.discountTotal}" type="number"/>₫</b>
                            </div>
                        </c:if>
                        <div style="display:flex; justify-content:space-between; font-size:12px; color:var(--text-muted); margin-bottom:6px">
                            <span>Phí vận chuyển:</span>
                            <b><fmt:formatNumber value="${selectedOrder.shippingFee}" type="number"/>₫</b>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:15px; font-weight:800; border-top:1px dashed var(--line); padding-top:8px">
                            <span style="color:var(--text-main)">TỔNG TIỀN THANH TOÁN:</span>
                            <b style="color:#ea580c; font-size:18px"><fmt:formatNumber value="${selectedOrder.totalAmount}" type="number"/>₫</b>
                        </div>
                    </div>
                </c:when>

                <c:otherwise>
                    <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:50px 20px; min-height:420px; color:var(--text-muted)">
                        <div style="width:56px; height:56px; border-radius:50%; background:#fff7ed; color:#ea580c; display:flex; align-items:center; justify-content:center; font-size:24px; margin-bottom:16px">
                            <i class="ti ti-receipt"></i>
                        </div>
                        <h3 style="margin:0 0 8px 0; color:var(--text-main); font-size:16px">Chi tiết đơn hàng</h3>
                        <p style="font-size:13px; max-width:320px; line-height:1.5; margin:0">
                            Không có đơn hàng nào được chọn. Hãy chọn một đơn hàng từ danh sách bên trái để theo dõi tiến trình và thực hiện thao tác.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<script>
    // Hàm chọn đơn hàng: điều hướng giữ nguyên các filter hiện tại và nạp đơn được chọn
    function selectOrderId(orderId) {
        const urlParams = new URLSearchParams(window.location.search);
        urlParams.set('orderId', orderId);
        window.location.search = urlParams.toString();
    }

    // Nhập lý do huỷ đơn hàng
    function promptCancelReason(form) {
        const reason = prompt('Nhập lý do huỷ đơn hàng này (bắt buộc):');
        if (!reason || reason.trim() === '') {
            alert('Bạn phải nhập lý do khi huỷ đơn hàng.');
            return false;
        }
        form.cancelReason.value = reason.trim();
        return true;
    }
</script>
</body>
</html>
