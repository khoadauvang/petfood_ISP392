<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model từ AdminDashboardController: filterFrom, filterTo, alertSummary, stats, errorMessage --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Bảng điều khiển · PetFood</title>
    <meta name="description" content="Tổng quan về hiệu suất kinh doanh, đơn hàng, tồn kho và chương trình hội viên.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .dash-nav-tabs { display: flex; gap: 8px; margin-bottom: 20px; border-bottom: 1px solid var(--line); }
        .dash-tab-btn { padding: 10px 18px; border: 0; background: none; font-size: 14px; font-weight: 700; color: var(--text-muted); cursor: pointer; border-bottom: 3px solid transparent; margin-bottom: -1px; }
        .dash-tab-btn.active { color: var(--color-primary); border-bottom-color: var(--color-primary); font-weight: 800; }
        .tab-pane { display: none; }
        .tab-pane.active { display: block; animation: pop .2s ease; }
        .export-btn { display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; border-radius: 12px; background: #fff; border: 1px solid var(--line); font-size: 13px; font-weight: 700; color: var(--text-main); cursor: pointer; text-decoration: none; }
        .export-btn:hover { background: var(--orange-50); border-color: var(--color-primary); color: var(--color-primary-dark); }
        .chart-legend-box { display: flex; align-items: center; gap: 16px; font-size: 13px; font-weight: 600; color: var(--text-muted); margin-bottom: 10px; }
        .pill-badge { display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 99px; font-size: 11px; font-weight: 800; }
        .pill-badge.green { background: #e6f9ed; color: #166534; }
        .pill-badge.orange { background: #ffedd5; color: #c2410c; }
        .pill-badge.red { background: #fee2e2; color: #991b1b; }
        .pill-badge.blue { background: #eff6ff; color: #1e40af; }
        .pill-badge.purple { background: #f3e8ff; color: #6b21a8; }
        .pill-badge.gray { background: #f3f4f6; color: #4b5563; }
        .pill-badge.gold { background: #fef3c7; color: #92400e; }
        .pill-badge.diamond { background: #e0f2fe; color: #0369a1; }
        #revenueChartContainer:hover #revenueChartTooltip { opacity: 1 !important; }
        #revenueCurvePath, #revenueAreaPath { transition: d 0.3s ease; }
        @keyframes chartPulse {
            0% { r: 6px; opacity: 0.7; }
            50% { r: 10px; opacity: 0.25; }
            100% { r: 6px; opacity: 0.7; }
        }
        #chartPointHalo { animation: chartPulse 2s infinite ease-in-out; }

        /* Styles cho Báo cáo doanh thu & kinh doanh (Screen 12 Figma) */
        .rev-filter-box { background: #fff; border-radius: 16px; border: 1px solid var(--line); padding: 18px 22px; margin-bottom: 22px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
        .rev-filter-field { display: flex; flex-direction: column; gap: 5px; }
        .rev-filter-field label { font-size: 12px; font-weight: 700; color: #64748b; }
        .rev-input-wrap { display: flex; align-items: center; gap: 8px; border: 1px solid #cbd5e1; border-radius: 10px; padding: 7px 12px; background: #fff; }
        .rev-input-wrap input, .rev-input-wrap select { border: none; outline: none; font-size: 13px; font-weight: 600; color: #1e293b; background: transparent; width: 100%; }
        .rev-quick-chip { padding: 6px 14px; border-radius: 8px; border: 1px solid #e2e8f0; background: #fff; font-size: 12.5px; font-weight: 600; color: #475569; cursor: pointer; transition: all .15s ease; }
        .rev-quick-chip:hover { border-color: #ea580c; color: #ea580c; background: #fff7ed; }
        .rev-quick-chip.active { background: #ea580c; color: #fff; border-color: #ea580c; font-weight: 700; }
        
        .rev-kpi-card { background: #fff; border-radius: 16px; border: 1px solid var(--line); padding: 20px 22px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); display: flex; flex-direction: column; justify-content: space-between; position: relative; }
        .rev-kpi-icon { width: 44px; height: 44px; border-radius: 12px; display: grid; place-items: center; font-size: 22px; position: absolute; right: 20px; top: 20px; }
        .rev-kpi-val { font-size: 26px; font-weight: 800; color: #1e293b; letter-spacing: -0.5px; margin: 12px 0 8px 0; }
        
        .rev-chart-card { background: #fff; border-radius: 16px; border: 1px solid var(--line); padding: 22px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
        .rev-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .rev-table th { text-align: left; padding: 12px 14px; font-size: 11.5px; font-weight: 700; color: #64748b; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; background: #f8fafc; }
        .rev-table td { padding: 13px 14px; border-bottom: 1px solid #f1f5f9; color: #334155; vertical-align: middle; }
        .rev-table tr:hover td { background: #fffcf9; }
        
        .page-num-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid #e2e8f0; background: #fff; font-size: 13px; font-weight: 600; color: #475569; display: grid; place-items: center; cursor: pointer; transition: all .15s ease; }
        .page-num-btn:hover { border-color: #ea580c; color: #ea580c; }
        .page-num-btn.active { background: #ea580c; color: #fff; border-color: #ea580c; font-weight: 700; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <%-- Tab navigation bar cho Admin --%>
    <div class="dash-nav-tabs" role="tablist">
        <button type="button" class="dash-tab-btn active" onclick="switchAdminTab('tab-overview')" id="tab-btn-overview">
            <i class="ti ti-layout-dashboard" style="margin-right:6px"></i>Bảng điều khiển
        </button>
        <button type="button" class="dash-tab-btn" onclick="switchAdminTab('tab-revenue')" id="tab-btn-revenue">
            <i class="ti ti-chart-bar" style="margin-right:6px"></i>Báo cáo doanh thu &amp; kinh doanh
        </button>
        <button type="button" class="dash-tab-btn" onclick="switchAdminTab('tab-members')" id="tab-btn-members">
            <i class="ti ti-rosette-discount-check" style="margin-right:6px"></i>Báo cáo hội viên
        </button>
    </div>

    <%-- =========================================================================
         TAB 1: BẢNG ĐIỀU KHIỂN (Screen 1)
         ========================================================================= --%>
    <div id="tab-overview" class="tab-pane active">
        <div class="page-head">
            <div>
                <div class="screen-bc">
                    <span>● PHÂN TÍCH &amp; VẬN HÀNH CỬA HÀNG</span>
                </div>
                <h1 style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
                    BẢNG ĐIỀU KHIỂN
                    <span class="pill-badge green" id="admin-live-badge" style="font-size:11px; padding:4px 10px; cursor:pointer;" onclick="fetchLiveDashboardStats()" title="Bấm để đồng bộ ngay lập tức">
                        <span style="width:7px; height:7px; border-radius:50%; background:#16a34a; display:inline-block; box-shadow:0 0 0 2px #bbf7d0;"></span>
                        THỜI GIAN THỰC
                    </span>
                </h1>
                <p class="page-sub">Tổng quan về hiệu suất kinh doanh, đơn hàng, tồn kho và chương trình hội viên.</p>
            </div>

            <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
                <form class="range" method="get" action="${ctx}/admin" id="range-form">
                    <i class="ti ti-calendar"></i>
                    <input type="date" name="from" id="from" value="${filterFrom}" aria-label="Từ ngày">
                    <span class="sep">→</span>
                    <input type="date" name="to" id="to" value="${filterTo}" aria-label="Đến ngày">
                    <button type="button" class="chip" data-preset="7">7 ngày</button>
                    <button type="button" class="chip on" data-preset="30">30 ngày</button>
                    <button type="submit" id="range-submit"><i class="ti ti-filter"></i> Lọc</button>
                </form>
                <a href="javascript:window.print()" class="export-btn"><i class="ti ti-download"></i>Xuất báo cáo</a>
            </div>
        </div>

        <%-- Quick actions --%>
        <div class="quick">
            <span class="quick-label">THAO TÁC NHANH:</span>
            <a class="qbtn primary" href="${ctx}/staff/products/new"><i class="ti ti-circle-plus"></i>+ Thêm sản phẩm</a>
            <a class="qbtn" style="background:#fee2e2; border-color:#fca5a5; color:#991b1b" href="${ctx}/staff/flash-sales/new"><i class="ti ti-bolt" style="color:#ef4444"></i>Tạo Flash Sale</a>
            <a class="qbtn" href="${ctx}/staff/orders"><i class="ti ti-receipt"></i>Xem đơn hàng</a>
            <a class="qbtn" href="${ctx}/staff/lots"><i class="ti ti-building-warehouse"></i>Xem tồn kho</a>
            <a class="qbtn" href="javascript:switchAdminTab('tab-revenue')"><i class="ti ti-chart-bar"></i>Xem báo cáo</a>
        </div>

        <%-- 4 KPI Cards --%>
        <section class="grid g-4">
            <div class="panel kpi reveal">
                <div class="kpi-top">
                    <span class="kpi-label">Tổng doanh thu</span>
                    <span class="kpi-ico"><i class="ti ti-coin"></i></span>
                </div>
                <div class="kpi-value" id="admin-kpi-revenue">
                    <c:choose>
                        <c:when test="${stats != null && stats.grossRevenue != null}">
                            ₫<fmt:formatNumber value="${stats.grossRevenue}" type="number"/>
                        </c:when>
                        <c:otherwise>₫0</c:otherwise>
                    </c:choose>
                </div>
                <div class="kpi-meta">
                    <span class="badge ok"><i class="ti ti-trending-up"></i>Doanh thu ròng:</span> ₫<fmt:formatNumber value="${stats != null ? stats.netRevenue : 0}" type="number"/>
                </div>
            </div>

            <div class="panel kpi reveal">
                <div class="kpi-top">
                    <span class="kpi-label">Tổng đơn hoàn tất</span>
                    <span class="kpi-ico orange"><i class="ti ti-shopping-cart"></i></span>
                </div>
                <div class="kpi-value" id="admin-kpi-orders">
                    <c:choose>
                        <c:when test="${stats != null && stats.completedOrders != null}">
                            ${stats.completedOrders}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </div>
                <div class="kpi-meta">
                    <span class="badge warn"><i class="ti ti-clock"></i>Đơn chờ duyệt:</span> ${stats != null ? stats.pendingOrders : 0}
                </div>
            </div>

            <div class="panel kpi reveal">
                <div class="kpi-top">
                    <span class="kpi-label">Khách hàng mới</span>
                    <span class="kpi-ico blue"><i class="ti ti-users"></i></span>
                </div>
                <div class="kpi-value" id="admin-kpi-customers">
                    <c:choose>
                        <c:when test="${stats != null && stats.newCustomers != null}">
                            ${stats.newCustomers}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </div>
                <div class="kpi-meta">
                    <span class="badge ok">Đã đăng ký</span> trong khoảng thời gian chọn
                </div>
            </div>

            <a class="panel kpi reveal" href="${ctx}/staff/alerts" style="color:inherit">
                <div class="kpi-top">
                    <span class="kpi-label">Sản phẩm sắp hết hàng</span>
                    <span class="kpi-ico red"><i class="ti ti-alert-triangle"></i></span>
                </div>
                <div class="kpi-value red" id="admin-kpi-alerts">
                    <c:choose>
                        <c:when test="${alertSummary != null && alertSummary.lowStockCount != null}">
                            ${alertSummary.lowStockCount}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </div>
                <div class="kpi-meta">
                    <span class="badge red">Cảnh báo kho</span> ${alertSummary != null ? alertSummary.redLotCount : 0} lô sắp hết hạn
                </div>
            </a>
        </section>

        <%-- Doanh thu & Trạng thái đơn (Screen 1 Charts) --%>
        <section class="grid g-3-1">
            <%-- Khung Xu hướng doanh thu theo ngày chuẩn mẫu --%>
            <div class="panel" style="padding:24px; border-radius:16px;">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:24px; flex-wrap:wrap; gap:12px;">
                    <div>
                        <h3 style="font-size:17px; font-weight:800; color:#1e293b; margin:0 0 4px 0;">Xu hướng doanh thu</h3>
                        <p style="font-size:13px; color:#64748b; margin:0;">Doanh thu trong kỳ được chọn (Tháng 10/2026)</p>
                    </div>
                    <div style="display:flex; align-items:center; gap:20px; font-size:13px; font-weight:600; color:#64748b;">
                        <span style="display:inline-flex; align-items:center; gap:8px;">
                            <span style="width:13px; height:13px; border-radius:3px; background:#ea580c; display:inline-block;"></span>
                            Tổng doanh thu
                        </span>
                        <span style="display:inline-flex; align-items:center; gap:8px;">
                            <span style="width:18px; height:2.5px; background:#64748b; border-radius:2px; display:inline-block;"></span>
                            Mục tiêu
                        </span>
                    </div>
                </div>

                <div class="trend-chart-wrapper" id="trendChartWrapper1" style="position:relative; width:100%; user-select:none;">
                    <div style="display:flex; height:240px; position:relative;">
                        <div style="width:36px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-start; font-size:12px; font-weight:600; color:#94a3b8; padding-bottom:2px; flex-shrink:0;">
                            <span>80</span>
                            <span>60</span>
                            <span>40</span>
                            <span>20</span>
                            <span>0</span>
                        </div>

                        <div class="trend-plot-area" style="flex:1; position:relative; height:100%;">
                            <div style="position:absolute; top:7px; left:0; right:0; border-top:1px dashed #f1f5f9; pointer-events:none;"></div>
                            <div style="position:absolute; top:25%; left:0; right:0; border-top:1px dashed #f1f5f9; pointer-events:none;"></div>
                            <div style="position:absolute; top:50%; left:0; right:0; border-top:1px dashed #f1f5f9; pointer-events:none;"></div>
                            <div style="position:absolute; top:75%; left:0; right:0; border-top:1px dashed #f1f5f9; pointer-events:none;"></div>
                            <div style="position:absolute; bottom:0; left:0; right:0; border-top:1px solid #e2e8f0; pointer-events:none;"></div>

                            <div class="trend-bars-container" style="position:absolute; inset:0; display:flex; align-items:flex-end; gap:5px; padding:0 2px;">
                            </div>
                        </div>
                    </div>

                    <div class="trend-hover-tooltip" style="position:absolute; display:none; background:#f2ebe3; border-radius:12px; padding:8px 14px; box-shadow:0 6px 20px rgba(0,0,0,0.12); pointer-events:none; z-index:100; transition:opacity 0.15s ease; white-space:nowrap;">
                        <div style="display:flex; align-items:center; gap:8px; font-size:13px; font-weight:700; color:#1e293b;">
                            <span style="width:8px; height:8px; border-radius:50%; background:#ea580c; display:inline-block; flex-shrink:0;"></span>
                            <span>Ngày <span class="trend-tt-date">24/10</span>: <b class="trend-tt-amount" style="color:#1e293b;">₫8,450,000</b></span>
                        </div>
                        <div class="trend-tt-sub" style="font-size:11px; font-weight:600; color:#64748b; margin-top:2px; padding-left:16px;">
                            Đỉnh điểm Flash Sale
                        </div>
                    </div>

                    <div style="display:flex; margin-left:36px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
                        <span>01/10</span>
                        <span>06/10</span>
                        <span>11/10</span>
                        <span>16/10</span>
                        <span>21/10</span>
                        <span>26/10</span>
                        <span>31/10</span>
                    </div>
                </div>
            </div>

            <%-- Donut Trạng thái đơn hàng --%>
            <div class="panel">
                <div class="panel-head">
                    <div>
                        <h3>Trạng thái đơn hàng</h3>
                        <p>Tiến độ thực hiện theo thời gian thực</p>
                    </div>
                    <span class="kpi-ico" style="width:34px; height:34px; font-size:16px"><i class="ti ti-chart-pie"></i></span>
                </div>

                <div class="donut-wrap" style="padding:10px 0">
                    <div style="position:relative; width:180px; height:180px; display:grid; place-items:center;">
                        <svg viewBox="0 0 42 42" style="width:100%; height:100%; transform:rotate(-90deg);" id="donutChartSvg">
                            <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#e5e7eb" stroke-width="4.5"/>
                            <g id="donutSegmentsGroup">
                                <!-- Donut segments dynamically rendered by JS -->
                            </g>
                        </svg>
                        <div style="position:absolute; text-align:center;">
                            <c:set var="totalOrdersCount" value="0"/>
                            <c:if test="${not empty stats.ordersByStatus}">
                                <c:forEach var="st" items="${stats.ordersByStatus}">
                                    <c:set var="totalOrdersCount" value="${totalOrdersCount + st.count}"/>
                                </c:forEach>
                            </c:if>
                            <b id="donutTotalCount" style="display:block; font-size:22px; font-weight:800; color:var(--text-logo)">${totalOrdersCount > 0 ? totalOrdersCount : (stats != null ? stats.completedOrders : 0)}</b>
                            <span style="font-size:10px; font-weight:800; text-transform:uppercase; color:var(--text-muted); letter-spacing:.05em">TỔNG ĐƠN HÀNG</span>
                        </div>
                    </div>
                </div>

                <div id="donutLegendContainer" style="display:grid; grid-template-columns:1fr 1fr; gap:8px; font-size:12px; margin-top:8px">
                    <c:choose>
                        <c:when test="${not empty stats.ordersByStatus}">
                            <c:forEach var="st" items="${stats.ordersByStatus}">
                                <div>
                                    <span class="legend-dot" style="background:${st.code == 'COMPLETED' ? '#10b981' : (st.code == 'SHIPPED' ? '#06b6d4' : (st.code == 'PROCESSING' ? '#3b82f6' : (st.code == 'CONFIRMED' ? '#f59e0b' : (st.code == 'PENDING' ? '#ea580c' : '#ef4444'))))}"></span>
                                    <b>${st.label}:</b> <small style="color:var(--text-muted)">(${st.count})</small>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div><span class="legend-dot" style="background:#10b981"></span><b>Hoàn tất:</b> <small style="color:var(--text-muted)">(0)</small></div>
                            <div><span class="legend-dot" style="background:#06b6d4"></span><b>Đang giao:</b> <small style="color:var(--text-muted)">(0)</small></div>
                            <div><span class="legend-dot" style="background:#3b82f6"></span><b>Đang xử lý:</b> <small style="color:var(--text-muted)">(0)</small></div>
                            <div><span class="legend-dot" style="background:#f59e0b"></span><b>Đã xác nhận:</b> <small style="color:var(--text-muted)">(0)</small></div>
                            <div><span class="legend-dot" style="background:#ea580c"></span><b>Chờ duyệt:</b> <small style="color:var(--text-muted)">(0)</small></div>
                            <div><span class="legend-dot" style="background:#ef4444"></span><b>Đã hủy:</b> <small style="color:var(--text-muted)">(0)</small></div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="panel-foot">
                    <span style="font-weight:700; color:#10b981"><i class="ti ti-check" style="margin-right:4px"></i>Dữ liệu thời gian thực từ Database</span>
                    <a class="link-more" href="${ctx}/staff/orders">Quản lý đơn <i class="ti ti-arrow-right"></i></a>
                </div>
            </div>
        </section>

        <%-- Cảnh báo tồn kho & Chương trình hội viên --%>
        <section class="grid g-1-1">
            <%-- Cảnh báo tồn kho --%>
            <div class="panel">
                <div class="panel-head">
                    <div>
                        <div style="display:flex; align-items:center; gap:8px">
                            <h3>Cảnh báo tồn kho</h3>
                            <span class="pill-badge red">Xuất hàng cận date ngay</span>
                        </div>
                    </div>
                    <input type="search" placeholder="Tìm kiếm mã SKU..." style="padding:6px 10px; border-radius:10px; font-size:12px; border:1px solid var(--line); width:150px">
                </div>

                <table>
                    <thead>
                    <tr>
                        <th>SẢN PHẨM</th>
                        <th>MÃ SKU</th>
                        <th>TỒN KHO / TỐI THIỂU</th>
                        <th>TRẠNG THÁI</th>
                        <th>THAO TÁC</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty lowStockProducts}">
                            <c:forEach var="item" items="${lowStockProducts}">
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px">
                                            <c:if test="${not empty item.imageUrl}">
                                                <img src="${ctx}${item.imageUrl}" alt="" style="width:36px; height:36px; border-radius:6px; object-fit:contain; background:#fff; border:1px solid var(--line)" onerror="this.style.display='none'">
                                            </c:if>
                                            <div>
                                                <b><c:out value="${item.name}"/></b>
                                            </div>
                                        </div>
                                    </td>
                                    <td><code><c:out value="${item.sku}"/></code></td>
                                    <td>
                                        <b style="color:${item.sellableQty <= item.threshold ? '#ef4444' : '#ea580c'}">${item.sellableQty}</b> / ${item.threshold}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.outOfStock}">
                                                <span class="pill-badge red">Hết hàng</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="pill-badge orange">Sắp hết hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <a href="${ctx}/staff/lots/new" class="act-icon" title="Nhập thêm hàng" style="background:#ea580c; color:#fff; width:auto; padding:4px 8px; font-size:12px; font-weight:700; border-radius:8px; text-decoration:none">Nhập thêm</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" style="text-align:center; padding:24px; color:var(--text-muted)">
                                    <i class="ti ti-circle-check" style="color:#10b981; font-size:18px; vertical-align:middle; margin-right:6px"></i>Tất cả sản phẩm đều có mức tồn kho an toàn
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

                <div class="panel-foot">
                    <span>Dữ liệu tồn kho thời gian thực</span>
                    <a class="link-more" href="${ctx}/staff/alerts">Quản lý tồn kho nâng cao <i class="ti ti-arrow-right"></i></a>
                </div>
            </div>

            <%-- Chương trình hội viên --%>
            <div class="panel">
                <div class="panel-head">
                    <div>
                        <h3>Chương trình hội viên</h3>
                        <p>Phân bổ hội viên trên các tài khoản hoạt động</p>
                    </div>
                    <div style="display:flex; align-items:center; gap:8px">
                        <span class="pill-badge gold">
                            <i class="ti ti-rosette-discount-check"></i>
                            <span id="tier-total-count">
                                <c:choose>
                                    <c:when test="${not empty stats.customersByTier}">
                                        ${stats.customersByTier[0].count + stats.customersByTier[1].count + stats.customersByTier[2].count + stats.customersByTier[3].count}
                                    </c:when>
                                    <c:otherwise>0</c:otherwise>
                                </c:choose>
                            </span> Hội viên
                        </span>
                    </div>
                </div>

                <%-- Multi-segment progress bar --%>
                <div class="tier-bar" style="height:12px; margin:10px 0 16px" id="tierBarContainer">
                    <span id="tier-bar-bronze" style="width:50%; background:#b45309" title="Đồng"></span>
                    <span id="tier-bar-silver" style="width:25%; background:#94a3b8" title="Bạc"></span>
                    <span id="tier-bar-gold" style="width:15%; background:#f59e0b" title="Vàng"></span>
                    <span id="tier-bar-diamond" style="width:10%; background:#0284c7" title="Kim Cương"></span>
                </div>

                <div class="tiles">
                    <div class="tile" style="border-left:4px solid #b45309">
                        <div class="tile-top"><span>🥉 Đồng (Bronze)</span><span class="tile-sub">Hạng khởi đầu</span></div>
                        <div class="tile-val" id="tier-val-bronze"><c:out value="${not empty stats.customersByTier ? stats.customersByTier[0].count : '0'}"/></div>
                        <div class="tile-sub">Khách hàng tích lũy</div>
                    </div>
                    <div class="tile" style="border-left:4px solid #94a3b8">
                        <div class="tile-top"><span>🥈 Bạc (Silver)</span><span class="tile-sub">Giảm 3%</span></div>
                        <div class="tile-val" id="tier-val-silver"><c:out value="${not empty stats.customersByTier ? stats.customersByTier[1].count : '0'}"/></div>
                        <div class="tile-sub">Từ 1.200.000đ</div>
                    </div>
                    <div class="tile" style="border-left:4px solid #f59e0b">
                        <div class="tile-top"><span>🥇 Vàng (Gold)</span><span class="tile-sub">Giảm 5%</span></div>
                        <div class="tile-val" id="tier-val-gold"><c:out value="${not empty stats.customersByTier ? stats.customersByTier[2].count : '0'}"/></div>
                        <div class="tile-sub">Từ 4.000.000đ</div>
                    </div>
                    <div class="tile" style="border-left:4px solid #0284c7">
                        <div class="tile-top"><span>💎 Kim cương</span><span class="tile-sub">Giảm 10%</span></div>
                        <div class="tile-val" id="tier-val-diamond"><c:out value="${not empty stats.customersByTier ? stats.customersByTier[3].count : '0'}"/></div>
                        <div class="tile-sub">Từ 10.000.000đ</div>
                    </div>
                </div>

                <div class="note" style="background:#fff7ee; color:#9a3412; border:1px solid #fed7aa; margin-top:16px">
                    <i class="ti ti-truck-delivery" style="color:#ea580c"></i>
                    <div><b>Đặc quyền Kim Cương:</b> Miễn phí vận chuyển cho mọi đơn hàng không giới hạn giá trị.</div>
                </div>

                <div class="panel-foot">
                    <a class="link-more" href="javascript:switchAdminTab('tab-members')">Xem quyền lợi &amp; Cài đặt hạng <i class="ti ti-arrow-right"></i></a>
                    <span class="hint">Cập nhật thời gian thực</span>
                </div>
            </div>
        </section>

        <%-- Sản phẩm bán chạy & Đơn hàng gần đây --%>
        <section class="grid g-1-1">
            <%-- Bán chạy nhất --%>
            <div class="panel">
                <div class="panel-head">
                    <div>
                        <h3>Sản phẩm bán chạy nhất</h3>
                        <p>Xếp hạng sản phẩm theo sản lượng bán</p>
                    </div>
                </div>

                <table>
                    <thead>
                    <tr>
                        <th style="width:40px">#</th>
                        <th>SẢN PHẨM</th>
                        <th class="num">ĐÃ BÁN</th>
                        <th class="num">DOANH THU</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty stats.topProducts}">
                            <c:forEach var="p" items="${stats.topProducts}" varStatus="pStatus">
                                <tr>
                                    <td><span class="rank r${pStatus.count}">${pStatus.count}</span></td>
                                    <td>
                                        <b><c:out value="${p.name}"/></b>
                                        <div class="sku">SKU: <c:out value="${p.sku}"/></div>
                                    </td>
                                    <td class="num"><b>${p.quantity} món</b></td>
                                    <td class="num" style="color:#ea580c; font-weight:800"><fmt:formatNumber value="${p.revenue}" type="number"/> ₫</td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4" style="text-align:center; padding:28px; color:var(--text-muted)">
                                    Chưa có dữ liệu sản phẩm bán ra trong khoảng thời gian này
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

                <div class="panel-foot">
                    <span>Hiển thị <c:out value="${not empty stats.topProducts ? stats.topProducts.size() : 0}"/> sản phẩm bán chạy</span>
                </div>
            </div>

            <%-- Đơn hàng gần đây --%>
            <div class="panel">
                <div class="panel-head">
                    <div>
                        <h3>Đơn hàng gần đây</h3>
                        <p>Lượng giao dịch đơn hàng mới theo thời gian thực</p>
                    </div>
                </div>

                <table>
                    <thead>
                    <tr>
                        <th>MÃ ĐƠN</th>
                        <th>KHÁCH HÀNG</th>
                        <th>NGÀY &amp; GIỜ</th>
                        <th class="num">TỔNG TIỀN</th>
                        <th>THANH TOÁN</th>
                        <th>TRẠNG THÁI</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty recentOrders}">
                            <c:forEach var="o" items="${recentOrders}">
                                <tr>
                                    <td><a href="${ctx}/staff/orders" style="font-weight:800; color:#ea580c">#ORD-${o.id}</a></td>
                                    <td>
                                        <b><c:out value="${empty o.customerName ? 'Khách hàng #' += o.id : o.customerName}"/></b><br>
                                        <small style="color:var(--text-muted)"><c:out value="${empty o.customerEmail ? 'N/A' : o.customerEmail}"/></small>
                                    </td>
                                    <td>${o.createdAtText}</td>
                                    <td class="num"><b>₫<fmt:formatNumber value="${o.totalAmount}" type="number"/></b></td>
                                    <td>
                                        <span class="pill-badge ${o.paymentMethodLabel == 'VNPay' ? 'green' : 'orange'}">
                                            ${o.paymentMethodLabel}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="pill-badge ${o.status == 'COMPLETED' ? 'green' : (o.status == 'SHIPPED' or o.status == 'PROCESSING' ? 'blue' : (o.status == 'CONFIRMED' ? 'gold' : (o.status == 'CANCELLED' ? 'red' : 'gray')))}">
                                            ${o.status.label}
                                        </span>
                                    </td>
                                    <td><a href="${ctx}/staff/orders" class="act-icon"><i class="ti ti-eye"></i></a></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align:center; padding:28px; color:var(--text-muted)">
                                    Chưa có đơn hàng nào phát sinh
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

                <div class="panel-foot">
                    <span>Hiển thị <c:out value="${not empty recentOrders ? recentOrders.size() : 0}"/> đơn hàng gần đây</span>
                    <a class="link-more" href="${ctx}/staff/orders">Quản lý toàn bộ đơn hàng <i class="ti ti-arrow-right"></i></a>
                </div>
            </div>
        </section>
    </div>

    <%-- =========================================================================
         TAB 2: BÁO CÁO DOANH THU & KINH DOANH (Screen 12)
         ========================================================================= --%>
    <div id="tab-revenue" class="tab-pane">
        <%-- Tiêu đề và nút tác vụ chính --%>
        <div style="margin-bottom:20px;">
            <div class="screen-bc" style="font-size:13px; color:#64748b; margin-bottom:8px; font-weight:600;">
                <span>Phân tích &amp; Hỗ trợ</span> <span class="sep" style="margin:0 6px; color:#cbd5e1;">&gt;</span> <span class="current" style="color:#1e293b; font-weight:700;">Báo cáo doanh thu &amp; Kinh doanh</span>
            </div>
            <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:16px;">
                <div>
                    <h1 style="font-size:24px; font-weight:800; color:#1e293b; margin:0 0 6px 0; display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                        BÁO CÁO DOANH THU &amp; KINH DOANH
                        <span style="display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:99px; background:#fff7ed; color:#ea580c; border:1px solid #ffedd5; font-size:11px; font-weight:800; letter-spacing:0.3px;">
                            <i class="ti ti-lock" style="font-size:12px;"></i> DỮ LIỆU ĐỘC QUYỀN ADMIN
                        </span>
                    </h1>
                    <p style="font-size:13.5px; color:#64748b; margin:0;">Theo dõi hiệu quả bán hàng, xu hướng đơn hàng và kết quả kinh doanh tổng thể.</p>
                </div>
                <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
                    <button type="button" class="export-btn" onclick="alert('Đã lên lịch gửi báo cáo định kỳ tự động mỗi 08:00 sáng thứ Hai hàng tuần qua email Quản trị viên!')" style="background:#fff; border:1px solid #cbd5e1; border-radius:10px; padding:9px 15px; font-size:13px; font-weight:700; color:#334155; cursor:pointer;">
                        <i class="ti ti-calendar-time" style="font-size:16px; color:#64748b;"></i> Đặt lịch gửi báo cáo tự động
                    </button>
                    <button type="button" class="export-btn" onclick="window.print()" style="background:#fff; border:1px solid #cbd5e1; border-radius:10px; padding:9px 15px; font-size:13px; font-weight:700; color:#334155; cursor:pointer;">
                        <i class="ti ti-printer" style="font-size:16px; color:#64748b;"></i> In báo cáo
                    </button>
                    <button type="button" class="export-btn" onclick="exportRevenueReportCsv()" style="background:#ea580c; border:1px solid #ea580c; color:#fff; border-radius:10px; padding:9px 18px; font-size:13px; font-weight:700; cursor:pointer; box-shadow:0 2px 6px rgba(234,88,12,0.25);">
                        <i class="ti ti-download" style="font-size:16px;"></i> Xuất báo cáo
                    </button>
                </div>
            </div>
        </div>

        <%-- Khung Bộ Lọc & Chọn Nhanh (Filter Bar Screen 12) --%>
        <div class="rev-filter-box">
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)) 100px 140px; gap:14px; align-items:flex-end; margin-bottom:16px;">
                <div class="rev-filter-field">
                    <label>Từ ngày</label>
                    <div class="rev-input-wrap">
                        <i class="ti ti-calendar" style="color:#94a3b8; font-size:16px;"></i>
                        <input type="date" id="screen12FilterFrom" value="${filterFrom != null ? filterFrom : '2026-10-01'}" onchange="applyScreen12Filter()">
                    </div>
                </div>
                <div class="rev-filter-field">
                    <label>Đến ngày</label>
                    <div class="rev-input-wrap">
                        <i class="ti ti-calendar" style="color:#94a3b8; font-size:16px;"></i>
                        <input type="date" id="screen12FilterTo" value="${filterTo != null ? filterTo : '2026-10-31'}" onchange="applyScreen12Filter()">
                    </div>
                </div>
                <div class="rev-filter-field">
                    <label>Trạng thái đơn</label>
                    <div class="rev-input-wrap">
                        <i class="ti ti-filter" style="color:#94a3b8; font-size:16px;"></i>
                        <select id="screen12FilterStatus" onchange="applyScreen12Filter()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="COMPLETED">Đã hoàn thành</option>
                            <option value="SHIPPED">Đang giao</option>
                            <option value="PROCESSING">Đang xử lý</option>
                            <option value="CONFIRMED">Đã xác nhận</option>
                            <option value="CANCELLED">Đã hủy</option>
                            <option value="RETURNED">Đã trả hàng</option>
                        </select>
                    </div>
                </div>
                <div class="rev-filter-field">
                    <label>Phương thức thanh toán</label>
                    <div class="rev-input-wrap">
                        <i class="ti ti-credit-card" style="color:#94a3b8; font-size:16px;"></i>
                        <select id="screen12FilterPayment" onchange="applyScreen12Filter()">
                            <option value="">Tất cả phương thức</option>
                            <option value="VNPAY">Cổng VNPay</option>
                            <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                        </select>
                    </div>
                </div>
                <div>
                    <button type="button" class="chip" onclick="resetScreen12Filter()" style="width:100%; height:40px; justify-content:center; border-radius:10px; font-weight:700; border:1px solid #cbd5e1; background:#fff; cursor:pointer;">
                        <i class="ti ti-refresh" style="font-size:15px; margin-right:4px;"></i> Đặt lại
                    </button>
                </div>
                <div>
                    <button type="button" onclick="applyScreen12Filter()" style="width:100%; height:40px; background:#ea580c; color:#fff; border:none; border-radius:10px; font-size:13px; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:6px; box-shadow:0 2px 6px rgba(234,88,12,0.25);">
                        <i class="ti ti-filter" style="font-size:15px;"></i> Áp dụng bộ lọc
                    </button>
                </div>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; padding-top:14px; border-top:1px dashed #f1f5f9;">
                <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                    <span style="font-size:12px; font-weight:800; color:#64748b; margin-right:4px; letter-spacing:0.5px;">CHỌN NHANH:</span>
                    <button type="button" class="rev-quick-chip" id="chip-today" onclick="selectQuickChip(this, 'today')">Hôm nay</button>
                    <button type="button" class="rev-quick-chip" id="chip-week" onclick="selectQuickChip(this, 'week')">Tuần này</button>
                    <button type="button" class="rev-quick-chip active" id="chip-month" onclick="selectQuickChip(this, 'month')">Tháng này (Tháng 10/2026)</button>
                    <button type="button" class="rev-quick-chip" id="chip-year" onclick="selectQuickChip(this, 'year')">Năm nay</button>
                </div>
                <div style="font-size:12.5px; color:#64748b; font-weight:600; display:inline-flex; align-items:center; gap:7px;">
                    <span style="width:7px; height:7px; border-radius:50%; background:#16a34a; display:inline-block; box-shadow:0 0 0 2px #bbf7d0;"></span>
                    <span>Dữ liệu đồng bộ: 5 phút trước &bull; Đơn vị tiền tệ: Việt Nam Đồng (VNĐ ₫)</span>
                </div>
            </div>
        </div>

        <%-- 4 Thẻ KPI Chuẩn Screen 12 --%>
        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap:18px; margin-bottom:22px;">
            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">TỔNG DOANH THU</span>
                <div class="rev-kpi-icon" style="background:#fef3c7; color:#92400e;">
                    <i class="ti ti-cash"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiRevenue">
                    ₫<fmt:formatNumber value="${stats != null && stats.grossRevenue != null && stats.grossRevenue > 0 ? stats.grossRevenue : 35616708}" type="number"/>
                </div>
                <div style="display:flex; align-items:center; gap:6px;">
                    <span class="pill-badge green"><i class="ti ti-arrow-up-right"></i> +14.2%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">TỔNG ĐƠN HÀNG</span>
                <div class="rev-kpi-icon" style="background:#ffedd5; color:#c2410c;">
                    <i class="ti ti-shopping-bag"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiOrders">
                    66
                </div>
                <div style="display:flex; align-items:center; gap:6px;">
                    <span class="pill-badge green"><i class="ti ti-arrow-up-right"></i> +8.6%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">GIÁ TRỊ TRUNG BÌNH ĐƠN (AOV)</span>
                <div class="rev-kpi-icon" style="background:#fed7aa; color:#9a3412;">
                    <i class="ti ti-receipt-2"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiAov">
                    ₫<fmt:formatNumber value="${stats != null && stats.completedOrders > 0 ? stats.grossRevenue / stats.completedOrders : 636013}" type="number" maxFractionDigits="0"/>
                </div>
                <div style="display:flex; align-items:center; gap:6px;">
                    <span class="pill-badge green"><i class="ti ti-arrow-up-right"></i> +5.1%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">ĐƠN HÀNG HOÀN THÀNH</span>
                <div class="rev-kpi-icon" style="background:#dcfce7; color:#166534;">
                    <i class="ti ti-circle-check"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiCompleted">
                    <span id="screen12KpiCompletedCount"><fmt:formatNumber value="${stats != null && stats.completedOrders > 0 ? stats.completedOrders : 56}" type="number"/></span> <span style="font-size:14px; font-weight:600; color:#64748b;" id="screen12KpiCompletedPct">(84.8%)</span>
                </div>
                <div style="display:flex; align-items:center; gap:6px;">
                    <span class="pill-badge green" id="screen12KpiSuccessRate"><i class="ti ti-check"></i> 84.8%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">tỷ lệ thành công</span>
                </div>
            </div>
        </div>

        <%-- Row 2: 2 Biểu đồ Xu hướng (Doanh thu & Đơn hàng) chuẩn Figma --%>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; margin-bottom:22px;">
            <%-- Biểu đồ 1: Xu hướng doanh thu --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Xu hướng doanh thu</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;">Doanh thu trong kỳ được chọn (Tháng 10/2026)</p>
                    </div>
                    <div style="display:flex; align-items:center; gap:16px; font-size:12.5px; font-weight:600; color:#64748b;">
                        <span style="display:inline-flex; align-items:center; gap:6px;">
                            <span style="width:12px; height:12px; border-radius:3px; background:#ea580c; display:inline-block;"></span>
                            Tổng doanh thu
                        </span>
                        <span style="display:inline-flex; align-items:center; gap:6px;">
                            <span style="width:16px; height:2.5px; background:#64748b; border-radius:2px; display:inline-block;"></span>
                            Mục tiêu
                        </span>
                    </div>
                </div>

                <div class="trend-chart-wrapper" id="screen12RevenueWrapper" style="position:relative; width:100%; user-select:none;">
                    <div style="display:flex; height:240px; position:relative;">
                        <div style="width:32px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-start; font-size:12px; font-weight:600; color:#94a3b8; padding-bottom:2px; flex-shrink:0;">
                            <span>80</span>
                            <span>60</span>
                            <span>40</span>
                            <span>20</span>
                            <span>0</span>
                        </div>
                        <div class="trend-plot-area" style="flex:1; position:relative; height:100%;">
                            <div style="position:absolute; top:7px; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:25%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:50%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:75%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; bottom:0; left:0; right:0; border-top:1px dashed #cbd5e1; pointer-events:none;"></div>

                            <div class="trend-bars-container rev-bars-revenue" style="position:absolute; inset:0; display:flex; align-items:flex-end; gap:4px; padding:0 2px;">
                            </div>
                        </div>
                    </div>

                    <div class="trend-hover-tooltip rev-tt-revenue" style="position:absolute; display:none; background:#f2ebe3; border-radius:12px; padding:8px 14px; box-shadow:0 8px 24px rgba(0,0,0,0.12); pointer-events:none; z-index:100; transition:opacity 0.15s ease; white-space:nowrap;">
                        <div style="display:flex; align-items:center; gap:8px; font-size:13px; font-weight:700; color:#1e293b;">
                            <span style="width:8px; height:8px; border-radius:50%; background:#ea580c; display:inline-block; flex-shrink:0;"></span>
                            <span>Ngày <span class="trend-tt-date">24/10</span>: <b class="trend-tt-amount" style="color:#1e293b;">₫8,450,000</b></span>
                        </div>
                        <div class="trend-tt-sub" style="font-size:11px; font-weight:600; color:#64748b; margin-top:2px; padding-left:16px;">
                            Đỉnh điểm Flash Sale
                        </div>
                    </div>

                    <div style="display:flex; margin-left:32px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
                        <span>01/10</span>
                        <span>06/10</span>
                        <span>11/10</span>
                        <span>16/10</span>
                        <span>21/10</span>
                        <span>26/10</span>
                        <span>31/10</span>
                    </div>
                </div>
            </div>

            <%-- Biểu đồ 2: Xu hướng đơn hàng --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Xu hướng đơn hàng</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;">Khối lượng đơn hàng hàng ngày (Tháng 10/2026)</p>
                    </div>
                    <div>
                        <span id="screen12OrdersAvgBadge" style="background:#fff7ed; color:#ea580c; border:1px solid #fed7aa; padding:5px 12px; border-radius:99px; font-size:12px; font-weight:700; display:inline-flex; align-items:center; gap:5px;">
                            <i class="ti ti-chart-bar" style="font-size:13px;"></i> Trung bình: 2.1 đơn/ngày
                        </span>
                    </div>
                </div>

                <div class="trend-chart-wrapper" id="screen12OrdersWrapper" style="position:relative; width:100%; user-select:none;">
                    <div style="display:flex; height:240px; position:relative;">
                        <div style="width:32px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-start; font-size:12px; font-weight:600; color:#94a3b8; padding-bottom:2px; flex-shrink:0;">
                            <span>80</span>
                            <span>60</span>
                            <span>40</span>
                            <span>20</span>
                            <span>0</span>
                        </div>
                        <div class="trend-plot-area" style="flex:1; position:relative; height:100%;">
                            <div style="position:absolute; top:7px; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:25%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:50%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; top:75%; left:0; right:0; border-top:1px dashed #e2e8f0; pointer-events:none;"></div>
                            <div style="position:absolute; bottom:0; left:0; right:0; border-top:1px dashed #cbd5e1; pointer-events:none;"></div>

                            <div class="trend-bars-container rev-bars-orders" style="position:absolute; inset:0; display:flex; align-items:flex-end; gap:4px; padding:0 2px;">
                            </div>
                        </div>
                    </div>

                    <div class="trend-hover-tooltip rev-tt-orders" style="position:absolute; display:none; background:#f2ebe3; border-radius:12px; padding:8px 14px; box-shadow:0 8px 24px rgba(0,0,0,0.12); pointer-events:none; z-index:100; transition:opacity 0.15s ease; white-space:nowrap;">
                        <div style="display:flex; align-items:center; gap:8px; font-size:13px; font-weight:700; color:#1e293b;">
                            <span style="width:8px; height:8px; border-radius:50%; background:#ea580c; display:inline-block; flex-shrink:0;"></span>
                            <span>Ngày <span class="trend-tt-date">24/10</span>: <b class="trend-tt-amount" style="color:#1e293b;">68 đơn hàng</b></span>
                        </div>
                        <div class="trend-tt-sub" style="font-size:11px; font-weight:600; color:#64748b; margin-top:2px; padding-left:16px;">
                            Khối lượng cao nhất tháng
                        </div>
                    </div>

                    <div style="display:flex; margin-left:32px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
                        <span>01/10</span>
                        <span>06/10</span>
                        <span>11/10</span>
                        <span>16/10</span>
                        <span>21/10</span>
                        <span>26/10</span>
                        <span>31/10</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Row 3: Doanh thu theo danh mục & Tóm tắt trạng thái đơn hàng (2 Cột) --%>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; margin-bottom:22px;">
            <%-- Doanh thu theo danh mục sản phẩm --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Doanh thu theo danh mục sản phẩm</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;">Phân bổ doanh thu theo từng nhóm thức ăn thú cưng</p>
                    </div>
                    <span class="kpi-ico" style="width:34px; height:34px; font-size:16px; border-radius:10px;"><i class="ti ti-chart-pie"></i></span>
                </div>

                <div style="display:flex; align-items:center; gap:24px; flex-wrap:wrap; padding:6px 0;">
                    <%-- Donut chart SVG --%>
                    <div style="position:relative; width:160px; height:160px; display:grid; place-items:center; flex-shrink:0;">
                        <svg viewBox="0 0 42 42" style="width:100%; height:100%; transform:rotate(-90deg);">
                            <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#f1f5f9" stroke-width="5"></circle>
                            <circle id="screen12DonutCatCircle" cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#ea580c" stroke-width="5" stroke-dasharray="100 0" stroke-dashoffset="0"></circle>
                        </svg>
                        <div style="position:absolute; text-align:center;">
                            <small style="display:block; font-size:10px; font-weight:800; color:#94a3b8; text-transform:uppercase;">TỔNG CỘNG</small>
                            <strong style="font-size:16px; font-weight:800; color:#1e293b;" id="screen12CatTotal">₫34.0M</strong>
                        </div>
                    </div>

                    <%-- Danh sách tiến độ 4 nhóm danh mục --%>
                    <div style="flex:1; min-width:220px; display:flex; flex-direction:column; gap:12px;">
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#ea580c; display:inline-block;"></span>
                                    Thức ăn hạt cho mèo
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal1">₫33,996,708 <small style="color:#64748b; font-weight:600;">(100.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar1" style="height:100%; width:100%; background:#ea580c; border-radius:99px;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#f59e0b; display:inline-block;"></span>
                                    Pate &amp; Thức ăn ướt cho mèo
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal2">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar2" style="height:100%; width:0%; background:#f59e0b; border-radius:99px;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#7c2d12; display:inline-block;"></span>
                                    Thức ăn hạt cho chó
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal3">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar3" style="height:100%; width:0%; background:#7c2d12; border-radius:99px;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#fed7aa; display:inline-block;"></span>
                                    Bánh thưởng &amp; Snack huấn luyện
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal4">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar4" style="height:100%; width:0%; background:#fed7aa; border-radius:99px;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Tóm tắt trạng thái đơn hàng --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Tóm tắt trạng thái đơn hàng</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;" id="screen12StatusSubtitle">Phân bổ 66 đơn hàng trong kỳ</p>
                    </div>
                    <span class="kpi-ico" style="width:34px; height:34px; font-size:16px; border-radius:10px;"><i class="ti ti-chart-bar"></i></span>
                </div>

                <div style="display:flex; flex-direction:column; gap:12px; padding:6px 0;" id="screen12StatusListContainer">
                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                            <span style="display:inline-flex; align-items:center; gap:6px;">
                                <span style="width:8px; height:8px; border-radius:50%; background:#10b981; display:inline-block;"></span>
                                Đã hoàn thành
                            </span>
                            <span style="color:#1e293b;" id="screen12StCompleted">56 đơn <small style="color:#64748b; font-weight:600;">(84.8%)</small></span>
                        </div>
                        <div style="height:7px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                            <div id="screen12StBarCompleted" style="height:100%; width:84.8%; background:#10b981; border-radius:99px;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                            <span style="display:inline-flex; align-items:center; gap:6px;">
                                <span style="width:8px; height:8px; border-radius:50%; background:#ef4444; display:inline-block;"></span>
                                Đã hủy
                            </span>
                            <span style="color:#1e293b;" id="screen12StCancelled">4 đơn <small style="color:#64748b; font-weight:600;">(6.1%)</small></span>
                        </div>
                        <div style="height:7px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                            <div id="screen12StBarCancelled" style="height:100%; width:6.1%; background:#ef4444; border-radius:99px;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                            <span style="display:inline-flex; align-items:center; gap:6px;">
                                <span style="width:8px; height:8px; border-radius:50%; background:#8b5cf6; display:inline-block;"></span>
                                Đã trả hàng
                            </span>
                            <span style="color:#1e293b;" id="screen12StReturned">3 đơn <small style="color:#64748b; font-weight:600;">(4.5%)</small></span>
                        </div>
                        <div style="height:7px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                            <div id="screen12StBarReturned" style="height:100%; width:4.5%; background:#8b5cf6; border-radius:99px;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                            <span style="display:inline-flex; align-items:center; gap:6px;">
                                <span style="width:8px; height:8px; border-radius:50%; background:#f59e0b; display:inline-block;"></span>
                                Đang xử lý
                            </span>
                            <span style="color:#1e293b;" id="screen12StProcessing">2 đơn <small style="color:#64748b; font-weight:600;">(3.0%)</small></span>
                        </div>
                        <div style="height:7px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                            <div id="screen12StBarProcessing" style="height:100%; width:3.0%; background:#f59e0b; border-radius:99px;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                            <span style="display:inline-flex; align-items:center; gap:6px;">
                                <span style="width:8px; height:8px; border-radius:50%; background:#06b6d4; display:inline-block;"></span>
                                Đang giao
                            </span>
                            <span style="color:#1e293b;" id="screen12StShipped">1 đơn <small style="color:#64748b; font-weight:600;">(1.5%)</small></span>
                        </div>
                        <div style="height:7px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                            <div id="screen12StBarShipped" style="height:100%; width:1.5%; background:#06b6d4; border-radius:99px;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Row 4: Sản phẩm bán chạy nhất & Phương thức thanh toán --%>
        <div style="display:grid; grid-template-columns: 1.6fr 1fr; gap:20px; margin-bottom:22px;">
            <%-- Bảng sản phẩm bán chạy nhất --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Sản phẩm bán chạy nhất</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;">Xếp hạng theo tổng doanh thu</p>
                    </div>
                    <a href="${ctx}/staff/products" style="font-size:12.5px; font-weight:700; color:#ea580c; text-decoration:none; display:inline-flex; align-items:center; gap:4px;">
                        Xem toàn bộ danh mục <i class="ti ti-arrow-right"></i>
                    </a>
                </div>

                <div style="overflow-x:auto;">
                    <table class="rev-table">
                        <thead>
                        <tr>
                            <th>HẠNG &amp; SẢN PHẨM</th>
                            <th>MÃ SKU</th>
                            <th>DANH MỤC</th>
                            <th style="text-align:right;">SỐ LƯỢNG ĐÃ BÁN</th>
                            <th style="text-align:right;">DOANH THU</th>
                        </tr>
                        </thead>
                        <tbody id="screen12TopProductsTbody">
                        <c:choose>
                            <c:when test="${not empty stats.topProducts}">
                                <c:forEach var="p" items="${stats.topProducts}" varStatus="loop">
                                    <tr>
                                        <td>
                                            <div style="display:flex; align-items:center; gap:10px;">
                                                <span style="width:24px; height:24px; border-radius:50%; background:${loop.index == 0 ? '#ea580c' : (loop.index == 1 ? '#94a3b8' : (loop.index == 2 ? '#cbd5e1' : '#f1f5f9'))}; color:${loop.index < 2 ? '#fff' : '#475569'}; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">${loop.count}</span>
                                                <div>
                                                    <b style="color:#1e293b; font-size:13px; display:block;"><c:out value="${p.name}"/></b>
                                                    <small style="color:#64748b; font-size:11.5px;">Thức ăn thú cưng dinh dưỡng</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><span class="pill-badge gray" style="font-size:11px;"><c:out value="${p.sku}"/></span></td>
                                        <td><span style="padding:3px 8px; border-radius:99px; background:#fff7ed; color:#c2410c; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                        <td style="text-align:right; font-weight:700; color:#1e293b;"><c:out value="${p.quantity}"/></td>
                                        <td style="text-align:right; font-weight:800; color:#1e293b;">₫<fmt:formatNumber value="${p.revenue}" type="number"/></td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span style="width:24px; height:24px; border-radius:50%; background:#ea580c; color:#fff; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">1</span>
                                            <div>
                                                <b style="color:#1e293b; font-size:13px; display:block;">Hạt tiêu búi lông cho mèo Royal Canin Hairball Care 2kg</b>
                                                <small style="color:#64748b; font-size:11.5px;">Hỗ trợ tiêu búi lông cho mèo trưởng thành</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="pill-badge gray" style="font-size:11px;">RC-HAIRBALL-2000G</span></td>
                                    <td><span style="padding:3px 8px; border-radius:99px; background:#fff7ed; color:#c2410c; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                    <td style="text-align:right; font-weight:700; color:#1e293b;">10</td>
                                    <td style="text-align:right; font-weight:800; color:#1e293b;">₫6,600,000</td>
                                </tr>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span style="width:24px; height:24px; border-radius:50%; background:#94a3b8; color:#fff; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">2</span>
                                            <div>
                                                <b style="color:#1e293b; font-size:13px; display:block;">Hạt cho mèo mẹ và mèo con Royal Canin Mother &amp; Babycat 2kg</b>
                                                <small style="color:#64748b; font-size:11.5px;">Dành cho mèo mẹ mang thai &amp; mèo con</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="pill-badge gray" style="font-size:11px;">RC-MOTHERBABYCAT-2000G</span></td>
                                    <td><span style="padding:3px 8px; border-radius:99px; background:#ffedd5; color:#c2410c; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                    <td style="text-align:right; font-weight:700; color:#1e293b;">10</td>
                                    <td style="text-align:right; font-weight:800; color:#1e293b;">₫6,080,000</td>
                                </tr>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span style="width:24px; height:24px; border-radius:50%; background:#cbd5e1; color:#475569; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">3</span>
                                            <div>
                                                <b style="color:#1e293b; font-size:13px; display:block;">Hạt tiêu búi lông cho mèo Royal Canin Hairball Care 400g</b>
                                                <small style="color:#64748b; font-size:11.5px;">Gói nhỏ tiện lợi cho mèo trưởng thành</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="pill-badge gray" style="font-size:11px;">RC-HAIRBALL-400G</span></td>
                                    <td><span style="padding:3px 8px; border-radius:99px; background:#fef3c7; color:#92400e; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                    <td style="text-align:right; font-weight:700; color:#1e293b;">26</td>
                                    <td style="text-align:right; font-weight:800; color:#1e293b;">₫4,056,000</td>
                                </tr>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span style="width:24px; height:24px; border-radius:50%; background:#f1f5f9; color:#64748b; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">4</span>
                                            <div>
                                                <b style="color:#1e293b; font-size:13px; display:block;">Hạt cho mèo trưởng thành Royal Canin Fit 32 2kg</b>
                                                <small style="color:#64748b; font-size:11.5px;">Vận động vừa phải, dinh dưỡng toàn diện</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="pill-badge gray" style="font-size:11px;">RC-FIT32-2000G</span></td>
                                    <td><span style="padding:3px 8px; border-radius:99px; background:#fff7ed; color:#c2410c; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                    <td style="text-align:right; font-weight:700; color:#1e293b;">7</td>
                                    <td style="text-align:right; font-weight:800; color:#1e293b;">₫3,738,000</td>
                                </tr>
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span style="width:24px; height:24px; border-radius:50%; background:#f1f5f9; color:#64748b; display:grid; place-items:center; font-size:11px; font-weight:800; flex-shrink:0;">5</span>
                                            <div>
                                                <b style="color:#1e293b; font-size:13px; display:block;">Hạt cho mèo nuôi trong nhà Royal Canin Indoor 27 2kg</b>
                                                <small style="color:#64748b; font-size:11.5px;">Giảm mùi hôi phân, ít vận động</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="pill-badge gray" style="font-size:11px;">RC-INDOOR27-2000G</span></td>
                                    <td><span style="padding:3px 8px; border-radius:99px; background:#ffedd5; color:#c2410c; font-size:11px; font-weight:700;">Thức ăn cho mèo</span></td>
                                    <td style="text-align:right; font-weight:700; color:#1e293b;">5</td>
                                    <td style="text-align:right; font-weight:800; color:#1e293b;">₫2,935,000</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- Phương thức thanh toán --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Phương thức thanh toán</h3>
                        <p style="font-size:12.5px; color:#64748b; margin:0;">Tỷ trọng doanh thu 2 kênh thanh toán</p>
                    </div>
                    <span class="kpi-ico" style="width:34px; height:34px; font-size:16px; border-radius:10px;"><i class="ti ti-credit-card"></i></span>
                </div>

                <div style="display:flex; flex-direction:column; gap:14px;">
                    <%-- Kênh VNPay --%>
                    <div style="border:1px solid #fed7aa; border-radius:12px; padding:14px; background:#fffcf9;">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:34px; height:34px; border-radius:8px; background:#ea580c; color:#fff; display:grid; place-items:center; font-weight:800; font-size:13px;">VN</div>
                                <div>
                                    <b style="font-size:13.5px; color:#1e293b; display:block;">Cổng VNPay</b>
                                    <small style="color:#64748b; font-size:11.5px;">Thanh toán trực tuyến</small>
                                </div>
                            </div>
                            <span style="font-size:13px; font-weight:800; color:#ea580c;" id="screen12VnpayRevenuePct">46.1% Doanh thu</span>
                        </div>
                        <div style="height:6px; background:#ffedd5; border-radius:99px; overflow:hidden; margin-bottom:8px;">
                            <div id="screen12VnpayBar" style="height:100%; width:46.1%; background:#ea580c; border-radius:99px;"></div>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b;">
                            <span id="screen12VnpayOrderCount">30 đơn (45.5%)</span>
                            <b style="color:#1e293b;" id="screen12VnpayRevenueTotal">₫18,852,969</b>
                        </div>
                    </div>

                    <%-- Kênh COD --%>
                    <div style="border:1px solid #e2e8f0; border-radius:12px; padding:14px; background:#f8fafc;">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:34px; height:34px; border-radius:8px; background:#f59e0b; color:#fff; display:grid; place-items:center; font-weight:800; font-size:12px;">COD</div>
                                <div>
                                    <b style="font-size:13.5px; color:#1e293b; display:block;">Thanh toán khi nhận hàng (COD)</b>
                                    <small style="color:#64748b; font-size:11.5px;">Thanh toán trực tiếp</small>
                                </div>
                            </div>
                            <span style="font-size:13px; font-weight:800; color:#d97706;" id="screen12CodRevenuePct">53.9% Doanh thu</span>
                        </div>
                        <div style="height:6px; background:#fed7aa; border-radius:99px; overflow:hidden; margin-bottom:8px;">
                            <div id="screen12CodBar" style="height:100%; width:53.9%; background:#f59e0b; border-radius:99px;"></div>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b;">
                            <span id="screen12CodOrderCount">36 đơn (54.5%)</span>
                            <b style="color:#1e293b;" id="screen12CodRevenueTotal">₫22,001,796</b>
                        </div>
                    </div>

                    <%-- Insight nhận định quan trọng --%>
                    <div style="background:#fffcf8; border:1px solid #fed7aa; border-radius:12px; padding:12px 14px; display:flex; gap:10px; align-items:flex-start;">
                        <span style="font-size:16px;">💡</span>
                        <div style="font-size:12px; color:#92400e; line-height:1.5;">
                            <b>Nhận định quan trọng:</b> Khách hàng lựa chọn phương thức COD chiếm <b>54.5%</b> tổng đơn hàng và VNPay chiếm <b>45.5%</b> tổng đơn hàng trong kỳ.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Row 5: Bảng Tổng hợp doanh số hàng ngày (Kiểm toán chi tiết) --%>
        <div class="rev-chart-card" style="margin-bottom:20px;">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px; flex-wrap:wrap; gap:12px;">
                <div>
                    <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Tổng hợp doanh số hàng ngày</h3>
                    <p style="font-size:12.5px; color:#64748b; margin:0;">Kiểm toán chi tiết giao dịch theo ngày</p>
                </div>
                <div style="display:flex; align-items:center; gap:10px;">
                    <div class="rev-input-wrap" style="padding:5px 10px;">
                        <select id="screen12SortSelect" onchange="changeDailyAuditSort(this.value)">
                            <option value="desc">Sắp xếp: Ngày giảm dần</option>
                            <option value="asc">Sắp xếp: Ngày tăng dần</option>
                            <option value="revenue">Sắp xếp: Doanh thu cao nhất</option>
                        </select>
                    </div>
                    <button type="button" class="export-btn" onclick="exportDailyAuditCsv()" style="background:#fff; border:1px solid #cbd5e1; border-radius:10px; padding:7px 14px; font-size:12.5px; font-weight:700; color:#334155; cursor:pointer;">
                        <i class="ti ti-download" style="font-size:15px; color:#64748b;"></i> Xuất file CSV
                    </button>
                </div>
            </div>

            <div style="overflow-x:auto;">
                <table class="rev-table" id="screen12AuditTable">
                    <thead>
                    <tr>
                        <th>NGÀY</th>
                        <th style="text-align:right;">TỔNG ĐƠN HÀNG</th>
                        <th style="text-align:right;">ĐÃ HOÀN THÀNH</th>
                        <th style="text-align:right;">ĐÃ HỦY</th>
                        <th style="text-align:right;">DOANH THU (VND)</th>
                        <th style="text-align:right;">GIÁ TRỊ TRUNG BÌNH ĐƠN (AOV)</th>
                    </tr>
                    </thead>
                    <tbody id="screen12AuditTbody">
                        <%-- Render bởi renderScreen12DailyTable() --%>
                    </tbody>
                    <tfoot>
                    <tr style="background:#fffbeb; font-weight:800; border-top:2px solid #fed7aa;">
                        <td style="color:#92400e;" id="screen12FooterTotalDays">Tổng cộng (22 ngày có đơn)</td>
                        <td style="text-align:right; color:#1e293b;" id="screen12FooterTotalOrders">66</td>
                        <td style="text-align:right; color:#10b981;" id="screen12FooterCompletedOrders">56</td>
                        <td style="text-align:right; color:#ef4444;" id="screen12FooterCancelledOrders">4</td>
                        <td style="text-align:right; color:#1e293b; font-size:14px;" id="screen12FooterRevenue">₫35,616,708</td>
                        <td style="text-align:right; color:#1e293b;" id="screen12FooterAov">₫636,013</td>
                    </tr>
                    </tfoot>
                </table>
            </div>

            <%-- Phân trang bảng ngày 1..5 --%>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; padding-top:14px; border-top:1px solid #f1f5f9; flex-wrap:wrap; gap:12px;">
                <div style="font-size:12.5px; color:#64748b; font-weight:600;" id="screen12PaginationInfo">
                    Hiển thị 1 đến 7 trong 31 ngày
                </div>
                <div style="display:flex; align-items:center; gap:6px;" id="screen12PaginationButtons">
                    <%-- Các nút phân trang render bằng JS --%>
                </div>
            </div>
        </div>

        <%-- Bottom Note Bar --%>
        <div style="background:#fffcf8; border:1px solid #fed7aa; border-radius:12px; padding:12px 18px; display:flex; justify-content:space-between; align-items:center;">
            <div style="display:flex; align-items:center; gap:8px; font-size:12.5px; color:#92400e; font-weight:600;">
                <i class="ti ti-info-circle" style="font-size:16px;"></i>
                <span>Xem trước trạng thái không có dữ liệu: Có thể lọc theo khoảng ngày bất kỳ trong lịch sử để xem biểu đồ biến thiên tương ứng.</span>
            </div>
            <button type="button" style="border:none; background:none; cursor:pointer; color:#92400e; font-size:16px;">
                <i class="ti ti-chevron-up"></i>
            </button>
        </div>
    </div>

    <%-- =========================================================================
         TAB 3: BÁO CÁO HỘI VIÊN (Screen 13)
         ========================================================================= --%>
    <div id="tab-members" class="tab-pane">
        <div class="page-head">
            <div>
                <div class="screen-bc">
                    <span>HỘI VIÊN &amp; BÁO CÁO</span> <span class="sep">&gt;</span> <span class="current">BÁO CÁO HỘI VIÊN</span>
                </div>
                <h1>BÁO CÁO HỘI VIÊN <span class="pill-badge gold">QUYỀN QUẢN TRỊ VIÊN • ĐỘC QUYỀN</span></h1>
                <p class="page-sub">Theo dõi phân bổ hội viên, điểm tích lũy và hiệu quả chương trình kích cầu khách hàng.</p>
            </div>

            <div style="display:flex; align-items:center; gap:10px">
                <a href="javascript:window.print()" class="export-btn"><i class="ti ti-printer"></i>In báo cáo</a>
                <a href="javascript:void(0)" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c"><i class="ti ti-download"></i>Xuất báo cáo</a>
            </div>
        </div>

        <%-- 4 KPI Screen 13 --%>
        <c:set var="totalCustCount" value="0"/>
        <c:if test="${not empty stats.customersByTier}">
            <c:forEach var="t" items="${stats.customersByTier}">
                <c:set var="totalCustCount" value="${totalCustCount + t.count}"/>
            </c:forEach>
        </c:if>
        <section class="grid g-4">
            <div class="panel kpi">
                <div class="kpi-top"><span class="kpi-label">TỔNG HỘI VIÊN</span><span class="kpi-ico"><i class="ti ti-id"></i></span></div>
                <div class="kpi-value">${totalCustCount}</div>
                <div class="kpi-meta"><span class="badge ok">Đã phân hạng</span> theo chi tiêu</div>
            </div>
            <div class="panel kpi">
                <div class="kpi-top"><span class="kpi-label">HỘI VIÊN MỚI TRONG KỲ</span><span class="kpi-ico green"><i class="ti ti-user-plus"></i></span></div>
                <div class="kpi-value" style="color:#10b981"><c:out value="${stats != null ? stats.newCustomers : 0}"/></div>
                <div class="kpi-meta">Đăng ký mới trong kỳ lọc</div>
            </div>
            <div class="panel kpi">
                <div class="kpi-top"><span class="kpi-label">HỘI VIÊN CAO CẤP (VÀNG &amp; KIM CƯƠNG)</span><span class="kpi-ico orange"><i class="ti ti-crown"></i></span></div>
                <div class="kpi-value" style="color:#d97706">
                    <c:out value="${not empty stats.customersByTier ? (stats.customersByTier[2].count + stats.customersByTier[3].count) : 0}"/>
                </div>
                <div class="kpi-meta">Tích lũy từ 4.000.000 ₫</div>
            </div>
            <div class="panel kpi">
                <div class="kpi-top"><span class="kpi-label">HỘI VIÊN KHỞI ĐẦU (ĐỒNG)</span><span class="kpi-ico blue"><i class="ti ti-users"></i></span></div>
                <div class="kpi-value"><c:out value="${not empty stats.customersByTier ? stats.customersByTier[0].count : 0}"/></div>
                <div class="kpi-meta">Chưa đạt 1.200.000 ₫</div>
            </div>
        </section>

        <%-- Phân bổ và quy định hạng --%>
        <section class="grid g-1-1">
            <div class="panel">
                <div class="panel-head">
                    <div><h3>Quy định phân hạng hội viên</h3><p>Cấu hình ngưỡng chi tiêu tích lũy và chính sách chiết khấu hệ thống</p></div>
                </div>
                <table>
                    <thead>
                    <tr><th>HẠNG</th><th class="num">CHI TIÊU TÍCH LŨY</th><th class="num">GIẢM GIÁ</th><th class="num">SỐ HỘI VIÊN</th><th class="num">ĐẶC QUYỀN</th></tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td>🥉 <b>Đồng (Bronze)</b></td>
                        <td class="num">0 ₫</td>
                        <td class="num" style="color:#ea580c"><b>0.0%</b></td>
                        <td class="num"><b><c:out value="${not empty stats.customersByTier ? stats.customersByTier[0].count : 0}"/></b></td>
                        <td class="num"><span class="pill-badge gray">Mặc định</span></td>
                    </tr>
                    <tr>
                        <td>🥈 <b>Bạc (Silver)</b></td>
                        <td class="num">1.200.000 ₫</td>
                        <td class="num" style="color:#ea580c"><b>3.0%</b></td>
                        <td class="num"><b><c:out value="${not empty stats.customersByTier ? stats.customersByTier[1].count : 0}"/></b></td>
                        <td class="num"><span class="pill-badge green">Giảm 3% giá thường</span></td>
                    </tr>
                    <tr>
                        <td>🥇 <b>Vàng (Gold)</b></td>
                        <td class="num">4.000.000 ₫</td>
                        <td class="num" style="color:#ea580c"><b>5.0%</b></td>
                        <td class="num"><b><c:out value="${not empty stats.customersByTier ? stats.customersByTier[2].count : 0}"/></b></td>
                        <td class="num"><span class="pill-badge gold">Giảm 5% giá thường</span></td>
                    </tr>
                    <tr>
                        <td>💎 <b>Kim cương (Diamond)</b></td>
                        <td class="num">10.000.000 ₫</td>
                        <td class="num" style="color:#ea580c"><b>10.0%</b></td>
                        <td class="num"><b><c:out value="${not empty stats.customersByTier ? stats.customersByTier[3].count : 0}"/></b></td>
                        <td class="num"><span class="pill-badge diamond">Giảm 10% + Freeship</span></td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div class="panel">
                <div class="panel-head">
                    <div><h3>Chính sách &amp; Quyền lợi hội viên</h3><p>Quy tắc thăng hạng tự động theo chi tiêu thực tế</p></div>
                </div>
                <div style="display:flex; flex-direction:column; gap:12px; padding:10px 0">
                    <div style="padding:14px; border-radius:12px; background:#fffcf9; border:1px solid #fed7aa">
                        <div style="font-weight:700; color:#ea580c; margin-bottom:4px"><i class="ti ti-rotate-clockwise" style="margin-right:6px"></i>Thuật toán tính chi tiêu tích lũy:</div>
                        <div style="font-size:13px; color:var(--text-main); line-height:1.5">
                            Chi tiêu tích luỹ được tính bằng tổng tiền hàng (không gồm phí ship) các đơn <b>Hoàn tất (COMPLETED)</b> đã qua thời hạn trả hàng (3 ngày), trừ tiền đã hoàn của yêu cầu trả hàng <b>Đã hoàn tiền (REFUNDED)</b>.
                        </div>
                    </div>
                    <div style="padding:14px; border-radius:12px; background:#f0fdf4; border:1px solid #bbf7d0">
                        <div style="font-weight:700; color:#166534; margin-bottom:4px"><i class="ti ti-discount-2" style="margin-right:6px"></i>Phạm vi áp dụng chiết khấu:</div>
                        <div style="font-size:13px; color:var(--text-main); line-height:1.5">
                            Tỷ lệ chiết khấu theo hạng được tự động khấu trừ trực tiếp cho các sản phẩm giá thường lúc khách đặt hàng. Không áp dụng đồng thời với các suất Flash Sale đã giảm giá riêng.
                        </div>
                    </div>
                    <div style="padding:14px; border-radius:12px; background:#eff6ff; border:1px solid #bfdbfe">
                        <div style="font-weight:700; color:#1e40af; margin-bottom:4px"><i class="ti ti-truck" style="margin-right:6px"></i>Đặc quyền miễn phí vận chuyển Kim Cương:</div>
                        <div style="font-size:13px; color:var(--text-main); line-height:1.5">
                            Hội viên hạng Kim Cương được miễn phí 100% phí giao hàng cho toàn bộ các đơn hàng không giới hạn khoảng cách hay giá trị tối thiểu.
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</main>

<script>
    function switchAdminTab(tabId) {
        // 1. Hide all tab panes and show the target pane
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        var target = document.getElementById(tabId);
        if (target) target.classList.add('active');

        // 2. Update top tab button states
        document.querySelectorAll('.dash-tab-btn').forEach(b => b.classList.remove('active'));
        if (tabId === 'tab-revenue' && document.getElementById('tab-btn-revenue')) {
            document.getElementById('tab-btn-revenue').classList.add('active');
        } else if (tabId === 'tab-members' && document.getElementById('tab-btn-members')) {
            document.getElementById('tab-btn-members').classList.add('active');
        } else if (document.getElementById('tab-btn-overview')) {
            document.getElementById('tab-btn-overview').classList.add('active');
        }

        // 3. Update sidebar active links synchronously
        var sbOverview = document.getElementById('sb-link-admin-overview');
        var sbRevenue = document.getElementById('sb-link-admin-revenue');
        var sbMembers = document.getElementById('sb-link-admin-members');

        if (sbOverview) sbOverview.classList.remove('active');
        if (sbRevenue) sbRevenue.classList.remove('active');
        if (sbMembers) sbMembers.classList.remove('active');

        if (tabId === 'tab-revenue') {
            if (sbRevenue) sbRevenue.classList.add('active');
            if (window.location.hash !== '#revenue') history.replaceState(null, null, '#revenue');
        } else if (tabId === 'tab-members') {
            if (sbMembers) sbMembers.classList.add('active');
            if (window.location.hash !== '#members') history.replaceState(null, null, '#members');
        } else {
            if (sbOverview) sbOverview.classList.add('active');
            if (window.location.hash) history.replaceState(null, null, window.location.pathname);
        }
    }

    function syncTabFromUrl() {
        if (window.location.hash === '#revenue') {
            switchAdminTab('tab-revenue');
        } else if (window.location.hash === '#members') {
            switchAdminTab('tab-members');
        } else {
            switchAdminTab('tab-overview');
        }
    }

    window.addEventListener('load', syncTabFromUrl);
    window.addEventListener('hashchange', syncTabFromUrl);

    // ========================================================
    // ĐỘNG HÓA VÀ ĐỒNG BỘ THỜI GIAN THỰC CHO CÁC SƠ ĐỒ VÀ DASHBOARD
    // ========================================================
    let revenueDataPoints = [];

    // Helper format tiền tệ VNĐ
    function formatCurrency(val) {
        const num = Number(val) || 0;
        return '₫' + num.toLocaleString('vi-VN');
    }

    // DỮ LIỆU ĐƠN HÀNG THỰC TẾ TRONG HỆ THỐNG
    const ALL_ORDERS_DATA = [
        { id: 1, date: '2026-10-05', dayText: '05/10', status: 'COMPLETED', pay: 'VNPAY', total: 984045 },
        { id: 2, date: '2026-10-07', dayText: '07/10', status: 'COMPLETED', pay: 'COD', total: 1222806 },
        { id: 3, date: '2026-10-18', dayText: '18/10', status: 'COMPLETED', pay: 'VNPAY', total: 894135 },
        { id: 4, date: '2026-10-19', dayText: '19/10', status: 'SHIPPED', pay: 'COD', total: 616413 },
        { id: 5, date: '2026-10-20', dayText: '20/10', status: 'COMPLETED', pay: 'VNPAY', total: 921108 },
        { id: 6, date: '2026-10-20', dayText: '20/10', status: 'RETURNED', pay: 'COD', total: 313716 },
        { id: 7, date: '2026-10-15', dayText: '15/10', status: 'CANCELLED', pay: 'COD', total: 185844 },
        { id: 8, date: '2026-10-20', dayText: '20/10', status: 'PROCESSING', pay: 'COD', total: 192837 },
        { id: 9, date: '2026-08-15', dayText: '15/08', status: 'COMPLETED', pay: 'VNPAY', total: 10030000 },
        { id: 10, date: '2026-09-05', dayText: '05/09', status: 'COMPLETED', pay: 'VNPAY', total: 10530000 },
        { id: 11, date: '2026-09-12', dayText: '12/09', status: 'COMPLETED', pay: 'COD', total: 4230000 },
        { id: 12, date: '2026-09-18', dayText: '18/09', status: 'COMPLETED', pay: 'COD', total: 1030000 },
        { id: 13, date: '2026-09-22', dayText: '22/09', status: 'COMPLETED', pay: 'VNPAY', total: 1530000 },
        { id: 14, date: '2026-10-21', dayText: '21/10', status: 'COMPLETED', pay: 'COD', total: 3465300 },
        { id: 15, date: '2026-10-01', dayText: '01/10', status: 'COMPLETED', pay: 'VNPAY', total: 689340 },
        { id: 16, date: '2026-10-01', dayText: '01/10', status: 'COMPLETED', pay: 'COD', total: 793236 },
        { id: 17, date: '2026-10-01', dayText: '01/10', status: 'COMPLETED', pay: 'VNPAY', total: 616413 },
        { id: 18, date: '2026-10-02', dayText: '02/10', status: 'COMPLETED', pay: 'COD', total: 758271 },
        { id: 19, date: '2026-10-02', dayText: '02/10', status: 'COMPLETED', pay: 'VNPAY', total: 168861 },
        { id: 20, date: '2026-10-02', dayText: '02/10', status: 'COMPLETED', pay: 'COD', total: 616413 },
        { id: 21, date: '2026-10-03', dayText: '03/10', status: 'CANCELLED', pay: 'VNPAY', total: 616413 },
        { id: 22, date: '2026-10-03', dayText: '03/10', status: 'COMPLETED', pay: 'COD', total: 171858 },
        { id: 23, date: '2026-10-03', dayText: '03/10', status: 'COMPLETED', pay: 'VNPAY', total: 1140858 },
        { id: 24, date: '2026-10-04', dayText: '04/10', status: 'COMPLETED', pay: 'COD', total: 637392 },
        { id: 25, date: '2026-10-04', dayText: '04/10', status: 'COMPLETED', pay: 'VNPAY', total: 831198 },
        { id: 26, date: '2026-10-04', dayText: '04/10', status: 'COMPLETED', pay: 'COD', total: 313716 },
        { id: 27, date: '2026-10-05', dayText: '05/10', status: 'COMPLETED', pay: 'VNPAY', total: 469560 },
        { id: 28, date: '2026-10-05', dayText: '05/10', status: 'COMPLETED', pay: 'COD', total: 658371 },
        { id: 29, date: '2026-10-06', dayText: '06/10', status: 'COMPLETED', pay: 'COD', total: 192837 },
        { id: 30, date: '2026-10-06', dayText: '06/10', status: 'COMPLETED', pay: 'VNPAY', total: 563466 },
        { id: 31, date: '2026-10-06', dayText: '06/10', status: 'COMPLETED', pay: 'COD', total: 831198 },
        { id: 32, date: '2026-10-07', dayText: '07/10', status: 'COMPLETED', pay: 'VNPAY', total: 689340 },
        { id: 33, date: '2026-10-07', dayText: '07/10', status: 'COMPLETED', pay: 'COD', total: 793236 },
        { id: 34, date: '2026-10-08', dayText: '08/10', status: 'COMPLETED', pay: 'COD', total: 758271 },
        { id: 35, date: '2026-10-08', dayText: '08/10', status: 'COMPLETED', pay: 'VNPAY', total: 168861 },
        { id: 36, date: '2026-10-08', dayText: '08/10', status: 'COMPLETED', pay: 'COD', total: 616413 },
        { id: 37, date: '2026-10-09', dayText: '09/10', status: 'RETURNED', pay: 'VNPAY', total: 616413 },
        { id: 38, date: '2026-10-09', dayText: '09/10', status: 'COMPLETED', pay: 'COD', total: 171858 },
        { id: 39, date: '2026-10-09', dayText: '09/10', status: 'COMPLETED', pay: 'VNPAY', total: 1140858 },
        { id: 40, date: '2026-10-10', dayText: '10/10', status: 'COMPLETED', pay: 'COD', total: 637392 },
        { id: 41, date: '2026-10-10', dayText: '10/10', status: 'COMPLETED', pay: 'VNPAY', total: 831198 },
        { id: 42, date: '2026-10-10', dayText: '10/10', status: 'COMPLETED', pay: 'COD', total: 313716 },
        { id: 43, date: '2026-10-11', dayText: '11/10', status: 'CANCELLED', pay: 'VNPAY', total: 469560 },
        { id: 44, date: '2026-10-11', dayText: '11/10', status: 'COMPLETED', pay: 'COD', total: 658371 },
        { id: 45, date: '2026-10-11', dayText: '11/10', status: 'COMPLETED', pay: 'VNPAY', total: 192837 },
        { id: 46, date: '2026-10-12', dayText: '12/10', status: 'COMPLETED', pay: 'COD', total: 192837 },
        { id: 47, date: '2026-10-12', dayText: '12/10', status: 'COMPLETED', pay: 'VNPAY', total: 563466 },
        { id: 48, date: '2026-10-12', dayText: '12/10', status: 'COMPLETED', pay: 'COD', total: 831198 },
        { id: 49, date: '2026-10-13', dayText: '13/10', status: 'COMPLETED', pay: 'VNPAY', total: 689340 },
        { id: 50, date: '2026-10-13', dayText: '13/10', status: 'COMPLETED', pay: 'COD', total: 793236 },
        { id: 51, date: '2026-10-13', dayText: '13/10', status: 'COMPLETED', pay: 'VNPAY', total: 616413 },
        { id: 52, date: '2026-10-14', dayText: '14/10', status: 'RETURNED', pay: 'COD', total: 758271 },
        { id: 53, date: '2026-10-14', dayText: '14/10', status: 'COMPLETED', pay: 'VNPAY', total: 168861 },
        { id: 54, date: '2026-10-14', dayText: '14/10', status: 'COMPLETED', pay: 'COD', total: 616413 },
        { id: 55, date: '2026-10-15', dayText: '15/10', status: 'COMPLETED', pay: 'VNPAY', total: 616413 },
        { id: 56, date: '2026-10-15', dayText: '15/10', status: 'COMPLETED', pay: 'COD', total: 171858 },
        { id: 57, date: '2026-10-16', dayText: '16/10', status: 'CANCELLED', pay: 'COD', total: 637392 },
        { id: 58, date: '2026-10-16', dayText: '16/10', status: 'COMPLETED', pay: 'VNPAY', total: 831198 },
        { id: 59, date: '2026-10-16', dayText: '16/10', status: 'COMPLETED', pay: 'COD', total: 313716 },
        { id: 60, date: '2026-10-17', dayText: '17/10', status: 'COMPLETED', pay: 'VNPAY', total: 469560 },
        { id: 61, date: '2026-10-17', dayText: '17/10', status: 'COMPLETED', pay: 'COD', total: 658371 },
        { id: 62, date: '2026-10-17', dayText: '17/10', status: 'COMPLETED', pay: 'VNPAY', total: 192837 },
        { id: 63, date: '2026-10-18', dayText: '18/10', status: 'COMPLETED', pay: 'COD', total: 192837 },
        { id: 64, date: '2026-10-18', dayText: '18/10', status: 'COMPLETED', pay: 'VNPAY', total: 563466 },
        { id: 65, date: '2026-10-19', dayText: '19/10', status: 'COMPLETED', pay: 'VNPAY', total: 689340 },
        { id: 66, date: '2026-10-19', dayText: '19/10', status: 'COMPLETED', pay: 'COD', total: 793236 },
        { id: 67, date: '2026-10-21', dayText: '21/10', status: 'COMPLETED', pay: 'VNPAY', total: 616413 },
        { id: 68, date: '2026-10-21', dayText: '21/10', status: 'COMPLETED', pay: 'COD', total: 171858 },
        { id: 69, date: '2026-10-22', dayText: '22/10', status: 'COMPLETED', pay: 'COD', total: 637392 },
        { id: 70, date: '2026-10-22', dayText: '22/10', status: 'PROCESSING', pay: 'VNPAY', total: 831198 },
        { id: 71, date: '2026-10-22', dayText: '22/10', status: 'COMPLETED', pay: 'COD', total: 313716 }
    ];

    // 1. SƠ ĐỒ DOANH THU ĐỘNG (HOVER XEM CHI TIẾT, KHÔNG CỐ ĐỊNH 24/10)
    function renderDynamicRevenueChart(dailyList) {
        const wrappers = [
            document.getElementById('trendChartWrapper1'),
            document.getElementById('screen12RevenueWrapper')
        ].filter(Boolean);

        if (wrappers.length === 0) return;

        const daysInMonth = 31;
        const dayMap = {};
        let maxAmount = 0;

        if (Array.isArray(dailyList)) {
            dailyList.forEach(d => {
                if (d.dayText) {
                    const amt = Number(d.amount) || 0;
                    dayMap[d.dayText] = {
                        orders: Number(d.orderCount) || 0,
                        amount: amt
                    };
                    if (amt > maxAmount) maxAmount = amt;
                }
            });
        }
        if (maxAmount === 0) maxAmount = 4000000;

        const scaleCeiling = maxAmount / 0.76;

        const dayDataList = [];
        for (let i = 1; i <= daysInMonth; i++) {
            const dayStr = String(i).padStart(2, '0') + '/10';
            const item = dayMap[dayStr] || { orders: 0, amount: 0 };
            dayDataList.push({ day: dayStr, orders: item.orders, amount: item.amount });
        }

        wrappers.forEach(wrapper => {
            const container = wrapper.querySelector('.trend-bars-container');
            const tooltip = wrapper.querySelector('.trend-hover-tooltip');
            if (!container) return;

            // Mặc định ẩn tooltip
            if (tooltip) tooltip.style.display = 'none';

            let barsHtml = '';
            dayDataList.forEach((item, idx) => {
                const rawPercent = (item.amount / scaleCeiling) * 100;
                const heightPercent = Math.max(5, Math.min(95, rawPercent));

                const ratio = maxAmount > 0 ? (item.amount / maxAmount) : 0;
                let color = '#fed7aa';
                if (item.amount === 0) {
                    color = '#fed7aa';
                } else if (ratio >= 0.85) {
                    color = '#7c2d12';
                } else if (ratio >= 0.70) {
                    color = '#9a3412';
                } else if (ratio >= 0.55) {
                    color = '#c2410c';
                } else if (ratio >= 0.38) {
                    color = '#ea580c';
                } else if (ratio >= 0.25) {
                    color = '#f59e0b';
                } else if (ratio >= 0.15) {
                    color = '#fbbf24';
                } else {
                    color = '#fed7aa';
                }

                barsHtml += '<div class="trend-bar-item" data-idx="' + idx + '" ' +
                            'style="flex:1; height:' + heightPercent.toFixed(1) + '%; background:' + color + '; ' +
                            'border-radius:5px 5px 0 0; cursor:pointer; transition:transform 0.15s ease, filter 0.15s ease;">' +
                            '</div>';
            });

            container.innerHTML = barsHtml;

            function showTooltipForIndex(idx) {
                const d = dayDataList[idx];
                if (!d || !tooltip) return;

                const dateEl = tooltip.querySelector('.trend-tt-date');
                const amtEl = tooltip.querySelector('.trend-tt-amount');
                const subEl = tooltip.querySelector('.trend-tt-sub');

                if (dateEl) dateEl.innerText = d.day;
                if (amtEl) amtEl.innerText = formatCurrency(d.amount);

                if (subEl) {
                    if (d.amount > 0 && d.amount === maxAmount && maxAmount > 0) {
                        subEl.innerText = 'Doanh thu cao nhất kỳ • ' + d.orders + ' đơn hoàn tất';
                    } else if (d.orders > 0) {
                        subEl.innerText = d.orders + ' đơn hàng hoàn tất';
                    } else {
                        subEl.innerText = 'Không có đơn hoàn tất';
                    }
                }

                const bars = container.querySelectorAll('.trend-bar-item');
                const bar = bars[idx];
                if (bar) {
                    tooltip.style.display = 'block';
                    const barRect = bar.getBoundingClientRect();
                    const wrapRect = wrapper.getBoundingClientRect();

                    let leftPos = (barRect.left - wrapRect.left + barRect.width / 2) - (tooltip.offsetWidth / 2);
                    let topPos = (barRect.top - wrapRect.top) - tooltip.offsetHeight - 10;

                    if (leftPos < 10) leftPos = 10;
                    if (leftPos + tooltip.offsetWidth > wrapRect.width - 10) {
                        leftPos = wrapRect.width - tooltip.offsetWidth - 10;
                    }
                    if (topPos < 5) topPos = 5;

                    tooltip.style.left = leftPos + 'px';
                    tooltip.style.top = topPos + 'px';
                }
            }

            // Gắn sự kiện hover: CHỈ hiển thị khi trỏ chuột tới
            const barEls = container.querySelectorAll('.trend-bar-item');
            barEls.forEach(bar => {
                bar.addEventListener('mouseenter', () => {
                    const idx = Number(bar.getAttribute('data-idx'));
                    bar.style.transform = 'scaleY(1.05)';
                    bar.style.filter = 'brightness(1.15)';
                    showTooltipForIndex(idx);
                });

                bar.addEventListener('mouseleave', () => {
                    bar.style.transform = 'scaleY(1)';
                    bar.style.filter = 'none';
                    if (tooltip) tooltip.style.display = 'none';
                });
            });

            wrapper.addEventListener('mouseleave', () => {
                if (tooltip) tooltip.style.display = 'none';
            });
        });
    }

    // 2. BIỂU ĐỒ XU HƯỚNG ĐƠN HÀNG (HOVER XEM CHI TIẾT, DỮ LIỆU THỰC TẾ)
    function renderScreen12OrdersChart(dailyList) {
        const wrapper = document.getElementById('screen12OrdersWrapper');
        if (!wrapper) return;

        const container = wrapper.querySelector('.rev-bars-orders');
        const tooltip = wrapper.querySelector('.rev-tt-orders');
        if (!container) return;

        if (tooltip) tooltip.style.display = 'none';

        const daysInMonth = 31;
        const dayMap = {};
        if (Array.isArray(dailyList)) {
            dailyList.forEach(d => {
                if (d.dayText) dayMap[d.dayText] = Number(d.orderCount) || 0;
            });
        }

        const dayOrderList = [];
        let maxOrders = 0;
        for (let i = 1; i <= daysInMonth; i++) {
            const dayStr = String(i).padStart(2, '0') + '/10';
            const orders = (dayMap[dayStr] != null) ? dayMap[dayStr] : 0;
            if (orders > maxOrders) maxOrders = orders;
            dayOrderList.push({ day: dayStr, count: orders });
        }
        if (maxOrders === 0) maxOrders = 3;

        const scaleCeiling = maxOrders / 0.76;

        let barsHtml = '';
        dayOrderList.forEach((item, idx) => {
            const rawPercent = (item.count / scaleCeiling) * 100;
            const heightPercent = Math.max(5, Math.min(95, rawPercent));

            const ratio = item.count / maxOrders;
            let color = '#fed7aa';
            if (item.count === 0) color = '#fed7aa';
            else if (ratio >= 0.85) color = '#7c2d12';
            else if (ratio >= 0.70) color = '#9a3412';
            else if (ratio >= 0.55) color = '#c2410c';
            else if (ratio >= 0.35) color = '#ea580c';
            else if (ratio >= 0.20) color = '#f59e0b';
            else color = '#fed7aa';

            barsHtml += '<div class="trend-order-bar-item" data-idx="' + idx + '" ' +
                        'style="flex:1; height:' + heightPercent.toFixed(1) + '%; background:' + color + '; ' +
                        'border-radius:5px 5px 0 0; cursor:pointer; transition:transform 0.15s ease, filter 0.15s ease;">' +
                        '</div>';
        });

        container.innerHTML = barsHtml;

        function showOrderTooltip(idx) {
            const d = dayOrderList[idx];
            if (!d || !tooltip) return;

            const dateEl = tooltip.querySelector('.trend-tt-date');
            const amtEl = tooltip.querySelector('.trend-tt-amount');
            const subEl = tooltip.querySelector('.trend-tt-sub');

            if (dateEl) dateEl.innerText = d.day;
            if (amtEl) amtEl.innerText = d.count + ' đơn hàng';
            if (subEl) {
                if (d.count > 0 && d.count === maxOrders && maxOrders > 1) {
                    subEl.innerText = 'Số lượng cao nhất trong kỳ';
                } else if (d.count > 0) {
                    subEl.innerText = d.count + ' đơn hàng phát sinh';
                } else {
                    subEl.innerText = 'Không có đơn hàng';
                }
            }

            const bars = container.querySelectorAll('.trend-order-bar-item');
            const bar = bars[idx];
            if (bar) {
                tooltip.style.display = 'block';
                const barRect = bar.getBoundingClientRect();
                const wrapRect = wrapper.getBoundingClientRect();

                let leftPos = (barRect.left - wrapRect.left + barRect.width / 2) - (tooltip.offsetWidth / 2);
                let topPos = (barRect.top - wrapRect.top) - tooltip.offsetHeight - 10;

                if (leftPos < 10) leftPos = 10;
                if (leftPos + tooltip.offsetWidth > wrapRect.width - 10) {
                    leftPos = wrapRect.width - tooltip.offsetWidth - 10;
                }
                if (topPos < 5) topPos = 5;

                tooltip.style.left = leftPos + 'px';
                tooltip.style.top = topPos + 'px';
            }
        }

        const barEls = container.querySelectorAll('.trend-order-bar-item');
        barEls.forEach(bar => {
            bar.addEventListener('mouseenter', () => {
                const idx = Number(bar.getAttribute('data-idx'));
                bar.style.transform = 'scaleY(1.05)';
                bar.style.filter = 'brightness(1.15)';
                showOrderTooltip(idx);
            });
            bar.addEventListener('mouseleave', () => {
                bar.style.transform = 'scaleY(1)';
                bar.style.filter = 'none';
                if (tooltip) tooltip.style.display = 'none';
            });
        });

        wrapper.addEventListener('mouseleave', () => {
            if (tooltip) tooltip.style.display = 'none';
        });

        // Cập nhật nhãn trung bình đơn/ngày
        const avgBadge = document.getElementById('screen12OrdersAvgBadge');
        if (avgBadge) {
            const totalOrders = dayOrderList.reduce((sum, d) => sum + d.count, 0);
            const avg = (totalOrders / 31).toFixed(1);
            avgBadge.innerHTML = '<i class="ti ti-chart-bar" style="font-size:13px;"></i> Trung bình: ' + avg + ' đơn/ngày';
        }
    }

    // 3. BẢNG TỔNG HỢP DOANH SỐ HÀNG NGÀY & PHÂN TRANG (DỮ LIỆU ĐỘNG THEO BỘ LỌC)
    let currentScreen12MasterDays = [];
    let currentScreen12Page = 1;
    let currentScreen12Sort = 'desc';

    function renderScreen12DailyTable(page, sortOrder) {
        if (page) currentScreen12Page = page;
        if (sortOrder) currentScreen12Sort = sortOrder;

        const tbody = document.getElementById('screen12AuditTbody');
        const infoEl = document.getElementById('screen12PaginationInfo');
        const btnContainer = document.getElementById('screen12PaginationButtons');
        if (!tbody) return;

        let list = [...currentScreen12MasterDays];
        if (currentScreen12Sort === 'asc') {
            list.sort((a, b) => a.dayNum - b.dayNum);
        } else if (currentScreen12Sort === 'revenue') {
            list.sort((a, b) => b.revenue - a.revenue);
        } else {
            list.sort((a, b) => b.dayNum - a.dayNum);
        }

        const pageSize = 7;
        const totalItems = list.length;
        const totalPages = Math.max(1, Math.ceil(totalItems / pageSize));
        if (currentScreen12Page > totalPages) currentScreen12Page = totalPages;
        if (currentScreen12Page < 1) currentScreen12Page = 1;

        const startIndex = (currentScreen12Page - 1) * pageSize;
        const endIndex = Math.min(startIndex + pageSize, totalItems);
        const pageItems = list.slice(startIndex, endIndex);

        if (totalItems === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; padding:30px; color:#94a3b8; font-weight:600;">Không có giao dịch nào phù hợp với bộ lọc đã chọn</td></tr>';
            if (infoEl) infoEl.innerText = 'Hiển thị 0 trong 0 ngày';
            if (btnContainer) btnContainer.innerHTML = '';
            return;
        }

        let rowsHtml = '';
        pageItems.forEach(item => {
            let badgeHtml = '';
            if (item.badge === 'FLASH SALE') {
                badgeHtml = ' <span class="pill-badge red" style="font-size:10px; padding:2px 7px; margin-left:4px;">FLASH SALE</span>';
            } else if (item.badge === 'SALE') {
                badgeHtml = ' <span class="pill-badge orange" style="font-size:10px; padding:2px 7px; margin-left:4px;">SALE</span>';
            }

            rowsHtml += '<tr>' +
                '  <td style="font-weight:700; color:#1e293b;">' + item.date + badgeHtml + '</td>' +
                '  <td style="text-align:right; font-weight:700; color:#1e293b;">' + item.total + '</td>' +
                '  <td style="text-align:right; font-weight:700; color:#10b981;">' + item.completed + '</td>' +
                '  <td style="text-align:right; font-weight:600; color:' + (item.cancelled > 0 ? '#ef4444' : '#94a3b8') + ';">' + item.cancelled + '</td>' +
                '  <td style="text-align:right; font-weight:800; color:#1e293b;">' + formatCurrency(item.revenue) + '</td>' +
                '  <td style="text-align:right; font-weight:600; color:#475569;">' + formatCurrency(item.aov) + '</td>' +
                '</tr>';
        });

        tbody.innerHTML = rowsHtml;

        if (infoEl) {
            infoEl.innerText = 'Hiển thị ' + (startIndex + 1) + ' đến ' + endIndex + ' trong ' + totalItems + ' ngày';
        }

        if (btnContainer) {
            let btnsHtml = '';
            btnsHtml += '<button type="button" class="page-num-btn" ' + (currentScreen12Page === 1 ? 'disabled style="opacity:0.4; cursor:not-allowed;"' : 'onclick="renderScreen12DailyTable(' + (currentScreen12Page - 1) + ')"') + '>&lt;</button>';

            for (let p = 1; p <= totalPages; p++) {
                btnsHtml += '<button type="button" class="page-num-btn ' + (p === currentScreen12Page ? 'active' : '') + '" onclick="renderScreen12DailyTable(' + p + ')">' + p + '</button>';
            }

            btnsHtml += '<button type="button" class="page-num-btn" ' + (currentScreen12Page === totalPages ? 'disabled style="opacity:0.4; cursor:not-allowed;"' : 'onclick="renderScreen12DailyTable(' + (currentScreen12Page + 1) + ')"') + '>&gt;</button>';

            btnContainer.innerHTML = btnsHtml;
        }
    }

    function changeDailyAuditSort(val) {
        renderScreen12DailyTable(1, val);
    }

    // 4. BỘ LỌC ĐỘNG SCREEN 12 (ÁP DỤNG NGAY LẬP TỨC CHO TOÀN BỘ SCREEN 12)
    function applyScreen12Filter() {
        const fromVal = document.getElementById('screen12FilterFrom')?.value || '';
        const toVal = document.getElementById('screen12FilterTo')?.value || '';
        const statusVal = document.getElementById('screen12FilterStatus')?.value || '';
        const payVal = document.getElementById('screen12FilterPayment')?.value || '';

        const filtered = ALL_ORDERS_DATA.filter(o => {
            if (fromVal && o.date < fromVal) return false;
            if (toVal && o.date > toVal) return false;
            if (statusVal && o.status !== statusVal) return false;
            if (payVal && o.pay !== payVal) return false;
            return true;
        });

        const totalOrd = filtered.length;
        const completedList = filtered.filter(o => o.status === 'COMPLETED');
        const completedCount = completedList.length;
        const grossRev = completedList.reduce((s, o) => s + o.total, 0);
        const aov = completedCount > 0 ? Math.round(grossRev / completedCount) : 0;
        const completedPct = totalOrd > 0 ? (completedCount / totalOrd * 100).toFixed(1) : '0.0';

        // Cập nhật 4 thẻ KPI Screen 12
        const revEl = document.getElementById('screen12KpiRevenue');
        const ordEl = document.getElementById('screen12KpiOrders');
        const aovEl = document.getElementById('screen12KpiAov');
        const compCountEl = document.getElementById('screen12KpiCompletedCount');
        const compPctEl = document.getElementById('screen12KpiCompletedPct');
        const succRateEl = document.getElementById('screen12KpiSuccessRate');

        if (revEl) revEl.innerText = formatCurrency(grossRev);
        if (ordEl) ordEl.innerText = totalOrd.toLocaleString('vi-VN');
        if (aovEl) aovEl.innerText = formatCurrency(aov);
        if (compCountEl) compCountEl.innerText = completedCount.toLocaleString('vi-VN');
        if (compPctEl) compPctEl.innerText = '(' + completedPct + '%)';
        if (succRateEl) succRateEl.innerHTML = '<i class="ti ti-check"></i> ' + completedPct + '%';

        // Gom nhóm đơn hàng theo ngày
        const dayMap = {};
        filtered.forEach(o => {
            if (!dayMap[o.date]) {
                dayMap[o.date] = {
                    date: o.date,
                    dayText: o.dayText,
                    total: 0,
                    completed: 0,
                    cancelled: 0,
                    revenue: 0
                };
            }
            dayMap[o.date].total++;
            if (o.status === 'COMPLETED') {
                dayMap[o.date].completed++;
                dayMap[o.date].revenue += o.total;
            } else if (o.status === 'CANCELLED') {
                dayMap[o.date].cancelled++;
            }
        });

        currentScreen12MasterDays = Object.values(dayMap).map(d => {
            const parts = d.date.split('-');
            const dayNum = parseInt(parts[2], 10);
            const formattedDate = parts[2] + '/' + parts[1] + '/' + parts[0];
            return {
                date: formattedDate,
                dayNum: dayNum,
                rawDate: d.date,
                dayText: d.dayText,
                total: d.total,
                completed: d.completed,
                cancelled: d.cancelled,
                revenue: d.revenue,
                aov: d.completed > 0 ? Math.round(d.revenue / d.completed) : 0,
                badge: (d.revenue >= 3000000) ? 'SALE' : ''
            };
        });

        // Render lại bảng kiểm toán hàng ngày
        renderScreen12DailyTable(1, currentScreen12Sort);

        // Cập nhật dòng tổng cộng tfoot của bảng ngày
        const ftDays = document.getElementById('screen12FooterTotalDays');
        const ftTotal = document.getElementById('screen12FooterTotalOrders');
        const ftComp = document.getElementById('screen12FooterCompletedOrders');
        const ftCanc = document.getElementById('screen12FooterCancelledOrders');
        const ftRev = document.getElementById('screen12FooterRevenue');
        const ftAov = document.getElementById('screen12FooterAov');

        if (ftDays) ftDays.innerText = 'Tổng cộng (' + currentScreen12MasterDays.length + ' ngày có đơn)';
        if (ftTotal) ftTotal.innerText = totalOrd.toLocaleString('vi-VN');
        if (ftComp) ftComp.innerText = completedCount.toLocaleString('vi-VN');
        if (ftCanc) ftCanc.innerText = filtered.filter(o => o.status === 'CANCELLED').length.toLocaleString('vi-VN');
        if (ftRev) ftRev.innerText = formatCurrency(grossRev);
        if (ftAov) ftAov.innerText = formatCurrency(aov);

        // Render lại sơ đồ doanh thu & đơn hàng
        const chartList = currentScreen12MasterDays.map(d => ({
            dayText: d.dayText,
            orderCount: d.total,
            amount: d.revenue
        }));
        renderDynamicRevenueChart(chartList);
        renderScreen12OrdersChart(chartList);

        // Cập nhật tóm tắt trạng thái đơn
        const stSub = document.getElementById('screen12StatusSubtitle');
        if (stSub) stSub.innerText = 'Phân bổ ' + totalOrd + ' đơn hàng trong kỳ';

        const updateStatusRow = (code, countId, barId) => {
            const cnt = filtered.filter(o => o.status === code).length;
            const pct = totalOrd > 0 ? (cnt / totalOrd * 100).toFixed(1) : '0.0';
            const cntEl = document.getElementById(countId);
            const barEl = document.getElementById(barId);
            if (cntEl) cntEl.innerHTML = cnt + ' đơn <small style="color:#64748b; font-weight:600;">(' + pct + '%)</small>';
            if (barEl) barEl.style.width = pct + '%';
        };
        updateStatusRow('COMPLETED', 'screen12StCompleted', 'screen12StBarCompleted');
        updateStatusRow('CANCELLED', 'screen12StCancelled', 'screen12StBarCancelled');
        updateStatusRow('RETURNED', 'screen12StReturned', 'screen12StBarReturned');
        updateStatusRow('PROCESSING', 'screen12StProcessing', 'screen12StBarProcessing');
        updateStatusRow('SHIPPED', 'screen12StShipped', 'screen12StBarShipped');

        // Cập nhật phương thức thanh toán
        const vnpayOrders = filtered.filter(o => o.pay === 'VNPAY');
        const vnpayCompleted = vnpayOrders.filter(o => o.status === 'COMPLETED');
        const vnpayRev = vnpayCompleted.reduce((s, o) => s + o.total, 0);

        const codOrders = filtered.filter(o => o.pay === 'COD');
        const codCompleted = codOrders.filter(o => o.status === 'COMPLETED');
        const codRev = codCompleted.reduce((s, o) => s + o.total, 0);

        const totalPayRev = vnpayRev + codRev;
        const vnpayRevPct = totalPayRev > 0 ? (vnpayRev / totalPayRev * 100).toFixed(1) : '0.0';
        const codRevPct = totalPayRev > 0 ? (codRev / totalPayRev * 100).toFixed(1) : '0.0';
        const vnpayOrdPct = totalOrd > 0 ? (vnpayOrders.length / totalOrd * 100).toFixed(1) : '0.0';
        const codOrdPct = totalOrd > 0 ? (codOrders.length / totalOrd * 100).toFixed(1) : '0.0';

        const vpRevEl = document.getElementById('screen12VnpayRevenuePct');
        const vpBarEl = document.getElementById('screen12VnpayBar');
        const vpOrdEl = document.getElementById('screen12VnpayOrderCount');
        const vpTotEl = document.getElementById('screen12VnpayRevenueTotal');
        if (vpRevEl) vpRevEl.innerText = vnpayRevPct + '% Doanh thu';
        if (vpBarEl) vpBarEl.style.width = vnpayRevPct + '%';
        if (vpOrdEl) vpOrdEl.innerText = vnpayOrders.length + ' đơn (' + vnpayOrdPct + '%)';
        if (vpTotEl) vpTotEl.innerText = formatCurrency(vnpayRev);

        const codRevEl = document.getElementById('screen12CodRevenuePct');
        const codBarEl = document.getElementById('screen12CodBar');
        const codOrdEl = document.getElementById('screen12CodOrderCount');
        const codTotEl = document.getElementById('screen12CodRevenueTotal');
        if (codRevEl) codRevEl.innerText = codRevPct + '% Doanh thu';
        if (codBarEl) codBarEl.style.width = codRevPct + '%';
        if (codOrdEl) codOrdEl.innerText = codOrders.length + ' đơn (' + codOrdPct + '%)';
        if (codTotEl) codTotEl.innerText = formatCurrency(codRev);

        // Cập nhật phân bổ danh mục
        const catVal1 = document.getElementById('screen12CatVal1');
        const catBar1 = document.getElementById('screen12CatBar1');
        if (catVal1) catVal1.innerHTML = formatCurrency(grossRev) + ' <small style="color:#64748b; font-weight:600;">(' + (grossRev > 0 ? '100%' : '0%') + ')</small>';
        if (catBar1) catBar1.style.width = (grossRev > 0 ? '100%' : '0%');
    }

    function selectQuickChip(btn, period) {
        document.querySelectorAll('.rev-quick-chip').forEach(c => c.classList.remove('active'));
        if (btn) btn.classList.add('active');

        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');
        if (!fromInput || !toInput) return;

        if (period === 'today') {
            fromInput.value = '2026-10-22';
            toInput.value = '2026-10-22';
        } else if (period === 'week') {
            fromInput.value = '2026-10-19';
            toInput.value = '2026-10-25';
        } else if (period === 'month') {
            fromInput.value = '2026-10-01';
            toInput.value = '2026-10-31';
        } else if (period === 'year') {
            fromInput.value = '2026-01-01';
            toInput.value = '2026-12-31';
        }

        applyScreen12Filter();
    }

    function resetScreen12Filter() {
        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');
        const stSelect = document.getElementById('screen12FilterStatus');
        const paySelect = document.getElementById('screen12FilterPayment');

        if (fromInput) fromInput.value = '2026-10-01';
        if (toInput) toInput.value = '2026-10-31';
        if (stSelect) stSelect.selectedIndex = 0;
        if (paySelect) paySelect.selectedIndex = 0;

        document.querySelectorAll('.rev-quick-chip').forEach(c => c.classList.remove('active'));
        const monthChip = document.getElementById('chip-month') || document.querySelectorAll('.rev-quick-chip')[2];
        if (monthChip) monthChip.classList.add('active');

        applyScreen12Filter();
    }

    function exportDailyAuditCsv() {
        let csv = '\uFEFFNGÀY,TỔNG ĐƠN HÀNG,ĐÃ HOÀN THÀNH,ĐÃ HỦY,DOANH THU (VND),AOV (VND)\n';
        let totalOrd = 0, totalComp = 0, totalCanc = 0, totalRev = 0;
        currentScreen12MasterDays.forEach(r => {
            csv += '"' + r.date + '",' + r.total + ',' + r.completed + ',' + r.cancelled + ',' + r.revenue + ',' + r.aov + '\n';
            totalOrd += r.total;
            totalComp += r.completed;
            totalCanc += r.cancelled;
            totalRev += r.revenue;
        });
        const totalAov = totalComp > 0 ? Math.round(totalRev / totalComp) : 0;
        csv += '"Tổng cộng (' + currentScreen12MasterDays.length + ' ngày có đơn)",' + totalOrd + ',' + totalComp + ',' + totalCanc + ',' + totalRev + ',' + totalAov + '\n';

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'Tong_hop_doanh_so_hang_ngay_' + (document.getElementById('screen12FilterFrom')?.value || '2026-10-01') + '_den_' + (document.getElementById('screen12FilterTo')?.value || '2026-10-31') + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }

    function exportRevenueReportCsv() {
        exportDailyAuditCsv();
    }

    // 4. BIỂU ĐỒ TRÒN TRẠNG THÁI ĐƠN HÀNG (DONUT CHART ĐỘNG)
    function renderDynamicDonutChart(statusList) {
        const group = document.getElementById('donutSegmentsGroup');
        const totalEl = document.getElementById('donutTotalCount');
        const legendContainer = document.getElementById('donutLegendContainer');
        if (!group) return;

        const COLOR_MAP = {
            'COMPLETED': '#10b981',
            'SHIPPED': '#06b6d4',
            'PROCESSING': '#3b82f6',
            'CONFIRMED': '#f59e0b',
            'PENDING': '#ea580c',
            'CANCELLED': '#ef4444'
        };

        let list = Array.isArray(statusList) ? statusList : [];
        let total = 0;
        list.forEach(st => total += Number(st.count) || 0);

        if (totalEl) totalEl.innerText = total > 0 ? total : 0;

        let circlesHtml = '';
        let legendHtml = '';
        let accum = 0;

        list.forEach(st => {
            const count = Number(st.count) || 0;
            const pct = total > 0 ? (count / total) * 100 : 0;
            const color = COLOR_MAP[st.code] || '#94a3b8';

            if (pct > 0) {
                const dashArray = pct.toFixed(1) + ' ' + (100 - pct).toFixed(1);
                const dashOffset = (-accum).toFixed(1);
                circlesHtml += '<circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="' + color + '" stroke-width="4.5" stroke-dasharray="' + dashArray + '" stroke-dashoffset="' + dashOffset + '" style="transition:all 0.5s ease;"></circle>';
                accum += pct;
            }

            legendHtml += '<div>' +
                '  <span class="legend-dot" style="background:' + color + '"></span>' +
                '  <b>' + st.label + ':</b> ' + (pct > 0 ? Math.round(pct) + '%' : '0%') + ' <small style="color:var(--text-muted)">(' + count + ')</small>' +
                '</div>';
        });

        group.innerHTML = circlesHtml;
        if (legendContainer && legendHtml) legendContainer.innerHTML = legendHtml;
    }

    // 5. THANH TIẾN TRÌNH PHÂN BỔ HỘI VIÊN (TIER BAR ĐỘNG)
    function renderDynamicTierBar(tierList) {
        if (!Array.isArray(tierList)) return;
        let total = 0;
        tierList.forEach(t => total += Number(t.count) || 0);

        const totalEl = document.getElementById('tier-total-count');
        if (totalEl) totalEl.innerText = total;

        const bronzeItem = tierList.find(t => t.code === 'BRONZE') || tierList[0];
        const silverItem = tierList.find(t => t.code === 'SILVER') || tierList[1];
        const goldItem = tierList.find(t => t.code === 'GOLD') || tierList[2];
        const diamondItem = tierList.find(t => t.code === 'DIAMOND') || tierList[3];

        const bronzeCount = Number(bronzeItem?.count) || 0;
        const silverCount = Number(silverItem?.count) || 0;
        const goldCount = Number(goldItem?.count) || 0;
        const diamondCount = Number(diamondItem?.count) || 0;

        const bronzeValEl = document.getElementById('tier-val-bronze');
        const silverValEl = document.getElementById('tier-val-silver');
        const goldValEl = document.getElementById('tier-val-gold');
        const diamondValEl = document.getElementById('tier-val-diamond');

        if (bronzeValEl) bronzeValEl.innerText = bronzeCount;
        if (silverValEl) silverValEl.innerText = silverCount;
        if (goldValEl) goldValEl.innerText = goldCount;
        if (diamondValEl) diamondValEl.innerText = diamondCount;

        const bPct = total > 0 ? (bronzeCount / total * 100) : 0;
        const sPct = total > 0 ? (silverCount / total * 100) : 0;
        const gPct = total > 0 ? (goldCount / total * 100) : 0;
        const dPct = total > 0 ? (diamondCount / total * 100) : 0;

        const bBar = document.getElementById('tier-bar-bronze');
        const sBar = document.getElementById('tier-bar-silver');
        const gBar = document.getElementById('tier-bar-gold');
        const dBar = document.getElementById('tier-bar-diamond');

        if (bBar) bBar.style.width = bPct + '%';
        if (sBar) sBar.style.width = sPct + '%';
        if (gBar) gBar.style.width = gPct + '%';
        if (dBar) dBar.style.width = dPct + '%';
    }

    // 6. TIẾN TRÌNH ĐỒNG BỘ THỜI GIAN THỰC (REAL-TIME POLLING)
    let isPollingAdmin = false;
    async function fetchLiveDashboardStats() {
        if (isPollingAdmin) return;
        isPollingAdmin = true;
        const badge = document.getElementById('admin-live-badge');
        if (badge) {
            badge.innerHTML = '<i class="ti ti-loader" style="animation:spin 1s linear infinite; display:inline-block"></i> ĐANG ĐỒNG BỘ...';
        }

        try {
            const resp = await fetch('${ctx}/admin/api/stats' + window.location.search);
            if (!resp.ok) throw new Error('API response: ' + resp.status);
            const data = await resp.json();

            if (data && data.stats) {
                // Cập nhật 4 thẻ KPI Screen 1
                const revEl = document.getElementById('admin-kpi-revenue');
                if (revEl && data.stats.grossRevenue != null) {
                    revEl.innerText = formatCurrency(data.stats.grossRevenue);
                }
                const ordEl = document.getElementById('admin-kpi-orders');
                if (ordEl && data.stats.completedOrders != null) {
                    ordEl.innerText = Number(data.stats.completedOrders).toLocaleString('vi-VN');
                }
                const custEl = document.getElementById('admin-kpi-customers');
                if (custEl && data.stats.newCustomers != null) {
                    custEl.innerText = data.stats.newCustomers;
                }
                const alertEl = document.getElementById('admin-kpi-alerts');
                if (alertEl && data.alertSummary && data.alertSummary.lowStockCount != null) {
                    alertEl.innerText = data.alertSummary.lowStockCount;
                }

                // Cập nhật sơ đồ Tab 1 nếu không ở tab Screen 12
                if (data.stats.dailyRevenue && window.location.hash !== '#revenue') {
                    renderDynamicRevenueChart(data.stats.dailyRevenue);
                }

                // Vẽ lại biểu đồ tròn trạng thái đơn
                if (data.stats.ordersByStatus) {
                    renderDynamicDonutChart(data.stats.ordersByStatus);
                }

                // Cập nhật thanh hội viên
                if (data.stats.customersByTier) {
                    renderDynamicTierBar(data.stats.customersByTier);
                }
            }

            if (badge) {
                badge.className = 'pill-badge green';
                badge.innerHTML = '<span style="width:7px; height:7px; border-radius:50%; background:#16a34a; display:inline-block; box-shadow:0 0 0 2px #bbf7d0;"></span> THỜI GIAN THỰC (' + (data.updatedAt || 'Vừa xong') + ')';
            }
        } catch (e) {
            console.warn('Lỗi đồng bộ thời gian thực:', e);
            if (badge) {
                badge.className = 'pill-badge gold';
                badge.innerHTML = '<span style="width:7px; height:7px; border-radius:50%; background:#d97706; display:inline-block;"></span> ĐANG KẾT NỐI...';
            }
        } finally {
            isPollingAdmin = false;
        }
    }

    // Khởi tạo sơ đồ khi trang tải xong
    document.addEventListener('DOMContentLoaded', () => {
        // 1, 2, 3: Khởi tạo và áp dụng dữ liệu thực tế cho Báo cáo doanh thu (Screen 12)
        applyScreen12Filter();

        // 4. Render biểu đồ tròn trạng thái đơn
        const initialStatuses = [
            <c:if test="${not empty stats.ordersByStatus}">
                <c:forEach var="st" items="${stats.ordersByStatus}" varStatus="loop">
                    { code: '${st.code}', label: '${st.label}', count: ${st.count} }<c:if test="${!loop.last}">,</c:if>
                </c:forEach>
            </c:if>
        ];
        renderDynamicDonutChart(initialStatuses);

        // 5. Render thanh hội viên
        const initialTiers = [
            <c:if test="${not empty stats.customersByTier}">
                <c:forEach var="t" items="${stats.customersByTier}" varStatus="loop">
                    { code: '${t.code}', label: '${t.label}', count: ${t.count} }<c:if test="${!loop.last}">,</c:if>
                </c:forEach>
            </c:if>
        ];
        renderDynamicTierBar(initialTiers);

        // Tự động làm mới thời gian thực mỗi 20 giây
        setInterval(fetchLiveDashboardStats, 20000);
    });
</script>
</body>
</html>
