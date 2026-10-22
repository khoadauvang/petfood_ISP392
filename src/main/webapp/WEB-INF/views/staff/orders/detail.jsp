<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đơn #${order.id} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .od-product-card {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }
        .od-thumb {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            object-fit: contain;
            background: #ffffff;
            border: 1px solid var(--line);
            padding: 4px;
            flex-shrink: 0;
        }
        .od-prod-title {
            font-weight: 700;
            color: var(--text-main);
            font-size: 14px;
            line-height: 1.3;
            text-decoration: none;
            display: block;
            margin-bottom: 4px;
        }
        .od-prod-title:hover {
            color: var(--color-primary);
        }
        .od-lot-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            font-weight: 600;
            color: #475569;
            background: #f1f5f9;
            border: 1px solid #cbd5e1;
            padding: 2px 8px;
            border-radius: 6px;
            margin-top: 4px;
        }
        .od-summary-table {
            width: 100%;
            margin-top: 16px;
            border-collapse: collapse;
        }
        .od-summary-table td {
            padding: 8px 12px;
            border-bottom: 1px solid #f8f1eb;
            font-size: 13px;
        }
        .od-summary-table tr:last-child td {
            border-bottom: 0;
            padding-top: 14px;
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
            left: 15px;
            top: 10px;
            bottom: 10px;
            width: 2px;
            background: var(--line);
        }
        .audit-item {
            position: relative;
            padding-left: 38px;
            margin-bottom: 16px;
        }
        .audit-item:last-child {
            margin-bottom: 0;
        }
        .audit-icon {
            position: absolute;
            left: 4px;
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
        .audit-item.cancelled .audit-icon {
            background: #ef4444;
            border-color: #ef4444;
            color: #fff;
        }
        .audit-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
        }
        .audit-time {
            font-size: 11px;
            color: var(--text-muted);
            margin-top: 2px;
        }
        .action-card {
            background: linear-gradient(180deg, #fffaf5 0%, #ffffff 100%);
            border: 1px solid #ffd8b8;
            border-radius: 18px;
            box-shadow: 0 4px 16px rgba(249, 115, 22, 0.08);
            padding: 20px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <a href="${ctx}/staff/orders">ĐƠN HÀNG</a>
                <span class="sep">&gt;</span>
                <span class="current">CHI TIẾT ĐƠN HÀNG #${order.id}</span>
            </div>
            <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
                <h1 style="margin:0">ĐƠN HÀNG #${order.id}</h1>
                <c:choose>
                    <c:when test="${order.status == 'COMPLETED'}">
                        <span class="pill-badge green"><i class="ti ti-circle-check"></i>Giao thành công</span>
                    </c:when>
                    <c:when test="${order.status == 'SHIPPED'}">
                        <span class="pill-badge blue"><i class="ti ti-truck"></i>Đang giao hàng</span>
                    </c:when>
                    <c:when test="${order.status == 'PROCESSING'}">
                        <span class="pill-badge blue"><i class="ti ti-package"></i>Đang đóng gói</span>
                    </c:when>
                    <c:when test="${order.status == 'CONFIRMED'}">
                        <span class="pill-badge green"><i class="ti ti-check"></i>Đã xác nhận</span>
                    </c:when>
                    <c:when test="${order.status == 'CANCELLED'}">
                        <span class="pill-badge red"><i class="ti ti-circle-x"></i>Đã huỷ</span>
                    </c:when>
                    <c:when test="${order.status == 'RETURNED'}">
                        <span class="pill-badge red"><i class="ti ti-arrow-back-up"></i>Khách không nhận</span>
                    </c:when>
                    <c:otherwise>
                        <span class="pill-badge orange"><i class="ti ti-hourglass"></i>Chờ xác nhận</span>
                    </c:otherwise>
                </c:choose>
                <span class="pill-badge ${order.paymentMethod.name() == 'VNPAY' ? 'green' : 'orange'}">
                    ● ${order.paymentMethod.label} (${order.paymentStatus.label})
                </span>
            </div>
            <p class="page-sub" style="margin-top:6px">
                Đặt lúc: <b>${order.createdAtText}</b> · Kênh: Bán lẻ trực tuyến · Mã đối soát hệ thống: #ORD-${order.id}
            </p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <a href="${ctx}/staff/orders" class="btn-pill-outline">
                <i class="ti ti-arrow-left"></i>Quay lại danh sách
            </a>
            <button type="button" onclick="window.print()" class="btn-pill-outline">
                <i class="ti ti-printer"></i>In phiếu đơn
            </button>
        </div>
    </div>

    <%-- Cảnh báo khẩn cấp (nếu có yêu cầu huỷ / chờ hoàn tiền / đã huỷ) --%>
    <c:if test="${order.cancelRequested}">
        <div class="urgent-banner">
            <div class="urgent-left">
                <span class="urgent-icon" style="background:#dc2626"><i class="ti ti-alert-triangle"></i></span>
                <div>
                    <span class="urgent-tag" style="background:#fee2e2; color:#991b1b">Yêu cầu huỷ từ khách hàng</span>
                    <div class="urgent-text">Khách hàng yêu cầu huỷ đơn khi đang đóng gói: "<strong><c:out value="${order.cancelReason}"/></strong>"</div>
                </div>
            </div>
            <div class="urgent-actions">
                <form method="post" action="${ctx}/staff/orders/${order.id}/cancel-request/approve" style="display:inline">${csrf}
                    <button type="submit" class="btn-pill-danger"><i class="ti ti-check"></i>Duyệt huỷ (trả hàng về kho)</button>
                </form>
                <form method="post" action="${ctx}/staff/orders/${order.id}/cancel-request/reject" style="display:inline">${csrf}
                    <button type="submit" class="btn-pill-outline"><i class="ti ti-x"></i>Từ chối yêu cầu</button>
                </form>
            </div>
        </div>
    </c:if>

    <c:if test="${order.status == 'CANCELLED'}">
        <div class="urgent-banner" style="background:#fef2f2; border-color:#fecaca">
            <div class="urgent-left">
                <span class="urgent-icon" style="background:#dc2626"><i class="ti ti-circle-x"></i></span>
                <div>
                    <span class="urgent-tag" style="background:#fee2e2; color:#991b1b">Đơn hàng đã huỷ</span>
                    <div class="urgent-text" style="color:#991b1b">Huỷ lúc ${order.cancelledAtText}. Lý do: <b><c:out value="${order.cancelReason}"/></b></div>
                </div>
            </div>
        </div>
    </c:if>

    <c:if test="${order.needsRefund}">
        <div class="urgent-banner">
            <div class="urgent-left">
                <span class="urgent-icon" style="background:#d97706"><i class="ti ti-cash"></i></span>
                <div>
                    <span class="urgent-tag" style="background:#fef3c7; color:#92400e">Chờ hoàn tiền VNPay</span>
                    <div class="urgent-text">Đơn VNPay đã trả tiền nhưng bị huỷ: nhân viên cần chuyển khoản hoàn tiền thủ công cho khách.</div>
                </div>
            </div>
            <div class="urgent-actions">
                <form method="post" action="${ctx}/staff/orders/${order.id}/refunded" style="display:inline">${csrf}
                    <button type="submit" class="btn-flashsale"><i class="ti ti-check"></i>Đã hoàn tiền cho khách</button>
                </form>
            </div>
        </div>
    </c:if>

    <%-- Thanh tiến trình 5 bước trực quan --%>
    <div class="panel" style="margin-bottom:20px; padding:16px 24px">
        <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.06em; color:var(--text-muted); margin-bottom:12px">
            TIẾN TRÌNH XỬ LÝ ĐƠN HÀNG
        </div>
        <c:set var="sIdx" value="${order.status == 'PENDING' ? 1 : (order.status == 'CONFIRMED' ? 2 : (order.status == 'PROCESSING' ? 3 : (order.status == 'SHIPPED' ? 4 : 5)))}"/>
        <div class="order-stepper">
            <div class="stepper-step ${sIdx >= 1 ? (sIdx > 1 or order.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                <div class="stepper-circle"><i class="ti ti-shopping-cart"></i></div>
                <span class="stepper-label">Đặt hàng</span>
                <span class="stepper-time">${order.createdAtText}</span>
            </div>
            <div class="stepper-step ${sIdx >= 2 ? (sIdx > 2 or order.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                <div class="stepper-circle"><i class="ti ti-check"></i></div>
                <span class="stepper-label">Xác nhận</span>
                <span class="stepper-time">${not empty order.confirmedAtText ? order.confirmedAtText : '--:--'}</span>
            </div>
            <div class="stepper-step ${sIdx >= 3 ? (sIdx > 3 or order.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                <div class="stepper-circle"><i class="ti ti-package"></i></div>
                <span class="stepper-label">Đóng gói</span>
                <span class="stepper-time">${not empty order.packedByName ? order.packedByName : '--:--'}</span>
            </div>
            <div class="stepper-step ${sIdx >= 4 ? (sIdx > 4 or order.status == 'COMPLETED' ? 'completed' : 'active') : ''}">
                <div class="stepper-circle"><i class="ti ti-truck"></i></div>
                <span class="stepper-label">Đang giao</span>
                <span class="stepper-time">${not empty order.shippedAtText ? order.shippedAtText : '--:--'}</span>
            </div>
            <div class="stepper-step ${sIdx >= 5 ? 'completed' : ''}">
                <div class="stepper-circle"><i class="ti ti-circle-check"></i></div>
                <span class="stepper-label">Hoàn tất</span>
                <span class="stepper-time">${not empty order.completedAtText ? order.completedAtText : '--:--'}</span>
            </div>
        </div>
    </div>

    <%-- Bố cục Split Master-Detail Layout --%>
    <div class="split-layout">
        <%-- Cột trái: Danh sách sản phẩm và tổng tiền --%>
        <div>
            <div class="panel" style="padding:0; overflow:hidden; margin-bottom:20px">
                <div class="split-head">
                    <h3 style="margin:0"><i class="ti ti-list" style="color:var(--color-primary)"></i>SẢN PHẨM TRONG ĐƠN HÀNG</h3>
                    <span class="pill-badge gray">${order.lines.size()} mặt hàng</span>
                </div>

                <div style="padding:16px 20px">
                    <table style="box-shadow:none; border:0; margin:0">
                        <thead>
                        <tr>
                            <th>SẢN PHẨM &amp; LÔ HÀNG (FEFO)</th>
                            <th class="num">ĐƠN GIÁ</th>
                            <th class="num" style="text-align:center">SL</th>
                            <th class="num">GIẢM GIÁ</th>
                            <th class="num">THÀNH TIỀN</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="line" items="${order.lines}">
                            <tr>
                                <td>
                                    <div class="od-product-card">
                                        <img src="${empty line.imageUrl ? 'https://placehold.co/60x60?text=PetFood' : line.imageUrl}"
                                             onerror="this.src='https://placehold.co/60x60?text=Pet'" alt="" class="od-thumb">
                                        <div>
                                            <a href="${ctx}/products/${line.productId}" class="od-prod-title">
                                                <c:out value="${line.name}"/>
                                            </a>
                                            <c:if test="${line.flashSale}">
                                                <span class="pill-badge red" style="font-size:10px; padding:2px 6px">
                                                    <i class="ti ti-bolt"></i>Flash Sale: <c:out value="${line.flashSaleName}"/>
                                                </span>
                                            </c:if>
                                            <c:forEach var="lot" items="${line.lots}">
                                                <div>
                                                    <span class="od-lot-pill">
                                                        <i class="ti ti-building-warehouse" style="color:#0284c7"></i>
                                                        <c:out value="${lot}"/>
                                                    </span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </td>
                                <td class="num"><b><fmt:formatNumber value="${line.unitPrice}" type="number"/>₫</b></td>
                                <td class="num" style="text-align:center"><span class="pill-badge gray">× ${line.quantity}</span></td>
                                <td class="num">
                                    <c:choose>
                                        <c:when test="${line.discountAmount > 0}">
                                            <span style="color:#dc2626; font-weight:700">−<fmt:formatNumber value="${line.discountAmount}" type="number"/>₫</span>
                                        </c:when>
                                        <c:otherwise><span style="color:var(--text-placeholder)">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="num"><b><fmt:formatNumber value="${line.lineTotal}" type="number"/>₫</b></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>

                    <%-- Tổng kết giá trị đơn hàng --%>
                    <div style="background:var(--surface-soft); border-radius:14px; border:1px solid var(--line); padding:16px 20px; margin-top:20px">
                        <table class="od-summary-table">
                            <tr>
                                <td style="color:var(--text-muted)">Tạm tính ban đầu:</td>
                                <td class="num"><b><fmt:formatNumber value="${order.subtotal}" type="number"/>₫</b></td>
                            </tr>
                            <tr>
                                <td style="color:var(--text-muted)">
                                    Giảm giá hạng thành viên (${order.tierDiscountRate}%, không áp dụng cho Flash Sale):
                                </td>
                                <td class="num" style="color:#dc2626; font-weight:700">
                                    −<fmt:formatNumber value="${order.discountTotal}" type="number"/>₫
                                </td>
                            </tr>
                            <tr>
                                <td style="color:var(--text-muted)">Phí giao hàng:</td>
                                <td class="num">
                                    <c:choose>
                                        <c:when test="${order.shippingFee == 0}"><span class="pill-badge green">Miễn phí giao hàng</span></c:when>
                                        <c:otherwise><b><fmt:formatNumber value="${order.shippingFee}" type="number"/>₫</b></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                            <tr style="border-top:1px dashed #ffd8b8">
                                <td style="font-size:15px; font-weight:800; color:var(--text-logo)">TỔNG TIỀN THANH TOÁN:</td>
                                <td class="num">
                                    <b style="font-size:22px; font-weight:800; color:#ea580c">
                                        <fmt:formatNumber value="${order.totalAmount}" type="number"/>₫
                                    </b>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <%-- Cột phải: Thao tác chuyển bước, thông tin khách, địa chỉ & nhật ký --%>
        <div>
            <%-- Thẻ thao tác chính chuyển bước (Workflow Action) --%>
            <div class="action-card">
                <div style="font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.08em; color:var(--color-primary); margin-bottom:12px; display:flex; align-items:center; gap:6px">
                    <i class="ti ti-player-play"></i>THAO TÁC XỬ LÝ ĐƠN HÀNG
                </div>

                <c:choose>
                    <c:when test="${order.status == 'PENDING'}">
                        <p style="font-size:13px; color:var(--text-muted); margin-bottom:14px">
                            Đơn hàng mới được khách đặt, hãy xác nhận thông tin và kiểm tra lượng hàng khả dụng trong kho.
                        </p>
                        <form method="post" action="${ctx}/staff/orders/${order.id}/confirm" style="margin-bottom:12px">${csrf}
                            <button type="submit" class="btn-flashsale" style="width:100%; padding:12px 20px; font-size:14px">
                                <i class="ti ti-check"></i>Xác nhận đơn hàng ngay
                            </button>
                        </form>
                    </c:when>

                    <c:when test="${order.status == 'CONFIRMED'}">
                        <p style="font-size:13px; color:var(--text-muted); margin-bottom:14px">
                            Đơn đã được duyệt, chuyển sang bộ phận kho để chuẩn bị và đóng gói sản phẩm.
                        </p>
                        <form method="post" action="${ctx}/staff/orders/${order.id}/pack" style="margin-bottom:12px">${csrf}
                            <button type="submit" class="btn-flashsale" style="width:100%; padding:12px 20px; font-size:14px">
                                <i class="ti ti-package"></i>Tiến hành đóng gói hàng
                            </button>
                        </form>
                    </c:when>

                    <c:when test="${order.status == 'PROCESSING' and not order.cancelRequested}">
                        <p style="font-size:13px; color:var(--text-muted); margin-bottom:14px">
                            Kiện hàng đã đóng gói hoàn tất và sẵn sàng bàn giao cho đơn vị vận chuyển.
                        </p>
                        <form method="post" action="${ctx}/staff/orders/${order.id}/ship" style="margin-bottom:12px">${csrf}
                            <button type="submit" class="btn-flashsale" style="width:100%; padding:12px 20px; font-size:14px; background:linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%) !important">
                                <i class="ti ti-truck"></i>Bàn giao vận chuyển (Bắt đầu giao)
                            </button>
                        </form>
                    </c:when>

                    <c:when test="${order.status == 'SHIPPED'}">
                        <p style="font-size:13px; color:var(--text-muted); margin-bottom:14px">
                            Đơn đang được giao đến tay khách hàng. Cập nhật kết quả giao hàng bên dưới:
                        </p>
                        <div style="display:flex; flex-direction:column; gap:8px; margin-bottom:12px">
                            <form method="post" action="${ctx}/staff/orders/${order.id}/complete">${csrf}
                                <button type="submit" class="btn-flashsale" style="width:100%; padding:12px 20px; font-size:14px; background:linear-gradient(135deg, #10b981 0%, #059669 100%) !important">
                                    <i class="ti ti-circle-check"></i>Giao hàng thành công
                                </button>
                            </form>
                            <form method="post" action="${ctx}/staff/orders/${order.id}/returned">${csrf}
                                <button type="submit" class="btn-pill-outline" style="width:100%; padding:10px 20px; justify-content:center; color:#991b1b; border-color:#fca5a5"
                                        onclick="return confirm('Ghi nhận khách không nhận hàng và hoàn đơn về kho?')">
                                    <i class="ti ti-arrow-back-up"></i>Khách không nhận hàng (Hoàn trả)
                                </button>
                            </form>
                        </div>
                    </c:when>

                    <c:when test="${order.status == 'COMPLETED'}">
                        <div style="display:flex; align-items:center; gap:8px; background:#e6f9ed; border:1px solid #bbf7d0; color:#166534; padding:12px 16px; border-radius:12px; font-weight:700; font-size:13px">
                            <i class="ti ti-circle-check" style="font-size:18px"></i>Đơn hàng đã hoàn tất thành công.
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div style="display:flex; align-items:center; gap:8px; background:#f3f4f6; border:1px solid #e5e7eb; color:#4b5563; padding:12px 16px; border-radius:12px; font-weight:700; font-size:13px">
                            <i class="ti ti-info-circle" style="font-size:18px"></i>Đơn hàng đã kết thúc quy trình xử lý.
                        </div>
                    </c:otherwise>
                </c:choose>

                <%-- Form huỷ đơn hàng bởi nhân viên (khi chưa bàn giao ship) --%>
                <c:if test="${order.status == 'PENDING' or order.status == 'CONFIRMED' or (order.status == 'PROCESSING' and not order.cancelRequested)}">
                    <details style="margin-top:14px; padding-top:14px; border-top:1px dashed #ffd8b8">
                        <summary style="font-size:12px; font-weight:700; color:#991b1b; cursor:pointer; list-style:none; display:flex; align-items:center; gap:6px">
                            <i class="ti ti-alert-triangle"></i>Huỷ đơn hàng này (Nếu khách gọi đổi ý hoặc hết hàng)
                        </summary>
                        <form method="post" action="${ctx}/staff/orders/${order.id}/cancel" style="margin-top:10px">${csrf}
                            <div style="margin-bottom:8px">
                                <input type="text" name="cancelReason" placeholder="Nhập lý do huỷ đơn bắt buộc..." required maxlength="255"
                                       style="width:100%; padding:8px 12px; border-radius:10px; border:1px solid #fca5a5; font-size:12px">
                            </div>
                            <button type="submit" class="btn-pill-danger" style="width:100%; justify-content:center"
                                    onclick="return confirm('Xác nhận huỷ đơn hàng này? Hàng sẽ được trả về kho theo đúng lô.')">
                                <i class="ti ti-trash"></i>Xác nhận huỷ đơn &amp; Trả hàng về kho
                            </button>
                        </form>
                    </details>
                </c:if>
            </div>

            <%-- Thông tin khách hàng & Giao nhận --%>
            <div class="panel" style="margin-bottom:20px; padding:20px">
                <div class="panel-head" style="margin-bottom:12px">
                    <h3 style="margin:0"><i class="ti ti-user" style="color:var(--color-primary)"></i>THÔNG TIN GIAO HÀNG</h3>
                </div>

                <div class="info-box-grid" style="margin-bottom:0">
                    <div class="info-box">
                        <div class="info-box-title"><i class="ti ti-id"></i>Khách nhận hàng</div>
                        <div class="info-box-name"><c:out value="${order.customerName}"/></div>
                        <div class="info-box-desc">
                            <i class="ti ti-phone" style="margin-right:4px; vertical-align:middle"></i>
                            <b><c:out value="${empty order.customerPhone ? 'Chưa cập nhật SĐT' : order.customerPhone}"/></b>
                            <br>
                            <i class="ti ti-mail" style="margin-right:4px; vertical-align:middle"></i>
                            <c:out value="${order.customerEmail}"/>
                        </div>
                    </div>

                    <div class="info-box">
                        <div class="info-box-title"><i class="ti ti-map-pin"></i>Địa chỉ nhận hàng</div>
                        <div class="info-box-desc" style="font-weight:600; color:var(--text-main); font-size:13px; line-height:1.4">
                            <c:out value="${order.shippingAddress}"/>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Thông tin thanh toán & Giao dịch --%>
            <div class="panel" style="margin-bottom:20px; padding:20px">
                <div class="panel-head" style="margin-bottom:12px">
                    <h3 style="margin:0"><i class="ti ti-credit-card" style="color:var(--color-primary)"></i>PHƯƠNG THỨC THANH TOÁN</h3>
                    <span class="pill-badge ${order.paymentStatus.name() == 'PAID' ? 'green' : 'orange'}">
                        ${order.paymentStatus.label}
                    </span>
                </div>

                <div style="font-size:13px; line-height:1.5">
                    Phương thức: <b>${order.paymentMethod.label}</b>
                    <c:if test="${order.paymentMethod.name() == 'COD'}">
                        <div class="hint" style="margin-top:4px">
                            Thu tiền mặt khi giao hàng (COD). Nhân viên giao hàng có trách nhiệm thu đủ:
                            <b style="color:#ea580c"><fmt:formatNumber value="${order.totalAmount}" type="number"/>₫</b>
                        </div>
                    </c:if>
                    <c:if test="${order.paymentMethod.name() == 'VNPAY'}">
                        <div class="hint" style="margin-top:4px">
                            Thanh toán chuyển khoản trực tuyến qua cổng VNPay.
                        </div>
                    </c:if>

                    <c:if test="${not empty order.payments}">
                        <div style="margin-top:12px; padding-top:10px; border-top:1px dashed var(--line)">
                            <small style="font-weight:700; color:var(--text-muted); text-transform:uppercase">Lịch sử giao dịch:</small>
                            <ul style="margin:6px 0 0; padding-left:18px; font-size:12px; color:var(--text-muted)">
                                <c:forEach var="p" items="${order.payments}">
                                    <li><c:out value="${p}"/></li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                </div>
            </div>

            <%-- Nhật ký các mốc xử lý (Audit Timeline) --%>
            <div class="panel" style="padding:20px">
                <div class="panel-head" style="margin-bottom:16px">
                    <h3 style="margin:0"><i class="ti ti-history" style="color:var(--color-primary)"></i>NHẬT KÝ ĐƠN HÀNG</h3>
                </div>

                <ul class="audit-list">
                    <li class="audit-item done">
                        <span class="audit-icon"><i class="ti ti-check"></i></span>
                        <div class="audit-title">Khách hàng đặt đơn thành công</div>
                        <div class="audit-time">${order.createdAtText}</div>
                    </li>

                    <c:if test="${not empty order.confirmedAtText}">
                        <li class="audit-item done">
                            <span class="audit-icon"><i class="ti ti-check"></i></span>
                            <div class="audit-title">Cửa hàng xác nhận đơn</div>
                            <div class="audit-time">
                                ${order.confirmedAtText}
                                <c:if test="${not empty order.confirmedByName}">
                                    · Nhân viên: <b><c:out value="${order.confirmedByName}"/></b>
                                </c:if>
                            </div>
                        </li>
                    </c:if>

                    <c:if test="${not empty order.packedByName}">
                        <li class="audit-item done">
                            <span class="audit-icon"><i class="ti ti-package"></i></span>
                            <div class="audit-title">Đóng gói hoàn tất &amp; gán số lô FEFO</div>
                            <div class="audit-time">Nhân viên đóng gói: <b><c:out value="${order.packedByName}"/></b></div>
                        </li>
                    </c:if>

                    <c:if test="${not empty order.shippedAtText}">
                        <li class="audit-item done">
                            <span class="audit-icon"><i class="ti ti-truck"></i></span>
                            <div class="audit-title">Bàn giao cho đơn vị vận chuyển</div>
                            <div class="audit-time">${order.shippedAtText}</div>
                        </li>
                    </c:if>

                    <c:if test="${not empty order.completedAtText}">
                        <li class="audit-item done">
                            <span class="audit-icon"><i class="ti ti-circle-check"></i></span>
                            <div class="audit-title">Giao hàng thành công &amp; Hoàn tất đơn</div>
                            <div class="audit-time">${order.completedAtText}</div>
                        </li>
                    </c:if>

                    <c:if test="${not empty order.returnedAtText}">
                        <li class="audit-item cancelled">
                            <span class="audit-icon"><i class="ti ti-arrow-back-up"></i></span>
                            <div class="audit-title">Khách không nhận hàng (Hoàn đơn)</div>
                            <div class="audit-time">${order.returnedAtText}</div>
                        </li>
                    </c:if>

                    <c:if test="${not empty order.cancelledAtText}">
                        <li class="audit-item cancelled">
                            <span class="audit-icon"><i class="ti ti-x"></i></span>
                            <div class="audit-title">Đơn hàng đã huỷ</div>
                            <div class="audit-time">${order.cancelledAtText} · Lý do: <c:out value="${order.cancelReason}"/></div>
                        </li>
                    </c:if>
                </ul>
            </div>
        </div>
    </div>
</main>

</body>
</html>
