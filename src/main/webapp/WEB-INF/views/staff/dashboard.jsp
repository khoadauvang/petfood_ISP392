<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: pageTitle, alertSummary --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Tổng quan vận hành sàn kho · PetFood</title>
    <meta name="description" content="Tổng quan về tình hình hoàn tất đơn hàng hôm nay, hàng đợi điều phối và các sai lệch trả hàng.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>● CA LÀM VIỆC 01 • VẬN HÀNH SÀN KHO</span>
            </div>
            <h1 style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
                TỔNG QUAN VẬN HÀNH
                <span class="pill-badge green" id="staff-live-badge" style="font-size:11px; padding:4px 10px; cursor:pointer;" onclick="fetchStaffLiveStats()" title="Bấm để đồng bộ ngay lập tức">
                    <span style="width:7px; height:7px; border-radius:50%; background:#16a34a; display:inline-block; box-shadow:0 0 0 2px #bbf7d0;"></span>
                    THỜI GIAN THỰC
                </span>
            </h1>
            <p class="page-sub">Tổng quan về tình hình hoàn tất đơn hàng hôm nay, hàng đợi điều phối và các sai lệch trả hàng</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <button type="button" class="export-btn" onclick="fetchStaffLiveStats()"><i class="ti ti-refresh"></i>Tự động đồng bộ mỗi 20 giây</button>
            <button type="button" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c" onclick="fetchStaffLiveStats()"><i class="ti ti-rotate-clockwise"></i>Làm mới dữ liệu</button>
        </div>
    </div>

    <%-- 4 KPI Stat Cards Screen 2 --%>
    <section class="grid g-4">
        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">ĐƠN HÀNG CẦN XỬ LÝ</span>
                <span class="kpi-ico orange"><i class="ti ti-clipboard-list"></i></span>
            </div>
            <div class="kpi-value" id="staff-kpi-pending">${pendingOrders != null ? pendingOrders : 0}</div>
            <div class="kpi-meta"><span class="badge ok">Cần xử lý</span> Chờ xác nhận đơn</div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">ĐƠN HÀNG ĐANG XỬ LÝ</span>
                <span class="kpi-ico blue"><i class="ti ti-package"></i></span>
            </div>
            <div class="kpi-value" id="staff-kpi-processing" style="color:#2563eb">${processingOrders != null ? processingOrders : 0}</div>
            <div class="kpi-meta">Đang đóng gói &amp; bàn giao</div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">YÊU CẦU TRẢ HÀNG</span>
                <span class="kpi-ico purple"><i class="ti ti-arrow-back-up"></i></span>
            </div>
            <div class="kpi-value" id="staff-kpi-returns" style="color:#7c3aed">${returnRequests != null ? returnRequests : 0}</div>
            <div class="kpi-meta"><span class="badge warn">Chờ duyệt &amp; kiểm tra</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top">
                <span class="kpi-label">ĐƠN ĐÃ HỦY / HOÀN</span>
                <span class="kpi-ico red"><i class="ti ti-alert-circle"></i></span>
            </div>
            <div class="kpi-value red" id="staff-kpi-cancelled">${cancelledOrders != null ? cancelledOrders : 0}</div>
            <div class="kpi-meta"><span class="badge red">Cần lưu ý</span></div>
        </div>
    </section>

    <%-- Banner COD cần xử lý --%>
    <c:if test="${codPendingCount > 0}">
    <div class="urgent-banner">
        <div class="urgent-left">
            <span class="urgent-icon"><i class="ti ti-alert-triangle"></i></span>
            <div>
                <span class="urgent-tag">[CẦN XỬ LÝ]</span>
                <span class="urgent-text">${codPendingCount} đơn hàng COD chờ xác nhận:</span>
                <span class="urgent-chips">
                    <c:forEach var="id" items="${codPendingIds}">
                        <span class="urgent-chip">#ORD-${id}</span>
                    </c:forEach>
                </span>
            </div>
        </div>
        <div class="urgent-actions">
            <a href="${ctx}/staff/orders?status=PENDING" class="urgent-btn-fill">Xem đơn COD</a>
        </div>
    </div>
    </c:if>

    <%-- Split Layout: Đơn hàng cần chú ý & Yêu cầu trả hàng gần đây --%>
    <div class="split-layout">
        <%-- Bảng Đơn hàng cần chú ý --%>
        <div class="split-panel">
            <div class="split-head">
                <div>
                    <h3 style="display:flex; align-items:center; gap:8px">
                        ĐƠN HÀNG CẦN CHÚ Ý <span class="pill-badge orange">${attentionOrders != null ? attentionOrders.size() : 0} Đơn chờ</span>
                    </h3>
                    <p style="font-size:12px; color:var(--text-muted); margin:2px 0 0">Hàng đợi các đơn PENDING cần duyệt hoặc có yêu cầu từ khách</p>
                </div>

                <div style="display:flex; gap:8px">
                    <a href="${ctx}/staff/orders" class="export-btn" style="padding:6px 10px"><i class="ti ti-list"></i>Xem tất cả</a>
                </div>
            </div>

            <div style="padding:0">
                <table style="margin:0; border:0; border-radius:0; box-shadow:none">
                    <thead>
                    <tr>
                        <th>MÃ ĐƠN</th>
                        <th>KHÁCH HÀNG</th>
                        <th>GIỜ ĐẶT</th>
                        <th>THANH TOÁN</th>
                        <th>TRẠNG THÁI ĐƠN</th>
                        <th>THAO TÁC</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty attentionOrders}">
                            <c:forEach var="o" items="${attentionOrders}" begin="0" end="7">
                                <tr>
                                    <td><a href="${ctx}/staff/orders/${o.id}" style="font-weight:800; color:#ea580c">#ORD-${o.id}</a></td>
                                    <td>
                                        <b><c:out value="${empty o.customerName ? 'Khách hàng #' += o.id : o.customerName}"/></b>
                                        <br><small style="color:var(--text-muted)"><c:out value="${empty o.customerEmail ? '' : o.customerEmail}"/></small>
                                    </td>
                                    <td>${o.createdAtText}</td>
                                    <td><span class="pill-badge gray">${o.paymentMethodLabel}</span></td>
                                    <td>
                                        <span class="pill-badge ${o.status == 'PENDING' ? 'gold' : 'gray'}">
                                            ● ${o.status.label}
                                        </span>
                                    </td>
                                    <td><a href="${ctx}/staff/orders/${o.id}" class="export-btn" style="padding:4px 10px; font-size:12px">Xử lý</a></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state" style="text-align:center; padding:35px 20px; color:var(--text-muted)">
                                        <i class="ti ti-circle-check" style="font-size:32px; display:block; margin-bottom:8px; color:#10b981"></i>
                                        <b>Không có đơn hàng nào cần chú ý</b>
                                        <p style="font-size:12px; margin-top:4px">Hàng đợi hiện tại đang trống.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="panel-foot" style="padding:14px 20px">
                <span>Hiển thị <b>${attentionOrders != null ? attentionOrders.size() : 0}</b> đơn hàng trong hàng đợi</span>
                <a href="${ctx}/staff/orders" style="font-size:12px; font-weight:700; color:#ea580c">Mở trang đơn hàng ›</a>
            </div>
        </div>

        <%-- Panel phải: Yêu cầu trả hàng gần đây --%>
        <div class="split-panel">
            <div class="split-head">
                <div>
                    <h3>YÊU CẦU TRẢ HÀNG GẦN ĐÂY</h3>
                    <p style="font-size:12px; color:var(--text-muted); margin:2px 0 0">Hộp thư phân loại và kiểm tra sản phẩm hoàn</p>
                </div>
                <a href="${ctx}/staff/returns" class="link-more">Xem tất cả <i class="ti ti-arrow-right"></i></a>
            </div>

            <div style="padding:16px; display:flex; flex-direction:column; gap:12px">
                <c:choose>
                    <c:when test="${not empty recentReturns}">
                        <c:forEach var="ret" items="${recentReturns}" begin="0" end="3">
                            <div style="border:1px solid var(--line); border-radius:14px; padding:14px; background:#fff">
                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px">
                                    <b style="font-size:13px; color:var(--text-logo)">#RR-00${ret.id}</b>
                                    <span class="pill-badge gold">${ret.status.label}</span>
                                    <small style="color:var(--text-muted)">${ret.createdAtText}</small>
                                </div>
                                <div style="display:flex; gap:12px; align-items:center; margin-bottom:10px">
                                    <div>
                                        <b style="display:block; font-size:13px"><c:out value="${ret.customerName}"/></b>
                                        <small style="color:#b91c1c; font-weight:600">Lý do: ${ret.reason.label}</small>
                                    </div>
                                </div>
                                <div style="display:flex; justify-content:space-between; align-items:center; font-size:11px; color:var(--text-muted); border-top:1px dashed var(--line); padding-top:8px">
                                    <span>Đơn #ORD-${ret.orderId}</span>
                                    <a href="${ctx}/staff/returns/${ret.id}" class="urgent-btn-fill" style="padding:4px 10px; font-size:11px; border-radius:6px">Xem chi tiết</a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align:center; padding:35px 20px; color:var(--text-muted)">
                            <i class="ti ti-inbox" style="font-size:32px; opacity:0.4; display:block; margin-bottom:8px"></i>
                            <b>Không có yêu cầu trả hàng nào gần đây</b>
                            <p style="font-size:12px; margin-top:4px">Chưa có yêu cầu trả hàng phát sinh.</p>
                        </div>
                    </c:otherwise>
                </c:choose>

                <a href="${ctx}/staff/returns" class="export-btn" style="display:flex; justify-content:center; padding:10px; background:#fffaf5; border-color:#fed7aa; color:#c2410c">
                    <i class="ti ti-clipboard-check"></i> Xem tất cả yêu cầu trả hàng
                </a>
            </div>
        </div>
    </div>
