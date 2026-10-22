<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: orders, currentPage, totalPages, totalItems, statuses, filterStatus, filterCancelRequested, filterKeyword, filterQuery, cancelRequestCount --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý đơn hàng · PetFood</title>
    <meta name="description" content="Xem và quản lý các đơn hàng của khách hàng trên toàn bộ các kênh bán lẻ.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .pill-badge { display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 99px; font-size: 11px; font-weight: 800; }
        .pill-badge.green { background: #e6f9ed; color: #166534; }
        .pill-badge.orange { background: #ffedd5; color: #c2410c; }
        .pill-badge.red { background: #fee2e2; color: #991b1b; }
        .pill-badge.blue { background: #eff6ff; color: #1e40af; }
        .pill-badge.purple { background: #f3e8ff; color: #6b21a8; }
        .pill-badge.gray { background: #f3f4f6; color: #4b5563; }
        .pill-badge.gold { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .pill-badge.diamond { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .pill-badge.silver { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .pill-badge.bronze { background: #ffedd5; color: #9a3412; border: 1px solid #fed7aa; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>ĐƠN HÀNG</span> <span class="sep">&gt;</span> <span class="current">QUẢN LÝ ĐƠN HÀNG</span>
            </div>
            <h1>QUẢN LÝ ĐƠN HÀNG <span class="pill-badge orange">ĐỒNG BỘ THỜI GIAN THỰC</span></h1>
            <p class="page-sub">Xem và quản lý các đơn hàng của khách hàng trên toàn bộ các kênh bán lẻ.</p>
        </div>

    </div>

    <%-- 4 KPI Cards Screen 4 --%>
    <section class="grid g-4">
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Tổng đơn hàng</span>
                <span class="kpi-ico orange"><i class="ti ti-shopping-bag"></i></span>
            </div>
            <div class="kpi-value">
                <c:choose>
                    <c:when test="${totalAllOrders != null}">${totalAllOrders}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge ok">Đơn hàng</span> trên toàn hệ thống</div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Chờ xác nhận</span>
                <span class="kpi-ico yellow"><i class="ti ti-hourglass"></i></span>
            </div>
            <div class="kpi-value" style="color:#d97706">
                <c:choose>
                    <c:when test="${pendingOrdersCount != null}">${pendingOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge warn">Cần xử lý</span> Đơn chờ cửa hàng xác nhận</div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Đang xử lý &amp; Đóng gói</span>
                <span class="kpi-ico blue"><i class="ti ti-package"></i></span>
            </div>
            <div class="kpi-value" style="color:#2563eb">
                <c:choose>
                    <c:when test="${processingOrdersCount != null}">${processingOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta">Trong hàng đợi đóng gói</div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">Đã giao thành công</span>
                <span class="kpi-ico green"><i class="ti ti-circle-check"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">
                <c:choose>
                    <c:when test="${completedOrdersCount != null}">${completedOrdersCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </div>
            <div class="kpi-meta"><span class="badge ok">Hoàn tất</span> trên toàn hệ thống</div>
        </div>
    </section>

    <%-- Có đơn khách xin huỷ đang chờ duyệt: nhắc staff, bấm vào để lọc nhanh --%>
    <c:if test="${cancelRequestCount > 0}">
        <a href="${ctx}/staff/orders?cancelRequested=true" class="pill-badge red" style="padding:8px 14px; font-size:13px; text-decoration:none; margin-bottom:12px">
            <i class="ti ti-alert-triangle"></i> ${cancelRequestCount} đơn đang chờ duyệt yêu cầu huỷ
        </a>
    </c:if>

    <%-- Filters Screen 4 --%>
    <form method="get" action="${ctx}/staff/orders" class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:240px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo Mã đơn hoặc Tên khách... (/)"
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="status" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="s" items="${statuses}">
                <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>

        <label style="display:flex; align-items:center; gap:6px; font-size:13px; cursor:pointer">
            <input type="checkbox" name="cancelRequested" value="true" ${filterCancelRequested ? 'checked' : ''}> Chỉ đơn khách yêu cầu huỷ
        </label>

        <button type="submit" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c">Lọc</button>
        <a href="${ctx}/staff/orders" class="act-icon" title="Đặt lại bộ lọc"><i class="ti ti-rotate"></i></a>
    </form>

    <%-- Master-Detail Split Screen Layout --%>
    <div class="split-layout">
        <%-- Trái: Danh sách đơn hàng --%>
        <div class="split-panel">
            <div class="split-head">
                <div>
                    <h3 style="margin:0">DANH SÁCH ĐƠN HÀNG</h3>
                    <small style="color:var(--text-muted)">Hiển thị theo thời gian thực</small>
                </div>
                <div style="font-size:12px; color:var(--text-muted)">
                    Sắp xếp: <b style="color:var(--color-primary)">Mới nhất ↓</b>
                </div>
            </div>

            <table style="margin:0; border:0; border-radius:0; box-shadow:none">
                <thead>
                <tr>
                    <th>MÃ ĐƠN</th>
                    <th>KHÁCH HÀNG</th>
                    <th>NGÀY ĐẶT</th>
                    <th class="num">TỔNG TIỀN</th>
                    <th>THANH TOÁN</th>
                    <th>TRẠNG THÁI</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty orders}">
                        <c:forEach var="o" items="${orders}" varStatus="oStatus">
                            <tr id="row-ORD-${o.id}" class="order-table-row <c:if test='${oStatus.first}'>selected-order-row</c:if>"
                                onclick="selectOrderCode('ORD-${o.id}')"
                                style="cursor:pointer; <c:if test='${oStatus.first}'>background:#fff7ee;</c:if>">
                                <td><b style="color:#ea580c">#ORD-${o.id}</b></td>
                                <td>
                                    <div style="display:flex; align-items:center; gap:8px">
                                        <div class="avatar" style="width:30px; height:30px; font-size:12px; background:#fed7aa; color:#9a3412">
                                            <c:out value="${empty o.customerName ? 'K' : o.customerName.substring(0, 1)}"/>
                                        </div>
                                        <div>
                                            <b><c:out value="${empty o.customerName ? 'Khách hàng #' += o.id : o.customerName}"/></b><br>
                                            <small style="color:var(--text-muted)"><c:out value="${empty o.customerEmail ? 'N/A' : o.customerEmail}"/></small>
                                        </div>
                                    </div>
                                </td>
                                <td>${o.createdAtText}</td>
                                <td class="num"><b><fmt:formatNumber value="${o.totalAmount}" type="number"/>₫</b></td>
                                <td>
                                    <span class="pill-badge ${o.paymentMethodLabel == 'VNPay' ? 'green' : 'orange'}">
                                        ● ${o.paymentMethodLabel}
                                    </span>
                                </td>
                                <td>
                                    <span id="row-badge-ORD-${o.id}" class="pill-badge ${o.status == 'COMPLETED' ? 'green' : (o.status == 'SHIPPED' ? 'blue' : (o.status == 'PROCESSING' ? 'blue' : (o.status == 'CONFIRMED' ? 'green' : (o.status == 'CANCELLED' ? 'red' : 'gray'))))}">
                                        ${o.status.label}
                                    </span>
                                    <c:if test="${o.cancelRequested}"><span class="pill-badge red">Yêu cầu huỷ</span></c:if>
                                </td>
                                <td><span class="act-icon" style="<c:if test='${oStatus.first}'>color:#ea580c; border-color:#ea580c; background:#ffedd5;</c:if>"><i class="ti ti-eye"></i></span></td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" style="text-align:center; padding:36px; color:var(--text-muted)">
                                <i class="ti ti-inbox" style="font-size:24px; vertical-align:middle; margin-right:8px"></i>Không tìm thấy đơn hàng nào phù hợp với bộ lọc
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>

            <div class="panel-foot" style="padding:14px 20px">
                <span>Hiển thị <c:out value="${not empty orders ? orders.size() : 0}"/> trong tổng số <b>${totalItems != null ? totalItems : 0}</b> đơn</span>
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

        <%-- Phải: Detail Drawer Pane (Screen 4) --%>
        <div class="detail-card" id="order-drawer">
            <c:choose>
                <c:when test="${not empty orders}">
                    <div class="detail-card-head">
                        <div>
                            <h3 style="display:flex; align-items:center; gap:8px">
                                <span id="detail-code">#ORD-</span>
                                <span class="pill-badge" id="detail-status">Đang tải...</span>
                            </h3>
                            <div class="detail-sub" id="detail-time">--</div>
                        </div>
                        <button type="button" class="act-icon" title="Đóng" onclick="document.getElementById('order-drawer').style.display='none'"><i class="ti ti-x"></i></button>
                    </div>

                    <%-- Stepper 5 bước động theo trạng thái --%>
                    <div style="font-size:12px; font-weight:800; text-transform:uppercase; color:var(--text-muted); margin-bottom:10px">
                        TIẾN TRÌNH XỬ LÝ ĐƠN HÀNG
                    </div>
                    <div class="order-stepper" id="order-stepper">
                        <!-- Được cập nhật tự động bằng renderStepper() -->
                    </div>

                    <%-- Khách hàng & Địa chỉ giao hàng --%>
                    <div class="info-box-grid">
                        <div class="info-box">
                            <div class="info-box-title"><i class="ti ti-user"></i>Thông tin khách hàng</div>
                            <div class="info-box-name" id="detail-cust-name">--</div>
                            <div class="info-box-desc" id="detail-cust-email">--</div>
                            <span class="pill-badge bronze" id="detail-cust-tier" style="align-self:flex-start; margin-top:4px">--</span>
                        </div>

                        <div class="info-box">
                            <div class="info-box-title"><i class="ti ti-map-pin"></i>Địa chỉ giao hàng</div>
                            <div class="info-box-name" id="detail-address-name">--</div>
                            <div class="info-box-desc" id="detail-address-desc">--</div>
                            <div id="detail-carrier" style="font-size:11px; color:#ea580c; font-weight:700; margin-top:4px">
                                --
                            </div>
                        </div>
                    </div>

                    <%-- Danh sách sản phẩm trong đơn --%>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px">
                        <div id="detail-items-count" style="font-size:12px; font-weight:800; text-transform:uppercase; color:var(--text-muted)">
                            Danh sách sản phẩm
                        </div>
                        <span class="hint" id="detail-items-weight">--</span>
                    </div>

                    <div class="order-items-list" id="detail-items-list">
                        <!-- Danh sách sản phẩm render theo từng đơn -->
                    </div>

                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; padding-top:14px; border-top:1px solid var(--line)">
                        <span style="font-size:14px; font-weight:700">Tổng thanh toán:</span>
                        <b style="font-size:20px; font-weight:800; color:#ea580c" id="detail-total">0₫</b>
                    </div>

                    <%-- Action buttons phù hợp cho từng giai đoạn --%>
                    <div id="action-btn-container" style="display:flex; gap:8px; margin-top:16px">
                        <!-- Nút xử lý chuyển đổi theo từng giai đoạn đơn hàng -->
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:40px 20px; min-height:420px; color:var(--text-muted)">
                        <div style="width:54px; height:54px; border-radius:50%; background:#fff7ed; color:#ea580c; display:flex; align-items:center; justify-content:center; font-size:24px; margin-bottom:16px">
                            <i class="ti ti-receipt"></i>
                        </div>
                        <h3 style="margin:0 0 8px 0; color:var(--text-main); font-size:16px">Chi tiết đơn hàng</h3>
                        <p style="font-size:13px; max-width:320px; line-height:1.5; margin:0">
                            Không có đơn hàng nào được chọn. Chọn một đơn hàng từ bảng bên trái để theo dõi tiến trình và quản lý giao nhận.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<script>

    function resolveCustomerInfo(email, totalAmount) {
        let tier = '✪ Hội viên Đồng';
        let tierClass = 'bronze';
        if (totalAmount >= 5000000) {
            tier = '✪ Hội viên Kim Cương';
            tierClass = 'diamond';
        } else if (totalAmount >= 2000000) {
            tier = '✪ Hội viên Vàng';
            tierClass = 'gold';
        } else if (totalAmount >= 1000000) {
            tier = '✪ Hội viên Bạc';
            tierClass = 'silver';
        }
        return {
            phone: 'Theo thông tin đăng ký',
            tier: tier,
            tierClass: tierClass,
            address: 'Địa chỉ theo đơn hàng #'
        };
    }

    // Dữ liệu đơn hàng thực tế lấy trực tiếp từ Spring Boot Model & Database
    const realOrdersMap = {};
    <c:forEach var="o" items="${orders}">
    (function() {
        const cInfo = resolveCustomerInfo('<c:out value="${empty o.customerEmail ? '' : o.customerEmail}"/>', ${o.totalAmount});
        const itemsList = [];
        realOrdersMap['ORD-${o.id}'] = {
            id: '${o.id}',
            code: 'ORD-${o.id}',
            name: '<c:out value="${empty o.customerName ? 'Khách hàng #' += o.id : o.customerName}"/>',
            phone: cInfo.phone,
            email: '<c:out value="${empty o.customerEmail ? 'N/A' : o.customerEmail}"/>',
            time: '${o.createdAtText}',
            channel: 'Hệ thống PetFood',
            total: '<fmt:formatNumber value="${o.totalAmount}" type="number"/>₫',
            status: '${o.status.name()}',
            statusLabel: '${o.status.label}',
            statusPill: '${o.status == "COMPLETED" ? "green" : (o.status == "SHIPPED" ? "blue" : (o.status == "PROCESSING" ? "blue" : (o.status == "CONFIRMED" ? "green" : (o.status == "CANCELLED" ? "red" : "gray"))))}',
            tier: cInfo.tier,
            tierClass: cInfo.tierClass,
            address: cInfo.address,
            carrier: 'Giao Hàng Nhanh (GHN)',
            weight: '${o.totalQuantity * 0.5} kg',
            stepIndex: ${o.status == "PENDING" ? 1 : (o.status == "CONFIRMED" ? 2 : (o.status == "PROCESSING" ? 3 : (o.status == "SHIPPED" ? 4 : 5)))},
            stepTimes: ['${o.createdAtText}', '--:--', '--:--', '--:--', '--:--'],
            isReal: true,
            lineCount: ${o.lineCount},
            totalQty: ${o.totalQuantity},
            paymentMethod: '${o.paymentMethodLabel}',
            paymentStatus: '${o.paymentStatusLabel}',
            cancelRequested: ${o.cancelRequested},
            items: itemsList
        };
    })();
    </c:forEach>

    // Dữ liệu đơn hàng thực tế
    const allOrdersData = realOrdersMap;
    let currentSelectedOrderCode = <c:choose><c:when test="${not empty orders}">'ORD-${orders[0].id}'</c:when><c:otherwise>null</c:otherwise></c:choose>;

    // Cấu hình từng giai đoạn xử lý đơn hàng
    const STAGE_CONFIG = {
        'PENDING': {
            stepIndex: 1,
            statusLabel: 'Chờ duyệt',
            statusPill: 'gray',
            btnText: 'Xác nhận đơn',
            btnIcon: 'ti-check',
            btnStyle: 'background:#ea580c; color:#fff;',
            nextStatus: 'CONFIRMED'
        },
        'CONFIRMED': {
            stepIndex: 2,
            statusLabel: 'Đã xác nhận',
            statusPill: 'green',
            btnText: 'Đóng gói hàng',
            btnIcon: 'ti-package',
            btnStyle: 'background:#ea580c; color:#fff;',
            nextStatus: 'PROCESSING'
        },
        'PROCESSING': {
            stepIndex: 3,
            statusLabel: 'Đang đóng gói',
            statusPill: 'blue',
            btnText: 'Bàn giao vận chuyển',
            btnIcon: 'ti-truck',
            btnStyle: 'background:#2563eb; color:#fff;',
            nextStatus: 'SHIPPED'
        },
        'SHIPPED': {
            stepIndex: 4,
            statusLabel: 'Đang giao',
            statusPill: 'blue',
            btnText: 'Xác nhận hoàn tất',
            btnIcon: 'ti-circle-check',
            btnStyle: 'background:#10b981; color:#fff;',
            nextStatus: 'COMPLETED'
        },
        'COMPLETED': {
            stepIndex: 5,
            statusLabel: 'Hoàn tất',
            statusPill: 'green',
            btnText: 'Đơn hàng đã hoàn tất thành công',
            btnIcon: 'ti-check-double',
            btnStyle: 'background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; cursor:default; font-weight:700;',
            nextStatus: null
        }
    };

    // Hàm chọn đơn hàng: Đồng bộ tức thì giao diện bên trái và bên phải
    function selectOrderCode(code) {
        const order = allOrdersData[code];
        if (!order) return;
        currentSelectedOrderCode = code;

        // 1. Cập nhật dòng được chọn ở bảng bên trái
        document.querySelectorAll('.order-table-row').forEach(row => {
            row.classList.remove('selected-order-row');
            row.style.background = '';
            const eye = row.querySelector('.act-icon');
            if (eye) {
                eye.style.color = '';
                eye.style.borderColor = '';
                eye.style.background = '';
            }
        });

        const activeRow = document.getElementById('row-' + code);
        if (activeRow) {
            activeRow.classList.add('selected-order-row');
            activeRow.style.background = '#fff7ee';
            const eye = activeRow.querySelector('.act-icon');
            if (eye) {
                eye.style.color = '#ea580c';
                eye.style.borderColor = '#ea580c';
                eye.style.background = '#ffedd5';
            }
        }

        // 2. Hiển thị thông tin chi tiết vào Drawer bên phải
        renderOrderDetail(order);
    }


    // Hiển thị toàn bộ chi tiết đơn hàng
    function renderOrderDetail(order) {
        const drawer = document.getElementById('order-drawer');
        if (!drawer) return;
        drawer.style.display = 'block';

        // Tiêu đề, trạng thái, thời gian
        document.getElementById('detail-code').innerText = '#' + order.code;
        const statusEl = document.getElementById('detail-status');
        if (statusEl) {
            statusEl.className = 'pill-badge ' + order.statusPill;
            statusEl.innerText = '● ' + order.statusLabel;
        }
        document.getElementById('detail-time').innerText = 'Tạo lúc: ' + order.time + ' • ' + order.channel;

        // Tiến trình 5 bước (Stepper)
        renderStepper(order.stepIndex, order.stepTimes);

        // Khách hàng & Địa chỉ
        document.getElementById('detail-cust-name').innerText = order.name;
        document.getElementById('detail-cust-email').innerHTML = order.email + '<br>' + order.phone;
        const tierEl = document.getElementById('detail-cust-tier');
        if (tierEl) {
            tierEl.className = 'pill-badge ' + order.tierClass;
            tierEl.innerText = order.tier;
        }

        document.getElementById('detail-address-name').innerText = 'Người nhận: ' + order.name;
        document.getElementById('detail-address-desc').innerText = order.address;
        if (order.isReal) {
            document.getElementById('detail-carrier').innerHTML = 'Phương thức thanh toán: <b>' + order.paymentMethod + ' (' + order.paymentStatus + ')</b>';
        } else {
            document.getElementById('detail-carrier').innerHTML = 'Đơn vị vận chuyển: <b>' + order.carrier + '</b>';
        }

        // Danh sách sản phẩm
        if (order.items && order.items.length > 0) {
            document.getElementById('detail-items-count').innerText = 'Danh sách sản phẩm (' + order.items.length + ' món' + (order.totalQty ? ' / ' + order.totalQty + ' sản phẩm' : '') + ')';
            document.getElementById('detail-items-weight').innerHTML = 'Khối lượng: <b>' + order.weight + '</b>';

            let itemsHtml = '';
            order.items.forEach(it => {
                itemsHtml += '<div class="order-item-row">' +
                    '  <div class="order-item-left">' +
                    '    <img src="${ctx}/images/' + it.img + '" onerror="this.src=\'https://placehold.co/44x44?text=Pet\'" alt="" class="order-item-img">' +
                    '    <div class="order-item-info">' +
                    '      <b>' + it.name + '</b>' +
                    '      <small>' + it.desc + '<br>' + it.price + ' × ' + it.qty + '</small>' +
                    '    </div>' +
                    '  </div>' +
                    '  <div class="order-item-price">' + it.price + '</div>' +
                    '</div>';
            });
            document.getElementById('detail-items-list').innerHTML = itemsHtml;
        } else if (order.isReal) {
            document.getElementById('detail-items-count').innerText = 'Danh sách sản phẩm (' + order.lineCount + ' dòng / ' + order.totalQty + ' món)';
            document.getElementById('detail-items-weight').innerHTML = 'Khối lượng: <b>' + order.weight + '</b>';

            let itemsHtml = '<div class="order-item-row" style="padding:10px; background:#fffcf9; border-radius:10px; border:1px solid #fed7aa">' +
                '  <div class="order-item-left">' +
                '    <div class="avatar" style="width:40px; height:40px; font-size:18px; background:#ffedd5; color:#ea580c; display:flex; align-items:center; justify-content:center; border-radius:8px"><i class="ti ti-package"></i></div>' +
                '    <div class="order-item-info">' +
                '      <b>Đơn hàng trực tuyến #' + order.id + '</b>' +
                '      <small>Gồm ' + order.lineCount + ' món hàng (' + order.totalQty + ' sản phẩm)<br>Thanh toán: ' + order.paymentMethod + ' · ' + order.paymentStatus + '</small>' +
                '    </div>' +
                '  </div>' +
                '  <div class="order-item-price" style="font-weight:800; color:#ea580c">' + order.total + '</div>' +
                '</div>';
            document.getElementById('detail-items-list').innerHTML = itemsHtml;
        }

        // Tổng tiền
        document.getElementById('detail-total').innerText = order.total;

        // Nút hành động tương ứng với giai đoạn
        renderActionButton(order);
    }

    // Vẽ thanh tiến trình (Stepper 5 bước) chính xác theo trạng thái
    function renderStepper(stepIndex, stepTimes) {
        const steps = [
            { label: 'Chờ duyệt', num: 1 },
            { label: 'Đã xác nhận', num: 2 },
            { label: 'Đang đóng gói', num: 3 },
            { label: 'Đang giao', num: 4 },
            { label: 'Hoàn tất', num: 5 }
        ];

        let html = '';
        steps.forEach((s, idx) => {
            const stepNum = idx + 1;
            let cls = 'stepper-step';
            let circleContent = stepNum;

            if (stepNum < stepIndex || (stepIndex === 5 && stepNum === 5)) {
                cls += ' completed';
                circleContent = '<i class="ti ti-check"></i>';
            } else if (stepNum === stepIndex) {
                cls += ' active';
            }

            const time = (stepTimes && stepTimes[idx]) ? stepTimes[idx] : '--:--';
            html += '<div class="' + cls + '">' +
                    '  <div class="stepper-circle">' + circleContent + '</div>' +
                    '  <span class="stepper-label">' + s.label + '</span>' +
                    '  <span class="stepper-time">' + time + '</span>' +
                    '</div>';
        });

        const stepperEl = document.getElementById('order-stepper');
        if (stepperEl) stepperEl.innerHTML = html;
    }

    // Hiển thị nút hành động phù hợp cho từng giai đoạn
    function renderActionButton(order) {
        const container = document.getElementById('action-btn-container');
        if (!container) return;

        if (order.isReal) {
            let actionFormHtml = '';
            if (order.status === 'PENDING') {
                actionFormHtml =
                    '<form method="post" action="${ctx}/staff/orders/' + order.id + '/confirm" style="flex:1; display:flex;">' +
                    '  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">' +
                    '  <button type="submit" class="urgent-btn-fill" style="flex:1; background:#ea580c; color:#fff; cursor:pointer;"><i class="ti ti-check" style="margin-right:6px"></i>Xác nhận đơn</button>' +
                    '</form>';
            } else if (order.status === 'CONFIRMED') {
                actionFormHtml =
                    '<form method="post" action="${ctx}/staff/orders/' + order.id + '/pack" style="flex:1; display:flex;">' +
                    '  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">' +
                    '  <button type="submit" class="urgent-btn-fill" style="flex:1; background:#ea580c; color:#fff; cursor:pointer;"><i class="ti ti-package" style="margin-right:6px"></i>Đóng gói hàng</button>' +
                    '</form>';
            } else if (order.status === 'PROCESSING') {
                actionFormHtml =
                    '<form method="post" action="${ctx}/staff/orders/' + order.id + '/ship" style="flex:1; display:flex;">' +
                    '  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">' +
                    '  <button type="submit" class="urgent-btn-fill" style="flex:1; background:#2563eb; color:#fff; cursor:pointer;"><i class="ti ti-truck" style="margin-right:6px"></i>Bàn giao vận chuyển</button>' +
                    '</form>';
            } else if (order.status === 'SHIPPED') {
                actionFormHtml =
                    '<form method="post" action="${ctx}/staff/orders/' + order.id + '/complete" style="flex:1; display:flex;">' +
                    '  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">' +
                    '  <button type="submit" class="urgent-btn-fill" style="flex:1; background:#10b981; color:#fff; cursor:pointer;"><i class="ti ti-circle-check" style="margin-right:6px"></i>Giao thành công</button>' +
                    '</form>';
            } else if (order.status === 'COMPLETED') {
                actionFormHtml =
                    '<div class="urgent-btn-fill" style="flex:1; background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; text-align:center; font-weight:700;"><i class="ti ti-check-double" style="margin-right:6px"></i>Đơn hàng đã hoàn tất thành công</div>';
            } else {
                actionFormHtml =
                    '<div class="urgent-btn-fill" style="flex:1; background:#fef2f2; color:#991b1b; border:1px solid #fecaca; text-align:center; font-weight:700;">Đơn hàng: ' + order.statusLabel + '</div>';
            }

            container.innerHTML = actionFormHtml +
                '<a href="${ctx}/staff/orders/' + order.id + '" class="urgent-btn-outline" title="Xem chi tiết đầy đủ đơn hàng" style="display:inline-flex; align-items:center; justify-content:center; text-decoration:none;"><i class="ti ti-external-link"></i></a>' +
                '<button type="button" onclick="window.print()" class="urgent-btn-outline" style="text-align:center; cursor:pointer;" title="In đơn hàng"><i class="ti ti-printer"></i></button>';
        }
    }

    // Hiển thị thông báo Toast
    function showToast(msg) {
        let t = document.getElementById('order-action-toast');
        if (!t) {
            t = document.createElement('div');
            t.id = 'order-action-toast';
            t.style.cssText = 'position:fixed; bottom:24px; right:24px; background:#1e293b; color:#fff; padding:12px 20px; border-radius:12px; font-size:13px; font-weight:700; display:flex; align-items:center; gap:8px; box-shadow:0 10px 25px rgba(0,0,0,0.25); z-index:99999; transform:translateY(100px); opacity:0; transition:all 0.3s cubic-bezier(0.16,1,0.3,1);';
            document.body.appendChild(t);
        }
        t.innerHTML = '<i class="ti ti-circle-check" style="color:#10b981; font-size:18px"></i> ' + msg;
        t.style.transform = 'translateY(0)';
        t.style.opacity = '1';
        clearTimeout(t.timer);
        t.timer = setTimeout(() => {
            t.style.transform = 'translateY(100px)';
            t.style.opacity = '0';
        }, 3000);
    }

    // Khởi tạo mặc định: chọn đơn đầu tiên nếu có
    window.addEventListener('DOMContentLoaded', () => {
        if (currentSelectedOrderCode) {
            selectOrderCode(currentSelectedOrderCode);
        }
    });
</script>
</body>
</html>
