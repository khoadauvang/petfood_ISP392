<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: productGroups, lotStats, lotViews, filterView, filterProductId, filterKeyword, filterQuery, products, shelfLifeDays, quarantineDays --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tồn kho · PetFood</title>
    <meta name="description" content="Theo dõi tồn kho theo từng sản phẩm, hạn sử dụng, trạng thái hàng và ưu tiên xuất kho theo FEFO.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .prod-row {
            cursor: pointer;
            transition: background var(--transition);
        }
        .prod-row:hover {
            background: #fffcf9 !important;
        }
        .prod-row.expanded {
            background: #fff7ee !important;
            border-bottom: 0 !important;
        }
        .prod-thumb {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            object-fit: contain;
            background: #ffffff;
            border: 1px solid var(--line);
            padding: 2px;
            flex-shrink: 0;
        }
        .chev-icon {
            font-size: 16px;
            color: var(--text-placeholder);
            transition: transform 0.2s ease, color 0.2s ease;
            display: inline-block;
        }
        .prod-row.expanded .chev-icon {
            transform: rotate(90deg);
            color: var(--color-primary);
        }
        .lot-accordion-card {
            background: #fffaf5;
            border: 1px solid #ffd8b8;
            border-radius: 14px;
            padding: 16px 20px;
            margin: 6px 0 14px;
            box-shadow: 0 4px 16px rgba(249, 115, 22, 0.05);
        }
        .lot-accordion-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding-bottom: 12px;
            margin-bottom: 12px;
            border-bottom: 1px dashed #fed7aa;
            flex-wrap: wrap;
        }
        .lot-subtable th {
            background: #fff0e2 !important;
            color: #9a3412 !important;
            font-size: 11px !important;
            font-weight: 800 !important;
            text-transform: uppercase !important;
            padding: 9px 12px !important;
            border-bottom: 1px solid #ffd8b8 !important;
        }
        .lot-subtable td {
            background: #ffffff !important;
            padding: 10px 12px !important;
            font-size: 12px !important;
            border-bottom: 1px solid #f8ede3 !important;
        }
        .lot-subtable tr:last-child td {
            border-bottom: 0 !important;
        }
        .lot-subtable tr:hover td {
            background: #fff9f4 !important;
        }
        .btn-lot-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 700;
            background: #fff7ee;
            border: 1px solid #fed7aa;
            color: #ea580c;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-lot-badge:hover, .prod-row.expanded .btn-lot-badge {
            background: #ea580c;
            color: #ffffff;
            border-color: #ea580c;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ KHO &amp; ĐỔI TRẢ</span> <span class="sep">&gt;</span> <span class="current">TỒN KHO</span>
            </div>
            <h1>TỒN KHO</h1>
            <p class="page-sub">Theo dõi tồn kho theo từng sản phẩm, bấm vào sản phẩm để xem chi tiết lô hàng sắp xếp theo thứ tự ưu tiên FEFO.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <button type="button" class="btn-pill-outline" onclick="toggleAllAccordions()" id="btn-toggle-all">
                <i class="ti ti-arrows-vertical"></i><span id="text-toggle-all">Mở rộng tất cả</span>
            </button>
            <a href="javascript:void(0)" class="btn-pill-outline" onclick="exportExcel()"><i class="ti ti-file-spreadsheet"></i>Xuất Excel</a>
            <a href="${ctx}/staff/lots/new" class="btn-flashsale">
                <i class="ti ti-plus"></i>Nhập lô hàng mới
            </a>
        </div>
    </div>

    <%-- 5 KPI Cards Screen 10 (Số liệu thực tế tính toán từ Database) --%>
    <section class="grid" style="grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 14px; margin-bottom: 20px">
        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">TỔNG TỒN KHẢ DỤNG</span>
                <span class="kpi-ico green"><i class="ti ti-package"></i></span>
            </div>
            <div class="kpi-value" style="color:#16a34a"><fmt:formatNumber value="${lotStats.totalOnHand != null ? lotStats.totalOnHand : 0}"/> <small>Đơn vị</small></div>
            <div class="kpi-meta"><span class="badge ok">Hàng còn trong kho</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">LÔ ĐANG LƯU KHO</span>
                <span class="kpi-ico blue"><i class="ti ti-building-warehouse"></i></span>
            </div>
            <div class="kpi-value" style="color:#2563eb"><fmt:formatNumber value="${lotStats.activeLots != null ? lotStats.activeLots : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge info">Trên tổng <fmt:formatNumber value="${lotStats.totalLots != null ? lotStats.totalLots : 0}"/> lô từng nhập</span></div>
        </div>

        <%-- Card: Sản phẩm tồn thấp chuyển từ màn Cảnh báo sang --%>
        <a href="${ctx}/staff/lots?stockStatus=LOW_STOCK" class="panel kpi" style="text-decoration:none; cursor:pointer" title="Bấm để lọc các sản phẩm tồn kho thấp">
            <div class="kpi-top">
                <span class="kpi-label">SẢN PHẨM TỒN THẤP</span>
                <span class="kpi-ico yellow"><i class="ti ti-alert-circle"></i></span>
            </div>
            <div class="kpi-value" style="color:#d97706"><fmt:formatNumber value="${lotStats.lowStockCount != null ? lotStats.lowStockCount : 0}"/> <small>Sản phẩm</small></div>
            <div class="kpi-meta"><span class="badge warn">Cần nhập bổ sung kho</span></div>
        </a>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">CẬN HẠN (&lt;90 NGÀY)</span>
                <span class="kpi-ico orange"><i class="ti ti-bolt"></i></span>
            </div>
            <div class="kpi-value" style="color:#ea580c"><fmt:formatNumber value="${lotStats.warningLots != null ? lotStats.warningLots : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge orange">Ưu tiên kích hoạt Flash Sale</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">NGUY CẤP / CHỜ TIÊU HỦY</span>
                <span class="kpi-ico red"><i class="ti ti-alert-triangle"></i></span>
            </div>
            <div class="kpi-value red"><fmt:formatNumber value="${lotStats.criticalLots != null ? lotStats.criticalLots : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge red">&lt; ${quarantineDays} ngày hoặc quá hạn</span></div>
        </div>
    </section>

    <%-- Banner Quy tắc FEFO --%>
    <div class="urgent-banner" style="background:#fffaf5; border-color:#fed7aa">
        <div class="urgent-left">
            <span class="urgent-icon" style="background:#ea580c"><i class="ti ti-route"></i></span>
            <div>
                <div style="display:flex; align-items:center; gap:8px">
                    <b style="color:var(--text-logo); font-size:14px">Quy tắc tự động FEFO trong hệ thống Pick &amp; Pack</b>
                    <span class="pill-badge green">ĐANG KÍCH HOẠT</span>
                </div>
                <div style="font-size:12px; color:var(--text-muted); margin-top:2px">
                    • Đơn thường tự động lấy lô có HSD gần nhất (cam kết HSD &ge; 90 ngày).<br>
                    • Lô cận hạn (&lt; 90 ngày) ưu tiên phân bổ vào Flash Sale. Lô nguy cấp (&lt; 21 ngày hoặc hết hạn) bị khóa bán, không bán dưới mọi hình thức (BR-51).
                </div>
            </div>
        </div>
        <div class="urgent-actions">
            <a href="javascript:void(0)" class="link-more" style="color:#ea580c">Xem sơ đồ phân bổ FEFO <i class="ti ti-arrow-right"></i></a>
        </div>
    </div>

    <%-- Tabs chuyển đổi nhanh: Tất cả / Tồn thấp / Hết hàng --%>
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; flex-wrap:wrap; gap:10px">
        <div class="screen-tabs" style="margin:0; border:0">
            <a href="${ctx}/staff/lots" class="screen-tab-btn ${empty filterStockStatus and (empty filterView or filterView == 'ALL') ? 'active' : ''}">
                <i class="ti ti-layout-grid" style="margin-right:6px"></i>Tất cả tồn kho
            </a>
            <a href="${ctx}/staff/lots?stockStatus=LOW_STOCK" class="screen-tab-btn ${filterStockStatus == 'LOW_STOCK' or filterView == 'LOW_STOCK' ? 'active' : ''}" style="${filterStockStatus == 'LOW_STOCK' or filterView == 'LOW_STOCK' ? 'background:#fffbeb; border-color:#f59e0b; color:#b45309; font-weight:800' : ''}">
                <i class="ti ti-alert-circle" style="margin-right:6px; color:#d97706"></i>Sản phẩm tồn thấp (${lotStats.lowStockCount != null ? lotStats.lowStockCount : 0})
            </a>
            <a href="${ctx}/staff/lots?stockStatus=OUT_OF_STOCK" class="screen-tab-btn ${filterStockStatus == 'OUT_OF_STOCK' ? 'active' : ''}">
                <i class="ti ti-circle-x" style="margin-right:6px; color:#dc2626"></i>Hết hàng
            </a>
        </div>
    </div>

    <%-- Filter bar Screen 10 --%>
    <form method="get" action="${ctx}/staff/lots" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:260px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:14px; top:50%; transform:translateY(-50%); color:var(--text-placeholder); font-size:16px"></i>
            <input type="text" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo tên sản phẩm, SKU hoặc số lô..."
                   style="width:100%; padding:9px 14px 9px 38px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="productId" style="max-width:260px; padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả sản phẩm</option>
            <c:forEach var="p" items="${products}">
                <option value="${p.id}" ${p.id == filterProductId ? 'selected' : ''}><c:out value="${p.sku}"/> - <c:out value="${p.name}"/></option>
            </c:forEach>
        </select>

        <%-- Lọc Trạng thái tồn kho (Tồn thấp / Hết hàng / Đủ hàng) --%>
        <select name="stockStatus" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px; font-weight:600; color:var(--text-main)">
            <option value="">Trạng thái tồn (Tất cả)</option>
            <option value="LOW_STOCK" ${filterStockStatus == 'LOW_STOCK' ? 'selected' : ''}>⚠️ Tồn kho thấp (Cần nhập)</option>
            <option value="OUT_OF_STOCK" ${filterStockStatus == 'OUT_OF_STOCK' ? 'selected' : ''}>❌ Hết hàng (0 đơn vị)</option>
            <option value="IN_STOCK" ${filterStockStatus == 'IN_STOCK' ? 'selected' : ''}>✅ Còn đủ hàng</option>
        </select>

        <%-- Lọc Hạn sử dụng (FEFO) - Không trùng lặp với Trạng thái tồn --%>
        <select name="view" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px; font-weight:600; color:var(--text-main)">
            <option value="ALL">Hạn sử dụng (Tất cả)</option>
            <option value="NEAR_EXPIRY" ${filterView == 'NEAR_EXPIRY' ? 'selected' : ''}>⚡ Lô cận hạn (&lt; 90 ngày)</option>
            <option value="CRITICAL" ${filterView == 'CRITICAL' ? 'selected' : ''}>🚨 Cấp bách (&lt; 21 ngày / Quá hạn)</option>
            <option value="SAFE" ${filterView == 'SAFE' ? 'selected' : ''}>🛡️ HSD an toàn (&ge; 90 ngày)</option>
        </select>

        <button type="submit" class="btn-pill-primary"><i class="ti ti-filter"></i>Lọc</button>
        <a href="${ctx}/staff/lots" class="act-icon" title="Xóa bộ lọc"><i class="ti ti-x"></i></a>
    </form>

    <%-- Banner thông báo nếu đang lọc Sản phẩm tồn kho thấp --%>
    <c:if test="${filterStockStatus == 'LOW_STOCK' or filterView == 'LOW_STOCK'}">
        <div style="margin:14px 0; padding:12px 18px; border-radius:12px; background:#fffbeb; border:1px solid #fde68a; color:#92400e; display:flex; align-items:center; justify-content:space-between; font-size:13px; font-weight:600; box-shadow:0 2px 8px rgba(217, 119, 6, 0.08)">
            <div style="display:flex; align-items:center; gap:10px">
                <i class="ti ti-alert-triangle" style="font-size:20px; color:#d97706"></i>
                <span>Đang hiển thị <b>Danh sách sản phẩm tồn kho thấp</b> (Tồn khả dụng &le; Định mức an toàn). Ưu tiên lập đơn nhập bổ sung!</span>
            </div>
            <a href="${ctx}/staff/lots" class="btn-pill-outline" style="padding:4px 14px; font-size:12px; text-decoration:none">
                <i class="ti ti-x"></i>Xem tất cả
            </a>
        </div>
    </c:if>

    <%-- BẢNG SẢN PHẨM & TỒN KHO THEO LÔ (Master-Detail Accordion giống Figma) --%>
    <div class="panel" style="background:#fff; border-radius:14px; border:1px solid var(--line); overflow:hidden; margin-top:16px; padding:0">
        <div class="split-head">
            <div>
                <h3 style="margin:0"><i class="ti ti-building-warehouse" style="color:var(--color-primary)"></i>DANH SÁCH TỒN KHO THEO SẢN PHẨM</h3>
                <small style="color:var(--text-muted)">Nhấp vào từng dòng để mở rộng chi tiết các lô hàng và thứ tự ưu tiên FEFO</small>
            </div>
            <div style="font-size:13px; color:var(--text-muted)">
                Hiển thị: <b>${productGroups != null ? productGroups.size() : 0}</b> sản phẩm
            </div>
        </div>

        <table class="table" style="margin:0; width:100%; border-collapse:collapse">
            <thead>
                <tr style="background:#f8fafc; border-bottom:1px solid #e2e8f0; font-size:11px; font-weight:800; color:#64748b; text-align:left; letter-spacing:.04em; text-transform:uppercase;">
                    <th style="padding:14px 16px; width:340px;">SẢN PHẨM &amp; SKU</th>
                    <th style="padding:14px 16px; text-align:right;">TỔNG TỒN THỰC</th>
                    <th style="padding:14px 16px; text-align:right;">GIỮ CHỖ (ORD)</th>
                    <th style="padding:14px 16px; text-align:right;">TỒN KHẢ DỤNG</th>
                    <th style="padding:14px 16px; text-align:right;">FLASH SALE</th>
                    <th style="padding:14px 16px;">TRẠNG THÁI TỒN</th>
                    <th style="padding:14px 16px;">TÌNH TRẠNG HẠN DÙNG</th>
                    <th style="padding:14px 16px; text-align:center; width:140px;">CHI TIẾT LÔ</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty productGroups}">
                        <c:forEach var="g" items="${productGroups}">
                            <%-- Dòng Sản phẩm chính (Master Row) --%>
                            <tr class="prod-row" id="row-prod-${g.productId}" onclick="toggleLotAccordion('${g.productId}')" style="border-bottom:1px solid #f1f5f9; font-size:13px;">
                                <td style="padding:14px 16px;">
                                    <div style="display:flex; align-items:center; gap:12px">
                                        <i class="ti ti-chevron-right chev-icon" id="chev-${g.productId}"></i>
                                        <img src="${empty g.imageUrl ? 'https://placehold.co/44x44?text=Pet' : g.imageUrl}"
                                             onerror="this.src='https://placehold.co/44x44?text=Pet'" alt="" class="prod-thumb">
                                        <div>
                                            <div style="font-weight:800; color:var(--text-logo); font-size:14px; line-height:1.3">
                                                <c:out value="${g.productName}"/>
                                            </div>
                                            <div style="font-size:11px; color:#64748b; margin-top:3px">
                                                SKU: <b><c:out value="${g.sku}"/></b>
                                                <span class="sep" style="margin:0 4px">•</span>
                                                <c:choose>
                                                    <c:when test="${g.activeLotCount > 0}">
                                                        <span style="color:#0284c7; font-weight:700">${g.activeLotCount} Lô hoạt động</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:#94a3b8">Không có lô còn hàng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td style="padding:14px 16px; text-align:right; font-weight:800; font-size:14px; color:${g.totalOnHand == 0 ? '#ef4444' : '#1e293b'}">
                                    <fmt:formatNumber value="${g.totalOnHand}"/> <small style="font-weight:normal; color:#64748b">sp</small>
                                </td>
                                <td style="padding:14px 16px; text-align:right; font-weight:700; color:#2563eb">
                                    <fmt:formatNumber value="${g.reservedQty}"/>
                                </td>
                                <td style="padding:14px 16px; text-align:right; font-weight:800; font-size:15px; color:#ea580c">
                                    <fmt:formatNumber value="${g.sellableQty}"/>
                                </td>
                                <td style="padding:14px 16px; text-align:right; font-weight:700; color:${g.flashSaleQty > 0 ? '#dc2626' : '#94a3b8'}">
                                    <fmt:formatNumber value="${g.flashSaleQty}"/>
                                </td>
                                <td style="padding:14px 16px;">
                                    <c:choose>
                                        <c:when test="${g.stockStatus == 'OUT_OF_STOCK'}">
                                            <span class="pill-badge red">● Hết hàng</span>
                                        </c:when>
                                        <c:when test="${g.stockStatus == 'LOW_STOCK'}">
                                            <span class="pill-badge orange">● Tồn thấp</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge green">● Đủ hàng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="padding:14px 16px;">
                                    <c:choose>
                                        <c:when test="${g.expiryStatus == 'CRITICAL'}">
                                            <span class="pill-badge red">● Cấp bách &lt; 21 ngày</span>
                                        </c:when>
                                        <c:when test="${g.expiryStatus == 'WARNING'}">
                                            <span class="pill-badge orange">● Lô cận hạn (&lt;90d)</span>
                                        </c:when>
                                        <c:when test="${g.expiryStatus == 'SAFE'}">
                                            <span class="pill-badge green">● HSD an toàn (&ge;90d)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:#94a3b8">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="padding:14px 16px; text-align:center;">
                                    <button type="button" class="btn-lot-badge" onclick="event.stopPropagation(); toggleLotAccordion('${g.productId}')">
                                        <i class="ti ti-layers-subtract"></i> ${g.totalLotCount} Lô
                                    </button>
                                </td>
                            </tr>

                            <%-- Dòng Accordion xổ ra danh sách chi tiết các lô hàng FEFO (Detail Row) --%>
                            <tr id="detail-prod-${g.productId}" class="lot-accordion-row" style="display:none; background:#fffcf9;">
                                <td colspan="8" style="padding:0 20px 20px 20px; border-bottom:2px solid #fed7aa">
                                    <div class="lot-accordion-card">
                                        <div class="lot-accordion-head">
                                            <div style="display:flex; align-items:center; gap:8px">
                                                <i class="ti ti-route" style="color:#ea580c; font-size:20px"></i>
                                                <b style="color:#9a3412; font-size:13px; text-transform:uppercase; letter-spacing:.04em">
                                                    CHI TIẾT ${g.totalLotCount} LÔ HÀNG &amp; THỨ TỰ XUẤT KHO FEFO CỦA: <c:out value="${g.productName}"/>
                                                </b>
                                            </div>
                                            <div style="display:flex; align-items:center; gap:12px">
                                                <span style="font-size:12px; color:#c2410c; font-weight:600">
                                                    <i class="ti ti-info-circle"></i> Hệ thống đề xuất xuất kho theo FEFO: Lô có HSD gần nhất xuất trước
                                                </span>
                                                <a href="${ctx}/staff/lots/new?productId=${g.productId}" class="btn-pill-primary" style="padding:4px 14px; font-size:11px; text-decoration:none">
                                                    <i class="ti ti-plus"></i>Nhập thêm lô
                                                </a>
                                            </div>
                                        </div>

                                        <c:choose>
                                            <c:when test="${not empty g.lots}">
                                                <table class="lot-subtable" style="width:100%; border-collapse:collapse; border-radius:10px; overflow:hidden; box-shadow:0 1px 4px rgba(0,0,0,0.04)">
                                                    <thead>
                                                        <tr>
                                                            <th>MÃ LÔ</th>
                                                            <th style="text-align:right">THỰC TẾ</th>
                                                            <th style="text-align:right">GIỮ CHỖ</th>
                                                            <th style="text-align:right">KHẢ DỤNG</th>
                                                            <th>NGÀY NHẬP</th>
                                                            <th>HẠN SỬ DỤNG</th>
                                                            <th>SỐ NGÀY CÒN</th>
                                                            <th>TRẠNG THÁI LÔ</th>
                                                            <th>ƯU TIÊN FEFO</th>
                                                            <th style="text-align:right">THAO TÁC</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="lot" items="${g.lots}" varStatus="lst">
                                                            <tr>
                                                                <td><code>#LOT-${lot.id}</code></td>
                                                                <td style="text-align:right; font-weight:700">${lot.onHandQty} sp</td>
                                                                <td style="text-align:right; color:#2563eb">0</td>
                                                                <td style="text-align:right; font-weight:800; color:#ea580c">
                                                                    ${lot.level == 'OK' ? lot.onHandQty : 0} sp
                                                                </td>
                                                                <td style="color:#64748b">${lot.receivedAtText}</td>
                                                                <td style="font-weight:700; color:${lot.daysLeft < quarantineDays ? '#dc2626' : (lot.daysLeft < shelfLifeDays ? '#ea580c' : '#16a34a')}">
                                                                    ${lot.expiryDateText}
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${lot.daysLeft < 0}">
                                                                            <span class="pill-badge red">Quá hạn (${-lot.daysLeft} ngày)</span>
                                                                        </c:when>
                                                                        <c:when test="${lot.daysLeft < quarantineDays}">
                                                                            <span class="pill-badge red">Khóa bán (${lot.daysLeft} ngày)</span>
                                                                        </c:when>
                                                                        <c:when test="${lot.daysLeft < shelfLifeDays}">
                                                                            <span class="pill-badge orange">Cận hạn (${lot.daysLeft} ngày)</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="pill-badge green">Còn ${lot.daysLeft} ngày</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${lot.level == 'EXPIRED'}">
                                                                            <span class="pill-badge red"><i class="ti ti-flame"></i> Quá hạn, khóa bán</span>
                                                                        </c:when>
                                                                        <c:when test="${lot.level == 'BLOCKED'}">
                                                                            <span class="pill-badge red"><i class="ti ti-lock"></i> Khóa bán, cấm xuất</span>
                                                                        </c:when>
                                                                        <c:when test="${lot.level == 'RED'}">
                                                                            <span class="pill-badge orange"><i class="ti ti-bolt"></i> Cận hạn (Flash Sale)</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="pill-badge green"><i class="ti ti-check"></i> Đang hoạt động</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${lst.first and lot.level == 'RED'}">
                                                                            <span class="pill-badge orange" style="background:#ea580c; color:#fff; font-weight:800">
                                                                                #1 (Xuất trước - Flash Sale)
                                                                            </span>
                                                                        </c:when>
                                                                        <c:when test="${lst.first and (lot.level == 'EXPIRED' or lot.level == 'BLOCKED')}">
                                                                            <span class="pill-badge red" style="background:#dc2626; color:#fff; font-weight:800">
                                                                                #1 (Khóa bán)
                                                                            </span>
                                                                        </c:when>
                                                                        <c:when test="${lst.first}">
                                                                            <span class="pill-badge green" style="background:#16a34a; color:#fff; font-weight:800">
                                                                                #1 (Xuất trước - FEFO)
                                                                            </span>
                                                                        </c:when>
                                                                        <c:when test="${lst.index == 1}">
                                                                            <span class="pill-badge blue" style="background:#2563eb; color:#fff; font-weight:800">
                                                                                #2 (Xuất tiếp theo)
                                                                            </span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="pill-badge gray">
                                                                                #${lst.count} (Dự phòng)
                                                                            </span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td style="text-align:right">
                                                                    <div style="display:flex; justify-content:flex-end; align-items:center; gap:6px;">
                                                                        <c:choose>
                                                                            <c:when test="${lot.untouched}">
                                                                                <a href="${ctx}/staff/lots/${lot.id}/edit" class="export-btn" style="padding:4px 8px; font-size:11px; text-decoration:none;" title="Sửa lô nhập nhầm">
                                                                                    <i class="ti ti-edit"></i>
                                                                                </a>
                                                                                <form method="post" action="${ctx}/staff/lots/${lot.id}/delete" style="display:inline; margin:0;" onsubmit="return confirm('Xác nhận xoá lô hàng này?');">
                                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                                    <button type="submit" class="export-btn" style="padding:4px 8px; font-size:11px; color:#dc2626; border-color:#fecaca; cursor:pointer;" title="Xoá lô nhập nhầm">
                                                                                        <i class="ti ti-trash"></i>
                                                                                    </button>
                                                                                </form>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span style="display:inline-flex; align-items:center; gap:3px; padding:3px 8px; border-radius:6px; font-size:11px; font-weight:600; color:#94a3b8; background:#fff; border:1px solid #e2e8f0;" title="Lô đã xuất hàng (${lot.receivedQty - lot.onHandQty} sp), hệ thống khoá sửa/xoá để bảo toàn lịch sử kho">
                                                                                    <i class="ti ti-lock" style="font-size:12px;"></i>Đã xuất
                                                                                </span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </c:when>
                                            <c:otherwise>
                                                <div style="text-align:center; padding:20px; color:#94a3b8; font-size:13px">
                                                    Sản phẩm này hiện chưa có lô hàng nào trong kho. Bấm nút <b>"Nhập thêm lô"</b> ở trên để tạo lô mới.
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="8" style="text-align:center; padding:48px 20px; color:#94a3b8;">
                                <i class="ti ti-package-off" style="font-size:2.4rem; display:block; margin-bottom:8px;"></i>
                                Không tìm thấy sản phẩm nào phù hợp với bộ lọc
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</main>