</main>

<script>
    let isPollingStaff = false;
    async function fetchStaffLiveStats() {
        if (isPollingStaff) return;
        isPollingStaff = true;
        const badge = document.getElementById('staff-live-badge');
        if (badge) {
            badge.innerHTML = '<i class="ti ti-loader" style="animation:spin 1s linear infinite; display:inline-block"></i> ĐANG ĐỒNG BỘ...';
        }
        try {
            const resp = await fetch('${ctx}/staff/api/stats');
            if (!resp.ok) throw new Error('API error: ' + resp.status);
            const data = await resp.json();
            if (data) {
                const pEl = document.getElementById('staff-kpi-pending');
                if (pEl && data.pendingOrders != null) pEl.innerText = data.pendingOrders;
                const prEl = document.getElementById('staff-kpi-processing');
                if (prEl && data.processingOrders != null) prEl.innerText = data.processingOrders;
                const rEl = document.getElementById('staff-kpi-returns');
                if (rEl && data.returnRequests != null) rEl.innerText = data.returnRequests;
                const cEl = document.getElementById('staff-kpi-cancelled');
                if (cEl && data.cancelledOrders != null) cEl.innerText = data.cancelledOrders;
            }
            if (badge) {
                badge.className = 'pill-badge green';
                badge.innerHTML = '<span style="width:7px; height:7px; border-radius:50%; background:#16a34a; display:inline-block; box-shadow:0 0 0 2px #bbf7d0;"></span> THỜI GIAN THỰC (' + (data.updatedAt || 'Vừa xong') + ')';
            }
        } catch (e) {
            console.warn('Lỗi đồng bộ staff stats:', e);
            if (badge) {
                badge.className = 'pill-badge gold';
                badge.innerHTML = '<span style="width:7px; height:7px; border-radius:50%; background:#d97706; display:inline-block;"></span> ĐANG KẾT NỐI...';
            }
        } finally {
            isPollingStaff = false;
        }
    }

    // Tự động làm mới mỗi 20 giây
    setInterval(fetchStaffLiveStats, 20000);
</script>
</body>
</html>
