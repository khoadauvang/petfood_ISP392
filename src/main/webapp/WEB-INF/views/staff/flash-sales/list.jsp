<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<%-- Model: activeProducts (List<ActiveFlashSaleProductRow>), campaigns (List<FlashSaleRow>), totalActiveProducts, totalCampaigns, activeCampaignName --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chương trình Khuyến mãi &amp; Flash Sale · PetFood</title>
    <meta name="description" content="Quản lý Flash Sale và các chương trình giảm giá của cửa hàng PetFood.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .promotions-container {
            display: flex;
            flex-direction: column;
            gap: 28px;
        }
        .section-header-wrap {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 14px;
        }
        .section-title-box {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .section-title {
            font-size: 17px;
            font-weight: 800;
            color: var(--text-logo);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .dot-indicator {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background-color: var(--color-primary);
            display: inline-block;
        }
        .active-campaign-chip {
            background: #fff7ed;
            color: #c2410c;
            border: 1px solid #fed7aa;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-toolbar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 12px;
        }
        .filter-input-wrap {
            position: relative;
            flex: 1;
            min-width: 250px;
        }
        .filter-input-wrap i {
            position: absolute;
            left: 13px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-placeholder);
            font-size: 15px;
        }
        .filter-input-wrap input {
            width: 100%;
            padding: 8px 12px 8px 36px;
            border: 1px solid var(--line);
            border-radius: 10px;
            font-size: 13px;
            background: #fff;
            box-sizing: border-box;
            transition: border-color .15s ease;
        }
        .filter-input-wrap input:focus {
            outline: none;
            border-color: var(--color-primary);
        }
        .filter-select {
            padding: 8px 14px;
            border: 1px solid var(--line);
            border-radius: 10px;
            font-size: 13px;
            background: #fff;
            color: var(--text-base);
            cursor: pointer;
            box-sizing: border-box;
        }
        .filter-select:focus {
            outline: none;
            border-color: var(--color-primary);
        }
        .btn-reset-filter {
            background: #fff;
            border: 1px solid var(--line);
            color: var(--text-muted);
            padding: 8px 12px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            transition: all .15s ease;
        }
        .btn-reset-filter:hover {
            color: var(--color-primary);
            border-color: var(--color-primary);
            background: #fff7ed;
        }
        .pill-badge.campaign-code {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 11px;
            font-weight: 700;
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 3px 8px;
            border-radius: 6px;
        }
        .pill-badge.flash-sale {
            background: #fff7ed;
            color: #ea580c;
            border: 1px solid #ffedd5;
            font-weight: 700;
        }
        .pill-badge.promotion-type {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #dbeafe;
            font-weight: 700;
        }
        .discount-pill {
            display: inline-block;
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
            font-size: 12px;
            font-weight: 800;
            padding: 2px 8px;
            border-radius: 6px;
        }
        .btn-stop-sm {
            background: #fff1f2 !important;
            color: #e11d48 !important;
            border: 1px solid #fecdd3 !important;
            font-size: 12px !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 8px !important;
            cursor: pointer !important;
            transition: all .15s !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 4px !important;
            box-shadow: none !important;
            transform: none !important;
            white-space: nowrap !important;
        }
        .btn-stop-sm:hover {
            background: #ffe4e6 !important;
            color: #be123c !important;
            border-color: #fda4af !important;
            transform: none !important;
            box-shadow: none !important;
        }
        .btn-cancel-sm {
            background: #f8fafc !important;
            color: #64748b !important;
            border: 1px solid #e2e8f0 !important;
            font-size: 12px !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 8px !important;
            cursor: pointer !important;
            transition: all .15s !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 4px !important;
            box-shadow: none !important;
            transform: none !important;
            white-space: nowrap !important;
        }
        .btn-cancel-sm:hover {
            background: #f1f5f9 !important;
            color: #334155 !important;
            transform: none !important;
            box-shadow: none !important;
        }
        body button.act-icon, body a.act-icon {
            width: 32px !important;
            height: 32px !important;
            padding: 0 !important;
            border-radius: 8px !important;
            display: inline-grid !important;
            place-items: center !important;
            border: 1px solid var(--line) !important;
            background: #ffffff !important;
            color: #64748b !important;
            font-size: 15px !important;
            cursor: pointer !important;
            box-shadow: none !important;
            transform: none !important;
            text-decoration: none !important;
            transition: all 0.15s ease !important;
        }
        body button.act-icon:hover, body a.act-icon:hover {
            border-color: var(--color-primary) !important;
            color: var(--color-primary) !important;
            background: #fffaf5 !important;
            transform: none !important;
            box-shadow: none !important;
        }
        body button.act-icon.warning, body a.act-icon.warning {
            color: #d97706 !important;
            background: #fffbeb !important;
            border-color: #fde68a !important;
        }
        body button.act-icon.warning:hover, body a.act-icon.warning:hover {
            color: #b45309 !important;
            background: #fef3c7 !important;
            border-color: #fcd34d !important;
        }
        body button.act-icon.danger, body a.act-icon.danger {
            color: #dc2626 !important;
            background: #fef2f2 !important;
            border-color: #fecaca !important;
        }
        body button.act-icon.danger:hover, body a.act-icon.danger:hover {
            border-color: #ef4444 !important;
            color: #b91c1c !important;
            background: #fee2e2 !important;
        }
        body button.act-icon.success, body a.act-icon.success {
            color: #16a34a !important;
            background: #f0fdf4 !important;
            border-color: #bbf7d0 !important;
        }
        body button.act-icon.success:hover, body a.act-icon.success:hover {
            color: #15803d !important;
            background: #dcfce7 !important;
            border-color: #86efac !important;
        }
        body button.act-icon.info, body a.act-icon.info {
            color: #0284c7 !important;
            background: #f0f9ff !important;
            border-color: #bae6fd !important;
        }
        body button.act-icon.info:hover, body a.act-icon.info:hover {
            color: #0369a1 !important;
            background: #e0f2fe !important;
            border-color: #7dd3fc !important;
        }
        .product-media-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .product-thumb-box {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            background: #f8fafc;
            border: 1px solid var(--line);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
        }
        .product-thumb-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .product-thumb-box i {
            font-size: 22px;
            color: #ea580c;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <%-- Header chính theo Figma Screen --%>
    <div class="page-head" style="margin-bottom:24px">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <span class="current">CHƯƠNG TRÌNH</span>
            </div>
            <h1 style="display:flex; align-items:center; gap:10px">
                CHƯƠNG TRÌNH
                <span class="pill-badge orange" style="font-size:12px; font-weight:700">
                    <i class="ti ti-tag"></i>Khuyến mãi &amp; Flash Sale
                </span>
            </h1>
            <p class="page-sub">Quản lý Flash Sale và các chương trình giảm giá của cửa hàng.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <c:if test="${currentUser.role == 'ADMIN'}">
                <a href="${ctx}/staff/flash-sales/new" class="btn-flashsale" style="box-shadow: 0 4px 12px rgba(234, 88, 12, 0.25)">
                    <i class="ti ti-plus"></i>Tạo chương trình giảm giá
                </a>
            </c:if>
        </div>
    </div>

    <div class="promotions-container">

        <%-- ========================================================================= --%>
        <%-- BẢNG 1: SẢN PHẨM ĐANG FLASH SALE                                           --%>
        <%-- ========================================================================= --%>
        <section class="panel" style="padding:20px; border-radius:16px; margin:0">
            <div class="section-header-wrap">
                <div>
                    <div class="section-title-box">
                        <span class="dot-indicator"></span>
                        <h2 class="section-title">
                            BẢNG 1: Sản phẩm đang Flash Sale
                        </h2>
                        <span class="pill-badge orange" style="font-size:12px">
                            ${totalActiveProducts} mặt hàng đang áp dụng
                        </span>
                    </div>
                    <p style="font-size:13px; color:var(--text-muted); margin:4px 0 0 17px">
                        Danh sách sản phẩm đang được giảm giá Flash Sale, kèm thời gian áp dụng và số lượng tham gia.
                    </p>
                </div>

                <div class="active-campaign-chip">
                    <i class="ti ti-bolt"></i>
                    <span>Chiến dịch active: <b>${activeCampaignName}</b></span>
                </div>
            </div>

            <%-- Filter bar BẢNG 1 --%>
            <div class="filter-toolbar">
                <div class="filter-input-wrap">
                    <i class="ti ti-search"></i>
                    <input type="search" id="b1-search" placeholder="Tìm theo tên sản phẩm, SKU hoặc mã lô (#LOT-...)" oninput="onFilterTable1Change()">
                </div>

                <select id="b1-status" class="filter-select" onchange="onFilterTable1Change()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Đang diễn ra">Đang diễn ra</option>
                    <option value="Sắp diễn ra">Sắp diễn ra</option>
                </select>
            </div>

            <%-- Table BẢNG 1 --%>
            <div style="overflow-x:auto; margin-top:8px">
                <table style="margin:0; width:100%; border:0">
                    <thead>
                    <tr>
                        <th style="min-width:260px">SẢN PHẨM</th>
                        <th style="min-width:140px">MÃ LÔ &amp; HẠN DÙNG</th>
                        <th style="min-width:110px">GIÁ GỐC</th>
                        <th style="min-width:160px">GIÁ FLASH SALE / MỨC GIẢM</th>
                        <th style="min-width:100px; text-align:center">SL THAM GIA</th>
                        <th style="min-width:100px; text-align:center">SL CÒN LẠI</th>
                        <th style="min-width:180px">THỜI GIAN</th>
                        <th style="min-width:120px">TRẠNG THÁI</th>
                        <th style="min-width:100px; text-align:right">THAO TÁC</th>
                    </tr>
                    </thead>
                    <tbody id="b1-tbody">
                    <c:choose>
                        <c:when test="${not empty activeProducts}">
                            <c:forEach var="p" items="${activeProducts}">
                                <tr class="b1-row"
                                    data-name="<c:out value='${p.productName}'/>"
                                    data-sku="<c:out value='${p.sku}'/>"
                                    data-lot="<c:out value='${p.lotCode}'/> lot-${p.lotId}"
                                    data-status="${p.statusDisplay}">
                                    <td>
                                        <div class="product-media-cell">
                                            <div class="product-thumb-box">
                                                <c:choose>
                                                    <c:when test="${not empty p.imageUrl}">
                                                        <img src="${p.imageUrl.startsWith('http') ? p.imageUrl : ctx.concat(p.imageUrl)}" alt="${p.productName}" onerror="this.onerror=null; this.parentElement.innerHTML='<i class=\'ti ti-bone\'></i>';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="ti ti-bone"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <a href="${ctx}/staff/products/${p.productId}" style="font-weight:700; color:var(--text-logo); line-height:1.3; display:block">
                                                    <c:out value="${p.productName}"/>
                                                </a>
                                                <span style="font-size:12px; color:var(--text-muted); font-family:monospace">
                                                    SKU: <c:out value="${p.sku}"/>
                                                </span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight:700; font-family:monospace; color:#334155">${p.lotCode}</div>
                                        <div style="font-size:12px; color:${p.daysLeft lt 30 ? '#dc2626' : '#ea580c'}; display:flex; align-items:center; gap:4px">
                                            <i class="ti ti-calendar" style="font-size:13px"></i>
                                            <span>HSD: ${p.expiryDate} (${p.daysLeft} ngày)</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="text-decoration:line-through; color:#94a3b8; font-weight:600">
                                            <fmt:formatNumber value="${p.originalPrice}" pattern="#,##0"/>đ
                                        </span>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px">
                                            <b style="color:#ea580c; font-size:14px">
                                                <fmt:formatNumber value="${p.salePrice}" pattern="#,##0"/>đ
                                            </b>
                                            <span class="discount-pill">-${p.discountPercent}%</span>
                                        </div>
                                    </td>
                                    <td style="text-align:center">
                                        <b>${p.allocatedQty} gói</b>
                                    </td>
                                    <td style="text-align:center">
                                        <span class="pill-badge green" style="font-weight:700">
                                            ${p.remainingQty} gói
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-size:12px; color:#475569">${p.timeRangeText}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.active}">
                                                <span class="pill-badge green">● Đang diễn ra</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="pill-badge blue">● Sắp diễn ra</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:right">
                                        <div style="display:inline-flex; align-items:center; gap:6px">
                                            <a href="${ctx}/staff/flash-sales/${p.saleId}" class="act-icon icon-btn" title="Xem chi tiết chiến dịch">
                                                <i class="ti ti-eye"></i>
                                            </a>
                                            <c:if test="${currentUser.role == 'ADMIN'}">
                                                <c:choose>
                                                    <c:when test="${p.active}">
                                                        <form method="post" action="${ctx}/staff/flash-sales/${p.saleId}/pause" style="margin:0; display:inline" onsubmit="return confirm('Tạm dừng chiến dịch Flash Sale chứa sản phẩm này?');">
                                                            ${csrf}
                                                            <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                            <button type="submit" class="act-icon icon-btn warning" title="Tạm dừng Flash Sale"><i class="ti ti-player-pause"></i></button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form method="post" action="${ctx}/staff/flash-sales/${p.saleId}/end" style="margin:0; display:inline" onsubmit="return confirm('Hủy hoặc kết thúc chiến dịch Flash Sale này?');">
                                                            ${csrf}
                                                            <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                            <button type="submit" class="act-icon icon-btn danger" title="Hủy / Kết thúc chiến dịch"><i class="ti ti-player-stop"></i></button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <tr id="b1-empty-filter" style="display:none">
                                <td colspan="9" style="text-align:center; padding:32px; color:var(--text-muted)">
                                    <i class="ti ti-search-off" style="font-size:28px; opacity:0.6; display:block; margin-bottom:6px"></i>
                                    Không tìm thấy sản phẩm Flash Sale nào khớp với bộ lọc.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" style="text-align:center; padding:36px; color:var(--text-muted)">
                                    <i class="ti ti-bolt-off" style="font-size:32px; opacity:0.5; display:block; margin-bottom:8px"></i>
                                    Hiện chưa có mặt hàng nào tham gia Flash Sale. Vào mục <a href="${ctx}/staff/alerts" style="color:var(--color-primary); font-weight:700">Cảnh báo hạn sử dụng</a> để tạo Flash Sale tức thì cho lô cận date.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- THANH PHÂN TRANG BẢNG 1: ĐỒNG BỘ 100% VỚI QUẢN LÝ ĐƠN HÀNG (Mỗi trang hiện 5 Flash Sale) --%>
            <div class="panel-foot" style="padding:14px 20px; background:#fff; border-top:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-top:8px">
                <span style="font-size:13px; color:var(--text-muted)">
                    Hiển thị <span id="b1-visible-count">0</span> trong tổng số <b><span id="b1-total-count">${totalActiveProducts}</span></b> mặt hàng
                </span>

                <div class="pager" style="margin:0; display:flex; align-items:center; gap:4px; flex-wrap:wrap" id="b1-pager">
                    <!-- Được render tự động qua JavaScript -->
                </div>
            </div>
        </section>


        <%-- ========================================================================= --%>
        <%-- BẢNG 2: CHƯƠNG TRÌNH KHUYẾN MÃI                                           --%>
        <%-- ========================================================================= --%>
        <section class="panel" style="padding:20px; border-radius:16px; margin:0">
            <div class="section-header-wrap">
                <div>
                    <div class="section-title-box">
                        <h2 class="section-title" style="color:var(--text-logo)">
                            BẢNG 2: Chương trình khuyến mãi (Promotions)
                        </h2>
                        <span class="pill-badge gray" style="font-size:12px">
                            ${totalCampaigns} chương trình
                        </span>
                    </div>
                    <p style="font-size:13px; color:var(--text-muted); margin:4px 0 0 0">
                        Quản lý các chương trình ưu đãi, giảm giá định kỳ do Admin tạo áp dụng cho sản phẩm và lô hàng bình thường (>90 ngày).
                    </p>
                </div>
            </div>

            <%-- Filter bar BẢNG 2 --%>
            <div class="filter-toolbar">
                <div class="filter-input-wrap">
                    <i class="ti ti-search"></i>
                    <input type="search" id="b2-search" placeholder="Tìm theo tên hoặc mã chương trình (#KM-...)" oninput="onFilterTable2Change()">
                </div>

                <select id="b2-status" class="filter-select" onchange="onFilterTable2Change()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="Đang diễn ra">Đang diễn ra</option>
                    <option value="Sắp diễn ra">Sắp diễn ra</option>
                    <option value="Bản nháp">Bản nháp</option>
                    <option value="Tạm dừng">Tạm dừng</option>
                    <option value="Đã kết thúc">Đã kết thúc</option>
                </select>

                <button type="button" class="btn-reset-filter" onclick="resetTable2Filters()">
                    <i class="ti ti-rotate"></i>Đặt lại
                </button>
            </div>

            <%-- Table BẢNG 2 --%>
            <div style="overflow-x:auto; margin-top:8px">
                <table style="margin:0; width:100%; border:0">
                    <thead>
                    <tr>
                        <th style="min-width:260px">TÊN CHƯƠNG TRÌNH</th>
                        <th style="min-width:200px">PHẠM VI ÁP DỤNG</th>
                        <th style="min-width:130px">HÌNH THỨC GIẢM</th>
                        <th style="min-width:180px">THỜI GIAN</th>
                        <th style="min-width:120px">TRẠNG THÁI</th>
                        <th style="min-width:130px">NGƯỜI TẠO</th>
                        <th style="min-width:120px; text-align:right">THAO TÁC</th>
                    </tr>
                    </thead>
                    <tbody id="b2-tbody">
                    <c:choose>
                        <c:when test="${not empty campaigns}">
                            <c:forEach var="c" items="${campaigns}">
                                <tr class="b2-row"
                                    data-name="<c:out value='${c.name}'/>"
                                    data-code="<c:out value='${c.code}'/> #${c.id}"
                                    data-status="${c.statusDisplay}">
                                    <td>
                                        <div>
                                            <a href="${ctx}/staff/flash-sales/${c.id}" style="font-weight:700; color:var(--text-logo); font-size:14px; line-height:1.3; display:block">
                                                <c:out value="${c.name}"/>
                                            </a>
                                            <small style="color:var(--text-muted); font-size:12px">
                                                <c:out value="${c.description}"/>
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="font-size:13px; color:#334155; font-weight:500">${c.scopeText}</span>
                                    </td>
                                    <td>
                                        <span class="discount-pill">${c.discountText}</span>
                                    </td>
                                    <td>
                                        <div style="font-size:12px; color:#475569; line-height:1.4">
                                            <b>${c.startText}</b><br>
                                            đến ${c.endText}
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'ACTIVE'}">
                                                <span class="pill-badge green">● Đang diễn ra</span>
                                            </c:when>
                                            <c:when test="${c.status == 'DRAFT'}">
                                                <span class="pill-badge blue">● ${c.statusDisplay}</span>
                                            </c:when>
                                            <c:when test="${c.status == 'PAUSED'}">
                                                <span class="pill-badge gold">● Tạm dừng</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="pill-badge gray">Đã kết thúc</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span style="font-size:13px; color:#475569; font-weight:500">
                                            <c:out value="${c.createdByName}"/>
                                        </span>
                                    </td>
                                    <td style="text-align:right">
                                        <div style="display:inline-flex; align-items:center; gap:6px">
                                            <a href="${ctx}/staff/flash-sales/${c.id}" class="act-icon icon-btn" title="Xem chi tiết">
                                                <i class="ti ti-eye"></i>
                                            </a>

                                            <c:if test="${currentUser.role == 'ADMIN'}">
                                                <%-- Nút Sửa (chỉ khi DRAFT) --%>
                                                <c:if test="${c.status == 'DRAFT'}">
                                                    <a href="${ctx}/staff/flash-sales/${c.id}/edit" class="act-icon icon-btn info" title="Chỉnh sửa">
                                                        <i class="ti ti-edit"></i>
                                                    </a>
                                                </c:if>

                                                <%-- Nút Kích hoạt mở bán (chỉ khi DRAFT) --%>
                                                <c:if test="${c.status == 'DRAFT'}">
                                                    <form method="post" action="${ctx}/staff/flash-sales/${c.id}/activate" style="margin:0; display:inline" onsubmit="return confirm('Bắt đầu mở bán chiến dịch #${c.id}?');">
                                                        ${csrf}
                                                        <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                        <button type="submit" class="act-icon icon-btn success" title="Mở bán ngay">
                                                            <i class="ti ti-player-play"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <%-- Nút Pause (khi ACTIVE) --%>
                                                <c:if test="${c.status == 'ACTIVE'}">
                                                    <form method="post" action="${ctx}/staff/flash-sales/${c.id}/pause" style="margin:0; display:inline" onsubmit="return confirm('Tạm dừng chiến dịch này?');">
                                                        ${csrf}
                                                        <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                        <button type="submit" class="act-icon icon-btn warning" title="Tạm dừng chiến dịch"><i class="ti ti-player-pause"></i></button>
                                                    </form>
                                                </c:if>

                                                <%-- Nút Resume (khi PAUSED) --%>
                                                <c:if test="${c.status == 'PAUSED'}">
                                                    <form method="post" action="${ctx}/staff/flash-sales/${c.id}/resume" style="margin:0; display:inline" onsubmit="return confirm('Tiếp tục chạy chiến dịch này?');">
                                                        ${csrf}
                                                        <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                        <button type="submit" class="act-icon icon-btn success" title="Tiếp tục chạy"><i class="ti ti-player-play"></i></button>
                                                    </form>
                                                </c:if>

                                                <%-- Nút Kết thúc sớm (khi ACTIVE hoặc PAUSED) --%>
                                                <c:if test="${c.status == 'ACTIVE' || c.status == 'PAUSED'}">
                                                    <form method="post" action="${ctx}/staff/flash-sales/${c.id}/end" style="margin:0; display:inline" onsubmit="return confirm('Kết thúc chiến dịch #${c.id}?');">
                                                        ${csrf}
                                                        <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                        <button type="submit" class="act-icon icon-btn danger" title="Kết thúc chiến dịch">
                                                            <i class="ti ti-player-stop"></i>
                                                        </button>
                                                    </form>
                                                </c:if>

                                                <%-- Nút Xóa (khi DRAFT) --%>
                                                <c:if test="${c.status == 'DRAFT'}">
                                                    <form method="post" action="${ctx}/staff/flash-sales/${c.id}/delete" style="margin:0; display:inline" onsubmit="return confirm('Xoá chiến dịch nháp #${c.id}?');">
                                                        ${csrf}
                                                        <input type="hidden" name="redirectUrl" value="/staff/flash-sales">
                                                        <button type="submit" class="act-icon icon-btn danger" title="Xóa chiến dịch nháp">
                                                            <i class="ti ti-trash"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <tr id="b2-empty-filter" style="display:none">
                                <td colspan="7" style="text-align:center; padding:32px; color:var(--text-muted)">
                                    <i class="ti ti-search-off" style="font-size:28px; opacity:0.6; display:block; margin-bottom:6px"></i>
                                    Không tìm thấy chương trình giảm giá nào khớp với bộ lọc.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align:center; padding:36px; color:var(--text-muted)">
                                    <i class="ti ti-tag-off" style="font-size:32px; opacity:0.5; display:block; margin-bottom:8px"></i>
                                    Chưa có chương trình giảm giá nào. Nhấn "Tạo chương trình giảm giá" để bắt đầu.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- THANH PHÂN TRANG BẢNG 2: ĐỒNG BỘ 100% VỚI QUẢN LÝ ĐƠN HÀNG --%>
            <div class="panel-foot" style="padding:14px 20px; background:#fff; border-top:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-top:8px">
                <span style="font-size:13px; color:var(--text-muted)">
                    Hiển thị <span id="b2-visible-count">0</span> trong tổng số <b><span id="b2-total-count">${totalCampaigns}</span></b> chương trình
                </span>

                <div class="pager" style="margin:0; display:flex; align-items:center; gap:4px; flex-wrap:wrap" id="b2-pager">
                    <!-- Được render tự động qua JavaScript -->
                </div>
            </div>
        </section>

    </div>
</main>

<script>
    function removeVietnameseTones(str) {
        if (!str) return '';
        str = str.toLowerCase();
        str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
        str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
        str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
        str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
        str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
        str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
        str = str.replace(/đ/g, "d");
        return str;
    }

    // =========================================================================
    // PHÂN TRANG & BỘ LỌC BẢNG 1: SẢN PHẨM FLASH SALE (Mỗi trang hiện 5 Flash Sale)
    // =========================================================================
    const PAGE_SIZE_B1 = 5;
    let currentB1Page = 1;
    let b1MatchedRows = [];

    function onFilterTable1Change() {
        currentB1Page = 1; // reset về trang 1 khi thay đổi bộ lọc
        applyTable1FilterAndPaging();
    }

    function applyTable1FilterAndPaging() {
        const keyword = removeVietnameseTones((document.getElementById('b1-search')?.value || '').trim());
        const status = (document.getElementById('b1-status')?.value || '').trim();
        const allRows = Array.from(document.querySelectorAll('.b1-row'));

        b1MatchedRows = allRows.filter(row => {
            const name = removeVietnameseTones(row.getAttribute('data-name') || '');
            const sku = (row.getAttribute('data-sku') || '').toLowerCase();
            const lot = (row.getAttribute('data-lot') || '').toLowerCase();
            const rowStatus = row.getAttribute('data-status') || '';

            const matchKeyword = !keyword || name.includes(keyword) || sku.includes(keyword) || lot.includes(keyword);
            const matchStatus = !status || rowStatus.includes(status);
            return matchKeyword && matchStatus;
        });

        renderB1Page();
    }

    function renderB1Page() {
        const allRows = document.querySelectorAll('.b1-row');
        allRows.forEach(r => r.style.display = 'none');

        const totalItems = b1MatchedRows.length;
        const totalPages = Math.ceil(totalItems / PAGE_SIZE_B1) || 1;

        if (currentB1Page > totalPages) currentB1Page = totalPages;
        if (currentB1Page < 1) currentB1Page = 1;

        const startIndex = (currentB1Page - 1) * PAGE_SIZE_B1;
        const endIndex = startIndex + PAGE_SIZE_B1;

        let visibleCount = 0;
        b1MatchedRows.forEach((row, idx) => {
            if (idx >= startIndex && idx < endIndex) {
                row.style.display = '';
                visibleCount++;
            }
        });

        const emptyMsg = document.getElementById('b1-empty-filter');
        if (emptyMsg) {
            emptyMsg.style.display = (totalItems === 0 && allRows.length > 0) ? '' : 'none';
        }

        // Cập nhật text "Hiển thị X trong tổng số Y mặt hàng"
        const countSpan = document.getElementById('b1-visible-count');
        const totalSpan = document.getElementById('b1-total-count');
        if (countSpan) countSpan.textContent = visibleCount;
        if (totalSpan) totalSpan.textContent = totalItems;

        // Render cụm nút pager đồng bộ 100% với Quản lý đơn hàng
        const pager = document.getElementById('b1-pager');
        if (!pager) return;

        if (totalPages <= 1) {
            pager.innerHTML = '';
            return;
        }

        let html = '';
        // Nút Về trang đầu & Trang trước
        if (currentB1Page > 1) {
            html += '<a href="javascript:void(0)" onclick="goToPageB1(1)" title="Về trang đầu" style="padding:0 9px; font-size:12px; font-weight:700">« Đầu</a>';
            html += '<a href="javascript:void(0)" onclick="goToPageB1(' + (currentB1Page - 1) + ')" title="Trang trước" style="padding:0 9px; font-size:12px; font-weight:700">‹ Trước</a>';
        }

        // Giới hạn 3 trang trước và sau currentB1Page
        const startPage = Math.max(1, currentB1Page - 3);
        const endPage = Math.min(totalPages, currentB1Page + 3);

        if (startPage > 1) {
            html += '<span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>';
        }

        for (let p = startPage; p <= endPage; p++) {
            if (p === currentB1Page) {
                html += '<strong style="background:var(--color-primary); color:#fff; border-color:transparent">' + p + '</strong>';
            } else {
                html += '<a href="javascript:void(0)" onclick="goToPageB1(' + p + ')">' + p + '</a>';
            }
        }

        if (endPage < totalPages) {
            html += '<span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>';
        }

        // Nút Trang sau & Đến trang cuối
        if (currentB1Page < totalPages) {
            html += '<a href="javascript:void(0)" onclick="goToPageB1(' + (currentB1Page + 1) + ')" title="Trang tiếp theo" style="padding:0 9px; font-size:12px; font-weight:700">Sau ›</a>';
            html += '<a href="javascript:void(0)" onclick="goToPageB1(' + totalPages + ')" title="Đến trang cuối" style="padding:0 9px; font-size:12px; font-weight:700">Cuối »</a>';
        }

        pager.innerHTML = html;
    }

    function goToPageB1(page) {
        currentB1Page = page;
        renderB1Page();
    }


    // =========================================================================
    // PHÂN TRANG & BỘ LỌC BẢNG 2: CHƯƠNG TRÌNH GIẢM GIÁ (Đồng bộ Quản lý đơn hàng)
    // =========================================================================
    const PAGE_SIZE_B2 = 5;
    let currentB2Page = 1;
    let b2MatchedRows = [];

    function onFilterTable2Change() {
        currentB2Page = 1;
        applyTable2FilterAndPaging();
    }

    function applyTable2FilterAndPaging() {
        const keyword = removeVietnameseTones((document.getElementById('b2-search')?.value || '').trim());
        const status = (document.getElementById('b2-status')?.value || '').trim();
        const allRows = Array.from(document.querySelectorAll('.b2-row'));

        b2MatchedRows = allRows.filter(row => {
            const name = removeVietnameseTones(row.getAttribute('data-name') || '');
            const code = (row.getAttribute('data-code') || '').toLowerCase();
            const rowStatus = row.getAttribute('data-status') || '';

            const matchKeyword = !keyword || name.includes(keyword) || code.includes(keyword);
            const matchStatus = !status || rowStatus.includes(status);
            return matchKeyword && matchStatus;
        });

        renderB2Page();
    }

    function renderB2Page() {
        const allRows = document.querySelectorAll('.b2-row');
        allRows.forEach(r => r.style.display = 'none');

        const totalItems = b2MatchedRows.length;
        const totalPages = Math.ceil(totalItems / PAGE_SIZE_B2) || 1;

        if (currentB2Page > totalPages) currentB2Page = totalPages;
        if (currentB2Page < 1) currentB2Page = 1;

        const startIndex = (currentB2Page - 1) * PAGE_SIZE_B2;
        const endIndex = startIndex + PAGE_SIZE_B2;

        let visibleCount = 0;
        b2MatchedRows.forEach((row, idx) => {
            if (idx >= startIndex && idx < endIndex) {
                row.style.display = '';
                visibleCount++;
            }
        });

        const emptyMsg = document.getElementById('b2-empty-filter');
        if (emptyMsg) {
            emptyMsg.style.display = (totalItems === 0 && allRows.length > 0) ? '' : 'none';
        }

        const countSpan = document.getElementById('b2-visible-count');
        const totalSpan = document.getElementById('b2-total-count');
        if (countSpan) countSpan.textContent = visibleCount;
        if (totalSpan) totalSpan.textContent = totalItems;

        const pager = document.getElementById('b2-pager');
        if (!pager) return;

        if (totalPages <= 1) {
            pager.innerHTML = '';
            return;
        }

        let html = '';
        if (currentB2Page > 1) {
            html += '<a href="javascript:void(0)" onclick="goToPageB2(1)" title="Về trang đầu" style="padding:0 9px; font-size:12px; font-weight:700">« Đầu</a>';
            html += '<a href="javascript:void(0)" onclick="goToPageB2(' + (currentB2Page - 1) + ')" title="Trang trước" style="padding:0 9px; font-size:12px; font-weight:700">‹ Trước</a>';
        }

        const startPage = Math.max(1, currentB2Page - 3);
        const endPage = Math.min(totalPages, currentB2Page + 3);

        if (startPage > 1) {
            html += '<span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>';
        }

        for (let p = startPage; p <= endPage; p++) {
            if (p === currentB2Page) {
                html += '<strong style="background:var(--color-primary); color:#fff; border-color:transparent">' + p + '</strong>';
            } else {
                html += '<a href="javascript:void(0)" onclick="goToPageB2(' + p + ')">' + p + '</a>';
            }
        }

        if (endPage < totalPages) {
            html += '<span style="color:#94a3b8; font-weight:700; padding:0 3px">...</span>';
        }

        if (currentB2Page < totalPages) {
            html += '<a href="javascript:void(0)" onclick="goToPageB2(' + (currentB2Page + 1) + ')" title="Trang tiếp theo" style="padding:0 9px; font-size:12px; font-weight:700">Sau ›</a>';
            html += '<a href="javascript:void(0)" onclick="goToPageB2(' + totalPages + ')" title="Đến trang cuối" style="padding:0 9px; font-size:12px; font-weight:700">Cuối »</a>';
        }

        pager.innerHTML = html;
    }

    function goToPageB2(page) {
        currentB2Page = page;
        renderB2Page();
    }

    function resetTable2Filters() {
        const search = document.getElementById('b2-search');
        const status = document.getElementById('b2-status');
        if (search) search.value = '';
        if (status) status.value = '';
        onFilterTable2Change();
    }

    // Khởi tạo phân trang khi tải trang
    document.addEventListener('DOMContentLoaded', () => {
        applyTable1FilterAndPaging();
        applyTable2FilterAndPaging();
    });
</script>
</body>
</html>