<script>
    function toggleLotAccordion(productId) {
        const detailRow = document.getElementById('detail-prod-' + productId);
        const mainRow = document.getElementById('row-prod-' + productId);
        if (!detailRow || !mainRow) return;

        const isHidden = (detailRow.style.display === 'none' || detailRow.style.display === '');
        if (isHidden) {
            detailRow.style.display = 'table-row';
            mainRow.classList.add('expanded');
        } else {
            detailRow.style.display = 'none';
            mainRow.classList.remove('expanded');
        }
    }

    let allExpanded = false;
    function toggleAllAccordions() {
        allExpanded = !allExpanded;
        const detailRows = document.querySelectorAll('.lot-accordion-row');
        const mainRows = document.querySelectorAll('.prod-row');
        const textToggle = document.getElementById('text-toggle-all');

        detailRows.forEach(row => {
            row.style.display = allExpanded ? 'table-row' : 'none';
        });

        mainRows.forEach(row => {
            if (allExpanded) {
                row.classList.add('expanded');
            } else {
                row.classList.remove('expanded');
            }
        });

        if (textToggle) {
            textToggle.innerText = allExpanded ? 'Thu gọn tất cả' : 'Mở rộng tất cả';
        }
    }

    function exportExcel() {
        let csv = '\uFEFFSản phẩm,SKU,Tổng tồn,Tồn khả dụng,Flash Sale,Trạng thái tồn,Mã lô,Tồn lô,HSD,Ngày nhập\n';
        document.querySelectorAll('.prod-row').forEach(row => {
            const prodId = row.id.replace('row-prod-', '');
            const prodName = (row.querySelector('b') ? row.querySelector('b').innerText : '').replace(/"/g, '""');
            const skuEl = row.querySelector('td div div small b');
            const sku = skuEl ? skuEl.innerText : '';

            const detailRow = document.getElementById('detail-prod-' + prodId);
            if (detailRow) {
                const subRows = detailRow.querySelectorAll('.lot-subtable tbody tr');
                if (subRows && subRows.length > 0) {
                    subRows.forEach(sRow => {
                        const cols = sRow.querySelectorAll('td');
                        if (cols.length >= 6) {
                            const lotCode = cols[0].innerText.trim();
                            const onHand = cols[1].innerText.trim();
                            const hsd = cols[5].innerText.trim();
                            const ngayNhap = cols[4].innerText.trim();
                            csv += '"' + prodName + '","' + sku + '","","","","","' + lotCode + '","' + onHand + '","' + hsd + '","' + ngayNhap + '"\n';
                        }
                    });
                } else {
                    csv += '"' + prodName + '","' + sku + '","0","0","0","Hết hàng","","","",""\n';
                }
            }
        });

        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'ton_kho_fefo_' + new Date().toISOString().slice(0, 10) + '.csv';
        a.click();
        URL.revokeObjectURL(url);
    }

    // Tự động mở rộng sản phẩm nếu người dùng tìm kiếm theo mã lô (ví dụ #LOT-21 hoặc 21)
    document.addEventListener('DOMContentLoaded', function () {
        const urlParams = new URLSearchParams(window.location.search);
        const kw = (urlParams.get('keyword') || '').trim().toLowerCase();
        if (kw) {
            document.querySelectorAll('.lot-accordion-row').forEach(row => {
                const text = row.innerText.toLowerCase();
                if (text.includes(kw)) {
                    const prodId = row.id.replace('detail-prod-', '');
                    toggleLotAccordion(prodId);
                }
            });
        }
    });
</script>
</body>
</html>
