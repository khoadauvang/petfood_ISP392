<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Yêu cầu trả hàng #${ret.id} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .rd-layout {
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 1024px) {
            .rd-layout {
                grid-template-columns: 1fr;
            }
        }
        .action-card {
            background: linear-gradient(180deg, #fffaf5 0%, #ffffff 100%);
            border: 1px solid #ffd8b8;
            border-radius: 18px;
            box-shadow: 0 4px 16px rgba(249, 115, 22, 0.08);
            padding: 22px;
            margin-bottom: 20px;
        }
        .action-card-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: #c2410c;
            margin-bottom: 14px;
        }
        .info-card {
            background: #ffffff;
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: var(--shadow-card);
            padding: 22px;
            margin-bottom: 20px;
        }
        .info-card-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .06em;
            color: var(--text-logo);
            margin-bottom: 16px;
            padding-bottom: 10px;
            border-bottom: 1px dashed var(--line);
        }
        .info-card-title i {
            color: var(--color-primary);
            font-size: 17px;
        }
        .user-avatar-badge {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            background: linear-gradient(135deg, #ffedd5 0%, #fed7aa 100%);
            color: #ea580c;
            font-weight: 800;
            font-size: 18px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(234, 88, 12, 0.15);
        }
        .rd-item-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .rd-item-table th {
            background: var(--surface-soft);
            color: var(--text-muted);
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .06em;
            padding: 12px 14px;
            border-bottom: 1px solid var(--line);
            text-align: left;
        }
        .rd-item-table td {
            padding: 14px;
            border-bottom: 1px solid #f8f1eb;
            vertical-align: middle;
        }
        .rd-item-table tr:hover td {
            background: #fffaf5;
        }
        .rd-item-table tr:last-child td {
            border-bottom: 0;
        }
        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 16px;
            margin-top: 14px;
        }
        .gallery-item {
            position: relative;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid var(--line);
            background: #0f172a;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            aspect-ratio: 1 / 1;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all var(--transition);
        }
        .gallery-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
            border-color: #fdba74;
        }
        .gallery-item img, .gallery-item video {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .gallery-badge {
            position: absolute;
            top: 8px;
            left: 8px;
            background: rgba(15, 23, 42, 0.75);
            backdrop-filter: blur(4px);
            color: #fff;
            padding: 3px 8px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            pointer-events: none;
        }
        .bank-card {
            background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
            border: 1px solid #fed7aa;
            border-radius: 14px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .bank-num {
            font-family: 'Courier New', Courier, monospace;
            font-size: 17px;
            font-weight: 800;
            letter-spacing: 1.5px;
            color: #9a3412;
        }
        .audit-list {
            list-style: none;
            padding: 0;
            margin: 0;
            position: relative;
        }
        .audit-list::before {
            content: "";
            position: absolute;
            left: 14px;
            top: 10px;
            bottom: 10px;
            width: 2px;
            background: var(--line);
        }
        .audit-item {
            position: relative;
            padding-left: 36px;
            margin-bottom: 16px;
        }
        .audit-item:last-child {
            margin-bottom: 0;
        }
        .audit-icon {
            position: absolute;
            left: 3px;
            top: 0;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: #fff;
            border: 2px solid var(--color-primary);
            color: var(--color-primary);
            display: grid;
            place-items: center;
            font-size: 11px;
            z-index: 2;
        }
        .audit-item.done .audit-icon {
            background: #10b981;
            border-color: #10b981;
            color: #fff;
        }
        .audit-item.rejected .audit-icon {
            background: #ef4444;
            border-color: #ef4444;
            color: #fff;
        }
        .audit-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-logo);
        }
        .audit-time {
            font-size: 11px;
            color: var(--text-muted);
            margin-top: 2px;
        }
        .inspect-box {
            background: #ffffff;
            border: 1px solid #ffd8b8;
            border-radius: 16px;
            padding: 18px;
            margin-bottom: 14px;
            box-shadow: 0 2px 10px rgba(249, 115, 22, 0.05);
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <%-- Header trang & Breadcrumb --%>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ KHO &amp; ĐỔI TRẢ</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/returns" style="color:inherit; text-decoration:none;">QUẢN LÝ TRẢ HÀNG</a>
                <span class="sep">&gt;</span>
                <span class="current">CHI TIẾT YÊU CẦU #${ret.id}</span>
            </div>
            <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
                <h1 style="margin:0">YÊU CẦU TRẢ HÀNG #${ret.id}</h1>
                <c:choose>
                    <c:when test="${ret.status == 'REQUESTED'}">
                        <span class="pill-badge gold"><i class="ti ti-clock-hour-4"></i>Chờ duyệt</span>
                    </c:when>
                    <c:when test="${ret.status == 'APPROVED'}">
                        <span class="pill-badge blue"><i class="ti ti-check"></i>Đã duyệt, chờ nhận hàng</span>
                    </c:when>
                    <c:when test="${ret.status == 'RECEIVED'}">
                        <span class="pill-badge purple"><i class="ti ti-package"></i>Đã nhận hàng trả</span>
                    </c:when>
                    <c:when test="${ret.status == 'INSPECTED'}">
                        <span class="pill-badge orange"><i class="ti ti-search"></i>Đã thẩm định</span>
                    </c:when>
                    <c:when test="${ret.status == 'REFUNDED'}">
                        <span class="pill-badge green"><i class="ti ti-cash"></i>Đã hoàn tiền</span>
                    </c:when>
                    <c:when test="${ret.status == 'CLOSED'}">
                        <span class="pill-badge gray"><i class="ti ti-circle-x"></i>Đã đóng</span>
                    </c:when>
                    <c:when test="${ret.status == 'REJECTED'}">
                        <span class="pill-badge red"><i class="ti ti-ban"></i>Từ chối</span>
                    </c:when>
                    <c:otherwise>
                        <span class="pill-badge gray">${ret.status.label}</span>
                    </c:otherwise>
                </c:choose>

                <span class="pill-badge orange">
                    <i class="ti ti-alert-circle"></i>${ret.reason.label}
                </span>
                <span class="pill-badge gray">
                    <i class="ti ti-receipt"></i>Đơn #ORD-${ret.orderId}
                </span>
            </div>
            <p class="page-sub" style="margin-top:6px">
                Gửi yêu cầu: <b>${ret.createdAtText}</b> · Phương thức: ${ret.paymentMethod.label} (${ret.paymentStatus.label}) · Mã phiếu: #RR-00${ret.id}
            </p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <a href="${ctx}/staff/returns" class="btn-pill-outline">
                <i class="ti ti-arrow-left"></i>Quay lại danh sách
            </a>
            <a href="${ctx}/staff/orders/${ret.orderId}" class="btn-pill-outline" target="_blank" title="Mở đơn hàng gốc ở tab mới">
                <i class="ti ti-external-link"></i>Xem đơn hàng gốc
            </a>
        </div>
    </div>

    <%-- Banner trạng thái nổi bật --%>
    <c:choose>
        <c:when test="${ret.status == 'REJECTED'}">
            <div class="urgent-banner" style="background:#fef2f2; border-color:#fecaca">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#dc2626"><i class="ti ti-circle-x"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#fee2e2; color:#991b1b">Yêu cầu đã bị từ chối</span>
                        <div class="urgent-text" style="color:#991b1b">
                            Từ chối lúc <b>${ret.reviewedText}</b>. Lý do từ chối: <strong><c:out value="${ret.rejectReason}"/></strong>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:when test="${ret.status == 'REQUESTED'}">
            <div class="urgent-banner">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#ea580c"><i class="ti ti-alert-triangle"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#ffedd5; color:#c2410c">Cần xử lý phê duyệt</span>
                        <div class="urgent-text">
                            Khách hàng gửi yêu cầu trả hàng với lý do: <strong>${ret.reason.label}</strong>. Vui lòng kiểm tra mô tả, hình ảnh/video bằng chứng và đưa ra quyết định Duyệt hoặc Từ chối.
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:when test="${ret.status == 'APPROVED'}">
            <div class="urgent-banner" style="background:#eff6ff; border-color:#bfdbfe">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#2563eb"><i class="ti ti-truck"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#dbeafe; color:#1e40af">Chờ nhận hàng trả về kho</span>
                        <div class="urgent-text" style="color:#1e40af">
                            Yêu cầu đã được duyệt (${ret.reviewedText}). Khách hàng đang tiến hành gửi sản phẩm về sàn kho. Khi đã nhận kiện hàng, vui lòng bấm <strong>"Xác nhận đã nhận hàng"</strong>.
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:when test="${ret.status == 'RECEIVED'}">
            <div class="urgent-banner" style="background:#f5f3ff; border-color:#ddd6fe">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#7c3aed"><i class="ti ti-package"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#ede9fe; color:#5b21b6">Đã nhận hàng – Cần thẩm định</span>
                        <div class="urgent-text" style="color:#5b21b6">
                            Đã nhận kiện hàng trả lúc <b>${ret.receivedAtText}</b>. Vui lòng thực hiện thẩm định tình trạng từng món bên dưới để quyết định tái nhập kho hay tiêu huỷ và xác nhận tiền hoàn.
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:when test="${ret.status == 'INSPECTED'}">
            <div class="urgent-banner" style="background:#ecfdf5; border-color:#a7f3d0">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#059669"><i class="ti ti-cash"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#d1fae5; color:#065f46">Chờ chuyển khoản hoàn tiền</span>
                        <div class="urgent-text" style="color:#065f46">
                            Đã thẩm định hoàn tất bởi <b>${ret.inspectedByName}</b>. Tổng số tiền cần hoàn cho khách: <strong style="font-size:16px; color:#047857">₫<fmt:formatNumber value="${ret.refundTotal}" type="number"/></strong>. Thực hiện chuyển khoản rồi bấm xác nhận bên dưới.
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
        <c:when test="${ret.status == 'REFUNDED'}">
            <div class="urgent-banner" style="background:#f0fdf4; border-color:#bbf7d0">
                <div class="urgent-left">
                    <span class="urgent-icon" style="background:#16a34a"><i class="ti ti-circle-check"></i></span>
                    <div>
                        <span class="urgent-tag" style="background:#dcfce7; color:#15803d">Hoàn tất hoàn tiền</span>
                        <div class="urgent-text" style="color:#15803d">
                            Đã hoàn tất hoàn trả số tiền <strong>₫<fmt:formatNumber value="${ret.refundTotal}" type="number"/></strong> vào lúc <b>${ret.refundedAtText}</b>.
                        </div>
                    </div>
                </div>
            </div>
        </c:when>
    </c:choose>

    <%-- Thanh tiến trình 5 bước trực quan theo BR-36 --%>
    <div class="panel" style="margin-bottom:20px; padding:18px 24px">
        <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:12px">
            QUY TRÌNH XỬ LÝ YÊU CẦU ĐỔI TRẢ (BR-36)
        </div>
        <c:set var="stepIdx" value="${ret.status == 'REQUESTED' ? 1 : (ret.status == 'APPROVED' ? 2 : (ret.status == 'RECEIVED' ? 3 : (ret.status == 'INSPECTED' ? 4 : 5)))}"/>
        <c:if test="${ret.status == 'REJECTED'}"><c:set var="stepIdx" value="2"/></c:if>

        <div class="order-stepper">
            <%-- Bước 1: Gửi yêu cầu --%>
            <div class="stepper-step completed">
                <div class="stepper-circle"><i class="ti ti-send"></i></div>
                <span class="stepper-label">Gửi yêu cầu</span>
                <span class="stepper-time">${ret.createdAtText}</span>
            </div>

            <%-- Bước 2: Duyệt yêu cầu --%>
            <div class="stepper-step ${ret.status == 'REJECTED' ? 'active' : (stepIdx > 2 || ret.status == 'REFUNDED' || ret.status == 'CLOSED' ? 'completed' : (ret.status == 'REQUESTED' ? 'active' : ''))}">
                <div class="stepper-circle" style="${ret.status == 'REJECTED' ? 'background:#ef4444; border-color:#ef4444; color:#fff;' : ''}">
                    <i class="ti ${ret.status == 'REJECTED' ? 'ti-x' : 'ti-check'}"></i>
                </div>
                <span class="stepper-label">${ret.status == 'REJECTED' ? 'Từ chối' : 'Duyệt yêu cầu'}</span>
                <span class="stepper-time">
                    <c:choose>
                        <c:when test="${not empty ret.reviewedText}">
                            <c:choose>
                                <c:when test="${ret.reviewedText.contains(' · ')}">
                                    ${ret.reviewedText.substring(0, ret.reviewedText.indexOf(' · '))}<br><small style="color:#64748b">${ret.reviewedText.substring(ret.reviewedText.indexOf(' · ') + 3)}</small>
                                </c:when>
                                <c:otherwise>${ret.reviewedText}</c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>${ret.status == 'REQUESTED' ? 'Đang chờ' : '--'}</c:otherwise>
                    </c:choose>
                </span>
            </div>

            <%-- Bước 3: Nhận hàng trả --%>
            <div class="stepper-step ${stepIdx > 3 || ret.status == 'REFUNDED' || ret.status == 'CLOSED' ? 'completed' : (ret.status == 'APPROVED' ? 'active' : '')}">
                <div class="stepper-circle"><i class="ti ti-package-import"></i></div>
                <span class="stepper-label">Nhận hàng trả</span>
                <span class="stepper-time">${not empty ret.receivedAtText ? ret.receivedAtText : (ret.status == 'APPROVED' ? 'Đang chờ gửi' : '--')}</span>
            </div>

            <%-- Bước 4: Thẩm định --%>
            <div class="stepper-step ${stepIdx > 4 || ret.status == 'REFUNDED' || ret.status == 'CLOSED' ? 'completed' : (ret.status == 'RECEIVED' ? 'active' : '')}">
                <div class="stepper-circle"><i class="ti ti-clipboard-check"></i></div>
                <span class="stepper-label">Thẩm định kho</span>
                <span class="stepper-time">${not empty ret.inspectedByName ? ret.inspectedByName : (ret.status == 'RECEIVED' ? 'Đang thẩm định' : '--')}</span>
            </div>

            <%-- Bước 5: Hoàn tiền / Đóng --%>
            <div class="stepper-step ${ret.status == 'REFUNDED' || ret.status == 'CLOSED' ? 'completed' : (ret.status == 'INSPECTED' ? 'active' : '')}">
                <div class="stepper-circle"><i class="ti ti-cash"></i></div>
                <span class="stepper-label">${ret.status == 'CLOSED' ? 'Đóng đơn' : 'Hoàn tiền'}</span>
                <span class="stepper-time">${not empty ret.refundedAtText ? ret.refundedAtText : (ret.status == 'INSPECTED' ? 'Chờ hoàn tiền' : '--')}</span>
            </div>
        </div>
    </div>

    <%-- Bố cục 2 cột chính --%>
    <div class="rd-layout">
        <%-- Cột bên trái: Danh sách sản phẩm, Hình ảnh bằng chứng, Form thẩm định --%>
        <div>
            <%-- 1. Bảng sản phẩm hoàn trả --%>
            <div class="info-card">
                <div class="info-card-title">
                    <span style="display:flex; align-items:center; gap:8px">
                        <i class="ti ti-box"></i>
                        <span>DANH SÁCH SẢN PHẨM HOÀN TRẢ</span>
                    </span>
                    <span class="badge orange">${ret.lines.size()} sản phẩm</span>
                </div>

                <div style="overflow-x:auto">
                    <table class="rd-item-table">
                        <thead>
                        <tr>
                            <th>SẢN PHẨM</th>
                            <th style="text-align:center">SL TRẢ / ĐÃ MUA</th>
                            <th style="text-align:center">TÌNH TRẠNG</th>
                            <th style="text-align:right">TỐI ĐA HOÀN</th>
                            <th style="text-align:center">THẨM ĐỊNH</th>
                            <th style="text-align:right">TIỀN HOÀN</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="l" items="${ret.lines}">
                            <tr>
                                <td>
                                    <div style="display:flex; align-items:center; gap:12px">
                                        <div style="width:40px; height:40px; border-radius:10px; background:#fff7ed; border:1px solid #ffd8b8; display:grid; place-items:center; color:#ea580c; flex-shrink:0">
                                            <i class="ti ti-paw" style="font-size:20px"></i>
                                        </div>
                                        <div>
                                            <b style="color:var(--text-logo); font-size:13px; display:block">
                                                <c:out value="${l.productName}"/>
                                            </b>
                                            <div style="display:flex; align-items:center; gap:6px; margin-top:2px">
                                                <c:if test="${not empty l.sku}">
                                                    <span style="font-size:11px; color:var(--text-muted)">SKU: ${l.sku}</span>
                                                </c:if>
                                                <c:if test="${l.promotion}">
                                                    <span class="pill-badge red" style="font-size:10px; padding:1px 6px">Chương trình</span>
                                                </c:if>
                                                <c:if test="${l.flashSale}">
                                                    <span class="pill-badge red" style="font-size:10px; padding:1px 6px">Flash Sale</span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td style="text-align:center">
                                    <b style="font-size:14px; color:#c2410c">${l.quantity}</b>
                                    <span style="color:var(--text-muted); font-size:12px">/ ${l.orderedQty}</span>
                                </td>
                                <td style="text-align:center">
                                    <c:choose>
                                        <c:when test="${l.opened}">
                                            <span class="pill-badge gold" style="font-size:11px">Đã mở bao bì</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge green" style="font-size:11px">Chưa mở (Nguyên seal)</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:right; font-weight:700">
                                    ₫<fmt:formatNumber value="${l.maxRefund}" type="number"/>
                                </td>
                                <td style="text-align:center">
                                    <c:choose>
                                        <c:when test="${not empty l.inspectionResult}">
                                            <span class="pill-badge ${l.inspectionResult.name() == 'RESTOCKED' ? 'green' : 'red'}" style="font-size:11px">
                                                ${l.inspectionResult.label}
                                            </span>
                                            <c:if test="${not empty l.inspectionNote}">
                                                <div style="font-size:11px; color:var(--text-muted); margin-top:2px">
                                                    <c:out value="${l.inspectionNote}"/>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:var(--text-placeholder)">Chưa thẩm định</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align:right">
                                    <c:choose>
                                        <c:when test="${l.refundAmount != null}">
                                            <b style="color:#16a34a; font-size:14px">₫<fmt:formatNumber value="${l.refundAmount}" type="number"/></b>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:var(--text-placeholder)">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                        <c:if test="${ret.status == 'INSPECTED' or ret.status == 'REFUNDED' or ret.status == 'CLOSED'}">
                            <tfoot>
                            <tr style="background:#fffaf5">
                                <td colspan="5" style="text-align:right; font-weight:800; text-transform:uppercase; font-size:12px; color:var(--text-logo); padding:14px">
                                    TỔNG TIỀN HOÀN THỰC TẾ:
                                </td>
                                <td style="text-align:right; font-size:16px; font-weight:800; color:#16a34a; padding:14px">
                                    ₫<fmt:formatNumber value="${ret.refundTotal}" type="number"/>
                                </td>
                            </tr>
                            </tfoot>
                        </c:if>
                    </table>
                </div>
            </div>

            <%-- 2. Thẩm định chi tiết (chỉ hiển thị khi status == 'RECEIVED') --%>
            <c:if test="${ret.status == 'RECEIVED'}">
                <div class="info-card" style="border:1.5px solid #a855f7; box-shadow:0 4px 20px rgba(168, 85, 247, 0.12)">
                    <div class="info-card-title" style="color:#7e22ce; border-bottom-color:#e9d5ff">
                        <span style="display:flex; align-items:center; gap:8px">
                            <i class="ti ti-clipboard-check" style="color:#9333ea"></i>
                            <span>THẨM ĐỊNH TỪNG SẢN PHẨM TẠI KHO (BR-38)</span>
                        </span>
                        <span class="pill-badge purple">BƯỚC THẨM ĐỊNH</span>
                    </div>

                    <p style="font-size:13px; color:var(--text-muted); margin:0 0 16px">
                        Vui lòng kiểm tra thực tế từng món hàng trả. Chọn <strong>Tái nhập về lô gốc</strong> (hàng còn nguyên seal) hoặc <strong>Tiêu huỷ</strong> (hàng lỗi/hỏng/đã bóc). Bỏ tick ô <em>"Hoàn tiền"</em> nếu khách không đủ điều kiện nhận hoàn.
                    </p>

                    <form:form method="post" action="${ctx}/staff/returns/${ret.id}/inspect" modelAttribute="inspectForm">
                        <c:forEach var="l" items="${ret.lines}" varStatus="s">
                            <div class="inspect-box">
                                <form:hidden path="lines[${s.index}].returnItemId"/>
                                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px; flex-wrap:wrap; gap:8px">
                                    <div>
                                        <b style="font-size:14px; color:var(--text-logo)"><c:out value="${l.productName}"/></b>
                                        <div style="font-size:12px; color:var(--text-muted); margin-top:2px">
                                            Số lượng trả: <b style="color:#ea580c">${l.quantity}</b> · Tình trạng: ${l.opened ? 'Đã mở bao bì' : 'Chưa mở'}
                                        </div>
                                    </div>
                                    <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:10px; padding:6px 12px">
                                        <label style="display:flex; align-items:center; gap:8px; font-weight:700; color:#065f46; cursor:pointer; font-size:13px">
                                            <form:checkbox path="lines[${s.index}].refund" style="accent-color:#10b981; width:16px; height:16px"/>
                                            Đồng ý hoàn: ₫<fmt:formatNumber value="${l.maxRefund}" type="number"/>
                                        </label>
                                    </div>
                                </div>

                                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; align-items:center">
                                    <div>
                                        <label style="font-size:12px; font-weight:700; color:var(--text-muted); display:block; margin-bottom:6px">
                                            KẾT QUẢ THẨM ĐỊNH <span style="color:#ef4444">*</span>
                                        </label>
                                        <div style="display:flex; gap:14px; flex-wrap:wrap">
                                            <c:forEach var="r" items="${inspectionResults}">
                                                <label style="display:inline-flex; align-items:center; gap:6px; font-size:13px; font-weight:600; cursor:pointer">
                                                    <form:radiobutton path="lines[${s.index}].result" value="${r}" required="required" style="accent-color:#9333ea"/>
                                                    ${r.label}
                                                </label>
                                            </c:forEach>
                                        </div>
                                    </div>

                                    <div>
                                        <label style="font-size:12px; font-weight:700; color:var(--text-muted); display:block; margin-bottom:6px">
                                            GHI CHÚ KIỂM HÀNG
                                        </label>
                                        <form:input path="lines[${s.index}].note" maxlength="255" placeholder="Nhập ghi chú tình trạng (nếu có)..."
                                                    style="width:100%; padding:8px 12px; border-radius:10px; border:1px solid var(--line); font-size:13px"/>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>

                        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding-top:14px; border-top:1px dashed var(--line); flex-wrap:wrap; gap:10px">
                            <span style="font-size:12px; color:var(--text-muted)">
                                <i class="ti ti-info-circle"></i> "Tái nhập" sẽ tự động cộng số lượng về đúng lô kho đã xuất ban đầu.
                            </span>
                            <button type="submit" class="btn-flashsale" style="background:linear-gradient(135deg, #9333ea 0%, #7e22ce 100%); box-shadow:0 2px 10px rgba(147, 51, 234, 0.3)">
                                <i class="ti ti-check"></i>Lưu kết quả thẩm định kho
                            </button>
                        </div>
                    </form:form>
                </div>
            </c:if>

            <%-- 3. Hình ảnh / Video bằng chứng từ khách hàng --%>
            <div class="info-card">
                <div class="info-card-title">
                    <span style="display:flex; align-items:center; gap:8px">
                        <i class="ti ti-photo"></i>
                        <span>HÌNH ẢNH / VIDEO BẰNG CHỨNG TỪ KHÁCH HÀNG</span>
                    </span>
                    <span class="badge ${empty ret.media ? 'gray' : 'orange'}">${empty ret.media ? 0 : ret.media.size()} tệp đính kèm</span>
                </div>

                <c:choose>
                    <c:when test="${not empty ret.media}">
                        <div class="gallery-grid">
                            <c:forEach var="m" items="${ret.media}">
                                <div class="gallery-item">
                                    <c:choose>
                                        <c:when test="${m.video}">
                                            <span class="gallery-badge"><i class="ti ti-video"></i> Video</span>
                                            <video src="${ctx}<c:out value='${m.url}'/>" controls preload="metadata"></video>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="gallery-badge"><i class="ti ti-photo"></i> Ảnh</span>
                                            <a href="${ctx}<c:out value='${m.url}'/>" target="_blank" style="display:block; width:100%; height:100%">
                                                <img src="${ctx}<c:out value='${m.url}'/>" alt="Bằng chứng trả hàng">
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align:center; padding:32px 16px; color:var(--text-muted)">
                            <i class="ti ti-photo-off" style="font-size:36px; opacity:0.4; display:block; margin-bottom:8px"></i>
                            <b>Khách hàng không đính kèm hình ảnh hoặc video</b>
                            <p style="font-size:12px; margin:4px 0 0">Yêu cầu được gửi chỉ kèm theo mô tả bằng văn bản.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- Cột bên phải: Khối Thao tác nghiệp vụ, Thông tin khách & đơn, Lý do, Tài khoản nhận hoàn, Audit trail --%>
        <div>
            <%-- Khối Thao tác nghiệp vụ (Action Card) --%>
            <div class="action-card">
                <div class="action-card-title">
                    <i class="ti ti-settings"></i>
                    <span>THAO TÁC XỬ LÝ NGHIỆP VỤ</span>
                </div>

                <c:choose>
                    <%-- 1. Khi đang REQUESTED --%>
                    <c:when test="${ret.status == 'REQUESTED'}">
                        <div style="margin-bottom:16px">
                            <form method="post" action="${ctx}/staff/returns/${ret.id}/approve">
                                ${csrf}
                                <button type="submit" class="btn-flashsale" style="width:100%; font-size:14px; padding:12px; justify-content:center">
                                    <i class="ti ti-check" style="font-size:18px"></i> Duyệt chấp thuận yêu cầu
                                </button>
                            </form>
                            <small style="color:var(--text-muted); display:block; margin-top:6px; text-align:center; font-size:12px">
                                Khách hàng sẽ nhận thông báo để gửi kiện hàng về kho.
                            </small>
                        </div>

                        <div style="border-top:1px dashed #ffd8b8; padding-top:16px">
                            <b style="display:block; font-size:12px; color:#991b1b; text-transform:uppercase; margin-bottom:8px">
                                Từ chối yêu cầu này:
                            </b>
                            <form method="post" action="${ctx}/staff/returns/${ret.id}/reject">
                                ${csrf}
                                <div style="margin-bottom:10px">
                                    <textarea name="rejectReason" maxlength="255" rows="3" required
                                              placeholder="Nhập lý do từ chối để thông báo đến khách hàng..."
                                              style="width:100%; padding:10px 12px; border-radius:12px; border:1px solid #fca5a5; font-size:13px; font-family:inherit; resize:vertical"></textarea>
                                </div>
                                <button type="submit" class="btn-pill-danger" style="width:100%; justify-content:center; padding:10px; font-size:13px">
                                    <i class="ti ti-ban"></i> Từ chối yêu cầu trả hàng
                                </button>
                            </form>
                        </div>
                    </c:when>

                    <%-- 2. Khi đang APPROVED: Chờ khách gửi hàng -> bấm Đã nhận hàng --%>
                    <c:when test="${ret.status == 'APPROVED'}">
                        <div>
                            <form method="post" action="${ctx}/staff/returns/${ret.id}/receive">
                                ${csrf}
                                <button type="submit" class="btn-flashsale" style="width:100%; font-size:14px; padding:12px; justify-content:center; background:linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); box-shadow:0 2px 10px rgba(37, 99, 235, 0.3)">
                                    <i class="ti ti-package-import" style="font-size:18px"></i> Xác nhận đã nhận hàng tại kho
                                </button>
                            </form>
                            <small style="color:var(--text-muted); display:block; margin-top:8px; text-align:center; font-size:12px">
                                Bấm khi kiện hàng hoàn từ đơn vị vận chuyển đã giao tới kho.
                            </small>
                        </div>
                    </c:when>

                    <%-- 3. Khi đang RECEIVED: Hướng dẫn thẩm định --%>
                    <c:when test="${ret.status == 'RECEIVED'}">
                        <div style="background:#f5f3ff; border:1px solid #ddd6fe; border-radius:12px; padding:14px; text-align:center">
                            <i class="ti ti-arrow-left" style="font-size:24px; color:#7c3aed; display:block; margin-bottom:6px"></i>
                            <b style="font-size:13px; color:#5b21b6">Đang chờ lưu kết quả thẩm định</b>
                            <p style="font-size:12px; color:#6b21a8; margin:4px 0 0">
                                Hãy hoàn tất việc chọn <em>Tái nhập</em> hoặc <em>Tiêu huỷ</em> ở khung thẩm định bên cạnh và nhấn nút Lưu.
                            </p>
                        </div>
                    </c:when>

                    <%-- 4. Khi đang INSPECTED: Chờ chuyển khoản hoàn tiền --%>
                    <c:when test="${ret.status == 'INSPECTED'}">
                        <div>
                            <div style="background:#ecfdf5; border:1px solid #a7f3d0; border-radius:12px; padding:14px; margin-bottom:14px; text-align:center">
                                <span style="font-size:12px; color:#065f46; font-weight:700; text-transform:uppercase">Số tiền cần hoàn trả:</span>
                                <div style="font-size:22px; font-weight:800; color:#047857; margin:4px 0">
                                    ₫<fmt:formatNumber value="${ret.refundTotal}" type="number"/>
                                </div>
                                <small style="color:#059669; font-size:11px">Đã trừ các phần từ chối hoặc sai quy định</small>
                            </div>

                            <form method="post" action="${ctx}/staff/returns/${ret.id}/refunded">
                                ${csrf}
                                <button type="submit" class="btn-flashsale" style="width:100%; font-size:14px; padding:12px; justify-content:center; background:linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow:0 2px 10px rgba(16, 185, 129, 0.3)">
                                    <i class="ti ti-check" style="font-size:18px"></i> Xác nhận đã chuyển khoản hoàn
                                </button>
                            </form>
                            <small style="color:var(--text-muted); display:block; margin-top:8px; text-align:center; font-size:12px">
                                Chuyển khoản hoàn tiền được thực hiện thủ công qua ngân hàng. Bấm xác nhận sau khi chuyển xong.
                            </small>
                        </div>
                    </c:when>

                    <%-- 5. Đã hoàn tất hoặc từ chối --%>
                    <c:when test="${ret.status == 'REFUNDED'}">
                        <div style="text-align:center; padding:10px 0; color:#15803d">
                            <i class="ti ti-circle-check" style="font-size:32px; display:block; margin-bottom:4px"></i>
                            <b style="font-size:14px">Yêu cầu đã hoàn tất hoàn tiền</b>
                            <p style="font-size:12px; margin:4px 0 0; color:var(--text-muted)">Quy trình trả hàng đã kết thúc thành công.</p>
                        </div>
                    </c:when>
                    <c:when test="${ret.status == 'REJECTED'}">
                        <div style="text-align:center; padding:10px 0; color:#b91c1c">
                            <i class="ti ti-circle-x" style="font-size:32px; display:block; margin-bottom:4px"></i>
                            <b style="font-size:14px">Yêu cầu đã bị từ chối</b>
                            <p style="font-size:12px; margin:4px 0 0; color:var(--text-muted)">Đã gửi lý do từ chối đến khách hàng.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align:center; padding:10px 0; color:var(--text-muted)">
                            <i class="ti ti-archive" style="font-size:32px; display:block; margin-bottom:4px"></i>
                            <b style="font-size:14px">Yêu cầu đã đóng (${ret.status.label})</b>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Thông tin khách hàng & Đơn hàng gốc --%>
            <div class="info-card">
                <div class="info-card-title">
                    <span style="display:flex; align-items:center; gap:8px">
                        <i class="ti ti-user"></i>
                        <span>KHÁCH HÀNG &amp; ĐƠN HÀNG</span>
                    </span>
                    <a href="${ctx}/staff/orders/${ret.orderId}" style="font-size:12px; font-weight:700; color:#ea580c; text-decoration:none">
                        #ORD-${ret.orderId} ›
                    </a>
                </div>

                <div style="display:flex; align-items:center; gap:14px; margin-bottom:16px">
                    <div class="user-avatar-badge">
                        <c:out value="${empty ret.customerName ? 'K' : ret.customerName.substring(0, 1).toUpperCase()}"/>
                    </div>
                    <div>
                        <b style="font-size:15px; color:var(--text-logo); display:block">
                            <c:out value="${ret.customerName}"/>
                        </b>
                        <span style="font-size:12px; color:var(--text-muted)">Khách hàng thân thiết PetFood</span>
                    </div>
                </div>

                <div style="display:flex; flex-direction:column; gap:10px; font-size:13px">
                    <div style="display:flex; align-items:center; gap:10px; color:var(--text-main)">
                        <i class="ti ti-mail" style="color:var(--color-primary); font-size:16px; flex-shrink:0"></i>
                        <span style="word-break:break-all"><c:out value="${ret.customerEmail}"/></span>
                    </div>
                    <c:if test="${not empty ret.customerPhone}">
                        <div style="display:flex; align-items:center; gap:10px; color:var(--text-main)">
                            <i class="ti ti-phone" style="color:var(--color-primary); font-size:16px; flex-shrink:0"></i>
                            <span><c:out value="${ret.customerPhone}"/></span>
                        </div>
                    </c:if>
                    <div style="display:flex; align-items:center; gap:10px; color:var(--text-main)">
                        <i class="ti ti-credit-card" style="color:var(--color-primary); font-size:16px; flex-shrink:0"></i>
                        <span>Thanh toán: <b>${ret.paymentMethod.label}</b> (<span class="badge ${ret.paymentStatus == 'PAID' ? 'ok' : 'warn'}" style="font-size:10px">${ret.paymentStatus.label}</span>)</span>
                    </div>
                </div>
            </div>

            <%-- Lý do & Mô tả chi tiết từ khách hàng --%>
            <div class="info-card">
                <div class="info-card-title">
                    <span style="display:flex; align-items:center; gap:8px">
                        <i class="ti ti-message-2"></i>
                        <span>LÝ DO TRẢ HÀNG TỪ KHÁCH</span>
                    </span>
                </div>

                <div style="margin-bottom:12px">
                    <span style="font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase; display:block; margin-bottom:4px">Phân loại lý do:</span>
                    <span class="pill-badge orange" style="font-size:13px; padding:6px 12px">
                        <i class="ti ti-alert-circle"></i>${ret.reason.label}
                    </span>
                </div>

                <div>
                    <span style="font-size:11px; font-weight:800; color:var(--text-muted); text-transform:uppercase; display:block; margin-bottom:4px">Mô tả của khách hàng:</span>
                    <div style="background:var(--surface-soft); border:1px solid var(--line); border-radius:12px; padding:12px; font-size:13px; line-height:1.5; color:var(--text-main); font-style:italic">
                        "<c:out value="${empty ret.description ? 'Khách hàng không nhập thêm mô tả.' : ret.description}"/>"
                    </div>
                </div>
            </div>

            <%-- Thông tin tài khoản ngân hàng nhận tiền hoàn (nếu có) --%>
            <c:if test="${not empty ret.refundBankName}">
                <div class="info-card">
                    <div class="info-card-title">
                        <span style="display:flex; align-items:center; gap:8px">
                            <i class="ti ti-building-bank"></i>
                            <span>TÀI KHOẢN NHẬN HOÀN TIỀN</span>
                        </span>
                        <span class="pill-badge green" style="font-size:11px">NGÂN HÀNG</span>
                    </div>

                    <div class="bank-card">
                        <div style="display:flex; justify-content:space-between; align-items:center">
                            <span style="font-size:11px; font-weight:800; color:#c2410c; text-transform:uppercase">NGÂN HÀNG:</span>
                            <b style="font-size:14px; color:#7c2d12"><c:out value="${ret.refundBankName}"/></b>
                        </div>
                        <div style="margin:4px 0">
                            <span style="font-size:11px; color:#9a3412; display:block">SỐ TÀI KHOẢN:</span>
                            <span class="bank-num"><c:out value="${ret.refundAccountNo}"/></span>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center; border-top:1px dashed #fed7aa; padding-top:8px">
                            <span style="font-size:11px; color:#9a3412">CHỦ TÀI KHOẢN:</span>
                            <b style="font-size:13px; color:#7c2d12; text-transform:uppercase"><c:out value="${ret.refundAccountHolder}"/></b>
                        </div>
                    </div>
                </div>
            </c:if>

            <%-- Nhật ký xử lý (Audit Timeline) --%>
            <div class="info-card">
                <div class="info-card-title">
                    <span style="display:flex; align-items:center; gap:8px">
                        <i class="ti ti-history"></i>
                        <span>NHẬT KÝ TIẾN TRÌNH</span>
                    </span>
                </div>

                <ul class="audit-list">
                    <li class="audit-item done">
                        <div class="audit-icon"><i class="ti ti-check"></i></div>
                        <div class="audit-title">Khách hàng gửi yêu cầu trả hàng</div>
                        <div class="audit-time">${ret.createdAtText}</div>
                    </li>

                    <c:if test="${not empty ret.reviewedText}">
                        <li class="audit-item ${ret.status == 'REJECTED' ? 'rejected' : 'done'}">
                            <div class="audit-icon">
                                <i class="ti ${ret.status == 'REJECTED' ? 'ti-x' : 'ti-check'}"></i>
                            </div>
                            <div class="audit-title">
                                ${ret.status == 'REJECTED' ? 'Nhân viên từ chối yêu cầu' : 'Nhân viên phê duyệt yêu cầu'}
                            </div>
                            <div class="audit-time"><c:out value="${ret.reviewedText}"/></div>
                        </li>
                    </c:if>

                    <c:if test="${not empty ret.receivedAtText}">
                        <li class="audit-item done">
                            <div class="audit-icon"><i class="ti ti-check"></i></div>
                            <div class="audit-title">Đã nhận kiện hàng trả tại kho</div>
                            <div class="audit-time">${ret.receivedAtText}</div>
                        </li>
                    </c:if>

                    <c:if test="${not empty ret.inspectedByName}">
                        <li class="audit-item done">
                            <div class="audit-icon"><i class="ti ti-check"></i></div>
                            <div class="audit-title">Hoàn tất thẩm định chất lượng kho</div>
                            <div class="audit-time">Thực hiện bởi: <b><c:out value="${ret.inspectedByName}"/></b></div>
                        </li>
                    </c:if>

                    <c:if test="${not empty ret.refundedAtText}">
                        <li class="audit-item done">
                            <div class="audit-icon"><i class="ti ti-cash"></i></div>
                            <div class="audit-title">Đã hoàn tất chuyển khoản hoàn tiền</div>
                            <div class="audit-time">${ret.refundedAtText}</div>
                        </li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</main>
</body>
</html>
