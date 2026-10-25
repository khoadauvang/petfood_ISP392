<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: productGroups, products, currentPage, totalPages, totalItems, categories, speciesList, productStatuses, filterKeyword, filterCategoryId, filterSpecies, filterStatus, filterQuery, productCounts --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý sản phẩm &amp; Biến thể · PetFood</title>
    <meta name="description" content="Quản lý danh sách sản phẩm gom nhóm theo biến thể quy cách (vd: 400g, 2kg), giá niêm yết và trạng thái kinh doanh.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .prod-group-row {
            cursor: pointer;
            transition: background var(--transition);
        }
        .prod-group-row:hover {
            background: #fff8f1 !important;
        }
        .prod-group-row.expanded {
            background: #fff4ea !important;
            border-bottom-color: transparent !important;
        }
        .chev-icon {
            display: inline-block;
            transition: transform 0.2s ease;
            font-size: 16px;
            color: #94a3b8;
        }
        .prod-group-row.expanded .chev-icon {
            transform: rotate(90deg);
            color: #ea580c;
        }
        .prod-thumb {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            object-fit: contain;
            background: #ffffff;
            border: 1px solid var(--line);
            padding: 2px;
            flex-shrink: 0;
        }
        .btn-variant-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            background: #fff7ee;
            border: 1px solid #fed7aa;
            color: #ea580c;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-variant-badge:hover, .prod-group-row.expanded .btn-variant-badge {
            background: #ea580c;
            color: #ffffff;
            border-color: #ea580c;
        }
        .variant-accordion-card {
            background: #ffffff;
            border: 1px solid #fed7aa;
            border-radius: 12px;
            padding: 16px 20px;
            margin: 6px 0 12px 0;
            box-shadow: 0 4px 12px rgba(234, 88, 12, 0.06);
        }
        .variant-accordion-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
            padding-bottom: 10px;
            border-bottom: 1px dashed #fed7aa;
        }
        .variant-subtable {
            width: 100%;
            border-collapse: collapse;
        }
        .variant-subtable th {
            background: #fbf7f2;
            padding: 10px 14px;
            font-size: 11px;
            font-weight: 800;
            color: #78350f;
            text-transform: uppercase;
            letter-spacing: .04em;
            border-bottom: 1px solid #fed7aa;
            text-align: left;
        }
        .variant-subtable td {
            padding: 12px 14px;
            font-size: 13px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
            background: #ffffff;
        }
        .variant-subtable tr:last-child td {
            border-bottom: none;
        }
        .variant-subtable tr:hover td {
            background: #fffcf8;
        }
        @keyframes spin { 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <span class="current">QUẢN LÝ SẢN PHẨM &amp; BIẾN THỂ</span>
            </div>
            <h1>QUẢN LÝ SẢN PHẨM &amp; BIẾN THỂ</h1>
            <p class="page-sub">Các biến thể quy cách (vd: 400g, 2kg) được gom nhóm chung theo từng dòng sản phẩm. Bấm vào dòng để xem chi tiết từng biến thể.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <button type="button" class="btn-pill-outline" onclick="toggleAllAccordions()" id="btn-toggle-all">
                <i class="ti ti-arrows-vertical"></i><span id="text-toggle-all">Mở rộng tất cả</span>
            </button>
            <a href="javascript:void(0)" class="btn-pill-outline" onclick="exportExcel()"><i class="ti ti-file-spreadsheet"></i>Xuất Excel</a>
            <a href="${ctx}/staff/products/new" class="btn-flashsale">
                <i class="ti ti-plus"></i>Thêm sản phẩm mới
            </a>
        </div>
    </div>

    <%-- 3 KPI Cards Screen 3 (Số liệu tính toán thực tế từ hệ thống) --%>
    <section class="grid" style="grid-template-columns: repeat(3, minmax(0, 1fr)); margin-bottom: 20px">
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">TỔNG SỐ BIẾN THỂ (SKU)</span>
                <span class="kpi-ico orange"><i class="ti ti-package"></i></span>
            </div>
            <div class="kpi-value">
                ${productCounts.total != null ? productCounts.total : (totalItems != null ? totalItems : 0)} <small>mã SKU</small>
            </div>
            <div class="kpi-meta"><span class="badge orange">Gồm <b>${productGroups != null ? productGroups.size() : 0}</b> dòng sản phẩm chính</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">ĐANG KINH DOANH</span>
                <span class="kpi-ico green"><i class="ti ti-check"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">
                ${productCounts.active != null ? productCounts.active : 0} <small>biến thể</small>
            </div>
            <div class="kpi-meta"><span class="badge ok">Đang mở bán trên hệ thống</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">TẠM NGỪNG KINH DOANH</span>
                <span class="kpi-ico gray"><i class="ti ti-player-pause"></i></span>
            </div>
            <div class="kpi-value" style="color:#6b7280">
                ${productCounts.discontinued != null ? productCounts.discontinued : 0} <small>biến thể</small>
            </div>
            <div class="kpi-meta"><span class="badge gray">Tạm ngưng hoặc lưu trữ</span></div>
        </div>
    </section>

    <%-- Filter Bar Screen 3 --%>
    <form method="get" action="${ctx}/staff/products" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:260px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="text" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo tên sản phẩm, biến thể, mã SKU hoặc mã vạch (EAN)..."
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="categoryId" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" ${cat.id == filterCategoryId ? 'selected' : ''}><c:out value="${cat.name}"/></option>
            </c:forEach>
        </select>

        <select name="species" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả thú cưng</option>
            <c:forEach var="sp" items="${speciesList}">
                <option value="${sp}" ${sp == filterSpecies ? 'selected' : ''}>${sp.label}</option>
            </c:forEach>
        </select>

        <select name="status" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="st" items="${productStatuses}">
                <option value="${st}" ${st == filterStatus ? 'selected' : ''}>${st.label}</option>
            </c:forEach>
        </select>

        <button type="submit" class="btn-pill-primary"><i class="ti ti-filter"></i>Lọc</button>
        <a href="${ctx}/staff/products" class="act-icon" title="Đặt lại bộ lọc"><i class="ti ti-rotate"></i></a>
    </form>

    <%-- BẢNG SẢN PHẨM & BIẾN THỂ (Master-Detail Accordion) --%>
    <div class="panel" style="padding:0; overflow:hidden; margin-top:16px; border-radius:14px; border:1px solid var(--line);">
        <div class="split-head" style="padding:16px 20px; background:#fff; border-bottom:1px solid var(--line); display:flex; justify-content:space-between; align-items:center">
            <div>
                <h3 style="margin:0; font-size:15px; font-weight:800; color:var(--text-logo)">
                    <i class="ti ti-packages" style="color:var(--color-primary)"></i> DANH SÁCH DÒNG SẢN PHẨM
                </h3>
                <small style="color:var(--text-muted)">Nhấp vào dòng sản phẩm để mở rộng chi tiết các biến thể quy cách (vd: 400g, 2kg)</small>
            </div>
            <div style="font-size:13px; color:var(--text-muted)">
                Hiển thị: <b>${productGroups != null ? productGroups.size() : 0}</b> dòng sản phẩm (${totalItems != null ? totalItems : 0} biến thể)
            </div>
        </div>

        <table style="margin:0; width:100%; border-collapse:collapse; border:0; box-shadow:none">
            <thead>
            <tr style="background:#f8fafc; border-bottom:1px solid #e2e8f0; font-size:11px; font-weight:800; color:#64748b; text-align:left; letter-spacing:.04em; text-transform:uppercase;">
                <th style="padding:14px 16px; width:64px; text-align:center;">ẢNH</th>
                <th style="padding:14px 16px; min-width:260px">TÊN DÒNG SẢN PHẨM &amp; BIẾN THỂ</th>
                <th style="padding:14px 16px;">MÃ SKU GỐC</th>
                <th style="padding:14px 16px;">DANH MỤC</th>
                <th style="padding:14px 16px;">THÚ CƯNG</th>
                <th style="padding:14px 16px; text-align:right;" class="num">GIÁ NIÊM YẾT</th>
                <th style="padding:14px 16px; min-width:160px">TRẠNG THÁI</th>
                <th style="padding:14px 16px; text-align:center; min-width:210px">THAO TÁC / BIẾN THỂ</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${not empty productGroups}">
                    <c:forEach var="g" items="${productGroups}">
                        <%-- Dòng Sản phẩm chính (Master Row) --%>
                        <tr class="prod-group-row" id="row-${g.groupId}" onclick="toggleProductAccordion('${g.groupId}')" style="border-bottom:1px solid #f1f5f9; font-size:13px;">
                            <td style="padding:14px 16px; text-align:center;">
                                <div style="position:relative; width:48px; height:48px; margin:0 auto;">
                                    <c:choose>
                                        <c:when test="${not empty g.imageUrl}">
                                            <img src="${ctx}<c:out value='${g.imageUrl}'/>" alt="" class="prod-thumb"
                                                 onerror="this.src='https://placehold.co/48x48?text=Pet'">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="prod-thumb" style="display:grid; place-items:center; color:#9ca3af; font-size:20px">
                                                <i class="ti ti-photo"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${g.variantCount > 1}">
                                        <span style="position:absolute; bottom:-4px; right:-4px; background:#ea580c; color:#fff; font-size:10px; font-weight:800; padding:1px 5px; border-radius:10px; border:2px solid #fff;">
                                            ${g.variantCount}
                                        </span>
                                    </c:if>
                                </div>
                            </td>
                            <td style="padding:14px 16px;">
                                <div style="display:flex; align-items:center; gap:10px">
                                    <i class="ti ti-chevron-right chev-icon" id="chev-${g.groupId}"></i>
                                    <div>
                                        <div style="font-weight:800; color:var(--text-logo); font-size:14px; line-height:1.3">
                                            <c:out value="${g.baseName}"/>
                                        </div>
                                        <div style="font-size:12px; color:#64748b; margin-top:3px; display:flex; align-items:center; gap:6px; flex-wrap:wrap">
                                            <span><c:out value="${empty g.brand ? 'PetCare' : g.brand}"/></span>
                                            <span class="sep">•</span>
                                            <span style="color:#0284c7; font-weight:700">
                                                <i class="ti ti-layers-subtract" style="font-size:12px"></i> ${g.variantCount} biến thể (${g.specsSummary})
                                            </span>
                                            <c:if test="${g.anyLowStock}">
                                                <span class="pill-badge red" style="font-size:11px; padding:1px 6px">Cảnh báo tồn thấp</span>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td style="padding:14px 16px;">
                                <code style="font-size:12px; font-weight:700; background:#f3f4f6; padding:3px 8px; border-radius:6px; color:#334155">
                                    <c:out value="${g.baseSku}"/>
                                </code>
                            </td>
                            <td style="padding:14px 16px;">
                                <span style="font-weight:600; color:#334155"><c:out value="${g.categoryName}"/></span>
                            </td>
                            <td style="padding:14px 16px;">
                                <c:choose>
                                    <c:when test="${g.species == 'DOG'}"><span class="pill-badge orange">🐶 Chó</span></c:when>
                                    <c:when test="${g.species == 'CAT'}"><span class="pill-badge red">🐱 Mèo</span></c:when>
                                    <c:otherwise><span class="pill-badge gold">🐶🐱 Chó &amp; Mèo</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding:14px 16px;" class="num">
                                <b style="font-size:14px; color:var(--text-logo)">
                                    <c:choose>
                                        <c:when test="${g.singlePrice}">
                                            <fmt:formatNumber value="${g.minPrice}"/>₫
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${g.minPrice}"/>₫ ~ <fmt:formatNumber value="${g.maxPrice}"/>₫
                                        </c:otherwise>
                                    </c:choose>
                                </b>
                            </td>
                            <td style="padding:14px 16px;">
                                <c:choose>
                                    <c:when test="${g.discontinuedCount == 0}">
                                        <span class="pill-badge green">● Đang kinh doanh (${g.activeCount}/${g.variantCount})</span>
                                    </c:when>
                                    <c:when test="${g.activeCount > 0}">
                                        <span class="pill-badge orange">● ${g.activeCount} bán, ${g.discontinuedCount} ngưng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pill-badge gray">● Ngừng kinh doanh</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding:14px 16px; text-align:center;" onclick="event.stopPropagation()">
                                <div style="display:inline-flex; align-items:center; justify-content:center; gap:6px;">
                                    <%-- Nút mở/thu gọn biến thể quy cách --%>
                                    <button type="button" class="btn-variant-badge" onclick="toggleProductAccordion('${g.groupId}')" title="Nhấp để xem/ẩn chi tiết ${g.variantCount} biến thể">
                                        <i class="ti ti-layers-subtract"></i> ${g.variantCount} Biến thể
                                    </button>

                                    <%-- Các thao tác cho cả dòng sản phẩm (cả N biến thể) --%>
                                    <div class="action-icons" style="display:inline-flex; align-items:center; gap:4px;">
                                        <c:if test="${g.activeCount > 0}">
                                            <button type="button" class="act-icon" style="color:#d97706; background:#fffbeb; border:1px solid #fed7aa; width:30px; height:30px; border-radius:8px; display:grid; place-items:center; cursor:pointer;"
                                                    onclick="batchToggleGroupStatus('${g.groupId}', 'DISCONTINUED', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},status:'${v.status}',sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])"
                                                    title="Tạm ngưng bán cả ${g.variantCount} biến thể">
                                                <i class="ti ti-player-pause" style="font-size:15px;"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${g.discontinuedCount > 0}">
                                            <button type="button" class="act-icon" style="color:#16a34a; background:#f0fdf4; border:1px solid #bbf7d0; width:30px; height:30px; border-radius:8px; display:grid; place-items:center; cursor:pointer;"
                                                    onclick="batchToggleGroupStatus('${g.groupId}', 'ACTIVE', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},status:'${v.status}',sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])"
                                                    title="Kích hoạt bán lại cả ${g.variantCount} biến thể">
                                                <i class="ti ti-player-play" style="font-size:15px;"></i>
                                            </button>
                                        </c:if>
                                        <button type="button" class="act-icon danger" style="width:30px; height:30px; border-radius:8px; display:grid; place-items:center; cursor:pointer;"
                                                onclick="batchDeleteGroup('${g.groupId}', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])"
                                                title="Xóa toàn bộ dòng sản phẩm (${g.variantCount} biến thể)">
                                            <i class="ti ti-trash" style="font-size:15px;"></i>
                                        </button>
                                    </div>
                                </div>
                            </td>
                        </tr>

                        <%-- Dòng Accordion xổ ra danh sách chi tiết các biến thể (Detail Row) --%>
                        <tr id="detail-${g.groupId}" class="variant-accordion-row" style="display:none; background:#fffcf9;">
                            <td colspan="8" style="padding:0 20px 20px 20px; border-bottom:2px solid #fed7aa">
                                <div class="variant-accordion-card">
                                    <div class="variant-accordion-head">
                                        <div style="display:flex; align-items:center; gap:8px">
                                            <i class="ti ti-box" style="color:#ea580c; font-size:20px"></i>
                                            <b style="color:#9a3412; font-size:13px; text-transform:uppercase; letter-spacing:.04em">
                                                CHI TIẾT ${g.variantCount} BIẾN THỂ CỦA: <c:out value="${g.baseName}"/>
                                            </b>
                                        </div>
                                        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap">
                                            <span style="font-size:12px; color:#c2410c; font-weight:600">
                                                <i class="ti ti-info-circle"></i> Tổng tồn: <b>${g.totalOnHand}</b> sp (Bán: <b>${g.totalSellable}</b> sp)
                                            </span>
                                            <c:if test="${g.activeCount > 0}">
                                                <button type="button" class="btn-pill-secondary" style="padding:4px 10px; font-size:11px; border:1px solid #fed7aa; color:#c2410c; background:#fff7ed; cursor:pointer; border-radius:8px; font-weight:700; display:inline-flex; align-items:center; gap:4px;"
                                                        onclick="batchToggleGroupStatus('${g.groupId}', 'DISCONTINUED', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},status:'${v.status}',sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])">
                                                    <i class="ti ti-player-pause"></i> Tạm ngưng bán cả dòng
                                                </button>
                                            </c:if>
                                            <c:if test="${g.discontinuedCount > 0}">
                                                <button type="button" class="btn-pill-secondary" style="padding:4px 10px; font-size:11px; border:1px solid #bbf7d0; color:#15803d; background:#f0fdf4; cursor:pointer; border-radius:8px; font-weight:700; display:inline-flex; align-items:center; gap:4px;"
                                                        onclick="batchToggleGroupStatus('${g.groupId}', 'ACTIVE', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},status:'${v.status}',sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])">
                                                    <i class="ti ti-player-play"></i> Kích hoạt bán cả dòng
                                                </button>
                                            </c:if>
                                            <button type="button" class="btn-pill-secondary" style="padding:4px 10px; font-size:11px; border:1px solid #fecaca; color:#dc2626; background:#fef2f2; cursor:pointer; border-radius:8px; font-weight:700; display:inline-flex; align-items:center; gap:4px;"
                                                    onclick="batchDeleteGroup('${g.groupId}', '<c:out value="${g.baseName}"/>', [<c:forEach var='v' items='${g.variants}' varStatus='vs'>{id:${v.id},sku:'${v.sku}'}<c:if test='${!vs.last}'>,</c:if></c:forEach>])">
                                                <i class="ti ti-trash"></i> Xóa cả dòng sản phẩm
                                            </button>
                                            <a href="${ctx}/staff/products/new?variantOf=${g.variants[0].id}" class="btn-pill-primary" style="padding:4px 14px; font-size:11px; text-decoration:none" title="Thêm quy cách mới cho dòng sản phẩm này">
                                                <i class="ti ti-plus"></i>Thêm biến thể mới
                                            </a>
                                        </div>
                                    </div>

                                    <table class="variant-subtable">
                                        <thead>
                                            <tr>
                                                <th style="width:110px">QUY CÁCH</th>
                                                <th>TÊN BIẾN THỂ &amp; SKU</th>
                                                <th>MÃ VẠCH (EAN)</th>
                                                <th class="num">GIÁ NIÊM YẾT</th>
                                                <th style="text-align:right">TỒN THỰC</th>
                                                <th style="text-align:right">KHẢ DỤNG</th>
                                                <th>TRẠNG THÁI</th>
                                                <th style="text-align:right; width:140px">THAO TÁC</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="v" items="${g.variants}">
                                                <tr>
                                                    <td>
                                                        <span class="pill-badge orange" style="font-weight:800; font-size:12px; background:#ffedd5; color:#c2410c; border:1px solid #fed7aa">
                                                            <i class="ti ti-scale"></i> <c:out value="${v.spec}"/>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <a href="${ctx}/staff/products/${v.id}" style="font-weight:800; color:var(--text-logo); text-decoration:none" title="Xem chi tiết biến thể">
                                                            <c:out value="${v.name}"/>
                                                        </a>
                                                        <div style="font-size:11px; color:#64748b; margin-top:2px">
                                                            SKU: <code style="font-size:11px; background:#f1f5f9; padding:1px 5px; border-radius:4px"><c:out value="${v.sku}"/></code>
                                                            <c:if test="${v.lowStock}">
                                                                <span class="pill-badge red" style="font-size:10px; margin-left:6px">Tồn thấp: ${v.sellableQty} sp</span>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty v.barcode}">
                                                                <span style="font-family:monospace; font-size:12px; color:#475569"><c:out value="${v.barcode}"/></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#94a3b8">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="num">
                                                        <b style="font-size:13px; color:${v.status == 'ACTIVE' ? 'var(--text-logo)' : '#9ca3af'}">
                                                            <fmt:formatNumber value="${v.sellingPrice}" type="number"/>₫
                                                        </b>
                                                    </td>
                                                    <td style="text-align:right; font-weight:700">
                                                        <fmt:formatNumber value="${v.onHandQty}"/> <small style="color:#64748b">sp</small>
                                                    </td>
                                                    <td style="text-align:right; font-weight:800; color:#ea580c">
                                                        <fmt:formatNumber value="${v.sellableQty}"/> <small style="color:#64748b">sp</small>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${v.status == 'ACTIVE'}">
                                                                <span class="pill-badge green">● Đang bán</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="pill-badge gray">● Ngừng bán</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align:right">
                                                        <div class="action-icons" style="justify-content:flex-end">
                                                            <a href="${ctx}/staff/lots?keyword=${v.sku}" class="act-icon" title="Xem danh sách lô hàng của biến thể"><i class="ti ti-building-warehouse"></i></a>
                                                            <a href="${ctx}/staff/products/${v.id}/edit" class="act-icon" title="Chỉnh sửa biến thể"><i class="ti ti-edit"></i></a>
                                                            <form method="post" action="${ctx}/staff/products/${v.id}/toggle-status" style="display:inline">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                <input type="hidden" name="from" value="list">
                                                                <button type="submit" class="act-icon" title="${v.status == 'ACTIVE' ? 'Tạm dừng bán' : 'Kích hoạt bán'}" style="padding:0">
                                                                    <i class="ti ${v.status == 'ACTIVE' ? 'ti-player-pause' : 'ti-player-play'}"></i>
                                                                </button>
                                                            </form>
                                                            <form method="post" action="${ctx}/staff/products/${v.id}/delete" style="display:inline" onsubmit="return confirm('Xác nhận xóa biến thể này?');">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                <button type="submit" class="act-icon danger" title="Xóa biến thể" style="padding:0">
                                                                    <i class="ti ti-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="8">
                            <div class="empty-state" style="text-align:center; padding:45px 20px; color:var(--text-muted)">
                                <i class="ti ti-package-off" style="font-size:36px; display:block; margin-bottom:10px; opacity:0.5"></i>
                                <b>Không tìm thấy sản phẩm nào</b>
                                <p style="font-size:13px; margin-top:4px">Thử thay đổi từ khóa hoặc bộ lọc tìm kiếm.</p>
                            </div>
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <%-- Pagination Screen 3 --%>
        <div class="panel-foot" style="padding:14px 20px; background:#fff; border-top:1px solid var(--line); display:flex; justify-content:space-between; align-items:center">
            <span>Hiển thị <b>${productGroups != null ? productGroups.size() : 0}</b> dòng sản phẩm (Tổng cộng <b>${totalItems != null ? totalItems : 0}</b> biến thể SKU)</span>
            <div style="display:flex; align-items:center; gap:12px">
                <div class="pager" style="margin:0">
                    <c:if test="${totalPages > 1}">
                        <c:if test="${currentPage > 1}"><a href="?${filterQuery}&page=${currentPage - 1}">‹</a></c:if>
                        <c:forEach begin="1" end="${totalPages}" var="n">
                            <c:choose>
                                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                                <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}"><a href="?${filterQuery}&page=${currentPage + 1}">›</a></c:if>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    // Bật/tắt accordion cho từng dòng sản phẩm
    function toggleProductAccordion(groupId) {
        const detailRow = document.getElementById('detail-' + groupId);
        const masterRow = document.getElementById('row-' + groupId);
        if (!detailRow || !masterRow) return;

        const isHidden = detailRow.style.display === 'none' || detailRow.style.display === '';
        if (isHidden) {
            detailRow.style.display = 'table-row';
            masterRow.classList.add('expanded');
        } else {
            detailRow.style.display = 'none';
            masterRow.classList.remove('expanded');
        }
        updateToggleAllButtonText();
    }

    // Mở rộng tất cả hoặc Thu gọn tất cả
    let allExpanded = false;
    function toggleAllAccordions() {
        allExpanded = !allExpanded;
        const detailRows = document.querySelectorAll('.variant-accordion-row');
        const masterRows = document.querySelectorAll('.prod-group-row');

        detailRows.forEach(row => {
            row.style.display = allExpanded ? 'table-row' : 'none';
        });
        masterRows.forEach(row => {
            if (allExpanded) row.classList.add('expanded');
            else row.classList.remove('expanded');
        });

        updateToggleAllButtonText();
    }

    function updateToggleAllButtonText() {
        const detailRows = document.querySelectorAll('.variant-accordion-row');
        let countOpen = 0;
        detailRows.forEach(r => {
            if (r.style.display === 'table-row') countOpen++;
        });

        const btnText = document.getElementById('text-toggle-all');
        if (!btnText) return;

        if (countOpen === detailRows.length && detailRows.length > 0) {
            allExpanded = true;
            btnText.textContent = 'Thu gọn tất cả';
        } else {
            allExpanded = false;
            btnText.textContent = 'Mở rộng tất cả';
        }
    }

    // Tự động mở rộng nếu đang tìm kiếm từ khóa
    document.addEventListener('DOMContentLoaded', () => {
        const searchInput = document.querySelector('input[name="keyword"]');
        if (searchInput && searchInput.value.trim().length > 0) {
            toggleAllAccordions();
        }
    });

    // Xuất file CSV/Excel đơn giản cho biến thể
    function exportExcel() {
        const rows = [];
        rows.push(["Dòng sản phẩm", "Quy cách", "Mã SKU", "Mã vạch", "Giá bán (VND)", "Tồn thực", "Tồn bán", "Trạng thái"]);

        <c:forEach var="g" items="${productGroups}">
            <c:forEach var="v" items="${g.variants}">
                rows.push([
                    "${g.baseName}",
                    "${v.spec}",
                    "${v.sku}",
                    "${not empty v.barcode ? v.barcode : ''}",
                    "${v.sellingPrice}",
                    "${v.onHandQty}",
                    "${v.sellableQty}",
                    "${v.status}"
                ]);
            </c:forEach>
        </c:forEach>

        if (rows.length <= 1) {
            alert("Không có dữ liệu sản phẩm để xuất.");
            return;
        }

        let csvContent = "data:text/csv;charset=utf-8,\uFEFF";
        rows.forEach(rowArray => {
            let row = rowArray.map(item => '"' + (item ? (item + '').replace(/"/g, '""') : '') + '"').join(",");
            csvContent += row + "\r\n";
        });

        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "Danh_Sach_San_Pham_Bien_The_" + new Date().toISOString().slice(0, 10) + ".csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    // ========================================================
    // THAO TÁC HÀNG LOẠT CHO TOÀN BỘ BIẾN THỂ CỦA DÒNG SẢN PHẨM
    // ========================================================
    async function batchToggleGroupStatus(groupId, targetStatus, productName, variants) {
        const isPause = (targetStatus === 'DISCONTINUED');
        const actionVerb = isPause ? 'TẠM NGƯNG BÁN' : 'KÍCH HOẠT BÁN LẠI';

        // Lọc các biến thể cần đổi trạng thái
        const toChange = variants.filter(v => isPause ? (v.status === 'ACTIVE') : (v.status !== 'ACTIVE'));

        if (toChange.length === 0) {
            alert('Tất cả các biến thể của "' + productName + '" hiện đã ở trạng thái ' + (isPause ? 'ngừng bán' : 'đang kinh doanh') + '!');
            return;
        }

        const msg = 'Xác nhận ' + actionVerb + ' cho tất cả ' + toChange.length + ' biến thể của dòng sản phẩm:\n\n' +
                    '👉 ' + productName + '\n\n' +
                    'Các biến thể sẽ cập nhật: ' + toChange.map(v => v.sku).join(', ');

        if (!confirm(msg)) return;

        // Tạo overlay loading
        const overlay = document.createElement('div');
        overlay.style.cssText = 'position:fixed; inset:0; background:rgba(0,0,0,0.35); z-index:99999; display:grid; place-items:center; color:#fff; font-size:16px; font-weight:700;';
        overlay.innerHTML = '<div style="background:#fff; color:#1e293b; padding:20px 30px; border-radius:12px; box-shadow:0 10px 25px rgba(0,0,0,0.2); display:flex; align-items:center; gap:12px;"><i class="ti ti-loader" style="font-size:24px; animation:spin 1s linear infinite; color:#ea580c;"></i> Đang cập nhật trạng thái ' + toChange.length + ' biến thể...</div>';
        document.body.appendChild(overlay);

        try {
            for (const v of toChange) {
                const formData = new FormData();
                formData.append('${_csrf.parameterName}', '${_csrf.token}');
                formData.append('from', 'list');
                await fetch('${ctx}/staff/products/' + v.id + '/toggle-status', {
                    method: 'POST',
                    body: formData
                });
            }
            window.location.reload();
        } catch (e) {
            alert('Lỗi khi thực hiện thao tác: ' + e.message);
            if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        }
    }

    async function batchDeleteGroup(groupId, productName, variants) {
        const msg = '⚠️ BẠN CÓ CHẮC CHẮN MUỐN XÓA TOÀN BỘ DÒNG SẢN PHẨM NÀY?\n\n' +
                    'Tên sản phẩm: "' + productName + '"\n' +
                    'Gồm ' + variants.length + ' biến thể: ' + variants.map(v => v.sku).join(', ') + '\n\n' +
                    'LƯU Ý QUAN TRỌNG: Chỉ những biến thể chưa từng nhập lô hàng hoặc phát sinh đơn hàng mới được phép xóa (theo quy tắc BR-11). Nếu sản phẩm đã phát sinh lô hàng, hệ thống sẽ yêu cầu chuyển sang Tạm ngưng bán.';

        if (!confirm(msg)) return;

        const overlay = document.createElement('div');
        overlay.style.cssText = 'position:fixed; inset:0; background:rgba(0,0,0,0.35); z-index:99999; display:grid; place-items:center; color:#fff; font-size:16px; font-weight:700;';
        overlay.innerHTML = '<div style="background:#fff; color:#1e293b; padding:20px 30px; border-radius:12px; box-shadow:0 10px 25px rgba(0,0,0,0.2); display:flex; align-items:center; gap:12px;"><i class="ti ti-loader" style="font-size:24px; animation:spin 1s linear infinite; color:#ef4444;"></i> Đang tiến hành xóa ' + variants.length + ' biến thể...</div>';
        document.body.appendChild(overlay);

        try {
            let errorMsg = null;
            for (const v of variants) {
                const formData = new FormData();
                formData.append('${_csrf.parameterName}', '${_csrf.token}');
                const resp = await fetch('${ctx}/staff/products/' + v.id + '/delete', {
                    method: 'POST',
                    body: formData
                });
                if (resp.url && resp.url.includes('/staff/products/' + v.id)) {
                    errorMsg = 'Sản phẩm "' + productName + '" (SKU: ' + v.sku + ') đã có lô hàng hoặc đơn hàng trong hệ thống nên không thể xóa (BR-11).\n\nHãy chọn "Tạm ngưng bán cả dòng" để ẩn khỏi gian hàng!';
                    break;
                }
            }
            if (errorMsg) {
                alert(errorMsg);
                if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
                return;
            }
            window.location.reload();
        } catch (e) {
            alert('Lỗi khi xóa: ' + e.message);
            if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        }
    }
</script>
</body>
</html>
