<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: productGroups, products, currentPage, totalPages, totalItems, categories, speciesList, productStatuses, stockStatuses, filterKeyword, filterCategoryId, filterSpecies, filterStatus, filterStockStatus, filterQuery --%>
<%-- Trang này gộp luôn bảng tồn kho cũ. Bảng biến thể (theo FE): Quy cách / Tên biến thể / Giá niêm yết / Số lượng / Flash Sale / Trạng thái / Thao tác.
     Số lượng (giá thường) = sellableQty, kèm nhãn Gần hết hàng / Chỉ còn hàng Flash Sale / Hết hàng; Flash Sale = hàng cận hạn chỉ bán qua Flash Sale.
     Không hiện hạn sử dụng, lô hay chữ "tồn", "kho" trên giao diện (dữ liệu bên dưới vẫn tính theo lô). --%>
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
            background: #fffcf9 !important;
        }
        .prod-group-row.expanded {
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
        .prod-group-row.expanded .chev-icon {
            transform: rotate(90deg);
            color: var(--color-primary);
        }
        .variant-accordion-card {
            background: #fffaf5;
            border: 1px solid #ffd8b8;
            border-radius: 14px;
            padding: 16px 20px;
            margin: 6px 0 14px;
            box-shadow: 0 4px 16px rgba(249, 115, 22, 0.05);
        }
        .variant-accordion-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding-bottom: 12px;
            margin-bottom: 12px;
            border-bottom: 1px dashed #fed7aa;
            flex-wrap: wrap;
        }
        .variant-subtable {
            width: 100%;
            border-collapse: collapse;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .variant-subtable th {
            background: #fff0e2 !important;
            color: #9a3412 !important;
            font-size: 11px !important;
            font-weight: 800 !important;
            text-transform: uppercase !important;
            padding: 9px 12px !important;
            border-bottom: 1px solid #ffd8b8 !important;
            white-space: nowrap;
            text-align: left;
            letter-spacing: .04em;
        }
        .variant-subtable th.num,
        .variant-subtable td.num {
            text-align: right !important;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }
        .variant-subtable td {
            background: #ffffff !important;
            padding: 10px 12px !important;
            font-size: 12px !important;
            border-bottom: 1px solid #f8ede3 !important;
            vertical-align: middle;
        }
        .variant-subtable tr:last-child td {
            border-bottom: 0 !important;
        }
        .variant-subtable tr:hover td {
            background: #fff9f4 !important;
        }
        .btn-variant-badge {
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
        .btn-variant-badge:hover, .prod-group-row.expanded .btn-variant-badge {
            background: #ea580c;
            color: #ffffff;
            border-color: #ea580c;
        }
        .btn-add-stock {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            height: 32px;
            padding: 0 11px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #059669;
            cursor: pointer;
            transition: all 0.15s ease;
            white-space: nowrap;
        }
        .btn-add-stock:hover {
            background: #059669;
            color: #ffffff;
            border-color: #059669;
            box-shadow: 0 3px 8px rgba(5, 150, 105, 0.22);
        }
        .stock-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(2px);
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 16px;
        }
        .stock-modal-backdrop.open {
            display: flex;
        }
        .stock-modal-card {
            background: #ffffff;
            width: 100%;
            max-width: 520px;
            border-radius: 16px;
            box-shadow: 0 20px 45px rgba(15, 23, 42, 0.22);
            border: 1px solid #e2e8f0;
            overflow: hidden;
            animation: modalPop 0.18s ease-out;
        }
        @keyframes modalPop {
            from { opacity: 0; transform: translateY(10px) scale(0.98); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .preset-chip {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 11.5px;
            font-weight: 700;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #334155;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .preset-chip:hover {
            background: #fff7ed;
            border-color: #fdba74;
            color: #ea580c;
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
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <span class="current"></span>
            </div>
            <h1>QUẢN LÝ SẢN PHẨM</h1>
            <%--            <p class="page-sub">Các biến thể quy cách (vd: 400g, 2kg) được gom nhóm chung theo từng dòng sản phẩm. Bấm vào dòng để xem chi tiết từng biến thể.</p>--%>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <button type="button" class="btn-pill-outline" onclick="toggleAllAccordions()" id="btn-toggle-all">
                <i class="ti ti-arrows-vertical"></i><span id="text-toggle-all">Mở rộng tất cả</span>
            </button>
            <a href="${ctx}/staff/products/new" class="btn-flashsale">
                <i class="ti ti-plus"></i>Thêm sản phẩm mới
            </a>
        </div>
    </div>

    <%-- Filter Bar Screen 3 --%>
    <form method="get" action="${ctx}/staff/products" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:260px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="text" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo tên sản phẩm, biến thể, hoặc mã sản phẩm..."
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

        <%-- Lọc theo tình trạng hàng: Còn hàng / Gần hết hàng / Hết hàng (tính theo số lượng có thể bán) --%>
        <select name="stockStatus" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả tình trạng hàng</option>
            <c:forEach var="ss" items="${stockStatuses}">
                <option value="${ss}" ${ss == filterStockStatus ? 'selected' : ''}>${ss.label}</option>
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
                    <i class="ti ti-packages" style="color:var(--color-primary)"></i> DANH SÁCH SẢN PHẨM
                </h3>
                <%--                <small style="color:var(--text-muted)">Nhấp vào dòng sản phẩm để mở rộng chi tiết các biến thể quy cách (vd: 400g, 2kg)</small>--%>
            </div>
            <div style="font-size:13px; color:var(--text-muted)">
                Hiển thị: <b>${productGroups != null ? productGroups.size() : 0}</b> sản phẩm (${totalItems != null ? totalItems : 0} biến thể)
            </div>
        </div>

        <table style="margin:0; width:100%; border-collapse:collapse; border:0; box-shadow:none">
            <thead>
            <%-- white-space:nowrap: tiêu đề cột không xuống hàng, cột tên sản phẩm co lại nhường chỗ --%>
            <tr style="background:#f8fafc; border-bottom:1px solid #e2e8f0; font-size:11px; font-weight:800; color:#64748b; text-align:left; letter-spacing:.04em; text-transform:uppercase; white-space:nowrap;">
                <th style="padding:14px 16px; width:64px; text-align:center;">ẢNH</th>
                <th style="padding:14px 16px; min-width:260px">TÊN SẢN PHẨM &amp; BIẾN THỂ</th>
                <th style="padding:14px 16px;">MÃ SẢN PHẨM</th>
                <th style="padding:14px 16px; text-align:right;" class="num">GIÁ NIÊM YẾT</th>
                <th style="padding:14px 16px; text-align:right;" title="Tổng số lượng bán giá thường của các biến thể">SỐ LƯỢNG (GIÁ THƯỜNG)</th>
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
                                            <span style="font-weight:600; color:#475569"><c:out value="${empty g.brand ? 'PetCare' : g.brand}"/></span>
                                            <span class="sep">•</span>
                                            <span style="font-weight:600; color:#475569"><c:out value="${g.categoryName}"/></span>
                                            <span class="sep">•</span>
                                            <c:choose>
                                                <c:when test="${g.species == 'DOG'}">
                                                    <span class="pill-badge orange" style="font-size:11px; padding:1px 6px"><i class="ti ti-dog"></i> Chó</span>
                                                </c:when>
                                                <c:when test="${g.species == 'CAT'}">
                                                    <span class="pill-badge purple" style="font-size:11px; padding:1px 6px"><i class="ti ti-cat"></i> Mèo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill-badge blue" style="font-size:11px; padding:1px 6px"><i class="ti ti-paw"></i> Chó &amp; Mèo</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="sep">•</span>
                                            <span style="color:#0284c7; font-weight:700">
                                                <i class="ti ti-layers-subtract" style="font-size:12px"></i> ${g.variantCount} biến thể (${g.specsSummary})
                                            </span>
                                            <c:if test="${g.anyOutOfStock}">
                                                <span class="pill-badge red" style="font-size:11px; padding:1px 6px">Có biến thể hết hàng</span>
                                            </c:if>
                                            <c:if test="${g.anyFlashSaleOnly}">
                                                <span class="pill-badge purple" style="font-size:11px; padding:1px 6px" title="Hết hàng giá thường, chỉ còn bán qua Flash Sale">Có biến thể chỉ còn hàng Flash Sale</span>
                                            </c:if>
                                            <c:if test="${g.anyLowStock}">
                                                <span class="pill-badge orange" style="font-size:11px; padding:1px 6px">Gần hết hàng</span>
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
                            <td style="padding:14px 16px; text-align:right;">
                                <b style="font-size:14px; color:${g.totalSellable == 0 ? '#ef4444' : 'var(--text-logo)'}"><fmt:formatNumber value="${g.totalSellable}"/></b> <small style="color:#64748b">sp</small>
                                <c:if test="${g.totalFlashSale > 0}">
                                    <div style="font-size:11px; color:#64748b; margin-top:2px">Flash Sale: <b style="color:#dc2626"><fmt:formatNumber value="${g.totalFlashSale}"/></b></div>
                                </c:if>
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
                                    <button type="button" class="btn-variant-badge" onclick="event.stopPropagation(); toggleProductAccordion('${g.groupId}')">
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
                                    </div>
                                </div>
                            </td>
                        </tr>

                        <tr id="detail-${g.groupId}" class="variant-accordion-row" style="display:none; background:#fffcf9;">
                            <td colspan="7" style="padding:0 20px 20px 20px; border-bottom:2px solid #fed7aa">
                                <div class="variant-accordion-card">
                                    <div class="variant-accordion-head">
                                        <div style="display:flex; align-items:center; gap:8px">
                                            <i class="ti ti-box" style="color:#ea580c; font-size:20px"></i>
                                            <b style="color:#9a3412; font-size:13px; text-transform:uppercase; letter-spacing:.04em">

                                            </b>
                                        </div>
                                        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap">
                                            <span style="font-size:12px; color:#c2410c; font-weight:600">
                                                    <%--                                                <i class="ti ti-info-circle"></i> Số lượng giá thường: <b>${g.totalSellable}</b> sp · Flash Sale: <b>${g.totalFlashSale}</b> sp--%>
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
                                            <a href="${ctx}/staff/products/new?variantOf=${g.variants[0].id}" class="btn-pill-primary" style="padding:4px 14px; font-size:11px; text-decoration:none" title="Thêm quy cách mới cho dòng sản phẩm này">
                                                <i class="ti ti-plus"></i>Thêm biến thể mới
                                            </a>
                                        </div>
                                    </div>

                                    <table class="variant-subtable">
                                        <thead>
                                        <tr>
                                            <th style="width:110px">QUY CÁCH</th>
                                            <th>TÊN BIẾN THỂ</th>
                                            <th class="num">GIÁ NIÊM YẾT</th>
                                            <th style="text-align:right" title="Số lượng khách đặt mua được với giá thường">SỐ LƯỢNG (GIÁ THƯỜNG)</th>
                                            <th style="text-align:right" title="Số lượng chỉ bán qua chương trình Flash Sale">FLASH SALE</th>
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
                                                    <div style="font-size:11px; color:#64748b; margin-top:2px; display:flex; align-items:center; gap:8px; flex-wrap:wrap">
                                                        <span>Mã sản phẩm: <code style="font-size:11px; background:#f1f5f9; padding:1px 5px; border-radius:4px"><c:out value="${v.sku}"/></code></span>
                                                        <c:if test="${not empty v.existingExpiriesDisplay}">
                                                                <span style="color:#475569; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; padding:1px 6px" title="Các đợt hàng (HSD) đang có của biến thể này">
                                                                    <i class="ti ti-calendar-event" style="color:#ea580c"></i> HSD: <c:out value="${v.existingExpiriesDisplay}"/>
                                                                </span>
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td class="num">
                                                    <b style="font-size:13px; color:${v.status == 'ACTIVE' ? 'var(--text-logo)' : '#9ca3af'}">
                                                        <fmt:formatNumber value="${v.sellingPrice}" type="number"/>₫
                                                    </b>
                                                </td>
                                                <td style="text-align:right">
                                                    <b style="font-weight:800; color:${v.sellableQty == 0 ? '#ef4444' : 'var(--text-logo)'}"><fmt:formatNumber value="${v.sellableQty}"/></b> <small style="color:#64748b">sp</small>
                                                        <%-- Nhãn tình trạng hàng (khớp bộ lọc), chỉ hiện khi gần hết / chỉ còn Flash Sale / hết --%>
                                                    <c:choose>
                                                        <c:when test="${v.stockStatus == 'FLASH_SALE_ONLY'}">
                                                            <div style="margin-top:3px"><span class="pill-badge purple" style="font-size:10px; padding:1px 6px" title="Hết hàng giá thường, ${v.flashSaleQty} sản phẩm chỉ bán qua Flash Sale">${v.stockStatus.label}</span></div>
                                                        </c:when>
                                                        <c:when test="${v.stockStatus == 'OUT_OF_STOCK'}">
                                                            <div style="margin-top:3px"><span class="pill-badge red" style="font-size:10px; padding:1px 6px">${v.stockStatus.label}</span></div>
                                                        </c:when>
                                                        <c:when test="${v.stockStatus == 'LOW_STOCK'}">
                                                            <div style="margin-top:3px"><span class="pill-badge orange" style="font-size:10px; padding:1px 6px" title="Còn ≤ ngưỡng cảnh báo (${v.lowStockThreshold})">${v.stockStatus.label}</span></div>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td style="text-align:right; font-weight:700; color:${v.flashSaleQty > 0 ? '#dc2626' : '#94a3b8'}">
                                                    <fmt:formatNumber value="${v.flashSaleQty}"/>
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
                                                        <button type="button"
                                                                class="act-icon"
                                                                style="padding:0"
                                                                data-id="${v.id}"
                                                                data-sku="<c:out value='${v.sku}'/>"
                                                                data-name="<c:out value='${v.name}'/>"
                                                                data-spec="<c:out value='${v.spec}'/>"
                                                                data-sellable="${v.sellableQty}"
                                                                data-flash="${v.flashSaleQty}"
                                                                data-expiries-iso="<c:out value='${v.existingExpiriesIso}'/>"
                                                                data-expiries-display="<c:out value='${v.existingExpiriesDisplay}'/>"
                                                                data-group-id="${g.groupId}"
                                                                onclick="openAddStockModal(this)"
                                                                title="Thêm số lượng &amp; hạn sử dụng mới (HSD khác đợt cũ)">
                                                            <i class="ti ti-package-import"></i>
                                                        </button>
                                                        <a href="${ctx}/staff/products/${v.id}/edit" class="act-icon" title="Chỉnh sửa biến thể"><i class="ti ti-edit"></i></a>
                                                        <form method="post" action="${ctx}/staff/products/${v.id}/toggle-status" style="display:inline">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                            <input type="hidden" name="from" value="list">
                                                            <button type="submit" class="act-icon" title="${v.status == 'ACTIVE' ? 'Tạm dừng bán' : 'Kích hoạt bán'}" style="padding:0">
                                                                <i class="ti ${v.status == 'ACTIVE' ? 'ti-player-pause' : 'ti-player-play'}"></i>
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
                        <td colspan="7">
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
            <span>Hiển thị <b>${productGroups != null ? productGroups.size() : 0}</b> sản phẩm (Tổng cộng <b>${totalItems != null ? totalItems : 0}</b> biến thể)</span>
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

<%-- MODAL THÊM SỐ LƯỢNG & HẠN SỬ DỤNG MỚI CHO BIẾN THỂ --%>
<div id="addStockModal" class="stock-modal-backdrop" onclick="if (event.target === this) closeAddStockModal()">
    <div class="stock-modal-card" role="dialog" aria-modal="true" aria-labelledby="addStockModalTitle">
        <div style="padding:18px 22px; background:linear-gradient(135deg, #fff7ed 0%, #ffffff 100%); border-bottom:1px solid #fed7aa; display:flex; align-items:center; justify-content:space-between; gap:12px">
            <div style="display:flex; align-items:center; gap:10px">
                <div style="width:38px; height:38px; border-radius:10px; background:#ea580c; color:#fff; display:grid; place-items:center; font-size:20px; flex-shrink:0">
                    <i class="ti ti-package-import"></i>
                </div>
                <div>
                    <h3 id="addStockModalTitle" style="margin:0; font-size:16px; font-weight:800; color:#1e293b">Thêm số lượng &amp; Hạn sử dụng mới</h3>
                    <small style="color:#64748b; font-size:12px">Tạo đợt hàng mới với HSD khác đợt cũ để tách biệt khi chạy Flash Sale</small>
                </div>
            </div>
            <button type="button" class="act-icon" onclick="closeAddStockModal()" title="Đóng" style="width:32px; height:32px">
                <i class="ti ti-x"></i>
            </button>
        </div>

        <form id="addStockForm" method="post" action="" style="margin:0; padding:20px 22px">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <input type="hidden" name="groupId" id="addStockGroupId" value="">
            <input type="hidden" name="filterQuery" value="<c:out value='${filterQuery}'/>">

            <%-- Thông tin biến thể đang chọn --%>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:12px; padding:12px 14px; margin-bottom:16px">
                <div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap">
                    <b id="addStockVariantName" style="font-size:14px; color:#0f172a"></b>
                    <span id="addStockVariantSpec" class="pill-badge orange" style="font-weight:800; font-size:11px"></span>
                </div>
                <div style="display:flex; align-items:center; gap:16px; margin-top:8px; font-size:12px; color:#475569; flex-wrap:wrap">
                    <span>Mã SP: <code id="addStockVariantSku" style="background:#e2e8f0; padding:1px 6px; border-radius:4px; font-weight:700"></code></span>
                    <span>Giá thường hiện có: <b id="addStockCurSellable" style="color:#059669">0</b> sp</span>
                    <span>Flash Sale hiện có: <b id="addStockCurFlash" style="color:#dc2626">0</b> sp</span>
                </div>
                <div style="margin-top:8px; padding-top:8px; border-top:1px dashed #cbd5e1; font-size:12px; color:#334155">
                    <i class="ti ti-calendar-Exclamation" style="color:#ea580c"></i>
                    <b>HSD đang có:</b> <span id="addStockExistingExpiries" style="color:#c2410c; font-weight:700"></span>
                </div>
            </div>

            <%-- Ô nhập số lượng thêm vào --%>
            <div style="margin-bottom:16px">
                <label for="addStockQty" style="display:block; font-size:13px; font-weight:800; color:#1e293b; margin-bottom:6px">
                    Số lượng nhập thêm <span style="color:#ef4444">*</span>
                </label>
                <div style="display:flex; align-items:center; gap:8px">
                    <input type="number" name="quantity" id="addStockQty" min="1" max="100000" step="1" value="50" required
                           oninput="validateAddStockForm()"
                           style="flex:1; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; font-size:14px; font-weight:700">
                    <button type="button" class="preset-chip" onclick="setAddStockQty(20)">+20</button>
                    <button type="button" class="preset-chip" onclick="setAddStockQty(50)">+50</button>
                    <button type="button" class="preset-chip" onclick="setAddStockQty(100)">+100</button>
                    <button type="button" class="preset-chip" onclick="setAddStockQty(200)">+200</button>
                </div>
            </div>

            <%-- Ô chọn Hạn sử dụng mới (khác HSD cũ) --%>
            <div style="margin-bottom:14px">
                <label for="addStockExpiry" style="display:block; font-size:13px; font-weight:800; color:#1e293b; margin-bottom:6px">
                    Hạn sử dụng (HSD) của đợt mới <span style="color:#ef4444">*</span>
                    <small style="font-weight:600; color:#64748b">(Bắt buộc khác HSD đang có)</small>
                </label>
                <input type="date" name="expiryDate" id="addStockExpiry" required
                       oninput="validateAddStockForm()" onchange="validateAddStockForm()"
                       style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; font-size:14px; font-weight:700; box-sizing:border-box">

                <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; margin-top:8px">
                    <span style="font-size:11px; color:#64748b; font-weight:700">Chọn nhanh HSD:</span>
                    <button type="button" class="preset-chip" onclick="pickAddStockPresetDays(30)" title="Cận hạn 21-89 ngày: dùng để tạo Flash Sale giảm 70%">
                        <i class="ti ti-bolt" style="color:#dc2626"></i> +30 ngày (Flash Sale)
                    </button>
                    <button type="button" class="preset-chip" onclick="pickAddStockPresetDays(60)" title="Cận hạn 21-89 ngày: dùng để tạo Flash Sale giảm 40%">
                        <i class="ti ti-bolt" style="color:#ea580c"></i> +60 ngày (Flash Sale)
                    </button>
                    <button type="button" class="preset-chip" onclick="pickAddStockPresetDays(180)" title="Còn hạn ≥ 90 ngày: cộng vào Số lượng (Giá thường)">
                        <i class="ti ti-check" style="color:#059669"></i> +6 tháng (Giá thường)
                    </button>
                    <button type="button" class="preset-chip" onclick="pickAddStockPresetDays(365)" title="Còn hạn ≥ 90 ngày: cộng vào Số lượng (Giá thường)">
                        <i class="ti ti-check" style="color:#059669"></i> +1 năm (Giá thường)
                    </button>
                </div>
            </div>

            <%-- Thông báo kiểm tra HSD trực tiếp --%>
            <div id="addStockFeedback" style="padding:10px 12px; border-radius:10px; font-size:12.5px; line-height:1.45; margin-bottom:18px; display:none"></div>

            <div style="display:flex; justify-content:flex-end; gap:10px; padding-top:12px; border-top:1px solid #f1f5f9">
                <button type="button" class="btn-pill-outline" onclick="closeAddStockModal()">Hủy</button>
                <button type="submit" id="addStockSubmitBtn" class="btn-flashsale" style="border:0; cursor:pointer">
                    <i class="ti ti-check"></i> Xác nhận cộng số lượng
                </button>
            </div>
        </form>
    </div>
</div>

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

    // Tự động mở rộng nếu đang tìm theo từ khóa, lọc theo tình trạng hàng, hoặc vừa thêm số lượng (openGroup)
    document.addEventListener('DOMContentLoaded', () => {
        const searchInput = document.querySelector('input[name="keyword"]');
        const stockSelect = document.querySelector('select[name="stockStatus"]');
        const params = new URLSearchParams(window.location.search);
        const openGroup = params.get('openGroup');

        if ((searchInput && searchInput.value.trim().length > 0) || (stockSelect && stockSelect.value)) {
            toggleAllAccordions();
        } else if (openGroup) {
            const detailRow = document.getElementById('detail-' + openGroup);
            const masterRow = document.getElementById('row-' + openGroup);
            if (detailRow && masterRow) {
                detailRow.style.display = 'table-row';
                masterRow.classList.add('expanded');
                updateToggleAllButtonText();
                setTimeout(() => masterRow.scrollIntoView({ behavior: 'smooth', block: 'center' }), 100);
            }
        }
    });

    // ========================================================
    // MODAL THÊM SỐ LƯỢNG & HSD MỚI (KHÔNG TRÙNG HSD CŨ)
    // ========================================================
    let currentExistingExpiries = [];

    function toIsoDateString(d) {
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        return yyyy + '-' + mm + '-' + dd;
    }

    function formatIsoToVn(isoStr) {
        if (!isoStr || !isoStr.includes('-')) return isoStr;
        const parts = isoStr.split('-');
        return parts[2] + '/' + parts[1] + '/' + parts[0];
    }

    function openAddStockModal(btn) {
        const id = btn.getAttribute('data-id');
        const sku = btn.getAttribute('data-sku') || '';
        const name = btn.getAttribute('data-name') || '';
        const spec = btn.getAttribute('data-spec') || '';
        const sellable = btn.getAttribute('data-sellable') || '0';
        const flash = btn.getAttribute('data-flash') || '0';
        const expiriesIso = btn.getAttribute('data-expiries-iso') || '';
        const expiriesDisplay = btn.getAttribute('data-expiries-display') || '';
        const groupId = btn.getAttribute('data-group-id') || '';

        currentExistingExpiries = expiriesIso
            ? expiriesIso.split(',').map(s => s.trim()).filter(Boolean)
            : [];

        const form = document.getElementById('addStockForm');
        form.action = '${ctx}/staff/products/' + id + '/add-stock';
        document.getElementById('addStockGroupId').value = groupId;
        document.getElementById('addStockVariantName').textContent = name;
        document.getElementById('addStockVariantSpec').textContent = spec;
        document.getElementById('addStockVariantSku').textContent = sku;
        document.getElementById('addStockCurSellable').textContent = Number(sellable).toLocaleString('vi-VN');
        document.getElementById('addStockCurFlash').textContent = Number(flash).toLocaleString('vi-VN');
        document.getElementById('addStockExistingExpiries').textContent = expiriesDisplay
            ? expiriesDisplay
            : 'Chưa có đợt hàng nào còn tồn';

        const qtyInput = document.getElementById('addStockQty');
        qtyInput.value = 50;

        // Đặt min cho ô chọn ngày là ngày mai
        const tomorrow = new Date();
        tomorrow.setHours(0, 0, 0, 0);
        tomorrow.setDate(tomorrow.getDate() + 1);
        const expiryInput = document.getElementById('addStockExpiry');
        expiryInput.min = toIsoDateString(tomorrow);

        // Mặc định gợi ý +180 ngày (tự động né HSD cũ nếu trùng)
        pickAddStockPresetDays(180);

        document.getElementById('addStockModal').classList.add('open');
        setTimeout(() => qtyInput.focus(), 50);
    }

    function closeAddStockModal() {
        document.getElementById('addStockModal').classList.remove('open');
    }

    function setAddStockQty(amount) {
        const qtyInput = document.getElementById('addStockQty');
        qtyInput.value = amount;
        validateAddStockForm();
    }

    function pickAddStockPresetDays(daysFromToday) {
        const d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() + daysFromToday);
        // Nếu ngày gợi ý vô tình trùng với HSD đang có của biến thể thì tự động dịch thêm 1 ngày
        while (currentExistingExpiries.includes(toIsoDateString(d))) {
            d.setDate(d.getDate() + 1);
        }
        const expiryInput = document.getElementById('addStockExpiry');
        expiryInput.value = toIsoDateString(d);
        validateAddStockForm();
    }

    function validateAddStockForm() {
        const qtyInput = document.getElementById('addStockQty');
        const expiryInput = document.getElementById('addStockExpiry');
        const feedback = document.getElementById('addStockFeedback');
        const submitBtn = document.getElementById('addStockSubmitBtn');

        const qty = parseInt(qtyInput.value, 10);
        const expIso = expiryInput.value;

        feedback.style.display = 'block';

        if (!qty || qty < 1) {
            feedback.style.background = '#fef2f2';
            feedback.style.border = '1px solid #fecaca';
            feedback.style.color = '#dc2626';
            feedback.innerHTML = '<i class="ti ti-alert-circle"></i> Vui lòng nhập số lượng thêm vào từ <b>1</b> sản phẩm trở lên.';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            return false;
        }

        if (!expIso) {
            feedback.style.background = '#fef2f2';
            feedback.style.border = '1px solid #fecaca';
            feedback.style.color = '#dc2626';
            feedback.innerHTML = '<i class="ti ti-alert-circle"></i> Vui lòng chọn <b>Hạn sử dụng</b> cho đợt hàng mới.';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            return false;
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const chosen = new Date(expIso + 'T00:00:00');
        const diffDays = Math.round((chosen - today) / (1000 * 60 * 60 * 24));

        if (diffDays <= 0) {
            feedback.style.background = '#fef2f2';
            feedback.style.border = '1px solid #fecaca';
            feedback.style.color = '#dc2626';
            feedback.innerHTML = '<i class="ti ti-alert-circle"></i> Hạn sử dụng phải <b>sau ngày hôm nay</b>.';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            return false;
        }

        if (currentExistingExpiries.includes(expIso)) {
            feedback.style.background = '#fef2f2';
            feedback.style.border = '1px solid #fecaca';
            feedback.style.color = '#dc2626';
            feedback.innerHTML = '<i class="ti ti-alert-triangle"></i> <b>Trùng hạn sử dụng!</b> Ngày <b>' + formatIsoToVn(expIso) +
                '</b> đã trùng với đợt hàng hiện có của biến thể này. Vui lòng chọn ngày khác để khi thêm vào Flash Sale không bị ảnh hưởng lẫn nhau.';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            return false;
        }

        submitBtn.disabled = false;
        submitBtn.style.opacity = '1';

        if (diffDays >= 90) {
            feedback.style.background = '#ecfdf5';
            feedback.style.border = '1px solid #a7f3d0';
            feedback.style.color = '#065f46';
            feedback.innerHTML = '<i class="ti ti-circle-check"></i> <b>Hợp lệ (còn ' + diffDays + ' ngày, ≥ 90 ngày):</b> ' +
                'Đợt hàng mới hoàn toàn độc lập với đợt cũ và <b>+' + qty.toLocaleString('vi-VN') + ' sp</b> sẽ được cộng gộp vào cột <b>SỐ LƯỢNG (GIÁ THƯỜNG)</b>.';
        } else if (diffDays >= 21) {
            feedback.style.background = '#fff7ed';
            feedback.style.border = '1px solid #fed7aa';
            feedback.style.color = '#9a3412';
            feedback.innerHTML = '<i class="ti ti-bolt"></i> <b>Hàng cận hạn (còn ' + diffDays + ' ngày, từ 21–89 ngày):</b> ' +
                'Sẽ tạo một đợt hàng riêng biệt và cộng <b>+' + qty.toLocaleString('vi-VN') + ' sp</b> vào cột <b>FLASH SALE</b> (không ảnh hưởng các đợt hàng khác).';
        } else {
            feedback.style.background = '#fef2f2';
            feedback.style.border = '1px solid #fecaca';
            feedback.style.color = '#991b1b';
            feedback.innerHTML = '<i class="ti ti-alert-triangle"></i> <b>Cảnh báo (còn ' + diffDays + ' ngày, &lt; 21 ngày):</b> ' +
                'Hạn sử dụng dưới ngưỡng an toàn 21 ngày nên số lượng này sẽ bị khóa bán.';
        }
        return true;
    }

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeAddStockModal();
        }
    });


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
            'LƯU Ý QUAN TRỌNG: Chỉ những biến thể chưa bán ra và chưa phát sinh đơn hàng mới được phép xóa. Nếu sản phẩm đã bán ra, hệ thống sẽ yêu cầu chuyển sang Tạm ngưng bán.';

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
                    errorMsg = 'Sản phẩm "' + productName + '" (Mã sản phẩm: ' + v.sku + ') đã bán ra hoặc có đơn hàng trong hệ thống nên không thể xóa.\n\nHãy chọn "Tạm ngưng bán cả dòng" để ẩn khỏi gian hàng!';
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
