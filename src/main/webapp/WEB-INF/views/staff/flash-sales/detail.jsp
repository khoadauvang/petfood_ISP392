<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isPromotion" value="${isPromotion || (sale != null && sale.saleType == 'PROMOTION')}"/>
<%-- Model: sale, items, redLots, itemForm, saleStartText, saleEndText, shelfLifeDays, quarantineDays,
     deepDiscountDays, discountPercent, deepDiscountPercent --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${sale != null ? sale.name : (isPromotion ? 'Chi tiết Chương trình Khuyến mãi' : 'Chi tiết Flash Sale')}"/> · PetFood</title>
    <meta name="description" content="Chi tiết chiến dịch ${isPromotion ? 'Khuyến mãi bán lẻ' : 'Flash Sale kích cầu xả hàng cận hạn'}.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .pill-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 3px 10px;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }
        .pill-badge.green { background: #e6f9ed; color: #166534; }
        .pill-badge.orange { background: #ffedd5; color: #c2410c; }
        .pill-badge.red { background: #fee2e2; color: #b91c1c; }
        .pill-badge.yellow { background: #fef3c7; color: #b45309; }
        .pill-badge.gray { background: #f1f5f9; color: #475569; }
        .pill-badge.dark { background: #334155; color: #ffffff; }

        .btn-flashsale {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 12px;
            background: var(--btn-primary-gradient, linear-gradient(135deg, #f47721 0%, #ea580c 100%));
            color: #ffffff !important;
            border: none;
            font-family: inherit;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(244, 119, 33, 0.25);
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        .btn-flashsale:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(244, 119, 33, 0.35);
        }

        .act-btn-danger {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 12px;
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: #ffffff !important;
            border: none;
            font-family: inherit;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(239, 68, 68, 0.25);
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        .act-btn-danger:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(239, 68, 68, 0.35);
        }

        .act-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid transparent;
            background: transparent;
            cursor: pointer;
            transition: all 0.15s ease;
            color: var(--text-muted);
        }
        .act-icon:hover {
            background: #f1f5f9;
            color: var(--text-logo);
        }
        .act-icon.danger {
            color: #dc2626;
        }
        .act-icon.danger:hover {
            background: #fee2e2;
            border-color: #fecaca;
        }

        /* Modal Styles */
        .modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 20px;
            animation: fadeInModal 0.2s ease;
        }
        .modal-container {
            background: #ffffff;
            border-radius: 20px;
            width: 100%;
            max-width: 640px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.06);
            animation: modalPop 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }
        @keyframes modalPop {
            from { transform: scale(0.96); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        @keyframes fadeInModal {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .form-control-custom {
            width: 100%;
            padding: 10px 14px;
            border-radius: 12px;
            border: 1px solid var(--line);
            font-size: 13.5px;
            font-family: inherit;
            background: #fff;
            color: var(--text-main);
            box-sizing: border-box;
            transition: border-color var(--transition), box-shadow var(--transition);
        }
        .form-control-custom:focus {
            outline: none;
            border-color: var(--color-primary);
            box-shadow: 0 0 0 3px rgba(244, 119, 33, 0.15);
        }

        .metric-card {
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 14px;
            padding: 14px 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .metric-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<%-- Staff chỉ xem; mọi nút thay đổi chỉ hiện cho Admin (SecurityConfig chặn POST của Staff) --%>
<c:set var="isAdmin" value="${currentUser.role == 'ADMIN'}"/>
<c:set var="draft" value="${isAdmin && sale.status == 'DRAFT'}"/>
<c:set var="isPromotion" value="${sale != null && sale.saleType == 'PROMOTION'}"/>

<main>
    <%-- Breadcrumb & Page Head --%>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/flash-sales" style="text-decoration:none; color:inherit;">CHƯƠNG TRÌNH</a> <span class="sep">&gt;</span> <span class="current">CHI TIẾT CHIẾN DỊCH</span><!--
                    ‹ ${isPromotion ? 'CHƯƠNG TRÌNH KHUYẾN MÃI' : 'FLASH SALE'}
                </a>
                <span class="sep" style="margin: 0 6px;">&gt;</span>
                <span class="current" style="color:var(--color-primary)">CHI TIẾT CHIẾN DỊCH</span>-->
            </div>
            <h1 style="display:flex; align-items:center; gap:12px; margin-top:4px; flex-wrap:wrap">
                <c:out value="${sale != null ? sale.name : (isPromotion ? 'Chi tiết chương trình' : 'Chi tiết Flash Sale')}"/>
                <c:choose>
                    <c:when test="${sale != null && sale.status == 'ACTIVE'}">
                        <span class="pill-badge green">● Đang diễn ra</span>
                    </c:when>
                    <c:when test="${draft}">
                        <span class="pill-badge orange">● Bản nháp</span>
                    </c:when>
                    <c:when test="${sale != null && sale.status == 'PAUSED'}">
                        <span class="pill-badge yellow">● Tạm dừng</span>
                    </c:when>
                    <c:when test="${sale != null && sale.status == 'ENDED'}">
                        <span class="pill-badge gray">● Đã kết thúc</span>
                    </c:when>
                </c:choose>
                <span class="pill-badge gray" style="font-size:12px">Mã ${isPromotion ? '#KM-' : '#FS-'}${sale.id}</span>
            </h1>
            <p class="page-sub">
                <c:choose>
                    <c:when test="${isPromotion}">
                        Chương trình ưu đãi giảm giá định kỳ dành cho các sản phẩm &amp; lô hàng bảo đảm hạn sử dụng tiêu chuẩn trên 90 ngày.
                    </c:when>
                    <c:otherwise>
                        Chiến dịch kích cầu xả hàng cận hạn theo chuẩn điều phối FEFO &amp; đồng bộ giá bán tự động.
                    </c:otherwise>
                </c:choose>
            </p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <a href="${ctx}/staff/flash-sales" class="btn-pill-outline" style="text-decoration:none">
                <i class="ti ti-arrow-left"></i> Quay lại
            </a>
            <%-- Chuyển trạng thái: DRAFT -> ACTIVE <-> PAUSED -> ENDED (BR-64); chỉ sửa / xoá khi còn DRAFT --%>
            <c:if test="${draft}">
                <a href="${ctx}/staff/flash-sales/${sale.id}/edit" class="btn-pill-outline" style="text-decoration:none">
                    <i class="ti ti-edit"></i> Chỉnh sửa
                </a>
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/delete" style="display:inline" onsubmit="return confirm('Xoá chiến dịch nháp này?');">
                    ${csrf}
                    <button type="submit" class="btn-pill-outline">
                        <i class="ti ti-trash"></i> Xoá nháp
                    </button>
                </form>
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/activate" style="display:inline">
                    ${csrf}
                    <button type="submit" class="btn-flashsale">
                        <i class="ti ti-player-play"></i> Bắt đầu chiến dịch
                    </button>
                </form>
            </c:if>
            <c:if test="${isAdmin && sale.status == 'ACTIVE'}">
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/pause" style="display:inline">
                    ${csrf}
                    <button type="submit" class="btn-pill-outline">
                        <i class="ti ti-player-pause"></i> Tạm dừng
                    </button>
                </form>
            </c:if>
            <c:if test="${isAdmin && sale.status == 'PAUSED'}">
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/resume" style="display:inline">
                    ${csrf}
                    <button type="submit" class="btn-flashsale">
                        <i class="ti ti-player-play"></i> Chạy lại
                    </button>
                </form>
            </c:if>
            <c:if test="${isAdmin && sale.status != 'ENDED'}">
                <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/end" style="display:inline" onsubmit="return confirm('Bạn có chắc chắn muốn kết thúc chiến dịch Flash Sale này sớm không?');">
                    ${csrf}
                    <button type="submit" class="btn-pill-danger">
                        <i class="ti ti-circle-x"></i> Kết thúc chiến dịch
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <%-- KPI Aggregates --%>
    <c:set var="totalAllocated" value="0"/>
    <c:set var="totalSold" value="0"/>
    <c:set var="totalRemaining" value="0"/>
    <c:set var="estRevenue" value="0"/>
    <c:forEach var="it" items="${items}">
        <c:set var="totalAllocated" value="${totalAllocated + it.allocatedQty}"/>
        <c:set var="totalSold" value="${totalSold + it.soldQty}"/>
        <c:set var="totalRemaining" value="${totalRemaining + it.remainingQty}"/>
        <c:set var="estRevenue" value="${estRevenue + (it.soldQty * it.salePrice)}"/>
    </c:forEach>

    <%-- Top Banner & Operations Stats --%>
    <section class="grid g-1-1" style="margin-bottom:24px">
        <%-- Card trái: Hero Campaign Banner --%>
        <div class="panel" style="background:linear-gradient(135deg, #fffcf9 0%, #fff7ed 100%); border-color:#fed7aa; display:flex; flex-direction:column; justify-content:space-between">
            <div>
                <div style="display:flex; align-items:center; gap:8px; margin-bottom:14px">
                    <c:choose>
                        <c:when test="${isPromotion}">
                            <span class="pill-badge blue" style="font-weight:900"><i class="ti ti-gift"></i> KHUYẾN MÃI</span>
                        </c:when>
                        <c:otherwise>
                            <span class="pill-badge red" style="font-weight:900"><i class="ti ti-bolt"></i> FLASH SALE</span>
                        </c:otherwise>
                    </c:choose>
                    <span class="pill-badge orange">${sale.status.label}</span>
                </div>

                <h2 style="font-size:22px; font-weight:800; margin:0 0 10px; color:var(--text-logo)">
                    <c:out value="${sale.name}"/>
                </h2>
                <c:choose>
                    <c:when test="${isPromotion}">
                        <p style="font-size:13.5px; color:var(--text-muted); line-height:1.6; margin:0 0 18px">
                            <c:out value="${not empty sale.description ? sale.description : 'Chương trình khuyến mãi áp dụng mức ưu đãi giá đặc biệt cho các lô hàng bảo đảm chất lượng hạn sử dụng trên 90 ngày.'}"/>
                        </p>
                    </c:when>
                    <c:otherwise>
                        <p style="font-size:13.5px; color:var(--text-muted); line-height:1.6; margin:0 0 18px">
                            Chiến dịch kích cầu xả kho các sản phẩm cận hạn theo thuật toán điều phối FEFO, giúp thu hồi vốn lưu động nhanh chóng và tối ưu hóa diện tích kho chứa.
                        </p>
                    </c:otherwise>
                </c:choose>

                <div style="display:inline-flex; align-items:center; gap:10px; font-size:13.5px; font-weight:700; color:#9a3412; background:#ffedd5; padding:8px 14px; border-radius:10px; margin-bottom:18px">
                    <i class="ti ti-calendar" style="color:#ea580c; font-size:18px"></i>
                    <span>${saleStartText} – ${saleEndText}</span>
                </div>
            </div>

            <div style="border-top:1px dashed #fed7aa; padding-top:14px; display:flex; justify-content:space-between; align-items:center; font-size:12.5px; color:var(--text-muted); flex-wrap:wrap; gap:8px">
                <span><b>Quy mô chiến dịch:</b> ${items != null ? items.size() : 0} sản phẩm</span>
                <span style="color:#10b981; font-weight:700; display:inline-flex; align-items:center; gap:4px">
                    <i class="ti ti-refresh"></i> Tự động đồng bộ POS &amp; Web
                </span>
            </div>
        </div>

        <%-- Card phải: Thông số vận hành chiến dịch --%>
        <div class="panel" style="display:flex; flex-direction:column; justify-content:space-between">
            <div>
                <div class="panel-head" style="margin-bottom:14px">
                    <div>
                        <h3 style="font-size:16px; margin:0">Thông số vận hành chiến dịch</h3>
                        <p style="margin:2px 0 0">Mã hệ thống: <b>${isPromotion ? '#KM-' : '#FS-'}${sale.id}</b></p>
                    </div>
                    <span class="pill-badge gray">Trạng thái: ${sale.status.label}</span>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:16px">
                    <div class="metric-card" style="background:#fffaf5; border-color:#fed7aa">
                        <small style="display:block; font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase">SL Áp Dụng</small>
                        <b style="font-size:24px; color:var(--text-logo); font-family:var(--font-heading)">${totalAllocated}</b> <small style="color:var(--text-muted)">đơn vị</small>
                        <div style="font-size:11.5px; color:var(--text-muted); margin-top:3px">${isPromotion ? 'Sản lượng phân bổ' : 'Cam kết xả kho'}</div>
                    </div>

                    <div class="metric-card" style="background:#ecfdf5; border-color:#a7f3d0">
                        <small style="display:block; font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase">Đã Bán</small>
                        <b style="font-size:24px; color:#10b981; font-family:var(--font-heading)">${totalSold}</b> <small style="color:var(--text-muted)">/ ${totalAllocated}</small>
                        <div style="font-size:11.5px; color:#059669; margin-top:3px; font-weight:700">
                            <i class="ti ti-shopping-cart"></i> <fmt:formatNumber value="${totalAllocated > 0 ? (totalSold * 100.0 / totalAllocated) : 0}" maxFractionDigits="1"/>% chỉ tiêu
                        </div>
                    </div>

                    <div class="metric-card" style="background:#f8fafc; border-color:var(--line)">
                        <small style="display:block; font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase">SL Còn Lại</small>
                        <b style="font-size:24px; color:#64748b; font-family:var(--font-heading)">${totalRemaining}</b> <small style="color:var(--text-muted)">đơn vị</small>
                        <div style="font-size:11.5px; color:var(--text-muted); margin-top:3px">Tồn an toàn khả dụng</div>
                    </div>

                    <div class="metric-card" style="background:#fffcf9; border-color:#fed7aa">
                        <small style="display:block; font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase">Doanh Thu Tạm Tính</small>
                        <b style="font-size:22px; color:#ea580c; font-family:var(--font-heading)"><fmt:formatNumber value="${estRevenue}" type="number"/>₫</b>
                        <div style="font-size:11.5px; color:var(--text-muted); margin-top:3px">Thực thu đơn chốt</div>
                    </div>
                </div>
            </div>

            <div style="font-size:13px; font-weight:700; color:#15803d; background:#f0fdf4; border:1px solid #bbf7d0; border-radius:12px; padding:10px 14px; display:flex; align-items:center; justify-content:space-between">
                <span>● Tỷ lệ hấp thụ toàn chiến dịch: <b><fmt:formatNumber value="${totalAllocated > 0 ? (totalSold * 100.0 / totalAllocated) : 0}" maxFractionDigits="1"/>%</b></span>
                <small style="font-weight:normal; color:#166534">${isPromotion ? 'Chuẩn khuyến mãi bán lẻ' : 'Chuẩn điều phối FEFO'}</small>
            </div>
        </div>
    </section>

    <%-- Danh sách sản phẩm & Lô hàng áp dụng --%>
    <div class="panel" style="margin-bottom:24px; padding:0; overflow:hidden">
        <div style="padding:18px 24px; border-bottom:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px">
            <div>
                <h3 style="margin:0; font-size:16px; display:flex; align-items:center; gap:8px">
                    Danh sách sản phẩm &amp; Lô hàng áp dụng (${isPromotion ? '&gt; 90 ngày' : '&lt; 90 ngày'})
                    <span class="pill-badge orange">${items != null ? items.size() : 0} suất bán</span>
                </h3>
                <small style="color:var(--text-muted); margin-top:2px; display:block">Dữ liệu bán hàng ghi nhận theo thời gian thực từ POS chi nhánh và Online Store.</small>
            </div>
            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap">
                <div style="position:relative; min-width:220px">
                    <i class="ti ti-search" style="position:absolute; left:10px; top:50%; transform:translateY(-50%); color:var(--text-placeholder); font-size:14px"></i>
                    <input type="search" id="flashSaleSearchInput" placeholder="Tìm theo tên, SKU, mã lô..." oninput="filterFlashSaleTable(this.value)"
                           style="width:100%; padding:7px 10px 7px 32px; border-radius:10px; border:1px solid var(--line); font-size:12.5px">
                </div>
                <a href="javascript:void(0)" class="export-btn" style="padding:7px 12px; font-size:12.5px" onclick="exportItemsTable()"><i class="ti ti-file-spreadsheet"></i>Xuất Excel</a>
                <c:if test="${draft}">
                    <c:choose>
                        <c:when test="${isPromotion}">
                            <a href="${ctx}/staff/flash-sales/${sale.id}/edit" class="btn-flashsale" style="padding:7px 16px; font-size:12.5px; text-decoration:none">
                                <i class="ti ti-edit"></i> Chỉnh sửa danh sách lô hàng
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button type="button" onclick="openAddModal()" class="btn-flashsale" style="padding:7px 16px; font-size:12.5px">
                                <i class="ti ti-plus"></i> Thêm sản phẩm / Suất bán
                            </button>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>
        </div>

        <c:choose>
            <c:when test="${isPromotion}">
                <div style="padding:10px 24px; background:#f0fdf4; border-bottom:1px solid #bbf7d0; font-size:12px; color:#166534; display:flex; align-items:center; gap:6px">
                    <i class="ti ti-info-circle" style="color:#16a34a; font-size:16px"></i>
                    <span>Chương trình khuyến mãi áp dụng mức giảm giá ưu đãi do Admin thiết lập cho các lô hàng tiêu chuẩn (hạn dùng trên 90 ngày). Không áp dụng cơ chế giảm giá theo hạn sử dụng cận date.</span>
                </div>
            </c:when>
            <c:otherwise>
                <div style="padding:10px 24px; background:#fffcf9; border-bottom:1px solid #fed7aa; font-size:12px; color:#9a3412; display:flex; align-items:center; gap:6px">
                    <i class="ti ti-info-circle" style="color:#ea580c; font-size:16px"></i>
                    <span>Các sản phẩm trong chương trình được chọn lọc nghiêm ngặt từ các lô hàng có hạn sử dụng dưới 90 ngày nhằm tối ưu luân chuyển hàng tồn kho. Giá Flash Sale tự tính theo HSD lô: còn ${deepDiscountDays} ngày trở lên giảm ${discountPercent}%, còn dưới ${deepDiscountDays} ngày giảm ${deepDiscountPercent}%.</span>
                </div>
            </c:otherwise>
        </c:choose>

        <div style="overflow-x:auto">
            <table id="flashSaleItemsTable" style="margin:0; border:0; border-radius:0; box-shadow:none; width:100%">
                <thead>
                <tr>
                    <th style="width:40px; text-align:center">STT</th>
                    <th>SẢN PHẨM &amp; MÃ SKU</th>
                    <th>LÔ HÀNG</th>
                    <th>HẠN SỬ DỤNG</th>
                    <th class="num">GIÁ GỐC</th>
                    <th class="num">${isPromotion ? 'GIÁ KHUYẾN MÃI' : 'GIÁ FLASH SALE'}</th>
                    <th class="num">MỨC GIẢM</th>
                    <th class="num">SL ÁP DỤNG</th>
                    <th class="num">ĐÃ BÁN</th>
                    <th class="num">CÒN LẠI</th>
                    <th>TIẾN ĐỘ</th>
                    <c:if test="${draft}">
                        <th style="width:70px; text-align:center">THAO TÁC</th>
                    </c:if>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty items}">
                        <c:forEach var="i" items="${items}" varStatus="st">
                            <tr class="item-row" data-search="${i.productName.toLowerCase()} ${i.sku.toLowerCase()} ${i.lotId}">
                                <td style="text-align:center; color:var(--text-muted)">${st.count}</td>
                                <td>
                                    <div style="display:flex; align-items:center; gap:12px">
                                        <div class="avatar" style="width:38px; height:38px; min-width:38px; font-size:16px; background:#fed7aa; color:#9a3412; display:flex; align-items:center; justify-content:center; border-radius:10px">
                                            <i class="ti ti-package"></i>
                                        </div>
                                        <div>
                                            <b style="color:var(--text-logo); font-size:13.5px"><c:out value="${i.productName}"/></b>
                                            <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px">
                                                SKU: <code><c:out value="${i.sku}"/></code>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="pill-badge gray">#LOT-${i.lotId}</span></td>
                                <td>
                                    <div style="font-weight:700; color:var(--text-logo); font-size:12.5px">${i.expiryText}</div>
                                    <span class="pill-badge ${i.daysLeft >= 90 ? 'green' : 'red'}" style="margin-top:2px">còn ${i.daysLeft} ngày</span>
                                </td>
                                <td class="num"><s style="color:var(--text-placeholder)"><fmt:formatNumber value="${i.sellingPrice}" type="number"/>₫</s></td>
                                <td class="num"><b style="color:#ea580c; font-size:14px"><fmt:formatNumber value="${i.salePrice}" type="number"/>₫</b></td>
                                <td class="num"><span class="pill-badge red">-<fmt:formatNumber value="${i.sellingPrice > 0 ? 100 - i.salePrice * 100 / i.sellingPrice : 0}" maxFractionDigits="0"/>%</span></td>
                                <td class="num"><b>${i.allocatedQty}</b></td>
                                <td class="num" style="color:#10b981"><b>${i.soldQty}</b></td>
                                <td class="num">${i.remainingQty}</td>
                                <td style="min-width:130px">
                                    <div style="display:flex; align-items:center; gap:8px">
                                        <div class="wh-progress-track" style="flex:1; margin:0; height:7px">
                                            <div class="wh-progress-fill fill-safe" style="width:${i.allocatedQty > 0 ? (i.soldQty * 100 / i.allocatedQty) : 0}%"></div>
                                        </div>
                                        <small style="font-weight:700; font-size:11.5px"><fmt:formatNumber value="${i.allocatedQty > 0 ? (i.soldQty * 100 / i.allocatedQty) : 0}" maxFractionDigits="0"/>%</small>
                                    </div>
                                </td>
                                <c:if test="${draft}">
                                    <td style="text-align:center">
                                        <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/items/${i.id}/delete" style="display:inline" onsubmit="return confirm('Bạn chắc chắn muốn xoá suất này khỏi chiến dịch?');">
                                            ${csrf}
                                            <button type="submit" class="act-icon danger" title="Xoá suất này">
                                                <i class="ti ti-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="${draft ? 12 : 11}" style="text-align:center; padding:48px 20px; color:var(--text-muted)">
                                <i class="ti ti-package-off" style="font-size:36px; display:block; margin-bottom:10px; color:#ea580c"></i>
                                <b style="font-size:16px; display:block; margin-bottom:6px; color:var(--text-logo)">Chưa có sản phẩm / suất lô nào trong chiến dịch này</b>
                                <c:if test="${draft}">
                                    <c:choose>
                                        <c:when test="${isPromotion}">
                                            <p style="font-size:13px; color:var(--text-muted); margin:0 0 16px; max-width:500px; margin-left:auto; margin-right:auto">
                                                Chương trình khuyến mãi đang ở trạng thái bản nháp. Hãy chọn các lô hàng tiêu chuẩn (&gt; 90 ngày) và thiết lập số lượng suất bán trước khi phát hành.
                                            </p>
                                            <a href="${ctx}/staff/flash-sales/${sale.id}/edit" class="btn-flashsale" style="text-decoration:none">
                                                <i class="ti ti-edit"></i> Chỉnh sửa &amp; Chọn lô hàng
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <p style="font-size:13px; color:var(--text-muted); margin:0 0 16px; max-width:500px; margin-left:auto; margin-right:auto">Chiến dịch đang ở trạng thái bản nháp. Hãy chọn các suất bán từ lô hàng cận hạn (&lt; 90 ngày) trước khi phát hành chiến dịch.</p>
                                            <button type="button" onclick="openAddModal()" class="btn-flashsale">
                                                <i class="ti ti-plus"></i> Thêm sản phẩm từ Lô cận hạn
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                <c:if test="${not empty items}">
                    <tr style="background:#fffaf5; font-weight:800; border-top:2px solid #fed7aa">
                        <td colspan="7" style="text-align:right">TỔNG CỘNG TOÀN CHIẾN DỊCH:</td>
                        <td class="num">${totalAllocated}</td>
                        <td class="num" style="color:#10b981">${totalSold}</td>
                        <td class="num">${totalRemaining}</td>
                        <td style="color:#ea580c"><fmt:formatNumber value="${totalAllocated > 0 ? (totalSold * 100.0 / totalAllocated) : 0}" maxFractionDigits="1"/>% Hoàn thành</td>
                        <c:if test="${draft}"><td></td></c:if>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <%-- Thông tin vận hành & Trạng thái chương trình --%>
    <div class="panel">
        <div class="panel-head">
            <div>
                <h3 style="font-size:16px; margin:0">Thông tin vận hành chiến dịch</h3>
                <p style="margin:2px 0 0">Theo dõi tiến trình và lịch sử thiết lập của chiến dịch</p>
            </div>
            <i class="ti ti-info-circle" style="font-size:20px; color:var(--text-placeholder)"></i>
        </div>

        <div class="audit-timeline">
            <div class="audit-item">
                <div class="audit-dot" style="border-color:#10b981; color:#10b981"><i class="ti ti-clock"></i></div>
                <div class="audit-info">
                    <div style="display:flex; align-items:center; justify-content:space-between">
                        <div class="audit-title">Khung giờ mở bán</div>
                        <span class="audit-time">${saleStartText} – ${saleEndText}</span>
                    </div>
                    <div class="audit-desc">
                        Trạng thái chiến dịch: <b>${sale.status.label}</b>.
                        <c:choose>
                            <c:when test="${sale.status == 'ACTIVE'}">Giá Flash Sale đang được áp dụng tự động trên hệ thống bán lẻ POS và website.</c:when>
                            <c:when test="${sale.status == 'PAUSED'}">Chiến dịch đang tạm dừng; giá bán tự động trở về mức niêm yết thông thường.</c:when>
                            <c:when test="${sale.status == 'ENDED'}">Chiến dịch đã kết thúc; các suất tồn kho trả về trạng thái bán bình thường.</c:when>
                            <c:otherwise>Chiến dịch đang ở trạng thái bản nháp. Admin có thể thêm / xoá suất trước khi kích hoạt; giá Flash Sale tự tính theo HSD lô.</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="audit-item">
                <div class="audit-dot" style="border-color:#2563eb; color:#2563eb"><i class="ti ti-user"></i></div>
                <div class="audit-info">
                    <div style="display:flex; align-items:center; justify-content:space-between">
                        <div class="audit-title">Người tạo chiến dịch</div>
                        <span class="audit-time">Khởi tạo ban đầu</span>
                    </div>
                    <div class="audit-desc">
                        Nhân viên thiết lập: <b><c:out value="${sale.createdBy.fullName}"/></b>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Modal thêm sản phẩm / suất bán từ lô cận hạn --%>
    <c:if test="${draft}">
        <div id="addLotModal" class="modal-backdrop">
            <div class="modal-container">
                <div style="padding:18px 24px; border-bottom:1px solid var(--line); display:flex; justify-content:space-between; align-items:center; background:#fffcf9">
                    <div>
                        <h3 style="margin:0; font-size:18px; color:var(--text-logo); display:flex; align-items:center; gap:8px">
                            <span style="width:32px; height:32px; border-radius:8px; background:#fff7ed; color:#ea580c; display:inline-flex; align-items:center; justify-content:center">
                                <i class="ti ti-bolt"></i>
                            </span>
                            Thêm sản phẩm / Suất bán Flash Sale
                        </h3>
                        <small style="color:var(--text-muted); margin-top:2px; display:block">Chọn lô hàng cận hạn (&lt; 90 ngày) đang lưu kho theo quy tắc FEFO</small>
                    </div>
                    <button type="button" onclick="closeAddModal()" class="act-icon" style="font-size:20px"><i class="ti ti-x"></i></button>
                </div>

                <div style="padding:24px">
                    <c:choose>
                        <c:when test="${not empty redLots}">
                            <form method="post" action="${ctx}/staff/flash-sales/${sale.id}/items" id="addLotForm">
                                ${csrf}
                                <div style="margin-bottom:16px">
                                    <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">
                                        Chọn lô hàng cận hạn <span style="color:#ef4444">*</span> 
                                        <span style="font-weight:normal; color:#ea580c">(${redLots.size()} lô đủ điều kiện theo quy tắc FEFO)</span>
                                    </label>
                                    <select name="lotId" id="lotSelect" required onchange="onLotChange(this)" class="form-control-custom">
                                        <option value="">-- Vui lòng chọn một lô hàng cận hạn --</option>
                                        <c:forEach var="rl" items="${redLots}">
                                            <option value="${rl.lotId}" 
                                                    data-price="${rl.sellingPrice}" 
                                                    data-avail="${rl.availableQty}" 
                                                    data-sku="${rl.sku}" 
                                                    data-exp="${rl.expiryText}" 
                                                    data-days="${rl.daysLeft}"
                                                    data-sale-price="${rl.salePrice}"
                                                    data-discount="${rl.discountPercent}"
                                                    data-name="<c:out value='${rl.productName}'/>">
                                                [Lô #${rl.lotId}] <c:out value="${rl.productName}"/> (SKU: ${rl.sku}) | Còn ${rl.daysLeft} ngày | Tồn: ${rl.availableQty} | Flash Sale <fmt:formatNumber value="${rl.salePrice}" type="number"/>₫ (-${rl.discountPercent}%)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <%-- Box thông tin chi tiết lô đã chọn --%>
                                <div id="lotInfoBox" style="display:none; background:#f8fafc; border:1px solid #e2e8f0; border-radius:14px; padding:14px 18px; margin-bottom:18px; font-size:13px">
                                    <div style="font-weight:700; color:var(--text-logo); margin-bottom:10px; display:flex; align-items:center; gap:6px">
                                        <i class="ti ti-clipboard-list" style="color:#2563eb"></i> Chi tiết thông số lô hàng:
                                    </div>
                                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px">
                                        <div class="metric-card" style="padding:10px 14px">
                                            <small style="color:var(--text-muted); display:block; font-size:11px">HẠN SỬ DỤNG</small>
                                            <b id="infoExpiry" style="color:#dc2626; font-size:14px"></b>
                                            <span class="pill-badge red" style="margin-left:4px">còn <span id="infoDays"></span> ngày</span>
                                        </div>
                                        <div class="metric-card" style="padding:10px 14px">
                                            <small style="color:var(--text-muted); display:block; font-size:11px">GIÁ BÁN NIÊM YẾT</small>
                                            <b id="infoPrice" style="color:#2563eb; font-size:14px"></b>
                                        </div>
                                        <div class="metric-card" style="padding:10px 14px">
                                            <small style="color:var(--text-muted); display:block; font-size:11px">TỒN KHO KHẢ DỤNG</small>
                                            <b id="infoAvail" style="color:#16a34a; font-size:14px"></b> <small>đơn vị</small>
                                        </div>
                                        <div class="metric-card" style="padding:10px 14px">
                                            <small style="color:var(--text-muted); display:block; font-size:11px">MÃ SKU SẢN PHẨM</small>
                                            <code id="infoSku" style="font-size:13px; font-weight:700"></code>
                                        </div>
                                    </div>
                                </div>

                                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:16px; margin-bottom:20px">
                                    <div>
                                        <%-- Giá do hệ thống tự tính theo HSD lô (InventoryPolicy), chốt lúc thêm suất: không nhập tay --%>
                                        <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">Giá Flash Sale (tự tính)</label>
                                        <div id="autoSalePrice" class="form-control-custom" style="font-weight:700; font-size:14px; color:#ea580c; background:#fffaf5">—</div>
                                        <small id="discountHint" style="display:block; font-size:11.5px; color:var(--text-muted); margin-top:5px">
                                            Còn ${deepDiscountDays} ngày trở lên giảm ${discountPercent}%, còn dưới ${deepDiscountDays} ngày giảm ${deepDiscountPercent}%
                                        </small>
                                    </div>
                                    <div>
                                        <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">Số lượng mở bán <span style="color:#ef4444">*</span></label>
                                        <input type="number" name="allocatedQty" id="inputAllocatedQty" min="1" required placeholder="Ví dụ: 10"
                                               class="form-control-custom" style="font-weight:700; font-size:14px">
                                        <small id="qtyHint" style="display:block; font-size:11.5px; color:var(--text-muted); margin-top:5px">Tối đa theo tồn khả dụng của lô</small>
                                    </div>
                                </div>

                                <div style="display:flex; justify-content:flex-end; gap:10px; padding-top:12px; border-top:1px solid var(--line)">
                                    <button type="button" onclick="closeAddModal()" class="btn-pill-outline" style="padding:9px 18px">Hủy bỏ</button>
                                    <button type="submit" class="btn-flashsale" style="padding:9px 22px">
                                        <i class="ti ti-check"></i> Thêm vào chiến dịch
                                    </button>
                                </div>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div style="text-align:center; padding:16px 0;">
                                <div style="width:56px; height:56px; border-radius:50%; background:#fff7ed; color:#ea580c; display:inline-flex; align-items:center; justify-content:center; font-size:28px; margin-bottom:14px">
                                    <i class="ti ti-alert-triangle"></i>
                                </div>
                                <h4 style="margin:0 0 10px; font-size:16px; color:#9a3412">Không có lô hàng cận hạn nào sẵn sàng trong kho</h4>
                                <div style="font-size:13px; color:var(--text-muted); line-height:1.6; margin:0 0 18px; text-align:left; background:#fffaf5; border:1px solid #fed7aa; border-radius:12px; padding:14px 18px;">
                                    Theo <b>Quy định kiểm soát hạn sử dụng (FEFO - BR-63)</b>:<br>
                                    • Chỉ những lô hàng có HSD <b>cận hạn từ ${quarantineDays} đến dưới ${shelfLifeDays} ngày</b> mới được phép bán Flash Sale để kích cầu xả hàng.<br>
                                    • Các lô còn <b>&ge; ${shelfLifeDays} ngày</b> được cam kết giữ bán giá tiêu chuẩn (không bán tháo).<br>
                                    • Các lô còn <b>&lt; ${quarantineDays} ngày</b> bị khóa bán (không được phép mở bán Flash Sale, BR-51).
                                </div>
                                <div style="display:flex; justify-content:center; gap:10px">
                                    <a href="${ctx}/staff/lots" class="btn-pill-outline" style="text-decoration:none"><i class="ti ti-building-warehouse"></i> Quản lý kho lô hàng</a>
                                    <button type="button" onclick="closeAddModal()" class="btn-flashsale" style="padding:8px 20px">Đóng</button>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <script>
            function openAddModal() {
                var modal = document.getElementById('addLotModal');
                if (modal) modal.style.display = 'flex';
            }

            function closeAddModal() {
                var modal = document.getElementById('addLotModal');
                if (modal) modal.style.display = 'none';
            }

            // Close on clicking backdrop
            window.addEventListener('click', function(e) {
                var modal = document.getElementById('addLotModal');
                if (e.target === modal) {
                    closeAddModal();
                }
            });

            function onLotChange(sel) {
                var opt = sel.options[sel.selectedIndex];
                var box = document.getElementById('lotInfoBox');
                var qtyInput = document.getElementById('inputAllocatedQty');
                if (!opt || !opt.value) {
                    box.style.display = 'none';
                    return;
                }
                var price = parseFloat(opt.getAttribute('data-price')) || 0;
                var avail = parseInt(opt.getAttribute('data-avail'), 10) || 0;
                var exp = opt.getAttribute('data-exp') || '';
                var days = opt.getAttribute('data-days') || '';
                var sku = opt.getAttribute('data-sku') || '';

                document.getElementById('infoExpiry').textContent = exp;
                document.getElementById('infoDays').textContent = days;
                document.getElementById('infoPrice').textContent = price.toLocaleString('vi-VN') + '₫';
                document.getElementById('infoAvail').textContent = avail.toLocaleString('vi-VN');
                document.getElementById('infoSku').textContent = sku;
                box.style.display = 'block';

                qtyInput.max = avail;
                document.getElementById('qtyHint').textContent = 'Tối đa ' + avail + ' sản phẩm khả dụng trong lô';
                if (!qtyInput.value || parseInt(qtyInput.value, 10) > avail) {
                    qtyInput.value = Math.min(10, avail);
                }

                var salePrice = parseFloat(opt.getAttribute('data-sale-price')) || 0;
                var discount = opt.getAttribute('data-discount') || '0';
                document.getElementById('autoSalePrice').textContent = salePrice.toLocaleString('vi-VN') + '₫ (-' + discount + '%)';
                document.getElementById('discountHint').textContent =
                    'Tiết kiệm ' + (price - salePrice).toLocaleString('vi-VN') + '₫ so với giá niêm yết';
            }

        </script>
    </c:if>

    <script>
            function filterFlashSaleTable(term) {
                var q = (term || '').trim().toLowerCase();
                var rows = document.querySelectorAll('#flashSaleItemsTable tbody tr.item-row');
                rows.forEach(function(r) {
                    var searchData = r.getAttribute('data-search') || '';
                    if (!q || searchData.indexOf(q) !== -1) {
                        r.style.display = '';
                    } else {
                        r.style.display = 'none';
                    }
                });
            }

            function exportItemsTable() {
                var table = document.getElementById('flashSaleItemsTable');
                if (!table) return;
                var rows = Array.from(table.querySelectorAll('tr'));
                var csv = rows.map(function(row) {
                    var cols = Array.from(row.querySelectorAll('th, td'));
                    return cols.map(function(col) {
                        var text = col.innerText.replace(/"/g, '""').trim();
                        return '"' + text + '"';
                    }).join(',');
                }).join('\n');

                var blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = 'flash-sale-${sale.id}-items.csv';
                link.click();
            }
    </script>
</main>

</body>
</html>
