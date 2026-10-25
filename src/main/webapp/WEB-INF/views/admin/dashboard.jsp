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

        /* Styles cho Thanh Lọc Hiện Đại (Screen 12 & Screen 13) theo mẫu Pill Bar */
        .modern-filter-container {
            margin-bottom: 22px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .filter-pill-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 9999px;
            padding: 6px 8px 6px 18px;
            box-shadow: 0 4px 18px -2px rgba(0, 0, 0, 0.05), 0 2px 6px -1px rgba(0, 0, 0, 0.02);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            transition: all 0.2s ease;
        }
        .filter-pill-card:hover {
            box-shadow: 0 6px 22px -2px rgba(0, 0, 0, 0.08), 0 3px 8px -1px rgba(0, 0, 0, 0.03);
            border-color: #cbd5e1;
        }
        .filter-controls-group {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }
        .filter-date-group {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-cal-icon {
            color: #ea580c;
            font-size: 19px;
            margin-right: 2px;
            flex-shrink: 0;
            display: inline-flex;
            align-items: center;
        }
        .filter-date-input {
            border: none;
            outline: none;
            background: transparent;
            font-size: 13.5px;
            font-weight: 700;
            color: #1e293b;
            font-family: inherit;
            cursor: pointer;
            padding: 4px 2px;
            width: 128px;
        }
        .filter-date-input::-webkit-calendar-picker-indicator {
            cursor: pointer;
            opacity: 0.7;
            transition: opacity 0.15s ease;
        }
        .filter-date-input::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
        }
        .filter-arrow-sep {
            color: #94a3b8;
            font-size: 15px;
            font-weight: 600;
            user-select: none;
            margin: 0 4px;
        }
        .filter-sep-line {
            width: 1px;
            height: 22px;
            background: #e2e8f0;
            margin: 0 2px;
            flex-shrink: 0;
        }
        .filter-select-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 9999px;
            padding: 5px 14px;
            transition: all 0.15s ease;
        }
        .filter-select-pill:focus-within, .filter-select-pill:hover {
            border-color: #f97316;
            background: #fff;
            box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.08);
        }
        .filter-select-pill select {
            border: none;
            outline: none;
            background: transparent;
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
            cursor: pointer;
            font-family: inherit;
            padding-right: 4px;
        }
        .filter-chips-group {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .rev-quick-chip, .s13-chip {
            padding: 6px 16px;
            border-radius: 12px;
            border: 1px solid transparent;
            background: #f3f4f6;
            font-size: 13px;
            font-weight: 600;
            color: #52525b;
            cursor: pointer;
            transition: all 0.15s ease;
            white-space: nowrap;
            user-select: none;
        }
        .rev-quick-chip:hover, .s13-chip:hover {
            background: #fed7aa;
            color: #c2410c;
        }
        .rev-quick-chip.active, .s13-chip.active {
            background: #ffedd5 !important;
            color: #ea580c !important;
            border-color: #fed7aa !important;
            font-weight: 700 !important;
        }
        .filter-actions-group {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: auto;
        }
        .filter-btn-reset {
            height: 38px;
            padding: 0 14px;
            border-radius: 9999px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #64748b;
            font-size: 12.5px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.15s ease;
            white-space: nowrap;
        }
        .filter-btn-reset:hover {
            background: #f8fafc;
            color: #1e293b;
            border-color: #cbd5e1;
        }
        .filter-btn-apply {
            height: 38px;
            padding: 0 24px;
            border-radius: 9999px;
            border: none;
            background: #ea580c;
            color: #ffffff;
            font-size: 13.5px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            box-shadow: 0 3px 10px rgba(234, 88, 12, 0.35);
            transition: all 0.15s ease;
            white-space: nowrap;
            letter-spacing: 0.2px;
        }
        .filter-btn-apply:hover {
            background: #d94e08;
            box-shadow: 0 4px 14px rgba(234, 88, 12, 0.45);
            transform: translateY(-1px);
        }
        .filter-btn-apply:active {
            transform: translateY(0);
        }
        .filter-meta-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            padding: 2px 12px 0 12px;
            font-size: 12.5px;
            color: #64748b;
            font-weight: 600;
        }
        .filter-meta-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
        }
        .filter-pulse-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #16a34a;
            display: inline-block;
            box-shadow: 0 0 0 2px #bbf7d0;
        }
        @media (max-width: 1100px) {
            .filter-pill-card {
                border-radius: 24px;
                padding: 12px 16px;
            }
            .filter-actions-group {
                margin-left: 0;
                width: 100%;
                justify-content: flex-end;
            }
        }
        
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

        /* Styles cho Báo cáo hội viên (Screen 13 Figma) */
        .s13-tier-dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; flex-shrink: 0; }
        .s13-tier-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; border-radius: 10px; border: 1px solid #e2e8f0; background: #fff; }
        .s13-stat-bar { height: 10px; border-radius: 99px; background: #f1f5f9; overflow: hidden; position: relative; margin-top: 6px; }
        .s13-stat-bar-fill { height: 100%; border-radius: 99px; transition: width 0.3s ease; }
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
                    <button type="button" class="chip" data-preset="week">Tuần này</button>
                    <button type="button" class="chip" data-preset="month">Tháng này</button>
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
                        <p id="trendSubtitle1" style="font-size:13px; color:#64748b; margin:0;">Doanh thu trong kỳ được chọn</p>
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

                    <div class="trend-axis-labels" style="display:flex; margin-left:36px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
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

        <%-- Khung Bộ Lọc Kiểu Pill Hiện Đại (Screen 12) --%>
        <div class="modern-filter-container">
            <div class="filter-pill-card">
                <div class="filter-controls-group">
                    <%-- Chọn khoảng ngày Từ ngày -> Đến ngày --%>
                    <div class="filter-date-group" title="Khoảng thời gian báo cáo">
                        <i class="ti ti-calendar filter-cal-icon"></i>
                        <input type="date" class="filter-date-input" id="screen12FilterFrom" value="2026-10-01" onchange="onScreen12DateChange()" title="Từ ngày">
                        <span class="filter-arrow-sep">&rarr;</span>
                        <input type="date" class="filter-date-input" id="screen12FilterTo" value="2026-10-31" onchange="onScreen12DateChange()" title="Đến ngày">
                    </div>

                    <div class="filter-sep-line"></div>

                    <%-- Các nút chọn nhanh --%>
                    <div class="filter-chips-group">
                        <button type="button" class="rev-quick-chip" id="chip-today" onclick="selectQuickChip(this, 'today')">Hôm nay</button>
                        <button type="button" class="rev-quick-chip" id="chip-week" onclick="selectQuickChip(this, 'week')">Tuần này</button>
                        <button type="button" class="rev-quick-chip active" id="chip-month" onclick="selectQuickChip(this, 'month')">Tháng này</button>
                        <button type="button" class="rev-quick-chip" id="chip-year" onclick="selectQuickChip(this, 'year')">Năm nay</button>
                    </div>
                </div>

                <%-- Nút tác vụ Đặt lại & Lọc --%>
                <div class="filter-actions-group">
                    <button type="button" class="filter-btn-reset" onclick="resetScreen12Filter()" title="Đặt lại về mặc định">
                        <i class="ti ti-rotate-2"></i> Đặt lại
                    </button>
                    <button type="button" class="filter-btn-apply" onclick="applyScreen12Filter()" title="Áp dụng lọc doanh thu">
                        Lọc
                    </button>
                </div>
            </div>

            <%-- Dòng trạng thái đồng bộ dữ liệu --%>
            <div class="filter-meta-bar">
                <div class="filter-meta-badge">
                    <span class="filter-pulse-dot"></span>
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
                    ₫<fmt:formatNumber value="${stats != null && stats.grossRevenue != null ? stats.grossRevenue : 0}" type="number"/>
                </div>
                <div style="display:flex; align-items:center; gap:6px;" id="screen12KpiRevenueGrowth">
                    <span class="pill-badge warn" style="background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5; font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;"><i class="ti ti-arrow-down-right"></i> -8.3%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">TỔNG ĐƠN HÀNG</span>
                <div class="rev-kpi-icon" style="background:#ffedd5; color:#c2410c;">
                    <i class="ti ti-shopping-bag"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiOrders">
                    <fmt:formatNumber value="${stats != null && stats.allOrders != null ? stats.allOrders.size() : 0}" type="number"/>
                </div>
                <div style="display:flex; align-items:center; gap:6px;" id="screen12KpiOrdersGrowth">
                    <span class="pill-badge green" style="font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;"><i class="ti ti-arrow-up-right"></i> +30.8%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">GIÁ TRỊ TRUNG BÌNH ĐƠN (AOV)</span>
                <div class="rev-kpi-icon" style="background:#fed7aa; color:#9a3412;">
                    <i class="ti ti-receipt-2"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiAov">
                    ₫<fmt:formatNumber value="${stats != null && stats.completedOrders > 0 ? stats.grossRevenue / stats.completedOrders : 0}" type="number" maxFractionDigits="0"/>
                </div>
                <div style="display:flex; align-items:center; gap:6px;" id="screen12KpiAovGrowth">
                    <span class="pill-badge warn" style="background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5; font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;"><i class="ti ti-arrow-down-right"></i> -6.2%</span>
                    <span style="font-size:12px; color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card">
                <span class="kpi-label" style="font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">ĐƠN HÀNG HOÀN THÀNH</span>
                <div class="rev-kpi-icon" style="background:#dcfce7; color:#166534;">
                    <i class="ti ti-circle-check"></i>
                </div>
                <div class="rev-kpi-val" id="screen12KpiCompleted">
                    <span id="screen12KpiCompletedCount"><fmt:formatNumber value="${stats != null && stats.completedOrders > 0 ? stats.completedOrders : 0}" type="number"/></span> <span style="font-size:14px; font-weight:600; color:#64748b;" id="screen12KpiCompletedPct">(${stats != null && stats.completedOrders > 0 && stats.allOrders != null && stats.allOrders.size() > 0 ? String.format("%.1f", (stats.completedOrders * 100.0) / stats.allOrders.size()) : '0.0'}%)</span>
                </div>
                <div style="display:flex; align-items:center; gap:6px;">
                    <span class="pill-badge green" id="screen12KpiSuccessRate"><i class="ti ti-check"></i> <c:out value="${stats != null && stats.completedOrders > 0 && stats.allOrders != null && stats.allOrders.size() > 0 ? String.format('%.1f', (stats.completedOrders * 100.0) / stats.allOrders.size()) : '0.0'}"/>%</span>
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
                        <p id="screen12RevenueSubtitle" style="font-size:12.5px; color:#64748b; margin:0;">Doanh thu trong kỳ được chọn (Tháng 10/2026)</p>
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

                    <div class="trend-axis-labels" style="display:flex; margin-left:32px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
                    </div>
                </div>
            </div>

            <%-- Biểu đồ 2: Xu hướng đơn hàng --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Xu hướng đơn hàng</h3>
                        <p id="screen12OrdersSubtitle" style="font-size:12.5px; color:#64748b; margin:0;">Khối lượng đơn hàng hàng ngày (Tháng 10/2026)</p>
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

                    <div class="trend-axis-labels" style="display:flex; margin-left:32px; margin-top:14px; justify-content:space-between; font-size:12px; font-weight:600; color:#64748b; padding:0 4px;">
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
                        <svg viewBox="0 0 42 42" style="width:100%; height:100%; transform:rotate(-90deg);" id="screen12DonutCatSvg">
                            <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#f1f5f9" stroke-width="5"></circle>
                            <g id="screen12DonutCatSlices">
                                <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#ea580c" stroke-width="5" stroke-dasharray="48 52" stroke-dashoffset="0"></circle>
                                <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#f59e0b" stroke-width="5" stroke-dasharray="12.5 87.5" stroke-dashoffset="-48"></circle>
                                <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#7c2d12" stroke-width="5" stroke-dasharray="32.6 67.4" stroke-dashoffset="-60.5"></circle>
                                <circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="#fb923c" stroke-width="5" stroke-dasharray="6.9 93.1" stroke-dashoffset="-93.1"></circle>
                            </g>
                        </svg>
                        <div style="position:absolute; text-align:center;">
                            <small style="display:block; font-size:10px; font-weight:800; color:#94a3b8; text-transform:uppercase;">TỔNG CỘNG</small>
                            <strong style="font-size:16px; font-weight:800; color:#1e293b;" id="screen12CatTotal">₫0</strong>
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
                                <span style="color:#1e293b;" id="screen12CatVal1">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar1" style="height:100%; width:0%; background:#ea580c; border-radius:99px; transition:width 0.4s ease;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#f59e0b; display:inline-block;"></span>
                                    Pate &amp; Thức ăn ướt
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal2">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar2" style="height:100%; width:0%; background:#f59e0b; border-radius:99px; transition:width 0.4s ease;"></div>
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
                                <div id="screen12CatBar3" style="height:100%; width:0%; background:#7c2d12; border-radius:99px; transition:width 0.4s ease;"></div>
                            </div>
                        </div>

                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:700; margin-bottom:4px;">
                                <span style="display:inline-flex; align-items:center; gap:6px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#fb923c; display:inline-block;"></span>
                                    Bánh thưởng &amp; Snack huấn luyện
                                </span>
                                <span style="color:#1e293b;" id="screen12CatVal4">₫0 <small style="color:#64748b; font-weight:600;">(0.0%)</small></span>
                            </div>
                            <div style="height:6px; background:#f1f5f9; border-radius:99px; overflow:hidden;">
                                <div id="screen12CatBar4" style="height:100%; width:0%; background:#fb923c; border-radius:99px; transition:width 0.4s ease;"></div>
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
        <%-- Top Breadcrumb & Actions --%>
        <div class="page-head" style="margin-bottom:20px;">
            <div>
                <div class="screen-bc" style="font-size:11.5px; font-weight:800; color:#ea580c; text-transform:uppercase; letter-spacing:0.8px; margin-bottom:6px;">
                    <span>HỘI VIÊN &amp; BÁO CÁO</span> <span class="sep" style="margin:0 6px; color:#cbd5e1;">&gt;</span> <span class="current" style="color:#64748b;">BÁO CÁO HỘI VIÊN</span>
                </div>
                <h1 style="display:flex; align-items:center; gap:12px; margin:0 0 6px 0; font-size:24px; font-weight:800; color:#1e293b; letter-spacing:-0.5px;">
                    BÁO CÁO HỘI VIÊN
                    <span class="pill-badge gold" style="font-size:11px; padding:4px 10px; border-radius:99px; background:#fef3c7; color:#92400e; font-weight:700;">
                        Quyền Quản trị viên • Chỉ xem
                    </span>
                </h1>
                <p class="page-sub" style="font-size:13px; color:#64748b; margin:0;">
                    Báo cáo tổng hợp cơ cấu hạng, hành vi mua sắm và hiệu quả kinh doanh từ chương trình hội viên PetCare.
                </p>
            </div>

            <div style="display:flex; align-items:center; gap:10px;">
                <button type="button" class="export-btn" onclick="exportScreen13TableCsv()" style="display:inline-flex; align-items:center; gap:6px; padding:8px 16px; border-radius:10px; background:#fff; border:1px solid #cbd5e1; font-size:13px; font-weight:700; color:#334155; cursor:pointer; box-shadow:0 1px 3px rgba(0,0,0,0.04);">
                    <i class="ti ti-download" style="font-size:16px; color:#ea580c;"></i> Xuất CSV
                </button>
            </div>
        </div>

        <%-- Khung Bộ Lọc Kiểu Pill Hiện Đại (Screen 13) --%>
        <div class="modern-filter-container">
            <div class="filter-pill-card">
                <div class="filter-controls-group">
                    <%-- Chọn khoảng ngày Từ ngày -> Đến ngày --%>
                    <div class="filter-date-group" title="Khoảng thời gian báo cáo">
                        <i class="ti ti-calendar filter-cal-icon"></i>
                        <input type="date" class="filter-date-input" id="s13FilterFrom" value="2026-10-01" onchange="onScreen13DateChange()" title="Từ ngày">
                        <span class="filter-arrow-sep">&rarr;</span>
                        <input type="date" class="filter-date-input" id="s13FilterTo" value="2026-10-31" onchange="onScreen13DateChange()" title="Đến ngày">
                    </div>

                    <div class="filter-sep-line"></div>

                    <%-- Lọc Hạng thành viên --%>
                    <div class="filter-select-pill" title="Lọc theo hạng thành viên">
                        <i class="ti ti-crown" style="color:#f59e0b; font-size:16px;"></i>
                        <select id="s13FilterTier" onchange="applyScreen13Filter()">
                            <option value="">Tất cả hạng (Toàn bộ)</option>
                            <option value="BRONZE">Đồng (Bronze)</option>
                            <option value="SILVER">Bạc (Silver)</option>
                            <option value="GOLD">Vàng (Gold)</option>
                            <option value="DIAMOND">Kim cương (Diamond)</option>
                        </select>
                    </div>

                    <div class="filter-sep-line"></div>

                    <%-- Các nút chọn nhanh --%>
                    <div class="filter-chips-group">
                        <button type="button" class="s13-chip" id="s13-chip-week" onclick="selectScreen13QuickChip(this, 'week')">Tuần này</button>
                        <button type="button" class="s13-chip active" id="s13-chip-month" onclick="selectScreen13QuickChip(this, 'month')">Tháng này</button>
                        <button type="button" class="s13-chip" id="s13-chip-prevmonth" onclick="selectScreen13QuickChip(this, 'prevmonth')">Tháng trước</button>
                        <button type="button" class="s13-chip" id="s13-chip-year" onclick="selectScreen13QuickChip(this, 'year')">Năm nay</button>
                    </div>
                </div>

                <%-- Nút tác vụ Đặt lại & Lọc --%>
                <div class="filter-actions-group">
                    <button type="button" class="filter-btn-reset" onclick="resetScreen13Filter()" title="Đặt lại về mặc định">
                        <i class="ti ti-rotate-2"></i> Đặt lại
                    </button>
                    <button type="button" class="filter-btn-apply" onclick="applyScreen13Filter()" title="Áp dụng lọc hội viên">
                        Lọc
                    </button>
                </div>
            </div>

            <%-- Dòng trạng thái lọc & phạm vi dữ liệu --%>
            <div class="filter-meta-bar">
                <div class="filter-meta-badge">
                    <span class="filter-pulse-dot"></span>
                    <span>Đang lọc: <b id="s13FilterStatusLabel" style="color:#1e293b;">01/10/2026 - 31/10/2026</b> &bull; Phạm vi: <b>Toàn hệ thống PetCare Shop (Cửa hàng &amp; Online)</b></span>
                </div>
            </div>
        </div>

        <%-- Row 1: 3 Thẻ KPI --%>
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:18px; margin-bottom:22px;">
            <div class="rev-kpi-card" style="padding:18px 22px;">
                <span style="font-size:11.5px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">TỔNG SỐ HỘI VIÊN</span>
                <div class="rev-kpi-icon" style="background:#fef3c7; color:#92400e; width:40px; height:40px; top:18px; right:18px;">
                    <i class="ti ti-users"></i>
                </div>
                <div class="rev-kpi-val" id="s13KpiTotalMembers" style="margin:10px 0 6px 0;">3,842</div>
                <div style="display:flex; align-items:center; gap:6px; font-size:12.5px;" id="s13KpiTotalMembersGrowth">
                    <span style="color:#16a34a; font-weight:800; display:inline-flex; align-items:center; gap:2px;"><i class="ti ti-arrow-up"></i> 5.4%</span>
                    <span style="color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card" style="padding:18px 22px;">
                <span style="font-size:11.5px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">HỘI VIÊN MỚI</span>
                <div class="rev-kpi-icon" style="background:#ffedd5; color:#c2410c; width:40px; height:40px; top:18px; right:18px;">
                    <i class="ti ti-user-plus"></i>
                </div>
                <div class="rev-kpi-val" id="s13KpiNewMembers" style="margin:10px 0 6px 0;">312</div>
                <div style="display:flex; align-items:center; gap:6px; font-size:12.5px;" id="s13KpiNewMembersGrowth">
                    <span style="color:#16a34a; font-weight:800; display:inline-flex; align-items:center; gap:2px;"><i class="ti ti-arrow-up"></i> 15.1%</span>
                    <span style="color:#64748b; font-weight:600;">so với tháng trước</span>
                </div>
            </div>

            <div class="rev-kpi-card" style="padding:18px 22px;">
                <span style="font-size:11.5px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">HỘI VIÊN PHÁT SINH ĐƠN</span>
                <div class="rev-kpi-icon" style="background:#dcfce7; color:#166534; width:40px; height:40px; top:18px; right:18px;">
                    <i class="ti ti-shopping-bag"></i>
                </div>
                <div class="rev-kpi-val" id="s13KpiActiveMembers" style="margin:10px 0 6px 0;">2,460</div>
                <div style="display:flex; align-items:center; gap:6px; font-size:12.5px;" id="s13KpiActiveMembersRatio">
                    <span class="pill-badge green" style="font-size:11px; padding:3px 8px; border-radius:6px; background:#dcfce7; color:#166534; font-weight:700;">64.0% tỷ lệ</span>
                    <span style="color:#64748b; font-weight:600;">phát sinh đơn hàng</span>
                </div>
            </div>
        </div>

        <%-- Row 2: 2 Panels (Phân bổ hạng & Biến động số lượng theo tháng) --%>
        <div style="display:grid; grid-template-columns: 42% 1fr; gap:20px; margin-bottom:22px;">
            <%-- Panel Trái: Phân bổ hạng thành viên --%>
            <div class="rev-chart-card">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:16px;">
                    <div>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Phân bổ hạng thành viên</h3>
                        <p id="s13DonutSubtitle" style="font-size:12px; color:#64748b; margin:0;">Cơ cấu 3,842 hội viên theo các cấp bậc</p>
                    </div>
                    <div style="width:34px; height:34px; border-radius:50%; border:1px solid #e2e8f0; display:grid; place-items:center; color:#64748b;">
                        <i class="ti ti-chart-pie" style="font-size:18px;"></i>
                    </div>
                </div>

                <%-- SVG Donut Chart --%>
                <div style="display:flex; justify-content:center; align-items:center; position:relative; height:200px; margin-bottom:16px;">
                    <svg viewBox="0 0 200 200" width="190" height="190" style="transform: rotate(-90deg);">
                        <%-- Background track --%>
                        <circle cx="100" cy="100" r="76" fill="transparent" stroke="#f1f5f9" stroke-width="22"/>
                        <%-- Bronze segment (55.7% -> 266px of 477.5px) --%>
                        <circle id="s13DonutBronze" cx="100" cy="100" r="76" fill="transparent" stroke="#d97706" stroke-width="22"
                                stroke-dasharray="266 477.5" stroke-dashoffset="0" style="transition:all 0.4s ease;"/>
                        <%-- Silver segment (26.5% -> 126.5px) --%>
                        <circle id="s13DonutSilver" cx="100" cy="100" r="76" fill="transparent" stroke="#64748b" stroke-width="22"
                                stroke-dasharray="126.5 477.5" stroke-dashoffset="-266" style="transition:all 0.4s ease;"/>
                        <%-- Gold segment (13.5% -> 64.5px) --%>
                        <circle id="s13DonutGold" cx="100" cy="100" r="76" fill="transparent" stroke="#f59e0b" stroke-width="22"
                                stroke-dasharray="64.5 477.5" stroke-dashoffset="-392.5" style="transition:all 0.4s ease;"/>
                        <%-- Diamond segment (4.2% -> 20.5px) --%>
                        <circle id="s13DonutDiamond" cx="100" cy="100" r="76" fill="transparent" stroke="#06b6d4" stroke-width="22"
                                stroke-dasharray="20.5 477.5" stroke-dashoffset="-457" style="transition:all 0.4s ease;"/>
                    </svg>
                    <%-- Center Text in Donut --%>
                    <div style="position:absolute; inset:0; display:flex; flex-direction:column; justify-content:center; align-items:center; pointer-events:none; text-align:center;">
                        <span id="s13DonutCenterVal" style="font-size:24px; font-weight:800; color:#1e293b; line-height:1.1;">3,842</span>
                        <span id="s13DonutCenterLabel" style="font-size:11px; font-weight:600; color:#64748b; margin-top:2px;">Tổng số hội viên</span>
                    </div>
                </div>

                <%-- 4 Thẻ chỉ số phân bổ 2x2 --%>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
                    <div class="s13-tier-card" style="background:#fffcf9; border-color:#fed7aa;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span class="s13-tier-dot" style="background:#d97706;"></span>
                            <div>
                                <div style="font-size:13px; font-weight:700; color:#1e293b;">Đồng</div>
                                <div style="font-size:10.5px; font-weight:600; color:#94a3b8;">Bronze</div>
                            </div>
                        </div>
                        <div style="text-align:right;">
                            <div style="font-size:13px; font-weight:800; color:#1e293b;" id="s13CardBronzeCount">2,140</div>
                            <div style="font-size:11px; font-weight:600; color:#d97706;" id="s13CardBronzePct">55.7%</div>
                        </div>
                    </div>

                    <div class="s13-tier-card" style="background:#f8fafc; border-color:#e2e8f0;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span class="s13-tier-dot" style="background:#64748b;"></span>
                            <div>
                                <div style="font-size:13px; font-weight:700; color:#1e293b;">Bạc</div>
                                <div style="font-size:10.5px; font-weight:600; color:#94a3b8;">Silver</div>
                            </div>
                        </div>
                        <div style="text-align:right;">
                            <div style="font-size:13px; font-weight:800; color:#1e293b;" id="s13CardSilverCount">1,020</div>
                            <div style="font-size:11px; font-weight:600; color:#64748b;" id="s13CardSilverPct">26.5%</div>
                        </div>
                    </div>

                    <div class="s13-tier-card" style="background:#fffbeb; border-color:#fef08a;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span class="s13-tier-dot" style="background:#f59e0b;"></span>
                            <div>
                                <div style="font-size:13px; font-weight:700; color:#1e293b;">Vàng</div>
                                <div style="font-size:10.5px; font-weight:600; color:#94a3b8;">Gold</div>
                            </div>
                        </div>
                        <div style="text-align:right;">
                            <div style="font-size:13px; font-weight:800; color:#1e293b;" id="s13CardGoldCount">520</div>
                            <div style="font-size:11px; font-weight:600; color:#d97706;" id="s13CardGoldPct">13.5%</div>
                        </div>
                    </div>

                    <div class="s13-tier-card" style="background:#ecfeff; border-color:#a5f3fc;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span class="s13-tier-dot" style="background:#06b6d4;"></span>
                            <div>
                                <div style="font-size:13px; font-weight:700; color:#1e293b;">Kim cương</div>
                                <div style="font-size:10.5px; font-weight:600; color:#94a3b8;">Diamond</div>
                            </div>
                        </div>
                        <div style="text-align:right;">
                            <div style="font-size:13px; font-weight:800; color:#1e293b;" id="s13CardDiamondCount">162</div>
                            <div style="font-size:11px; font-weight:600; color:#0891b2;" id="s13CardDiamondPct">4.2%</div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Panel Phải: Biến động số lượng hội viên theo hạng qua các tháng --%>
            <div class="rev-chart-card" style="display:flex; flex-direction:column; justify-content:space-between;">
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:20px;">
                        <div>
                            <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0;">Biến động số lượng hội viên theo hạng qua các tháng</h3>
                            <p style="font-size:12px; color:#64748b; margin:0;">Thước đo tăng trưởng cơ cấu từ Tháng 7 đến Tháng 10/2026</p>
                        </div>
                        <div style="width:34px; height:34px; border-radius:50%; border:1px solid #e2e8f0; display:grid; place-items:center; color:#64748b;">
                            <i class="ti ti-chart-bar" style="font-size:18px;"></i>
                        </div>
                    </div>

                    <%-- Danh sách 4 thanh xếp tầng (Stacked horizontal bars) --%>
                    <div id="s13MonthlyTrendContainer" style="display:flex; flex-direction:column; gap:16px;">
                        <%-- Tháng 10/2026 (Kỳ này) --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px;">
                                <span style="font-weight:700; color:#ea580c; display:inline-flex; align-items:center; gap:4px;">
                                    <i class="ti ti-caret-down" style="font-size:13px;"></i> Tháng 10/2026 (Kỳ này)
                                </span>
                                <span style="font-weight:800; color:#ea580c;">3,842 hội viên (+5.4%)</span>
                            </div>
                            <div style="height:12px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">
                                <div style="width:55.7%; background:#d97706;" title="Đồng: 2,140"></div>
                                <div style="width:26.5%; background:#64748b;" title="Bạc: 1,020"></div>
                                <div style="width:13.5%; background:#f59e0b;" title="Vàng: 520"></div>
                                <div style="width:4.3%; background:#06b6d4;" title="Kim cương: 162"></div>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:10.5px; font-weight:600; color:#64748b; margin-top:3px;">
                                <span>Đồng: 2,140</span>
                                <span>Bạc: 1,020</span>
                                <span>Vàng: 520</span>
                                <span>Kim cương: 162</span>
                            </div>
                        </div>

                        <%-- Tháng 09/2026 --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px;">
                                <span style="font-weight:700; color:#334155;">Tháng 09/2026</span>
                                <span style="font-weight:700; color:#1e293b;">3,645 hội viên (+6.3%)</span>
                            </div>
                            <div style="height:12px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">
                                <div style="width:56.8%; background:#d97706;" title="Đồng: 2,072"></div>
                                <div style="width:26.2%; background:#64748b;" title="Bạc: 955"></div>
                                <div style="width:13.1%; background:#f59e0b;" title="Vàng: 476"></div>
                                <div style="width:3.9%; background:#06b6d4;" title="Kim cương: 142"></div>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:10.5px; font-weight:600; color:#64748b; margin-top:3px;">
                                <span>Đồng: 2,072</span>
                                <span>Bạc: 955</span>
                                <span>Vàng: 476</span>
                                <span>Kim cương: 142</span>
                            </div>
                        </div>

                        <%-- Tháng 08/2026 --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px;">
                                <span style="font-weight:700; color:#334155;">Tháng 08/2026</span>
                                <span style="font-weight:700; color:#1e293b;">3,430 hội viên (+4.6%)</span>
                            </div>
                            <div style="height:12px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">
                                <div style="width:58.6%; background:#d97706;" title="Đồng: 2,010"></div>
                                <div style="width:26.5%; background:#64748b;" title="Bạc: 910"></div>
                                <div style="width:12.0%; background:#f59e0b;" title="Vàng: 410"></div>
                                <div style="width:2.9%; background:#06b6d4;" title="Kim cương: 100"></div>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:10.5px; font-weight:600; color:#64748b; margin-top:3px;">
                                <span>Đồng: 2,010</span>
                                <span>Bạc: 910</span>
                                <span>Vàng: 410</span>
                                <span>Kim cương: 100</span>
                            </div>
                        </div>

                        <%-- Tháng 07/2026 --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px;">
                                <span style="font-weight:700; color:#334155;">Tháng 07/2026</span>
                                <span style="font-weight:700; color:#1e293b;">3,278 hội viên (+5.0%)</span>
                            </div>
                            <div style="height:12px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">
                                <div style="width:60.1%; background:#d97706;" title="Đồng: 1,970"></div>
                                <div style="width:25.9%; background:#64748b;" title="Bạc: 850"></div>
                                <div style="width:11.2%; background:#f59e0b;" title="Vàng: 367"></div>
                                <div style="width:2.8%; background:#06b6d4;" title="Kim cương: 91"></div>
                            </div>
                            <div style="display:flex; justify-content:space-between; font-size:10.5px; font-weight:600; color:#64748b; margin-top:3px;">
                                <span>Đồng: 1,970</span>
                                <span>Bạc: 850</span>
                                <span>Vàng: 367</span>
                                <span>Kim cương: 91</span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Chú thích Legend phía dưới --%>
                <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; padding-top:14px; margin-top:16px; border-top:1px dashed #f1f5f9; font-size:12px;">
                    <div style="display:flex; align-items:center; gap:14px; font-weight:600; color:#64748b;">
                        <span style="display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#d97706;"></span> Đồng</span>
                        <span style="display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#64748b;"></span> Bạc</span>
                        <span style="display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#f59e0b;"></span> Vàng</span>
                        <span style="display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#06b6d4;"></span> Kim cương</span>
                    </div>
                    <span style="font-weight:700; color:#ea580c; display:inline-flex; align-items:center; gap:4px;">
                        <i class="ti ti-trending-up"></i> Tăng trưởng đều 4 tháng
                    </span>
                </div>
            </div>
        </div>

        <%-- Row 3: Hành vi mua sắm của hội viên --%>
        <div class="rev-chart-card" style="margin-bottom:22px;">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px; flex-wrap:wrap; gap:12px;">
                <div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <i class="ti ti-shopping-cart" style="color:#ea580c; font-size:20px;"></i>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0;">Hành vi mua sắm của hội viên</h3>
                    </div>
                    <p style="font-size:12.5px; color:#64748b; margin:3px 0 0 0;">
                        So sánh chuyên sâu về tỷ trọng doanh thu, số lượng đơn và giá trị đơn hàng trung bình (AOV) giữa các hạng.
                    </p>
                </div>
                <div>
                    <span class="pill-badge orange" style="background:#fff7ed; border:1px solid #fed7aa; color:#ea580c; font-size:12px; font-weight:700; padding:6px 14px; border-radius:99px;">
                        <i class="ti ti-shield-check" style="margin-right:4px;"></i> Dữ liệu giao dịch được xác thực
                    </span>
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:24px;">
                <%-- Cột trái: Tỷ trọng doanh thu theo hạng thành viên --%>
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                        <span style="font-size:13.5px; font-weight:800; color:#1e293b; display:inline-flex; align-items:center; gap:6px;">
                            <i class="ti ti-chart-bar" style="color:#ea580c;"></i> Tỷ trọng doanh thu theo hạng thành viên
                        </span>
                        <span style="font-size:11px; font-weight:600; color:#94a3b8;">*Tổng doanh thu các đơn trong kỳ</span>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:14px;">
                        <%-- Kim cương --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#0891b2; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#06b6d4;"></span> Kim cương (Diamond)</span>
                                <span style="color:#1e293b;"><span id="s13RevDiamondVal">0₫</span> &bull; <b style="color:#0891b2;" id="s13RevDiamondPct">0%</b></span>
                            </div>
                            <div class="s13-stat-bar"><div id="s13RevDiamondBar" class="s13-stat-bar-fill" style="width:0%; background:#06b6d4;"></div></div>
                        </div>

                        <%-- Vàng --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#d97706; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#f59e0b;"></span> Vàng (Gold)</span>
                                <span style="color:#1e293b;"><span id="s13RevGoldVal">0₫</span> &bull; <b style="color:#ea580c;" id="s13RevGoldPct">0%</b></span>
                            </div>
                            <div class="s13-stat-bar"><div id="s13RevGoldBar" class="s13-stat-bar-fill" style="width:0%; background:#f59e0b;"></div></div>
                        </div>

                        <%-- Bạc --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#475569; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#64748b;"></span> Bạc (Silver)</span>
                                <span style="color:#1e293b;"><span id="s13RevSilverVal">0₫</span> &bull; <b style="color:#475569;" id="s13RevSilverPct">0%</b></span>
                            </div>
                            <div class="s13-stat-bar"><div id="s13RevSilverBar" class="s13-stat-bar-fill" style="width:0%; background:#64748b;"></div></div>
                        </div>

                        <%-- Đồng --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#b45309; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#d97706;"></span> Đồng (Bronze)</span>
                                <span style="color:#1e293b;"><span id="s13RevBronzeVal">0₫</span> &bull; <b style="color:#b45309;" id="s13RevBronzePct">0%</b></span>
                            </div>
                            <div class="s13-stat-bar"><div id="s13RevBronzeBar" class="s13-stat-bar-fill" style="width:0%; background:#d97706;"></div></div>
                        </div>
                    </div>

                    <%-- Khung tổng đơn theo hạng --%>
                    <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:10px; padding:10px 14px; margin-top:16px; font-size:12px; color:#475569;">
                        <b>Tổng đơn phân bổ theo hạng:</b>
                        <span id="s13OrdersSummaryText" style="margin-left:4px;">Đồng: <b>0 đơn</b> &bull; Bạc: <b>0 đơn</b> &bull; Vàng: <b>0 đơn</b> &bull; Kim cương: <b>0 đơn</b></span>
                    </div>
                </div>

                <%-- Cột phải: Giá trị đơn hàng trung bình (AOV) theo hạng --%>
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                        <span style="font-size:13.5px; font-weight:800; color:#1e293b; display:inline-flex; align-items:center; gap:6px;">
                            <i class="ti ti-trending-up" style="color:#ea580c;"></i> Giá trị đơn hàng trung bình (AOV) theo hạng
                        </span>
                        <span style="font-size:11px; font-weight:600; color:#94a3b8;">Giá trị TB trên 1 đơn</span>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:14px;">
                        <%-- Kim cương --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#0891b2; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#06b6d4;"></span> Kim cương</span>
                                <b style="color:#0891b2; font-size:13px;" id="s13AovDiamondVal">0₫</b>
                            </div>
                            <div class="s13-stat-bar"><div id="s13AovDiamondBar" class="s13-stat-bar-fill" style="width:0%; background:#06b6d4;"></div></div>
                        </div>

                        <%-- Vàng --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#d97706; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#f59e0b;"></span> Vàng</span>
                                <b style="color:#ea580c; font-size:13px;" id="s13AovGoldVal">0₫</b>
                            </div>
                            <div class="s13-stat-bar"><div id="s13AovGoldBar" class="s13-stat-bar-fill" style="width:0%; background:#f59e0b;"></div></div>
                        </div>

                        <%-- Bạc --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#475569; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#64748b;"></span> Bạc</span>
                                <b style="color:#475569; font-size:13px;" id="s13AovSilverVal">0₫</b>
                            </div>
                            <div class="s13-stat-bar"><div id="s13AovSilverBar" class="s13-stat-bar-fill" style="width:0%; background:#64748b;"></div></div>
                        </div>

                        <%-- Đồng --%>
                        <div>
                            <div style="display:flex; justify-content:space-between; font-size:12.5px; font-weight:700; margin-bottom:4px;">
                                <span style="color:#b45309; display:inline-flex; align-items:center; gap:5px;"><span class="s13-tier-dot" style="background:#d97706;"></span> Đồng</span>
                                <b style="color:#b45309; font-size:13px;" id="s13AovBronzeVal">0₫</b>
                            </div>
                            <div class="s13-stat-bar"><div id="s13AovBronzeBar" class="s13-stat-bar-fill" style="width:0%; background:#d97706;"></div></div>
                        </div>
                    </div>

                    <%-- Khung insight nhận xét --%>
                    <div style="background:#fff7ed; border:1px solid #fed7aa; border-radius:10px; padding:10px 14px; margin-top:16px; font-size:12px; color:#9a3412;">
                        <b>Nhận xét văn hóa:</b>
                        <span id="s13AovInsightText" style="margin-left:4px;">Hội viên Kim cương có giá trị đơn hàng trung bình (AOV) vượt trội.</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Row 4: Hiệu quả chương trình hội viên --%>
        <div class="rev-chart-card" style="margin-bottom:22px;">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px; flex-wrap:wrap; gap:12px;">
                <div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <i class="ti ti-tags" style="color:#ea580c; font-size:20px;"></i>
                        <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0;">Hiệu quả chương trình hội viên</h3>
                    </div>
                    <p style="font-size:12.5px; color:#64748b; margin:3px 0 0 0;">
                        Đánh giá ROI chương trình khách hàng thân thiết, tác động kích cầu lên doanh số và tỷ lệ chuyển đổi.
                    </p>
                </div>
                <div>
                    <span class="pill-badge orange" style="background:#fff7ed; border:1px solid #fed7aa; color:#ea580c; font-size:12.5px; font-weight:800; padding:6px 16px; border-radius:99px;" id="s13RoiBadge">
                        Tỷ suất ROI: 14.3%
                    </span>
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px;">
                <%-- Thẻ 1: Đơn áp dụng ưu đãi --%>
                <div style="background:#fffcf9; border:1px solid #fed7aa; border-radius:14px; padding:18px 22px; display:flex; flex-direction:column; justify-content:space-between;">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <span style="font-size:11.5px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">ĐƠN HỘI VIÊN TÍCH LŨY</span>
                        <div style="width:36px; height:36px; border-radius:10px; background:#fef3c7; color:#92400e; display:grid; place-items:center; font-size:18px;">
                            <i class="ti ti-tag"></i>
                        </div>
                    </div>
                    <div style="font-size:26px; font-weight:800; color:#1e293b; margin:12px 0 6px 0;" id="s13PromoOrdersVal">
                        0 <span style="font-size:15px; font-weight:600; color:#64748b;">đơn</span>
                    </div>
                    <div style="display:flex; align-items:center; gap:6px; font-size:12.5px;">
                        <span class="pill-badge green" style="background:#dcfce7; color:#166534; font-weight:700; font-size:11px; padding:3px 8px; border-radius:6px;" id="s13PromoOrdersPct">0%</span>
                        <span style="color:#64748b; font-weight:600;">tổng đơn hoàn tất trong kỳ</span>
                    </div>
                </div>

                <%-- Thẻ 2: Giá trị ưu đãi đã dùng --%>
                <div style="background:#fffcf9; border:1px solid #fed7aa; border-radius:14px; padding:18px 22px; display:flex; flex-direction:column; justify-content:space-between;">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <span style="font-size:11.5px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:0.5px;">DOANH THU ĐƠN HỘI VIÊN</span>
                        <div style="width:36px; height:36px; border-radius:10px; background:#ffedd5; color:#c2410c; display:grid; place-items:center; font-size:18px;">
                            <i class="ti ti-receipt-2"></i>
                        </div>
                    </div>
                    <div style="font-size:26px; font-weight:800; color:#1e293b; margin:12px 0 6px 0;" id="s13PromoAmountVal">
                        0₫
                    </div>
                    <div style="font-size:12.5px; color:#64748b; font-weight:600;" id="s13PromoSubtitle">
                        Tổng đóng góp từ các hội viên
                    </div>
                </div>
            </div>
        </div>
            </div>
        </div>

        <%-- Row 5: Bảng tổng hợp kinh doanh theo hạng thành viên --%>
        <div class="rev-chart-card">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:18px; flex-wrap:wrap; gap:12px;">
                <div>
                    <h3 style="font-size:16px; font-weight:800; color:#1e293b; margin:0 0 3px 0; display:inline-flex; align-items:center; gap:6px;">
                        <i class="ti ti-table" style="color:#ea580c;"></i> Bảng tổng hợp kinh doanh theo hạng thành viên
                    </h3>
                    <p id="s13TablePeriodLabel" style="font-size:12px; color:#64748b; margin:0;">
                        Kỳ báo cáo: Tháng 10/2026 (01/10/2026 - 31/10/2026)
                    </p>
                </div>
                <div>
                    <button type="button" class="export-btn" onclick="exportScreen13TableCsv()" style="display:inline-flex; align-items:center; gap:6px; padding:7px 14px; border-radius:10px; background:#fff; border:1px solid #cbd5e1; font-size:12.5px; font-weight:700; color:#334155; cursor:pointer;">
                        <i class="ti ti-download" style="font-size:15px;"></i> Xuất bảng (CSV)
                    </button>
                </div>
            </div>

            <div style="overflow-x:auto;">
                <table class="rev-table" id="screen13Table">
                    <thead>
                        <tr>
                            <th style="width:24%;">HẠNG THÀNH VIÊN</th>
                            <th style="text-align:center;">SỐ LƯỢNG HỘI VIÊN</th>
                            <th style="text-align:center;">SỐ HỘI VIÊN MỚI</th>
                            <th style="text-align:center;">SỐ ĐƠN HÀNG</th>
                            <th style="text-align:right;">TỔNG DOANH THU (VNĐ)</th>
                            <th style="text-align:right;">GIÁ TRỊ ĐƠN TB (AOV)</th>
                        </tr>
                    </thead>
                    <tbody id="s13TableBody">
                        <tr id="s13-row-BRONZE">
                            <td>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span class="s13-tier-dot" style="background:#d97706;"></span>
                                    <div>
                                        <b style="color:#1e293b;">Đồng</b>
                                        <div style="font-size:11px; color:#94a3b8; font-weight:600;">Bronze</div>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align:center; font-weight:700; color:#1e293b;">2,140</td>
                            <td style="text-align:center;"><span style="color:#16a34a; font-weight:700;">+218</span></td>
                            <td style="text-align:center; font-weight:600; color:#334155;">920 đơn</td>
                            <td style="text-align:right; font-weight:700; color:#1e293b;">9,845,000₫</td>
                            <td style="text-align:right; font-weight:700; color:#334155;">245,000₫</td>
                        </tr>
                        <tr id="s13-row-SILVER">
                            <td>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span class="s13-tier-dot" style="background:#64748b;"></span>
                                    <div>
                                        <b style="color:#1e293b;">Bạc</b>
                                        <div style="font-size:11px; color:#94a3b8; font-weight:600;">Silver</div>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align:center; font-weight:700; color:#1e293b;">1,020</td>
                            <td style="text-align:center;"><span style="color:#16a34a; font-weight:700;">+65</span></td>
                            <td style="text-align:center; font-weight:600; color:#334155;">785 đơn</td>
                            <td style="text-align:right; font-weight:700; color:#1e293b;">22,643,500₫</td>
                            <td style="text-align:right; font-weight:700; color:#334155;">450,000₫</td>
                        </tr>
                        <tr id="s13-row-GOLD">
                            <td>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span class="s13-tier-dot" style="background:#f59e0b;"></span>
                                    <div>
                                        <b style="color:#1e293b;">Vàng</b>
                                        <div style="font-size:11px; color:#94a3b8; font-weight:600;">Gold</div>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align:center; font-weight:700; color:#1e293b;">520</td>
                            <td style="text-align:center;"><span style="color:#16a34a; font-weight:700;">+21</span></td>
                            <td style="text-align:center; font-weight:600; color:#334155;">450 đơn</td>
                            <td style="text-align:right; font-weight:700; color:#ea580c;">34,467,500₫</td>
                            <td style="text-align:right; font-weight:700; color:#ea580c;">850,000₫</td>
                        </tr>
                        <tr id="s13-row-DIAMOND">
                            <td>
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span class="s13-tier-dot" style="background:#06b6d4;"></span>
                                    <div>
                                        <b style="color:#1e293b;">Kim cương</b>
                                        <div style="font-size:11px; color:#94a3b8; font-weight:600;">Diamond</div>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align:center; font-weight:700; color:#1e293b;">162</td>
                            <td style="text-align:center;"><span style="color:#16a34a; font-weight:700;">+8</span></td>
                            <td style="text-align:center; font-weight:600; color:#334155;">305 đơn</td>
                            <td style="text-align:right; font-weight:700; color:#0891b2;">31,504,000₫</td>
                            <td style="text-align:right; font-weight:700; color:#0891b2;">1,050,000₫</td>
                        </tr>
                    </tbody>
                    <tfoot style="background:#fff7ed; border-top:2px solid #fed7aa;">
                        <tr>
                            <td style="font-weight:800; color:#1e293b;">
                                <i class="ti ti-check" style="color:#ea580c; margin-right:4px;"></i> Tổng cộng / Trung bình
                            </td>
                            <td style="text-align:center; font-weight:800; color:#1e293b;" id="s13TableTotalMembers">3,842</td>
                            <td style="text-align:center; font-weight:800; color:#16a34a;" id="s13TableTotalNew">+312</td>
                            <td style="text-align:center; font-weight:800; color:#1e293b;" id="s13TableTotalOrders">2,460 đơn</td>
                            <td style="text-align:right; font-weight:800; color:#ea580c; font-size:14px;" id="s13TableTotalRevenue">98,460,000₫</td>
                            <td style="text-align:right; font-weight:800; color:#1e293b; font-size:14px;" id="s13TableAvgAov">615,000₫</td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-top:14px; font-size:12px; color:#64748b;">
                <div>
                    * Ghi chú: Doanh thu tính theo giá trị hóa đơn đã thanh toán thành công trong kỳ báo cáo.
                </div>
                <div style="color:#ea580c; font-weight:600;">
                    Xuất dữ liệu chi tiết hỗ trợ đối soát kế toán
                </div>
            </div>
        </div>
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
            if (typeof syncScreen12QuickChips === 'function') syncScreen12QuickChips();
            if (typeof applyScreen12Filter === 'function') {
                applyScreen12Filter();
            }
        } else if (tabId === 'tab-members') {
            if (sbMembers) sbMembers.classList.add('active');
            if (window.location.hash !== '#members') history.replaceState(null, null, '#members');
            if (typeof applyScreen13Filter === 'function') {
                applyScreen13Filter();
            }
        } else {
            if (sbOverview) sbOverview.classList.add('active');
            if (window.location.hash) history.replaceState(null, null, window.location.pathname);
            if (typeof renderDynamicRevenueChart === 'function' && revenueDataPoints && revenueDataPoints.length > 0) {
                renderDynamicRevenueChart(revenueDataPoints, 'trendChartWrapper1');
            }
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

    function formatShortCurrency(val) {
        const num = Number(val) || 0;
        if (num >= 1000000000) {
            return '₫' + (num / 1000000000).toFixed(1) + 'B';
        }
        if (num >= 1000000) {
            return '₫' + (num / 1000000).toFixed(1) + 'M';
        }
        if (num >= 1000) {
            return '₫' + (num / 1000).toFixed(0) + 'K';
        }
        return '₫' + num.toLocaleString('vi-VN');
    }

    // DỮ LIỆU HỘI VIÊN VÀ ĐƠN HÀNG THỰC TẾ TRONG HỆ THỐNG (ĐỒNG BỘ 100% TỪ DATABASE)
    let ALL_CUSTOMERS_DATA = [
        <c:if test="${not empty stats.allCustomers}">
            <c:forEach var="c" items="${stats.allCustomers}" varStatus="loop">
                { id: ${c.id}, tier: '${c.tier}', createdAt: '${c.createdAt}' }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        </c:if>
    ];

    let ALL_ORDERS_DATA = [
        <c:if test="${not empty stats.allOrders}">
            <c:forEach var="o" items="${stats.allOrders}" varStatus="loop">
                { id: ${o.id}, customerId: ${o.customerId != null ? o.customerId : 'null'}, tier: '${o.customerTier}', customerTier: '${o.customerTier}', date: '${o.date}', dayText: '${o.dayText}', status: '${o.status}', pay: '${o.pay}', total: ${o.total}, cats: ${o.catsJson} }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        </c:if>
    ];

    // 1. SƠ ĐỒ DOANH THU ĐỘNG (HOVER XEM CHI TIẾT, ĐỘNG THEO BỘ LỌC VÀ CẬP NHẬT TRỤC NGÀY)
    function renderDynamicRevenueChart(dailyList, targetWrapperId) {
        const wrappers = targetWrapperId
            ? [document.getElementById(targetWrapperId)].filter(Boolean)
            : [document.getElementById('trendChartWrapper1'), document.getElementById('screen12RevenueWrapper')].filter(Boolean);

        if (wrappers.length === 0) return;

        wrappers.forEach(wrapper => {
            const isTab1 = (wrapper.id === 'trendChartWrapper1');
            const fromInput = isTab1 ? document.getElementById('from') : document.getElementById('screen12FilterFrom');
            const toInput = isTab1 ? document.getElementById('to') : document.getElementById('screen12FilterTo');

            let fromVal = fromInput ? fromInput.value : '';
            let toVal = toInput ? toInput.value : '';

            // Mặc định tháng 10/2026 nếu trống
            if (!fromVal || !toVal) {
                fromVal = '2026-10-01';
                toVal = '2026-10-31';
            }

            const startDate = new Date(fromVal + 'T00:00:00');
            const endDate = new Date(toVal + 'T00:00:00');

            // Gom dữ liệu từ dailyList
            const dataMap = {};
            let maxAmount = 0;

            if (Array.isArray(dailyList)) {
                dailyList.forEach(d => {
                    const amt = Number(d.amount) || 0;
                    const ords = Number(d.orderCount) || 0;
                    if (amt > maxAmount) maxAmount = amt;
                    if (d.date) dataMap[d.date] = { orders: ords, amount: amt };
                    if (d.dayText) dataMap[d.dayText] = { orders: ords, amount: amt };
                    if (d.rawDate) dataMap[d.rawDate] = { orders: ords, amount: amt };
                });
            }
            if (maxAmount === 0) maxAmount = 3000000;

            const scaleCeiling = maxAmount / 0.76;

            // Tạo danh sách từng ngày trong khoảng [startDate, endDate]
            const dayDataList = [];
            let curr = new Date(startDate);
            while (curr <= endDate && dayDataList.length < 366) {
                const y = curr.getFullYear();
                const m = String(curr.getMonth() + 1).padStart(2, '0');
                const day = String(curr.getDate()).padStart(2, '0');
                const isoDate = y + '-' + m + '-' + day;
                const dayText = day + '/' + m;
                const displayDate = day + '/' + m + '/' + y;

                const match = dataMap[isoDate] || dataMap[dayText] || { orders: 0, amount: 0 };
                dayDataList.push({
                    date: isoDate,
                    dayText: dayText,
                    displayDate: displayDate,
                    orders: match.orders,
                    amount: match.amount
                });

                curr.setDate(curr.getDate() + 1);
            }

            const container = wrapper.querySelector('.trend-bars-container');
            const tooltip = wrapper.querySelector('.trend-hover-tooltip');
            const axisLabels = wrapper.querySelector('.trend-axis-labels');

            if (!container) return;
            if (tooltip) tooltip.style.display = 'none';

            const totalDays = dayDataList.length;

            // Khoảng cách giữa các cột co giãn theo tổng số ngày
            let gap = 5;
            if (totalDays > 60) gap = 1;
            else if (totalDays > 35) gap = 2;
            else if (totalDays > 15) gap = 4;
            else gap = 8;
            container.style.gap = gap + 'px';

            let barsHtml = '';
            dayDataList.forEach((item, idx) => {
                const hasAmount = Number(item.amount) > 0;
                const rawPercent = hasAmount ? (item.amount / scaleCeiling) * 100 : 0;
                const heightPercent = hasAmount ? Math.max(6, Math.min(95, rawPercent)) : 0;

                const ratio = maxAmount > 0 ? (item.amount / maxAmount) : 0;
                let color = 'transparent';
                if (hasAmount) {
                    if (ratio >= 0.85) color = '#7c2d12';
                    else if (ratio >= 0.70) color = '#9a3412';
                    else if (ratio >= 0.55) color = '#c2410c';
                    else if (ratio >= 0.38) color = '#ea580c';
                    else if (ratio >= 0.25) color = '#f59e0b';
                    else if (ratio >= 0.15) color = '#fbbf24';
                    else color = '#fed7aa';
                }

                barsHtml += '<div class="trend-bar-item" data-idx="' + idx + '" ' +
                            'style="flex:1; height:100%; display:flex; align-items:flex-end; justify-content:center; cursor:pointer;">' +
                            '  <div class="trend-bar-fill" style="width:100%; height:' + (hasAmount ? heightPercent.toFixed(1) + '%' : '0') + '; ' +
                            'background:' + (hasAmount ? color : 'transparent') + '; border-radius:3px 3px 0 0; ' +
                            'transition:transform 0.15s ease, filter 0.15s ease; transform-origin:bottom center;"></div>' +
                            '</div>';
            });

            container.innerHTML = barsHtml;

            // RENDER PHẦN NGÀY PHÍA DƯỚI (TRỤC X) ĐỘNG THEO BỘ LỌC!
            if (axisLabels && totalDays > 0) {
                let ticksHtml = '';
                if (totalDays <= 8) {
                    dayDataList.forEach(d => {
                        ticksHtml += '<span>' + d.dayText + '</span>';
                    });
                } else {
                    const tickCount = Math.min(7, totalDays);
                    const step = (totalDays - 1) / (tickCount - 1);
                    const usedIndices = new Set();
                    for (let i = 0; i < tickCount; i++) {
                        const idx = Math.round(i * step);
                        if (!usedIndices.has(idx) && dayDataList[idx]) {
                            usedIndices.add(idx);
                            ticksHtml += '<span>' + dayDataList[idx].dayText + '</span>';
                        }
                    }
                }
                axisLabels.innerHTML = ticksHtml;
            }

            // Cập nhật tiêu đề phụ (Subtitle)
            if (isTab1) {
                const sub = document.getElementById('trendSubtitle1');
                if (sub && dayDataList.length > 0) {
                    const sDate = dayDataList[0].displayDate;
                    const eDate = dayDataList[dayDataList.length - 1].displayDate;
                    if (sDate === eDate) {
                        sub.innerText = 'Doanh thu ngày ' + sDate;
                    } else {
                        sub.innerText = 'Doanh thu từ ' + sDate + ' đến ' + eDate;
                    }
                }
            } else {
                const sub12 = document.getElementById('screen12RevenueSubtitle');
                if (sub12 && dayDataList.length > 0) {
                    const sDate = dayDataList[0].displayDate;
                    const eDate = dayDataList[dayDataList.length - 1].displayDate;
                    if (sDate === eDate) {
                        sub12.innerText = 'Doanh thu ngày ' + sDate;
                    } else {
                        sub12.innerText = 'Doanh thu từ ' + sDate + ' đến ' + eDate;
                    }
                }
            }

            function showTooltipForIndex(idx) {
                const d = dayDataList[idx];
                if (!d || !tooltip) return;

                const dateEl = tooltip.querySelector('.trend-tt-date');
                const amtEl = tooltip.querySelector('.trend-tt-amount');
                const subEl = tooltip.querySelector('.trend-tt-sub');

                if (dateEl) dateEl.innerText = d.displayDate;
                if (amtEl) amtEl.innerText = formatCurrency(d.amount);

                if (subEl) {
                    if (d.amount > 0 && d.amount === maxAmount && maxAmount > 0) {
                        subEl.innerText = 'Doanh thu cao nhất kỳ • ' + d.orders + ' đơn hoàn tất';
                    } else if (d.amount > 0 && d.orders > 0) {
                        subEl.innerText = d.orders + ' đơn hàng hoàn tất';
                    } else if (d.amount > 0) {
                        subEl.innerText = 'Doanh thu ghi nhận';
                    } else {
                        subEl.innerText = 'Không có doanh thu';
                    }
                }

                const bars = container.querySelectorAll('.trend-bar-item');
                const bar = bars[idx];
                if (bar) {
                    tooltip.style.display = 'block';
                    const fillEl = bar.querySelector('.trend-bar-fill');
                    const barRect = bar.getBoundingClientRect();
                    const wrapRect = wrapper.getBoundingClientRect();

                    let leftPos = (barRect.left - wrapRect.left + barRect.width / 2) - (tooltip.offsetWidth / 2);
                    let topPos;
                    if (d.amount > 0 && fillEl && fillEl.offsetHeight > 0) {
                        const fillRect = fillEl.getBoundingClientRect();
                        topPos = (fillRect.top - wrapRect.top) - tooltip.offsetHeight - 10;
                    } else {
                        topPos = wrapRect.height - tooltip.offsetHeight - 35;
                    }

                    if (leftPos < 10) leftPos = 10;
                    if (leftPos + tooltip.offsetWidth > wrapRect.width - 10) {
                        leftPos = wrapRect.width - tooltip.offsetWidth - 10;
                    }
                    if (topPos < 5) topPos = 5;

                    tooltip.style.left = leftPos + 'px';
                    tooltip.style.top = topPos + 'px';
                }
            }

            // Gắn sự kiện hover
            const barEls = container.querySelectorAll('.trend-bar-item');
            barEls.forEach(bar => {
                bar.addEventListener('mouseenter', () => {
                    const idx = Number(bar.getAttribute('data-idx'));
                    const fill = bar.querySelector('.trend-bar-fill');
                    if (fill && dayDataList[idx] && dayDataList[idx].amount > 0) {
                        fill.style.transform = 'scaleY(1.05)';
                        fill.style.filter = 'brightness(1.15)';
                    }
                    showTooltipForIndex(idx);
                });

                bar.addEventListener('mouseleave', () => {
                    const fill = bar.querySelector('.trend-bar-fill');
                    if (fill) {
                        fill.style.transform = 'scaleY(1)';
                        fill.style.filter = 'none';
                    }
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

        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');

        let fromVal = fromInput ? fromInput.value : '';
        let toVal = toInput ? toInput.value : '';
        if (!fromVal || !toVal) {
            fromVal = '2026-10-01';
            toVal = '2026-10-31';
        }

        const startDate = new Date(fromVal + 'T00:00:00');
        const endDate = new Date(toVal + 'T00:00:00');

        const dataMap = {};
        if (Array.isArray(dailyList)) {
            dailyList.forEach(d => {
                const ords = Number(d.orderCount) || 0;
                if (d.date) dataMap[d.date] = ords;
                if (d.dayText) dataMap[d.dayText] = ords;
                if (d.rawDate) dataMap[d.rawDate] = ords;
            });
        }

        const dayOrderList = [];
        let maxOrders = 0;
        let curr = new Date(startDate);
        while (curr <= endDate && dayOrderList.length < 366) {
            const y = curr.getFullYear();
            const m = String(curr.getMonth() + 1).padStart(2, '0');
            const day = String(curr.getDate()).padStart(2, '0');
            const isoDate = y + '-' + m + '-' + day;
            const dayText = day + '/' + m;
            const displayDate = day + '/' + m + '/' + y;

            const count = (dataMap[isoDate] != null) ? dataMap[isoDate] : ((dataMap[dayText] != null) ? dataMap[dayText] : 0);
            if (count > maxOrders) maxOrders = count;
            dayOrderList.push({ date: isoDate, dayText: dayText, displayDate: displayDate, count: count });

            curr.setDate(curr.getDate() + 1);
        }
        if (maxOrders === 0) maxOrders = 3;

        const scaleCeiling = maxOrders / 0.76;
        const container = wrapper.querySelector('.rev-bars-orders');
        const tooltip = wrapper.querySelector('.rev-tt-orders');
        const axisLabels = wrapper.querySelector('.trend-axis-labels');

        if (!container) return;
        if (tooltip) tooltip.style.display = 'none';

        const totalDays = dayOrderList.length;
        let gap = 5;
        if (totalDays > 60) gap = 1;
        else if (totalDays > 35) gap = 2;
        else if (totalDays > 15) gap = 4;
        else gap = 8;
        container.style.gap = gap + 'px';

        let barsHtml = '';
        dayOrderList.forEach((item, idx) => {
            const hasCount = Number(item.count) > 0;
            const rawPercent = hasCount ? (item.count / scaleCeiling) * 100 : 0;
            const heightPercent = hasCount ? Math.max(6, Math.min(95, rawPercent)) : 0;

            const ratio = maxOrders > 0 ? (item.count / maxOrders) : 0;
            let color = 'transparent';
            if (hasCount) {
                if (ratio >= 0.85) color = '#7c2d12';
                else if (ratio >= 0.70) color = '#9a3412';
                else if (ratio >= 0.55) color = '#c2410c';
                else if (ratio >= 0.35) color = '#ea580c';
                else if (ratio >= 0.20) color = '#f59e0b';
                else color = '#fed7aa';
            }

            barsHtml += '<div class="trend-order-bar-item" data-idx="' + idx + '" ' +
                        'style="flex:1; height:100%; display:flex; align-items:flex-end; justify-content:center; cursor:pointer;">' +
                        '  <div class="trend-order-fill" style="width:100%; height:' + (hasCount ? heightPercent.toFixed(1) + '%' : '0') + '; ' +
                        'background:' + (hasCount ? color : 'transparent') + '; border-radius:3px 3px 0 0; ' +
                        'transition:transform 0.15s ease, filter 0.15s ease; transform-origin:bottom center;"></div>' +
                        '</div>';
        });

        container.innerHTML = barsHtml;

        // Render trục X ngày động
        if (axisLabels && totalDays > 0) {
            let ticksHtml = '';
            if (totalDays <= 8) {
                dayOrderList.forEach(d => {
                    ticksHtml += '<span>' + d.dayText + '</span>';
                });
            } else {
                const tickCount = Math.min(7, totalDays);
                const step = (totalDays - 1) / (tickCount - 1);
                const usedIndices = new Set();
                for (let i = 0; i < tickCount; i++) {
                    const idx = Math.round(i * step);
                    if (!usedIndices.has(idx) && dayOrderList[idx]) {
                        usedIndices.add(idx);
                        ticksHtml += '<span>' + dayOrderList[idx].dayText + '</span>';
                    }
                }
            }
            axisLabels.innerHTML = ticksHtml;
        }

        // Cập nhật tiêu đề phụ (Subtitle)
        const subOrders = document.getElementById('screen12OrdersSubtitle');
        if (subOrders && dayOrderList.length > 0) {
            const sDate = dayOrderList[0].displayDate;
            const eDate = dayOrderList[dayOrderList.length - 1].displayDate;
            if (sDate === eDate) {
                subOrders.innerText = 'Khối lượng đơn hàng ngày ' + sDate;
            } else {
                subOrders.innerText = 'Khối lượng đơn hàng từ ' + sDate + ' đến ' + eDate;
            }
        }

        function showOrderTooltip(idx) {
            const d = dayOrderList[idx];
            if (!d || !tooltip) return;

            const dateEl = tooltip.querySelector('.trend-tt-date');
            const amtEl = tooltip.querySelector('.trend-tt-amount');
            const subEl = tooltip.querySelector('.trend-tt-sub');

            if (dateEl) dateEl.innerText = d.displayDate;
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
                const fillEl = bar.querySelector('.trend-order-fill');
                const barRect = bar.getBoundingClientRect();
                const wrapRect = wrapper.getBoundingClientRect();

                let leftPos = (barRect.left - wrapRect.left + barRect.width / 2) - (tooltip.offsetWidth / 2);
                let topPos;
                if (d.count > 0 && fillEl && fillEl.offsetHeight > 0) {
                    const fillRect = fillEl.getBoundingClientRect();
                    topPos = (fillRect.top - wrapRect.top) - tooltip.offsetHeight - 10;
                } else {
                    topPos = wrapRect.height - tooltip.offsetHeight - 35;
                }

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
                const fill = bar.querySelector('.trend-order-fill');
                if (fill && dayOrderList[idx] && dayOrderList[idx].count > 0) {
                    fill.style.transform = 'scaleY(1.05)';
                    fill.style.filter = 'brightness(1.15)';
                }
                showOrderTooltip(idx);
            });
            bar.addEventListener('mouseleave', () => {
                const fill = bar.querySelector('.trend-order-fill');
                if (fill) {
                    fill.style.transform = 'scaleY(1)';
                    fill.style.filter = 'none';
                }
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
            const avg = totalDays > 0 ? (totalOrders / totalDays).toFixed(1) : '0.0';
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

        const filtered = ALL_ORDERS_DATA.filter(o => {
            if (fromVal && o.date < fromVal) return false;
            if (toVal && o.date > toVal) return false;
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

        // Tính toán và hiển thị tăng trưởng % thực tế so với kỳ trước
        calculateAndRenderGrowth(fromVal, toVal, grossRev, totalOrd, aov);

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
            date: d.rawDate,
            dayText: d.dayText,
            orderCount: d.total,
            amount: d.revenue
        }));
        renderDynamicRevenueChart(chartList, 'screen12RevenueWrapper');
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

        // Cập nhật phân bổ danh mục theo dữ liệu thực tế
        let catRev1 = 0; // Thức ăn hạt cho mèo: category 1
        let catRev2 = 0; // Pate & Thức ăn ướt: category 3 + 4
        let catRev3 = 0; // Thức ăn hạt cho chó: category 2
        let catRev4 = 0; // Bánh thưởng & Snack: category 5 + 6 + 7

        completedList.forEach(o => {
            if (o.cats) {
                // Category 1: Thức ăn hạt cho mèo
                if (o.cats['1'] || o.cats[1]) catRev1 += Number(o.cats['1'] || o.cats[1]) || 0;
                // Category 3 + 4: Pate cho mèo (3) + Pate cho chó (4)
                if (o.cats['3'] || o.cats[3]) catRev2 += Number(o.cats['3'] || o.cats[3]) || 0;
                if (o.cats['4'] || o.cats[4]) catRev2 += Number(o.cats['4'] || o.cats[4]) || 0;
                // Category 2: Thức ăn hạt cho chó
                if (o.cats['2'] || o.cats[2]) catRev3 += Number(o.cats['2'] || o.cats[2]) || 0;
                // Category 5 + 6 + 7: Bánh thưởng & Snack
                if (o.cats['5'] || o.cats[5]) catRev4 += Number(o.cats['5'] || o.cats[5]) || 0;
                if (o.cats['6'] || o.cats[6]) catRev4 += Number(o.cats['6'] || o.cats[6]) || 0;
                if (o.cats['7'] || o.cats[7]) catRev4 += Number(o.cats['7'] || o.cats[7]) || 0;
            }
        });

        const totalCatRev = catRev1 + catRev2 + catRev3 + catRev4;

        // Cập nhật text tổng cộng ở tâm Donut Chart
        const catTotalEl = document.getElementById('screen12CatTotal');
        if (catTotalEl) {
            catTotalEl.innerText = formatShortCurrency(totalCatRev);
            catTotalEl.title = 'Tổng tiền hàng theo danh mục: ' + formatCurrency(totalCatRev);
        }

        const pct1 = totalCatRev > 0 ? (catRev1 / totalCatRev * 100) : 0;
        const pct2 = totalCatRev > 0 ? (catRev2 / totalCatRev * 100) : 0;
        const pct3 = totalCatRev > 0 ? (catRev3 / totalCatRev * 100) : 0;
        const pct4 = totalCatRev > 0 ? (catRev4 / totalCatRev * 100) : 0;

        const updateCatRow = (valId, barId, rev, pct) => {
            const valEl = document.getElementById(valId);
            const barEl = document.getElementById(barId);
            const pctText = pct.toFixed(1);
            if (valEl) valEl.innerHTML = formatCurrency(rev) + ' <small style="color:#64748b; font-weight:600;">(' + pctText + '%)</small>';
            if (barEl) barEl.style.width = pctText + '%';
        };

        updateCatRow('screen12CatVal1', 'screen12CatBar1', catRev1, pct1);
        updateCatRow('screen12CatVal2', 'screen12CatBar2', catRev2, pct2);
        updateCatRow('screen12CatVal3', 'screen12CatBar3', catRev3, pct3);
        updateCatRow('screen12CatVal4', 'screen12CatBar4', catRev4, pct4);

        // Vẽ các lát của Donut Chart SVG
        const donutGroup = document.getElementById('screen12DonutCatSlices');
        if (donutGroup) {
            if (totalCatRev === 0) {
                donutGroup.innerHTML = '';
            } else {
                const slices = [
                    { pct: pct1, color: '#ea580c' },
                    { pct: pct2, color: '#f59e0b' },
                    { pct: pct3, color: '#7c2d12' },
                    { pct: pct4, color: '#fb923c' }
                ];
                let slicesHtml = '';
                let accum = 0;
                slices.forEach(s => {
                    if (s.pct > 0) {
                        const dashArray = s.pct.toFixed(2) + ' ' + (100 - s.pct).toFixed(2);
                        const dashOffset = (-accum).toFixed(2);
                        slicesHtml += '<circle cx="21" cy="21" r="15.91549430918954" fill="none" stroke="' + s.color + '" stroke-width="5" stroke-dasharray="' + dashArray + '" stroke-dashoffset="' + dashOffset + '" style="transition:all 0.5s ease;"></circle>';
                        accum += s.pct;
                    }
                });
                donutGroup.innerHTML = slicesHtml;
            }
        }
    }

    function calculateAndRenderGrowth(fromVal, toVal, grossRev, totalOrd, aov) {
        const revGrowthEl = document.getElementById('screen12KpiRevenueGrowth');
        const ordGrowthEl = document.getElementById('screen12KpiOrdersGrowth');
        const aovGrowthEl = document.getElementById('screen12KpiAovGrowth');
        if (!revGrowthEl || !ordGrowthEl || !aovGrowthEl) return;

        if (!fromVal || !toVal) {
            fromVal = '2026-10-01';
            toVal = '2026-10-31';
        }

        const startDate = new Date(fromVal + 'T00:00:00');
        const endDate = new Date(toVal + 'T23:59:59');
        const pad = n => String(n).padStart(2, '0');
        const toIso = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());

        let prevStart, prevEnd, periodLabel;

        const isFullMonth = (startDate.getDate() === 1 &&
            endDate.getDate() === new Date(endDate.getFullYear(), endDate.getMonth() + 1, 0).getDate() &&
            startDate.getMonth() === endDate.getMonth() &&
            startDate.getFullYear() === endDate.getFullYear());

        const isFullYear = (startDate.getMonth() === 0 && startDate.getDate() === 1 &&
            endDate.getMonth() === 11 && endDate.getDate() === 31 &&
            startDate.getFullYear() === endDate.getFullYear());

        const diffDays = Math.round((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));

        if (isFullMonth) {
            prevStart = new Date(startDate.getFullYear(), startDate.getMonth() - 1, 1);
            prevEnd = new Date(startDate.getFullYear(), startDate.getMonth(), 0);
            periodLabel = 'tháng trước';
        } else if (isFullYear) {
            prevStart = new Date(startDate.getFullYear() - 1, 0, 1);
            prevEnd = new Date(startDate.getFullYear() - 1, 11, 31);
            periodLabel = 'năm trước';
        } else if (diffDays === 7) {
            prevEnd = new Date(startDate);
            prevEnd.setDate(prevEnd.getDate() - 1);
            prevStart = new Date(prevEnd);
            prevStart.setDate(prevStart.getDate() - 6);
            periodLabel = 'tuần trước';
        } else if (diffDays === 1) {
            prevEnd = new Date(startDate);
            prevEnd.setDate(prevEnd.getDate() - 1);
            prevStart = new Date(prevEnd);
            periodLabel = 'hôm qua';
        } else {
            prevEnd = new Date(startDate);
            prevEnd.setDate(prevEnd.getDate() - 1);
            prevStart = new Date(prevEnd);
            prevStart.setDate(prevStart.getDate() - diffDays + 1);
            periodLabel = 'kỳ trước';
        }

        const prevFromIso = toIso(prevStart);
        const prevToIso = toIso(prevEnd);

        const prevOrders = ALL_ORDERS_DATA.filter(o => o.date >= prevFromIso && o.date <= prevToIso);
        const prevTotalOrd = prevOrders.length;
        const prevCompOrders = prevOrders.filter(o => o.status === 'COMPLETED');
        const prevGrossRev = prevCompOrders.reduce((s, o) => s + o.total, 0);
        const prevAov = prevCompOrders.length > 0 ? Math.round(prevGrossRev / prevCompOrders.length) : 0;

        function buildGrowthBadge(cur, prev) {
            if (prev === 0 && cur === 0) {
                return '<span class="pill-badge" style="background:#f1f5f9; color:#64748b; font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;">0.0%</span>' +
                       '<span style="font-size:12px; color:#64748b; font-weight:600;">so với ' + periodLabel + '</span>';
            }
            let pct = 0;
            if (prev === 0) {
                pct = 100;
            } else {
                pct = ((cur - prev) / prev) * 100;
            }
            const isPos = pct >= 0;
            const sign = isPos ? '+' : '';
            const text = sign + pct.toFixed(1) + '%';
            if (isPos) {
                return '<span class="pill-badge green" style="font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;"><i class="ti ti-arrow-up-right"></i> ' + text + '</span>' +
                       '<span style="font-size:12px; color:#64748b; font-weight:600;">so với ' + periodLabel + '</span>';
            } else {
                return '<span class="pill-badge warn" style="background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5; font-size:11px; padding:3px 8px; border-radius:99px; font-weight:700;"><i class="ti ti-arrow-down-right"></i> ' + text + '</span>' +
                       '<span style="font-size:12px; color:#64748b; font-weight:600;">so với ' + periodLabel + '</span>';
            }
        }

        revGrowthEl.innerHTML = buildGrowthBadge(grossRev, prevGrossRev);
        ordGrowthEl.innerHTML = buildGrowthBadge(totalOrd, prevTotalOrd);
        aovGrowthEl.innerHTML = buildGrowthBadge(aov, prevAov);
    }

    function syncScreen12QuickChips() {
        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');
        if (!fromInput || !toInput) return;

        const fromVal = fromInput.value;
        const toVal = toInput.value;

        const now = new Date();
        const pad = n => String(n).padStart(2, '0');
        const toIso = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());

        const todayIso = toIso(now);

        const startOfWeek = new Date(now);
        const dayOfWeek = (startOfWeek.getDay() + 6) % 7;
        startOfWeek.setDate(startOfWeek.getDate() - dayOfWeek);
        const endOfWeek = new Date(startOfWeek);
        endOfWeek.setDate(endOfWeek.getDate() + 6);
        const weekFromIso = toIso(startOfWeek);
        const weekToIso = toIso(endOfWeek);

        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        const monthFromIso = toIso(startOfMonth);
        const monthToIso = toIso(endOfMonth);

        const yearFromIso = now.getFullYear() + '-01-01';
        const yearToIso = now.getFullYear() + '-12-31';

        document.querySelectorAll('.rev-quick-chip').forEach(c => c.classList.remove('active'));

        if (fromVal === todayIso && toVal === todayIso) {
            document.getElementById('chip-today')?.classList.add('active');
        } else if (fromVal === weekFromIso && toVal === weekToIso) {
            document.getElementById('chip-week')?.classList.add('active');
        } else if ((fromVal === monthFromIso && toVal === monthToIso) || (fromVal === '2026-10-01' && toVal === '2026-10-31')) {
            document.getElementById('chip-month')?.classList.add('active');
        } else if (fromVal === yearFromIso && toVal === yearToIso) {
            document.getElementById('chip-year')?.classList.add('active');
        }
    }

    function onScreen12DateChange() {
        syncScreen12QuickChips();
        applyScreen12Filter();
    }

    function selectQuickChip(btn, period) {
        document.querySelectorAll('.rev-quick-chip').forEach(c => c.classList.remove('active'));
        if (btn) btn.classList.add('active');

        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');
        if (!fromInput || !toInput) return;

        const now = new Date();
        const pad = n => String(n).padStart(2, '0');
        const toIso = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());

        if (period === 'today') {
            fromInput.value = toIso(now);
            toInput.value = toIso(now);
        } else if (period === 'week') {
            const startOfWeek = new Date(now);
            const dayOfWeek = (startOfWeek.getDay() + 6) % 7; // Monday = 0
            startOfWeek.setDate(startOfWeek.getDate() - dayOfWeek);
            const endOfWeek = new Date(startOfWeek);
            endOfWeek.setDate(endOfWeek.getDate() + 6);
            fromInput.value = toIso(startOfWeek);
            toInput.value = toIso(endOfWeek);
        } else if (period === 'month') {
            const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
            const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            fromInput.value = toIso(startOfMonth);
            toInput.value = toIso(endOfMonth);
        } else if (period === 'year') {
            fromInput.value = now.getFullYear() + '-01-01';
            toInput.value = now.getFullYear() + '-12-31';
        }

        applyScreen12Filter();
    }

    function resetScreen12Filter() {
        const fromInput = document.getElementById('screen12FilterFrom');
        const toInput = document.getElementById('screen12FilterTo');

        if (fromInput) fromInput.value = '2026-10-01';
        if (toInput) toInput.value = '2026-10-31';

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

    // ========================================================
    // BÁO CÁO HỘI VIÊN (Screen 13 - Figma)
    // ========================================================
    // ========================================================
    // BÁO CÁO HỘI VIÊN (Screen 13 - Dữ liệu thực từ Database)
    // ========================================================
    function formatVnDate(val) {
        if (!val) return '';
        if (val.includes('-')) {
            const parts = val.split('-');
            if (parts.length === 3) return parts[2] + '/' + parts[1] + '/' + parts[0];
        }
        return val;
    }

    function onScreen13DateChange() {
        document.querySelectorAll('.s13-chip').forEach(c => c.classList.remove('active'));
        applyScreen13Filter();
    }

    function selectScreen13QuickChip(btn, type) {
        document.querySelectorAll('.s13-chip').forEach(c => c.classList.remove('active'));
        if (btn) btn.classList.add('active');

        const fromInput = document.getElementById('s13FilterFrom');
        const toInput = document.getElementById('s13FilterTo');
        if (!fromInput || !toInput) return;

        if (type === 'week') {
            fromInput.value = '2026-10-19';
            toInput.value = '2026-10-25';
        } else if (type === 'month') {
            fromInput.value = '2026-10-01';
            toInput.value = '2026-10-31';
        } else if (type === 'prevmonth') {
            fromInput.value = '2026-09-01';
            toInput.value = '2026-09-30';
        } else if (type === 'year') {
            fromInput.value = '2026-01-01';
            toInput.value = '2026-12-31';
        }
        applyScreen13Filter();
    }

    function resetScreen13Filter() {
        document.querySelectorAll('.s13-chip').forEach(c => c.classList.remove('active'));
        const monthChip = document.getElementById('s13-chip-month');
        if (monthChip) monthChip.classList.add('active');

        const fromInput = document.getElementById('s13FilterFrom');
        const toInput = document.getElementById('s13FilterTo');
        const tierSelect = document.getElementById('s13FilterTier');

        if (fromInput) fromInput.value = '2026-10-01';
        if (toInput) toInput.value = '2026-10-31';
        if (tierSelect) tierSelect.value = '';

        applyScreen13Filter();
    }

    function applyScreen13Filter() {
        const fromRaw = document.getElementById('s13FilterFrom')?.value || '2026-10-01';
        const toRaw = document.getElementById('s13FilterTo')?.value || '2026-10-31';
        const tierVal = document.getElementById('s13FilterTier')?.value || '';

        const fromDisplay = formatVnDate(fromRaw);
        const toDisplay = formatVnDate(toRaw);

        const statusLabel = document.getElementById('s13FilterStatusLabel');
        if (statusLabel) statusLabel.innerText = fromDisplay + ' - ' + toDisplay;

        const tablePeriodLabel = document.getElementById('s13TablePeriodLabel');
        if (tablePeriodLabel) {
            tablePeriodLabel.innerText = 'Kỳ báo cáo: ' + fromDisplay + ' - ' + toDisplay;
        }

        const allCust = Array.isArray(ALL_CUSTOMERS_DATA) ? ALL_CUSTOMERS_DATA : [];
        const allOrd = Array.isArray(ALL_ORDERS_DATA) ? ALL_ORDERS_DATA : [];

        // Tính khoảng ngày trước đó để so sánh tăng trưởng
        const fromD = new Date(fromRaw + 'T00:00:00');
        const toD = new Date(toRaw + 'T23:59:59');
        const durationMs = toD.getTime() - fromD.getTime();
        const prevToD = new Date(fromD.getTime() - 1);
        const prevFromD = new Date(prevToD.getTime() - durationMs);
        const prevFromIso = prevFromD.toISOString().slice(0, 10);
        const prevToIso = prevToD.toISOString().slice(0, 10);

        // Bảng tra cứu hạng hội viên theo customerId để đảm bảo 100% khớp đúng dù là từ JSP render hay API polling
        const custTierMap = {};
        allCust.forEach(c => {
            const t = c.tier || c.customerTier || 'BRONZE';
            custTierMap[c.id] = t;
        });
        const getOrderTier = (o) => (o.customerTier || o.tier || (o.customerId ? custTierMap[o.customerId] : null) || 'BRONZE');

        // Lọc khách hàng theo hạng (nếu có chọn)
        const scopedCust = tierVal ? allCust.filter(c => (c.tier || c.customerTier) === tierVal) : allCust;
        const totalMembers = scopedCust.length;

        // Hội viên mới gia nhập trong kỳ
        const newMembers = scopedCust.filter(c => c.createdAt >= fromRaw && c.createdAt <= toRaw).length;
        const prevNewMembers = scopedCust.filter(c => c.createdAt >= prevFromIso && c.createdAt <= prevToIso).length;

        let newGrowthHtml = '';
        if (prevNewMembers > 0) {
            const growthRate = ((newMembers - prevNewMembers) / prevNewMembers * 100).toFixed(1);
            const isUp = (newMembers >= prevNewMembers);
            newGrowthHtml = '<span style="color:' + (isUp ? '#16a34a' : '#ef4444') + '; font-weight:800; display:inline-flex; align-items:center; gap:2px;"><i class="ti ti-arrow-' + (isUp ? 'up' : 'down') + '"></i> ' + Math.abs(growthRate) + '%</span><span style="color:#64748b; font-weight:600;">so với kỳ trước (' + prevNewMembers + ' mới)</span>';
        } else {
            newGrowthHtml = '<span class="pill-badge green" style="font-size:11px; padding:3px 8px; border-radius:6px; background:#dcfce7; color:#166534; font-weight:700;">+' + newMembers + ' mới</span><span style="color:#64748b; font-weight:600;">trong kỳ lọc</span>';
        }

        // Tăng trưởng tổng quy mô
        const prevTotalMembers = scopedCust.filter(c => c.createdAt < fromRaw).length;
        let totalGrowthHtml = '';
        if (prevTotalMembers > 0) {
            const totalGrowthRate = ((totalMembers - prevTotalMembers) / prevTotalMembers * 100).toFixed(1);
            totalGrowthHtml = '<span style="color:#16a34a; font-weight:800; display:inline-flex; align-items:center; gap:2px;"><i class="ti ti-arrow-up"></i> ' + totalGrowthRate + '%</span><span style="color:#64748b; font-weight:600;">tăng trưởng tổng quy mô</span>';
        } else {
            totalGrowthHtml = '<span style="color:#16a34a; font-weight:800; display:inline-flex; align-items:center; gap:2px;"><i class="ti ti-arrow-up"></i> 100%</span><span style="color:#64748b; font-weight:600;">quy mô hiện tại</span>';
        }

        // Đơn hàng COMPLETED trong kỳ
        const completedOrders = allOrd.filter(o => o.status === 'COMPLETED' && o.date >= fromRaw && o.date <= toRaw);
        const scopedOrders = tierVal ? completedOrders.filter(o => getOrderTier(o) === tierVal) : completedOrders;

        // Hội viên phát sinh đơn trong kỳ
        const activeCustIds = new Set(scopedOrders.map(o => o.customerId).filter(Boolean));
        const activeMembersCount = activeCustIds.size;
        const activeRatio = totalMembers > 0 ? ((activeMembersCount / totalMembers) * 100).toFixed(1) : '0.0';

        // 1. CẬP NHẬT 3 THẺ KPI TRÊN CÙNG
        const kpiMembers = document.getElementById('s13KpiTotalMembers');
        const kpiMembersGrowth = document.getElementById('s13KpiTotalMembersGrowth');
        const kpiNew = document.getElementById('s13KpiNewMembers');
        const kpiNewGrowth = document.getElementById('s13KpiNewMembersGrowth');
        const kpiOrders = document.getElementById('s13KpiActiveMembers');
        const kpiOrdersRatio = document.getElementById('s13KpiActiveMembersRatio');

        if (kpiMembers) kpiMembers.innerText = totalMembers.toLocaleString('vi-VN');
        if (kpiMembersGrowth) kpiMembersGrowth.innerHTML = totalGrowthHtml;
        if (kpiNew) kpiNew.innerText = newMembers.toLocaleString('vi-VN');
        if (kpiNewGrowth) kpiNewGrowth.innerHTML = newGrowthHtml;
        if (kpiOrders) kpiOrders.innerText = activeMembersCount.toLocaleString('vi-VN');
        if (kpiOrdersRatio) {
            kpiOrdersRatio.innerHTML = '<span class="pill-badge green" style="font-size:11px; padding:3px 8px; border-radius:6px; background:#dcfce7; color:#166534; font-weight:700;">' + activeRatio + '% tỷ lệ</span><span style="color:#64748b; font-weight:600;">hội viên mua sắm</span>';
        }

        // 2. THỐNG KÊ CHI TIẾT THEO 4 HẠNG
        const tierStats = {
            'BRONZE': { name: 'Đồng', en: 'Bronze', color: '#d97706', count: 0, pct: 0, newCount: 0, orders: 0, revenue: 0, aov: 0 },
            'SILVER': { name: 'Bạc', en: 'Silver', color: '#64748b', count: 0, pct: 0, newCount: 0, orders: 0, revenue: 0, aov: 0 },
            'GOLD': { name: 'Vàng', en: 'Gold', color: '#f59e0b', count: 0, pct: 0, newCount: 0, orders: 0, revenue: 0, aov: 0 },
            'DIAMOND': { name: 'Kim cương', en: 'Diamond', color: '#06b6d4', count: 0, pct: 0, newCount: 0, orders: 0, revenue: 0, aov: 0 }
        };

        const totalAllCust = allCust.length || 1;
        ['BRONZE', 'SILVER', 'GOLD', 'DIAMOND'].forEach(t => {
            const mList = allCust.filter(c => (c.tier || c.customerTier) === t);
            tierStats[t].count = mList.length;
            tierStats[t].pct = (mList.length / totalAllCust * 100).toFixed(1);
            tierStats[t].newCount = mList.filter(c => c.createdAt >= fromRaw && c.createdAt <= toRaw).length;

            const tOrders = completedOrders.filter(o => getOrderTier(o) === t);
            tierStats[t].orders = tOrders.length;
            tierStats[t].revenue = tOrders.reduce((sum, o) => sum + (o.total || 0), 0);
            tierStats[t].aov = tOrders.length > 0 ? Math.round(tierStats[t].revenue / tOrders.length) : 0;
        });

        // 3. CẬP NHẬT BIỂU ĐỒ DONUT VÀ 4 THẺ CHỈ SỐ PHÂN BỔ
        const C = 477.5; // Chu vi vòng tròn r=76
        const lenB = (tierStats.BRONZE.count / totalAllCust) * C;
        const lenS = (tierStats.SILVER.count / totalAllCust) * C;
        const lenG = (tierStats.GOLD.count / totalAllCust) * C;
        const lenD = (tierStats.DIAMOND.count / totalAllCust) * C;

        const elB = document.getElementById('s13DonutBronze');
        const elS = document.getElementById('s13DonutSilver');
        const elG = document.getElementById('s13DonutGold');
        const elD = document.getElementById('s13DonutDiamond');

        if (elB) {
            elB.setAttribute('stroke-dasharray', lenB.toFixed(1) + ' ' + C);
            elB.setAttribute('stroke-dashoffset', '0');
        }
        if (elS) {
            elS.setAttribute('stroke-dasharray', lenS.toFixed(1) + ' ' + C);
            elS.setAttribute('stroke-dashoffset', (-lenB).toFixed(1));
        }
        if (elG) {
            elG.setAttribute('stroke-dasharray', lenG.toFixed(1) + ' ' + C);
            elG.setAttribute('stroke-dashoffset', (-(lenB + lenS)).toFixed(1));
        }
        if (elD) {
            elD.setAttribute('stroke-dasharray', lenD.toFixed(1) + ' ' + C);
            elD.setAttribute('stroke-dashoffset', (-(lenB + lenS + lenG)).toFixed(1));
        }

        const centerVal = document.getElementById('s13DonutCenterVal');
        const centerLabel = document.getElementById('s13DonutCenterLabel');
        const donutSubtitle = document.getElementById('s13DonutSubtitle');

        const donutSegments = {
            'BRONZE': elB,
            'SILVER': elS,
            'GOLD': elG,
            'DIAMOND': elD
        };

        if (tierVal && tierStats[tierVal]) {
            const st = tierStats[tierVal];
            if (centerVal) centerVal.innerText = st.count.toLocaleString('vi-VN');
            if (centerLabel) centerLabel.innerText = 'Hội viên ' + st.name + ' (' + st.pct + '%)';
            if (donutSubtitle) donutSubtitle.innerText = 'Chi tiết hạng ' + st.name + ': ' + st.count + ' hội viên (' + st.pct + '%)';

            Object.keys(donutSegments).forEach(k => {
                if (donutSegments[k]) {
                    if (k === tierVal) {
                        donutSegments[k].style.opacity = '1';
                        donutSegments[k].setAttribute('stroke-width', '26');
                    } else {
                        donutSegments[k].style.opacity = '0.25';
                        donutSegments[k].setAttribute('stroke-width', '22');
                    }
                }
            });
        } else {
            if (centerVal) centerVal.innerText = allCust.length.toLocaleString('vi-VN');
            if (centerLabel) centerLabel.innerText = 'Tổng số hội viên';
            if (donutSubtitle) donutSubtitle.innerText = 'Cơ cấu ' + allCust.length + ' hội viên thực tế theo các cấp bậc';

            Object.keys(donutSegments).forEach(k => {
                if (donutSegments[k]) {
                    donutSegments[k].style.opacity = '1';
                    donutSegments[k].setAttribute('stroke-width', '22');
                }
            });
        }

        const cBc = document.getElementById('s13CardBronzeCount');
        const cBp = document.getElementById('s13CardBronzePct');
        const cSc = document.getElementById('s13CardSilverCount');
        const cSp = document.getElementById('s13CardSilverPct');
        const cGc = document.getElementById('s13CardGoldCount');
        const cGp = document.getElementById('s13CardGoldPct');
        const cDc = document.getElementById('s13CardDiamondCount');
        const cDp = document.getElementById('s13CardDiamondPct');

        if (cBc) cBc.innerText = tierStats.BRONZE.count.toLocaleString('vi-VN');
        if (cBp) cBp.innerText = tierStats.BRONZE.pct + '%';
        if (cSc) cSc.innerText = tierStats.SILVER.count.toLocaleString('vi-VN');
        if (cSp) cSp.innerText = tierStats.SILVER.pct + '%';
        if (cGc) cGc.innerText = tierStats.GOLD.count.toLocaleString('vi-VN');
        if (cGp) cGp.innerText = tierStats.GOLD.pct + '%';
        if (cDc) cDc.innerText = tierStats.DIAMOND.count.toLocaleString('vi-VN');
        if (cDp) cDp.innerText = tierStats.DIAMOND.pct + '%';

        // 4. BIẾN ĐỘNG SỐ LƯỢNG HỘI VIÊN THEO HẠNG QUA CÁC THÁNG (DỮ LIỆU THỰC TẾ)
        const monthlyContainer = document.getElementById('s13MonthlyTrendContainer');
        if (monthlyContainer) {
            const targetDate = new Date(toRaw + 'T00:00:00');
            let months = [];
            for (let i = 0; i < 4; i++) {
                const d = new Date(targetDate.getFullYear(), targetDate.getMonth() - i, 1);
                const ym = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
                const lastDay = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate();
                const endYmd = ym + '-' + String(lastDay).padStart(2, '0');
                months.push({ ym: ym, endYmd: endYmd, label: 'Tháng ' + String(d.getMonth() + 1).padStart(2, '0') + '/' + d.getFullYear() });
            }

            let trendHtml = '';
            months.forEach((m, idx) => {
                const mCust = allCust.filter(c => c.createdAt <= m.endYmd);
                const mTotal = mCust.length;
                const mB = mCust.filter(c => (c.tier || c.customerTier) === 'BRONZE').length;
                const mS = mCust.filter(c => (c.tier || c.customerTier) === 'SILVER').length;
                const mG = mCust.filter(c => (c.tier || c.customerTier) === 'GOLD').length;
                const mD = mCust.filter(c => (c.tier || c.customerTier) === 'DIAMOND').length;

                const prevM = new Date(targetDate.getFullYear(), targetDate.getMonth() - idx - 1, 1);
                const prevLastDay = new Date(prevM.getFullYear(), prevM.getMonth() + 1, 0).getDate();
                const prevEndYmd = prevM.getFullYear() + '-' + String(prevM.getMonth() + 1).padStart(2, '0') + '-' + String(prevLastDay).padStart(2, '0');
                const prevTotal = allCust.filter(c => c.createdAt <= prevEndYmd).length;
                const growthPct = prevTotal > 0 ? (((mTotal - prevTotal) / prevTotal) * 100).toFixed(1) : '100.0';

                const pB = mTotal > 0 ? (mB / mTotal * 100).toFixed(1) : 0;
                const pS = mTotal > 0 ? (mS / mTotal * 100).toFixed(1) : 0;
                const pG = mTotal > 0 ? (mG / mTotal * 100).toFixed(1) : 0;
                const pD = mTotal > 0 ? (mD / mTotal * 100).toFixed(1) : 0;

                const isCurrent = (idx === 0);

                trendHtml += '<div>' +
                    '<div style="display:flex; justify-content:space-between; font-size:12.5px; margin-bottom:6px;">' +
                        '<span style="font-weight:700; color:' + (isCurrent ? '#ea580c' : '#334155') + '; display:inline-flex; align-items:center; gap:4px;">' +
                            (isCurrent ? '<i class="ti ti-caret-down" style="font-size:13px;"></i> ' : '') + m.label + (isCurrent ? ' (Kỳ lọc)' : '') +
                        '</span>' +
                        '<span style="font-weight:' + (isCurrent ? '800' : '700') + '; color:' + (isCurrent ? '#ea580c' : '#1e293b') + ';">' + mTotal.toLocaleString('vi-VN') + ' hội viên (+' + growthPct + '%)</span>' +
                    '</div>' +
                    '<div style="height:12px; border-radius:99px; overflow:hidden; display:flex; background:#e2e8f0;">' +
                        '<div style="width:' + pB + '%; background:#d97706;" title="Đồng: ' + mB + '"></div>' +
                        '<div style="width:' + pS + '%; background:#64748b;" title="Bạc: ' + mS + '"></div>' +
                        '<div style="width:' + pG + '%; background:#f59e0b;" title="Vàng: ' + mG + '"></div>' +
                        '<div style="width:' + pD + '%; background:#06b6d4;" title="Kim cương: ' + mD + '"></div>' +
                    '</div>' +
                    '<div style="display:flex; justify-content:space-between; font-size:10.5px; font-weight:600; color:#64748b; margin-top:3px;">' +
                        '<span>Đồng: ' + mB + '</span>' +
                        '<span>Bạc: ' + mS + '</span>' +
                        '<span>Vàng: ' + mG + '</span>' +
                        '<span>Kim cương: ' + mD + '</span>' +
                    '</div>' +
                '</div>';
            });
            monthlyContainer.innerHTML = trendHtml;
        }

        // 5. ROW 3: HÀNH VI MUA SẮM (TỶ TRỌNG DOANH THU & AOV THEO HẠNG)
        const totalRev = completedOrders.reduce((sum, o) => sum + (o.total || 0), 0);
        const pRevD = totalRev > 0 ? (tierStats.DIAMOND.revenue / totalRev * 100).toFixed(0) : 0;
        const pRevG = totalRev > 0 ? (tierStats.GOLD.revenue / totalRev * 100).toFixed(0) : 0;
        const pRevS = totalRev > 0 ? (tierStats.SILVER.revenue / totalRev * 100).toFixed(0) : 0;
        const pRevB = totalRev > 0 ? (tierStats.BRONZE.revenue / totalRev * 100).toFixed(0) : 0;

        const revDVal = document.getElementById('s13RevDiamondVal');
        const revDPct = document.getElementById('s13RevDiamondPct');
        const revDBar = document.getElementById('s13RevDiamondBar');
        if (revDVal) revDVal.innerText = tierStats.DIAMOND.revenue.toLocaleString('vi-VN') + '₫';
        if (revDPct) revDPct.innerText = pRevD + '%';
        if (revDBar) revDBar.style.width = pRevD + '%';

        const revGVal = document.getElementById('s13RevGoldVal');
        const revGPct = document.getElementById('s13RevGoldPct');
        const revGBar = document.getElementById('s13RevGoldBar');
        if (revGVal) revGVal.innerText = tierStats.GOLD.revenue.toLocaleString('vi-VN') + '₫';
        if (revGPct) revGPct.innerText = pRevG + '%';
        if (revGBar) revGBar.style.width = pRevG + '%';

        const revSVal = document.getElementById('s13RevSilverVal');
        const revSPct = document.getElementById('s13RevSilverPct');
        const revSBar = document.getElementById('s13RevSilverBar');
        if (revSVal) revSVal.innerText = tierStats.SILVER.revenue.toLocaleString('vi-VN') + '₫';
        if (revSPct) revSPct.innerText = pRevS + '%';
        if (revSBar) revSBar.style.width = pRevS + '%';

        const revBVal = document.getElementById('s13RevBronzeVal');
        const revBPct = document.getElementById('s13RevBronzePct');
        const revBBar = document.getElementById('s13RevBronzeBar');
        if (revBVal) revBVal.innerText = tierStats.BRONZE.revenue.toLocaleString('vi-VN') + '₫';
        if (revBPct) revBPct.innerText = pRevB + '%';
        if (revBBar) revBBar.style.width = pRevB + '%';

        const ordersSummary = document.getElementById('s13OrdersSummaryText');
        if (ordersSummary) {
            ordersSummary.innerHTML = 'Đồng: <b>' + tierStats.BRONZE.orders + ' đơn</b> &bull; Bạc: <b>' + tierStats.SILVER.orders + ' đơn</b> &bull; Vàng: <b>' + tierStats.GOLD.orders + ' đơn</b> &bull; Kim cương: <b>' + tierStats.DIAMOND.orders + ' đơn</b>';
        }

        // AOV Bars & Values
        const maxAov = Math.max(tierStats.DIAMOND.aov, tierStats.GOLD.aov, tierStats.SILVER.aov, tierStats.BRONZE.aov, 1);

        const aovDVal = document.getElementById('s13AovDiamondVal');
        const aovDBar = document.getElementById('s13AovDiamondBar');
        if (aovDVal) aovDVal.innerText = tierStats.DIAMOND.aov.toLocaleString('vi-VN') + '₫';
        if (aovDBar) aovDBar.style.width = Math.round(tierStats.DIAMOND.aov / maxAov * 100) + '%';

        const aovGVal = document.getElementById('s13AovGoldVal');
        const aovGBar = document.getElementById('s13AovGoldBar');
        if (aovGVal) aovGVal.innerText = tierStats.GOLD.aov.toLocaleString('vi-VN') + '₫';
        if (aovGBar) aovGBar.style.width = Math.round(tierStats.GOLD.aov / maxAov * 100) + '%';

        const aovSVal = document.getElementById('s13AovSilverVal');
        const aovSBar = document.getElementById('s13AovSilverBar');
        if (aovSVal) aovSVal.innerText = tierStats.SILVER.aov.toLocaleString('vi-VN') + '₫';
        if (aovSBar) aovSBar.style.width = Math.round(tierStats.SILVER.aov / maxAov * 100) + '%';

        const aovBVal = document.getElementById('s13AovBronzeVal');
        const aovBBar = document.getElementById('s13AovBronzeBar');
        if (aovBVal) aovBVal.innerText = tierStats.BRONZE.aov.toLocaleString('vi-VN') + '₫';
        if (aovBBar) aovBBar.style.width = Math.round(tierStats.BRONZE.aov / maxAov * 100) + '%';

        const aovInsight = document.getElementById('s13AovInsightText');
        if (aovInsight) {
            if (tierStats.BRONZE.aov > 0 && tierStats.DIAMOND.aov > 0) {
                const ratioD = (tierStats.DIAMOND.aov / tierStats.BRONZE.aov).toFixed(1);
                aovInsight.innerHTML = 'Hội viên Kim cương có giá trị đơn TB (AOV) gấp <b>' + ratioD + ' lần</b> so với hạng Đồng.';
            } else if (tierStats.SILVER.aov > 0 && tierStats.BRONZE.aov > 0) {
                const ratioS = (tierStats.SILVER.aov / tierStats.BRONZE.aov).toFixed(1);
                aovInsight.innerHTML = 'Hội viên Bạc có giá trị đơn TB (AOV) gấp <b>' + ratioS + ' lần</b> so với hạng Đồng.';
            } else {
                aovInsight.innerHTML = 'Hạng thành viên càng cao tương ứng với sức chi tiêu và giá trị đơn hàng trung bình càng lớn.';
            }
        }

        // 6. ROW 4: HIỆU QUẢ CHƯƠNG TRÌNH HỘI VIÊN
        const promoOrdersVal = document.getElementById('s13PromoOrdersVal');
        const promoOrdersPct = document.getElementById('s13PromoOrdersPct');
        const promoAmountVal = document.getElementById('s13PromoAmountVal');

        const memberOrdersCount = scopedOrders.length;
        const totalPeriodOrders = completedOrders.length;
        const memberOrdersPct = totalPeriodOrders > 0 ? ((memberOrdersCount / totalPeriodOrders) * 100).toFixed(1) : '100.0';
        const memberRevenue = scopedOrders.reduce((sum, o) => sum + (o.total || 0), 0);

        if (promoOrdersVal) promoOrdersVal.innerHTML = memberOrdersCount.toLocaleString('vi-VN') + ' <span style="font-size:15px; font-weight:600; color:#64748b;">đơn</span>';
        if (promoOrdersPct) promoOrdersPct.innerText = memberOrdersPct + '%';
        if (promoAmountVal) promoAmountVal.innerText = memberRevenue.toLocaleString('vi-VN') + '₫';

        // 7. ROW 5: BẢNG TỔNG HỢP KINH DOANH THEO HẠNG THÀNH VIÊN
        const tableBody = document.getElementById('s13TableBody');
        const tiersToRender = tierVal ? [tierVal] : ['BRONZE', 'SILVER', 'GOLD', 'DIAMOND'];

        if (tableBody) {
            let bodyHtml = '';
            tiersToRender.forEach(t => {
                const st = tierStats[t];
                if (!st) return;
                const isSelected = (tierVal === t);
                bodyHtml += '<tr id="s13-row-' + t + '" style="' + (isSelected ? 'background:#fff7ed;' : '') + '">' +
                    '<td>' +
                        '<div style="display:flex; align-items:center; gap:8px;">' +
                            '<span class="s13-tier-dot" style="background:' + st.color + ';"></span>' +
                            '<div>' +
                                '<b style="color:#1e293b;">' + st.name + '</b>' +
                                '<div style="font-size:11px; color:#94a3b8; font-weight:600;">' + st.en + '</div>' +
                            '</div>' +
                        '</div>' +
                    '</td>' +
                    '<td style="text-align:center; font-weight:700; color:#1e293b;">' + st.count.toLocaleString('vi-VN') + '</td>' +
                    '<td style="text-align:center;"><span style="color:#16a34a; font-weight:700;">+' + st.newCount.toLocaleString('vi-VN') + '</span></td>' +
                    '<td style="text-align:center; font-weight:600; color:#334155;">' + st.orders.toLocaleString('vi-VN') + ' đơn</td>' +
                    '<td style="text-align:right; font-weight:700; color:#1e293b;">' + st.revenue.toLocaleString('vi-VN') + '₫</td>' +
                    '<td style="text-align:right; font-weight:700; color:#334155;">' + st.aov.toLocaleString('vi-VN') + '₫</td>' +
                '</tr>';
            });
            tableBody.innerHTML = bodyHtml;
        }

        // Cập nhật Footer Table
        let footMembers = 0;
        let footNew = 0;
        let footOrders = 0;
        let footRev = 0;
        tiersToRender.forEach(t => {
            const st = tierStats[t];
            if (st) {
                footMembers += st.count;
                footNew += st.newCount;
                footOrders += st.orders;
                footRev += st.revenue;
            }
        });
        const footAov = footOrders > 0 ? Math.round(footRev / footOrders) : 0;

        const elTotM = document.getElementById('s13TableTotalMembers');
        const elTotN = document.getElementById('s13TableTotalNew');
        const elTotO = document.getElementById('s13TableTotalOrders');
        const elTotR = document.getElementById('s13TableTotalRevenue');
        const elAvgA = document.getElementById('s13TableAvgAov');

        if (elTotM) elTotM.innerText = footMembers.toLocaleString('vi-VN');
        if (elTotN) elTotN.innerText = '+' + footNew.toLocaleString('vi-VN');
        if (elTotO) elTotO.innerText = footOrders.toLocaleString('vi-VN') + ' đơn';
        if (elTotR) elTotR.innerText = footRev.toLocaleString('vi-VN') + '₫';
        if (elAvgA) elAvgA.innerText = footAov.toLocaleString('vi-VN') + '₫';
    }

    function exportScreen13TableCsv() {
        const fromRaw = document.getElementById('s13FilterFrom')?.value || '2026-10-01';
        const toRaw = document.getElementById('s13FilterTo')?.value || '2026-10-31';
        const fromVal = formatVnDate(fromRaw);
        const toVal = formatVnDate(toRaw);

        const tableBody = document.getElementById('s13TableBody');
        let csv = '\uFEFF"HẠNG THÀNH VIÊN","SỐ LƯỢNG HỘI VIÊN","SỐ HỘI VIÊN MỚI","SỐ ĐƠN HÀNG","TỔNG DOANH THU (VNĐ)","GIÁ TRỊ ĐƠN TB (AOV)"\n';

        if (tableBody) {
            const trs = tableBody.querySelectorAll('tr');
            trs.forEach(tr => {
                const tds = tr.querySelectorAll('td');
                if (tds.length >= 6) {
                    const name = tds[0].innerText.replace(/\n/g, ' ').trim();
                    const members = tds[1].innerText.replace(/,/g, '').trim();
                    const newM = tds[2].innerText.replace(/[\+,]/g, '').trim();
                    const orders = tds[3].innerText.replace(/[^\d]/g, '').trim();
                    const rev = tds[4].innerText.replace(/[^\d]/g, '').trim();
                    const aov = tds[5].innerText.replace(/[^\d]/g, '').trim();
                    csv += '"' + name + '",' + members + ',' + newM + ',' + orders + ',' + rev + ',' + aov + '\n';
                }
            });
        }

        const elTotM = document.getElementById('s13TableTotalMembers')?.innerText.replace(/,/g, '') || '';
        const elTotN = document.getElementById('s13TableTotalNew')?.innerText.replace(/[\+,]/g, '') || '';
        const elTotO = document.getElementById('s13TableTotalOrders')?.innerText.replace(/[^\d]/g, '') || '';
        const elTotR = document.getElementById('s13TableTotalRevenue')?.innerText.replace(/[^\d]/g, '') || '';
        const elAvgA = document.getElementById('s13TableAvgAov')?.innerText.replace(/[^\d]/g, '') || '';
        csv += '"Tổng cộng / Trung bình",' + elTotM + ',' + elTotN + ',' + elTotO + ',' + elTotR + ',' + elAvgA + '\n';

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'Bao_cao_hoi_vien_PetCare_' + fromVal.replace(/\//g, '') + '_den_' + toVal.replace(/\//g, '') + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
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

                // Cập nhật sơ đồ Tab 1 nếu có dailyRevenue
                if (data.stats.dailyRevenue) {
                    revenueDataPoints = data.stats.dailyRevenue;
                    if (window.location.hash !== '#revenue') {
                        renderDynamicRevenueChart(revenueDataPoints, 'trendChartWrapper1');
                    }
                }

                // Vẽ lại biểu đồ tròn trạng thái đơn
                if (data.stats.ordersByStatus) {
                    renderDynamicDonutChart(data.stats.ordersByStatus);
                }

                // Cập nhật thanh hội viên
                if (data.stats.customersByTier) {
                    renderDynamicTierBar(data.stats.customersByTier);
                }

                // Cập nhật ALL_ORDERS_DATA, ALL_CUSTOMERS_DATA và các màn hình Screen 12, Screen 13
                if (Array.isArray(data.stats.allOrders)) {
                    ALL_ORDERS_DATA = data.stats.allOrders;
                    applyScreen12Filter();
                }
                if (Array.isArray(data.stats.allCustomers)) {
                    ALL_CUSTOMERS_DATA = data.stats.allCustomers;
                    applyScreen13Filter();
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

    // Khởi tạo bộ chọn nhanh (Presets) cho form lọc khoảng ngày Tab 1
    function initRangeFormPresets() {
        const form = document.getElementById('range-form');
        if (!form) return;
        const fromInput = document.getElementById('from');
        const toInput = document.getElementById('to');

        function checkActivePreset() {
            if (!fromInput || !toInput || !fromInput.value || !toInput.value) return;
            const d1 = new Date(fromInput.value + 'T00:00:00');
            const d2 = new Date(toInput.value + 'T00:00:00');

            const now = new Date();
            const pad = n => String(n).padStart(2, '0');
            const toIso = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());

            const startOfWeek = new Date(now);
            const dayOfWeek = (startOfWeek.getDay() + 6) % 7; // Monday = 0
            startOfWeek.setDate(startOfWeek.getDate() - dayOfWeek);
            const endOfWeek = new Date(startOfWeek);
            endOfWeek.setDate(endOfWeek.getDate() + 6);
            const weekFromIso = toIso(startOfWeek);
            const weekToIso = toIso(endOfWeek);

            const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
            const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
            const monthFromIso = toIso(startOfMonth);
            const monthToIso = toIso(endOfMonth);

            form.querySelectorAll('.chip[data-preset]').forEach(btn => {
                const p = btn.getAttribute('data-preset');
                if (p === 'week') {
                    if (fromInput.value === weekFromIso && toInput.value === weekToIso) {
                        btn.classList.add('on');
                    } else {
                        btn.classList.remove('on');
                    }
                } else if (p === 'month') {
                    if ((fromInput.value === monthFromIso && toInput.value === monthToIso) ||
                        (fromInput.value === '2026-10-01' && toInput.value === '2026-10-31') ||
                        (d1.getDate() === 1 && d2.getDate() === new Date(d2.getFullYear(), d2.getMonth() + 1, 0).getDate() && d1.getMonth() === d2.getMonth() && d1.getFullYear() === d2.getFullYear())) {
                        btn.classList.add('on');
                    } else {
                        btn.classList.remove('on');
                    }
                } else {
                    btn.classList.remove('on');
                }
            });
        }
        checkActivePreset();

        form.querySelectorAll('.chip[data-preset]').forEach(btn => {
            btn.addEventListener('click', () => {
                const preset = btn.getAttribute('data-preset');
                const now = new Date();
                const pad = n => String(n).padStart(2, '0');
                const toIso = d => d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
                let newFromStr, newToStr;

                if (preset === 'week') {
                    const startOfWeek = new Date(now);
                    const dayOfWeek = (startOfWeek.getDay() + 6) % 7; // Monday = 0
                    startOfWeek.setDate(startOfWeek.getDate() - dayOfWeek);
                    const endOfWeek = new Date(startOfWeek);
                    endOfWeek.setDate(endOfWeek.getDate() + 6);
                    newFromStr = toIso(startOfWeek);
                    newToStr = toIso(endOfWeek);
                } else if (preset === 'month') {
                    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
                    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                    newFromStr = toIso(startOfMonth);
                    newToStr = toIso(endOfMonth);
                }

                if (newFromStr && newToStr) {
                    fromInput.value = newFromStr;
                    toInput.value = newToStr;
                    form.querySelectorAll('.chip[data-preset]').forEach(b => b.classList.remove('on'));
                    btn.classList.add('on');
                    form.submit();
                }
            });
        });
    }

    // Khởi tạo sơ đồ khi trang tải xong
    document.addEventListener('DOMContentLoaded', () => {
        // 0. Khởi tạo bộ lọc preset cho Tab 1
        initRangeFormPresets();

        // 1. Render Tab 1 Xu hướng doanh thu với dữ liệu thực tế từ Database
        revenueDataPoints = [
            <c:if test="${not empty stats.dailyRevenue}">
                <c:forEach var="d" items="${stats.dailyRevenue}" varStatus="loop">
                    { date: '${d.date}', dayText: '${d.dayText}', orderCount: ${d.orderCount}, amount: ${d.amount} }<c:if test="${!loop.last}">,</c:if>
                </c:forEach>
            </c:if>
        ];
        renderDynamicRevenueChart(revenueDataPoints, 'trendChartWrapper1');

        // 2, 3: Khởi tạo và áp dụng dữ liệu thực tế cho Báo cáo doanh thu (Screen 12)
        const s12From = document.getElementById('screen12FilterFrom');
        const s12To = document.getElementById('screen12FilterTo');
        if (s12From && (!s12From.value || s12From.value !== '2026-10-01')) {
            s12From.value = '2026-10-01';
        }
        if (s12To && (!s12To.value || s12To.value !== '2026-10-31')) {
            s12To.value = '2026-10-31';
        }
        if (typeof syncScreen12QuickChips === 'function') syncScreen12QuickChips();
        applyScreen12Filter();

        // Screen 13: Báo cáo hội viên
        applyScreen13Filter();

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
