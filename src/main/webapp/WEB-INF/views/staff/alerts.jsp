<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<%-- Model: lowStockProducts, nearExpiryLots, alertSummary, shelfLifeDays, quarantineDays --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Cảnh báo hạn sử dụng · PetFood</title>
    <meta name="description" content="Giám sát các ngưỡng hạn sử dụng cấp bách, đề xuất Flash Sale giải phóng hàng cận hạn và theo dõi các lô hàng đã hết hạn.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .pill-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            border-radius: var(--radius-pill);
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }
        .pill-badge.red { background: #fee2e2; color: #b91c1c; }
        .pill-badge.orange { background: #ffedd5; color: #c2410c; }
        .pill-badge.yellow { background: #fef3c7; color: #b45309; }
        .pill-badge.dark { background: #3d3028; color: #ffffff; }
        .pill-badge.green { background: #dcfce7; color: #15803d; }
        .pill-badge.gray { background: #f3f4f6; color: #4b5563; }

        .btn-flashsale {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: var(--radius-pill);
            background: linear-gradient(135deg, #ea580c 0%, #c2410c 100%);
            color: #ffffff !important;
            border: 1px solid transparent;
            font-family: var(--font-main);
            font-size: 12px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(234, 88, 12, 0.22);
            transition: all var(--transition);
            white-space: nowrap;
        }
        .btn-flashsale:hover {
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(234, 88, 12, 0.32);
            color: #ffffff !important;
        }
        .btn-flashsale .ti {
            font-size: 15px;
        }

        .btn-dispose {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: var(--radius-pill);
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: #ffffff !important;
            border: 1px solid transparent;
            font-family: var(--font-main);
            font-size: 12px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(220, 38, 38, 0.22);
            transition: all var(--transition);
            white-space: nowrap;
        }
        .btn-dispose:hover {
            background: linear-gradient(135deg, #f87171 0%, #ef4444 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.32);
            color: #ffffff !important;
        }
        .btn-dispose .ti {
            font-size: 15px;
        }

        .lot-action-cell {
            display: inline-flex;
            align-items: center;
            justify-content: flex-end;
            gap: 8px;
        }

        /* Nút Quick Actions ở Header trang Cảnh báo */
        .head-btn-flashsale {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 20px;
            border-radius: 9999px;
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
            color: #ffffff !important;
            font-family: var(--font-main);
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            border: 1px solid transparent;
            cursor: pointer;
            box-shadow: 0 3px 10px rgba(234, 88, 12, 0.28);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            white-space: nowrap;
        }
        .head-btn-flashsale:hover {
            background: linear-gradient(135deg, #fb923c 0%, #f97316 100%);
            box-shadow: 0 6px 18px rgba(234, 88, 12, 0.4);
            transform: translateY(-2px);
            color: #ffffff !important;
        }
        .head-btn-flashsale:active {
            transform: translateY(0);
        }
        .head-btn-flashsale .ti {
            font-size: 17px;
            color: #fef08a;
            filter: drop-shadow(0 0 4px rgba(254, 240, 138, 0.6));
        }

        .head-btn-lots {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 20px;
            border-radius: 9999px;
            background: #ffffff;
            color: #334155 !important;
            font-family: var(--font-main);
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            border: 1.5px solid #e2e8f0;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            white-space: nowrap;
        }
        .head-btn-lots:hover {
            background: #fff7ed;
            border-color: #ea580c;
            color: #ea580c !important;
            box-shadow: 0 4px 14px rgba(234, 88, 12, 0.15);
            transform: translateY(-2px);
        }
        .head-btn-lots:active {
            transform: translateY(0);
        }
        .head-btn-lots .ti {
            font-size: 17px;
            color: #64748b;
            transition: color 0.2s ease;
        }
        .head-btn-lots:hover .ti {
            color: #ea580c;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ KHO &amp; ĐỔI TRẢ</span> <span class="sep">&gt;</span> <span class="current">CẢNH BÁO HẠN SỬ DỤNG</span>
            </div>
            <h1>CẢNH BÁO HẠN SỬ DỤNG KHO</h1>
            <p class="page-sub">Giám sát các ngưỡng hạn sử dụng cấp bách, đề xuất Flash Sale giải phóng hàng cận hạn và theo dõi các lô hàng đã hết hạn.</p>
        </div>

        <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
            <a href="${ctx}/staff/flash-sales" class="head-btn-flashsale">
                <i class="ti ti-bolt"></i>Quản lý Flash Sale
            </a>
            <a href="${ctx}/staff/lots" class="head-btn-lots">
                <i class="ti ti-building-warehouse"></i>Tồn kho theo lô
            </a>
        </div>
    </div>

    <%-- 3 KPI Cards: Thông tin chính xác theo số liệu thực tế hạn dùng kho --%>
    <section class="grid" style="grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; margin-bottom: 20px">
        <%-- Card 1: Lô cận hạn (21-90 ngày) - Ưu tiên Flash Sale --%>
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">LÔ CẬN HẠN (21 - 90 NGÀY)</span>
                <span class="pill-badge orange">CẬN HẠN</span>
            </div>
            <div class="kpi-value" style="color:#ea580c"><c:out value="${alertSummary != null ? alertSummary.redLotCount : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge orange">● Đề xuất bán Flash Sale</span></div>
        </div>

        <%-- Card 2: Lô cấp bách (< 21 ngày) - Chặn bán --%>
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">LÔ CẤP BÁCH (&lt; 21 NGÀY)</span>
                <span class="pill-badge red">CẤP BÁCH</span>
            </div>
            <div class="kpi-value red"><c:out value="${alertSummary != null ? alertSummary.blockedLotCount : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge red">● Đã chặn bán đơn hàng mới</span></div>
        </div>

        <%-- Card 3: Lô đã quá hạn - Tiêu hủy --%>
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">LÔ HÀNG ĐÃ QUÁ HẠN</span>
                <span class="pill-badge dark">QUÁ HẠN</span>
            </div>
            <div class="kpi-value" style="color:#78350f"><c:out value="${alertSummary != null ? alertSummary.expiredLotCount : 0}"/> <small>Lô</small></div>
            <div class="kpi-meta"><span class="badge gray">● Tiêu hủy, không xuất kho</span></div>
        </div>
    </section>

    <%-- Tabs chuyển đổi chế độ xem & Trạng thái FEFO --%>
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; flex-wrap:wrap; gap:10px">
        <div class="screen-tabs" style="margin:0; border:0">
            <button type="button" class="screen-tab-btn active" id="tab-all" onclick="filterTable('ALL', this)">
                <i class="ti ti-alert-triangle" style="margin-right:6px; color:#ea580c"></i>Tất cả lô cần xử lý (${not empty nearExpiryLots ? nearExpiryLots.size() : 0})
            </button>
            <button type="button" class="screen-tab-btn" id="tab-red" onclick="filterTable('RED', this)">
                <i class="ti ti-bolt" style="margin-right:6px; color:#ea580c"></i>Lô cận hạn / Flash Sale (${alertSummary != null ? alertSummary.redLotCount : 0})
            </button>
            <button type="button" class="screen-tab-btn" id="tab-urgent" onclick="filterTable('URGENT', this)">
                <i class="ti ti-trash" style="margin-right:6px; color:#dc2626"></i>Lô cấp bách &amp; quá hạn (${alertSummary != null ? alertSummary.blockedLotCount + alertSummary.expiredLotCount : 0})
            </button>
        </div>

        <div style="font-size:12px; font-weight:700; color:#15803d; display:flex; align-items:center; gap:6px">
            <i class="ti ti-arrows-shuffle" style="font-size:16px"></i>
            Thuật toán điều phối FEFO: <b>Đang hoạt động</b>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="display:flex; align-items:center; gap:6px; font-weight:700; color:var(--text-main); font-size:13px">
            <i class="ti ti-filter" style="font-size:18px; color:#ea580c"></i>
            <span>Bộ lọc:</span>
        </div>
        <div style="flex:1; min-width:260px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="search" id="lotSearchInput" placeholder="Tìm kiếm SKU, Tên sản phẩm, hoặc Số lô..."
                   oninput="applyFilterSearch()"
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select id="levelSelectFilter" onchange="applyFilterSearch()" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="ALL">Ngưỡng hạn: Tất cả cảnh báo</option>
            <option value="RED">Cận hạn 21 - 90 Ngày (Flash Sale)</option>
            <option value="BLOCKED">Cấp bách &lt; 21 Ngày (Chặn bán)</option>
            <option value="EXPIRED">Đã quá hạn sử dụng (Cần hủy)</option>
        </select>

        <button type="button" class="export-btn" onclick="resetAllFilters()">
            <i class="ti ti-rotate"></i>Đặt lại bộ lọc
        </button>
    </div>

    <%-- Main Table --%>
    <div class="panel" style="padding:0; overflow:visible">
        <table id="lotsAlertTable" style="margin:0; border:0; border-radius:0; box-shadow:none">
            <thead>
            <tr>
                <th>SẢN PHẨM &amp; SKU</th>
                <th>MÃ LÔ</th>
                <th>HẠN SỬ DỤNG</th>
                <th>SỐ NGÀY CÒN LẠI</th>
                <th>TỒN KHO HIỆN TẠI</th>
                <th>CHÍNH SÁCH ĐIỀU PHỐI</th>
                <th style="text-align:right">THAO TÁC</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${not empty nearExpiryLots}">
                    <c:forEach var="l" items="${nearExpiryLots}">
                        <tr class="lot-data-row"
                            data-level="${l.level}"
                            data-days="${l.daysLeft}"
                            data-search="${l.sku.toLowerCase()} ${l.productName.toLowerCase()} ${l.id}">
                            <td>
                                <div style="display:flex; align-items:center; gap:10px">
                                    <div class="avatar" style="width:40px; height:40px; font-size:16px; background:#fed7aa; color:#9a3412; display:flex; align-items:center; justify-content:center; border-radius:10px">
                                        <i class="ti ti-package"></i>
                                    </div>
                                    <div>
                                        <b style="color:var(--text-logo)"><c:out value="${l.productName}"/></b>
                                        <div style="font-size:11px; color:var(--text-muted); margin-top:2px">
                                            SKU: <code><c:out value="${l.sku}"/></code> • <span class="pill-badge gray">Kệ kho chuẩn</span>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td><code>#LOT-${l.id}</code></td>
                            <td>
                                <span style="color:#dc2626; font-weight:700">
                                    <i class="ti ti-calendar" style="font-size:13px; margin-right:3px"></i>${l.expiryDateText}
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${l.daysLeft le 0 or l.level == 'EXPIRED'}">
                                        <span class="pill-badge dark">
                                            <i class="ti ti-alert-octagon"></i>Đã quá hạn
                                        </span>
                                    </c:when>
                                    <c:when test="${l.level == 'BLOCKED'}">
                                        <span class="pill-badge red">
                                            <i class="ti ti-alert-triangle"></i>${l.daysLeft} Ngày [Cấp bách]
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pill-badge orange">
                                            <i class="ti ti-clock"></i>${l.daysLeft} Ngày [Cận hạn]
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <b>${l.onHandQty} / ${l.receivedQty} Đơn vị</b>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${l.daysLeft le 0 or l.level == 'EXPIRED'}">
                                        <span style="color:#78350f; font-weight:700">● Ngừng bán - Chờ tiêu hủy</span>
                                    </c:when>
                                    <c:when test="${l.level == 'BLOCKED'}">
                                        <span style="color:#dc2626; font-weight:700">● Chặn bán - Chờ tiêu hủy</span>
                                    </c:when>
                                    <c:when test="${l.daysLeft lt 30}">
                                        <span style="color:#ea580c; font-weight:700">● Ưu tiên Flash Sale (Giảm 70%)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:#ea580c; font-weight:700">● Ưu tiên Flash Sale (Giảm 40%)</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align:right">
                                <div class="lot-action-cell">
                                    <c:choose>
                                        <%-- Lô đã quá hạn hoặc cấp bách (<21 ngày): Tiêu hủy --%>
                                        <c:when test="${l.daysLeft le 0 or l.level == 'EXPIRED' or l.level == 'BLOCKED'}">
                                            <form method="post" action="${ctx}/staff/lots/${l.id}/dispose" style="display:inline; margin:0;" onsubmit="return confirm('Xác nhận tiêu hủy lô hàng #LOT-${l.id} (${l.sku})?\n\nToàn bộ ${l.onHandQty} sản phẩm tồn sẽ được xuất hủy khỏi kho.');">
                                                ${csrf}
                                                <input type="hidden" name="redirectUrl" value="/staff/alerts">
                                                <button type="submit" class="btn-dispose" title="Lập biên bản xuất hủy lô hàng này">
                                                    <i class="ti ti-trash"></i>Tiêu hủy
                                                </button>
                                            </form>
                                        </c:when>

                                        <%-- Lô cận hạn (21-90 ngày): Kích hoạt Flash Sale NGAY LẬP TỨC --%>
                                        <c:otherwise>
                                            <form method="post" action="${ctx}/staff/flash-sales/quick-create" style="display:inline; margin:0;"
                                                  onsubmit="return confirm('Kích hoạt Flash Sale NGAY LẬP TỨC cho lô hàng #LOT-${l.id}?\n\n• Sản phẩm: ${l.productName}\n• Hạn dùng còn: ${l.daysLeft} ngày\n• Mức giảm theo HSD: ${l.daysLeft lt 30 ? '70%' : '40%'}\n• Số lượng xả kho: ${l.onHandQty} đơn vị\n\nChiến dịch sẽ bắt đầu mở bán ngay trên hệ thống!');">
                                                ${csrf}
                                                <input type="hidden" name="lotId" value="${l.id}">
                                                <button type="submit" class="btn-flashsale" title="Kích hoạt Flash Sale ngay lập tức cho lô này (Giảm ${l.daysLeft lt 30 ? '70%' : '40%'})">
                                                    <i class="ti ti-bolt"></i>Tạo Flash Sale
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="7" style="text-align:center; padding:36px; color:var(--text-muted)">
                            <i class="ti ti-circle-check" style="color:#10b981; font-size:28px; vertical-align:middle; margin-right:8px"></i>
                            Hiện tại kho an toàn! Không có lô hàng nào rơi vào diện cận hạn hoặc quá hạn.
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <div class="panel-foot" style="padding:14px 20px; display:flex; justify-content:space-between; align-items:center">
            <span id="lotCountSummaryText">Hiển thị <c:out value="${not empty nearExpiryLots ? nearExpiryLots.size() : 0}"/> lô hàng cần theo dõi</span>
            <small style="color:var(--text-muted)">Cập nhật thời gian thực dựa trên hạn sử dụng đối chiếu với ngày hôm nay</small>
        </div>
    </div>

    <%-- Phần thông tin chính sách & Widget: Sức khỏe Hạn dùng Kho --%>
    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px; margin-top:20px">
        <%-- Khung hướng dẫn chính sách FEFO & Xử lý cận hạn --%>
        <div class="panel" style="margin:0; display:flex; flex-direction:column; justify-content:space-between">
            <div>
                <h3 style="margin:0 0 8px; font-size:15px; display:flex; align-items:center; gap:8px">
                    <i class="ti ti-info-circle" style="color:var(--color-primary)"></i>Chính sách Quản lý Hạn dùng (FEFO)
                </h3>
                <p style="font-size:13px; color:var(--text-muted); line-height:1.5; margin:0 0 14px">
                    Hệ thống tự động áp dụng các quy tắc xuất kho nghiêm ngặt nhằm bảo đảm chất lượng và an toàn dinh dưỡng cho thú cưng:
                </p>
                <div style="display:flex; flex-direction:column; gap:10px; font-size:12px">
                    <div style="display:flex; align-items:flex-start; gap:8px">
                        <span class="pill-badge green" style="margin-top:2px">&ge; 90 Ngày</span>
                        <div><b>Hạn tối ưu (An toàn):</b> Đủ điều kiện bán lẻ thông thường và xuất kho tự động theo thứ tự FEFO.</div>
                    </div>
                    <div style="display:flex; align-items:flex-start; gap:8px">
                        <span class="pill-badge orange" style="margin-top:2px">21 - 90 Ngày</span>
                        <div><b>Cận hạn sử dụng:</b> Dừng bán lẻ thông thường; ưu tiên đưa vào chiến dịch Flash Sale với mức chiết khấu hấp dẫn để thu hồi vốn.</div>
                    </div>
                    <div style="display:flex; align-items:flex-start; gap:8px">
                        <span class="pill-badge red" style="margin-top:2px">&lt; 21 Ngày / Quá hạn</span>
                        <div><b>Cấp bách &amp; Hết hạn:</b> Chặn bán toàn bộ; xuất hủy tiêu hủy hàng theo quy định an toàn (BR-51).</div>
                    </div>
                </div>
            </div>
            <div style="margin-top:16px; padding-top:12px; border-top:1px dashed var(--line); font-size:12px; color:var(--text-muted)">
                Mốc cam kết hạn dùng: <b>${shelfLifeDays} ngày</b> • Ngưỡng chặn bán cấp bách: <b>${quarantineDays} ngày</b>
            </div>
        </div>

        <%-- Widget: Sức khỏe Hạn dùng Kho (Số liệu thực tế chính xác) --%>
        <div class="wh-health-card" style="margin:0">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px">
                <h3 style="margin:0; font-size:15px; display:flex; align-items:center; gap:8px">
                    <i class="ti ti-heart-rate-monitor" style="color:#ea580c"></i>Sức khỏe Hạn dùng Kho
                </h3>
                <span class="pill-badge gray">Tổng cộng ${alertSummary != null ? alertSummary.totalInStockLots : 0} Lô tồn kho</span>
            </div>
            <p style="font-size:12px; color:var(--text-muted); margin:0 0 14px">Phân bổ tỷ lệ thực tế các lô hàng đang lưu kho theo thời hạn sử dụng còn lại.</p>

            <%-- Cấp bách & Quá hạn --%>
            <div class="wh-health-row">
                <span>Cấp bách &lt; 21 Ngày (${alertSummary != null ? alertSummary.blockedLotCount + alertSummary.expiredLotCount : 0} Lô)</span>
                <span style="color:#ef4444; font-weight:800">${alertSummary != null ? alertSummary.urgentPercent : 0}%</span>
            </div>
            <div class="wh-progress-track">
                <div class="wh-progress-fill fill-urgent" style="width:${alertSummary != null ? alertSummary.urgentPercent : 0}%"></div>
            </div>

            <%-- Cận hạn Flash Sale --%>
            <div class="wh-health-row">
                <span>Cảnh báo 21 - 90 Ngày (${alertSummary != null ? alertSummary.redLotCount : 0} Lô)</span>
                <span style="color:#f59e0b; font-weight:800">${alertSummary != null ? alertSummary.redPercent : 0}%</span>
            </div>
            <div class="wh-progress-track">
                <div class="wh-progress-fill fill-warning" style="width:${alertSummary != null ? alertSummary.redPercent : 0}%"></div>
            </div>

            <%-- An toàn / Tối ưu --%>
            <div class="wh-health-row">
                <span>Tối ưu &ge; 90 Ngày (${alertSummary != null ? alertSummary.safeLotCount : 0} Lô)</span>
                <span style="color:#16a34a; font-weight:800">${alertSummary != null ? alertSummary.safePercent : 0}%</span>
            </div>
            <div class="wh-progress-track">
                <div class="wh-progress-fill" style="background:#16a34a; width:${alertSummary != null ? alertSummary.safePercent : 0}%"></div>
            </div>
        </div>
    </div>
</main>

<script>
    var currentTabFilter = 'ALL';

    function filterTable(type, btn) {
        currentTabFilter = type;
        document.querySelectorAll('.screen-tab-btn').forEach(function(b) {
            b.classList.remove('active');
        });
        if (btn) btn.classList.add('active');
        applyFilterSearch();
    }

    function applyFilterSearch() {
        var query = (document.getElementById('lotSearchInput').value || '').trim().toLowerCase();
        var selectVal = document.getElementById('levelSelectFilter').value;
        var rows = document.querySelectorAll('#lotsAlertTable tbody tr.lot-data-row');
        var visibleCount = 0;

        rows.forEach(function(r) {
            var level = r.getAttribute('data-level');
            var searchData = r.getAttribute('data-search') || '';
            var matchesTab = true;

            if (currentTabFilter === 'RED') {
                matchesTab = (level === 'RED');
            } else if (currentTabFilter === 'URGENT') {
                matchesTab = (level === 'BLOCKED' || level === 'EXPIRED');
            }

            var matchesSelect = true;
            if (selectVal !== 'ALL') {
                matchesSelect = (level === selectVal);
            }

            var matchesQuery = true;
            if (query.length > 0) {
                matchesQuery = searchData.indexOf(query) !== -1;
            }

            if (matchesTab && matchesSelect && matchesQuery) {
                r.style.display = '';
                visibleCount++;
            } else {
                r.style.display = 'none';
            }
        });

        var summaryText = document.getElementById('lotCountSummaryText');
        if (summaryText) {
            summaryText.innerText = 'Hiển thị ' + visibleCount + ' lô hàng phù hợp bộ lọc';
        }
    }

    function resetAllFilters() {
        document.getElementById('lotSearchInput').value = '';
        document.getElementById('levelSelectFilter').value = 'ALL';
        var tabAllBtn = document.getElementById('tab-all');
        filterTable('ALL', tabAllBtn);
    }

    function toggleSelectAll(master) {
        var checkboxes = document.querySelectorAll('.row-checkbox');
        checkboxes.forEach(function(cb) {
            var row = cb.closest('tr');
            if (row && row.style.display !== 'none') {
                cb.checked = master.checked;
            }
        });
    }

</script>
</body>
</html>
