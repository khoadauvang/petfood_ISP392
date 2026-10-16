<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: filterFrom, filterTo (LocalDate), alertSummary, stats (AdminDashboard; null nếu khoảng ngày sai, kèm errorMessage) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thống kê · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; margin: 12px 0; }
        .card { border: 1px solid #e5e5e5; border-radius: 6px; padding: 10px 12px; }
        .card .value { font-size: 22px; font-weight: bold; margin-top: 4px; }
        .bar { background: #4caf50; height: 12px; border-radius: 2px; min-width: 2px; }
        .cols { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<h1>Thống kê</h1>

<form class="filters" method="get" action="${ctx}/admin">
    <label>Từ ngày <input type="date" name="from" value="${filterFrom}"></label>
    <label>Đến ngày <input type="date" name="to" value="${filterTo}"></label>
    <button type="submit">Xem</button>
    <span class="hint">Doanh thu tính theo đơn giao thành công (Hoàn thành) theo ngày hoàn tất.</span>
</form>

<c:if test="${stats != null}">
    <div class="cards">
        <div class="card">Doanh thu<div class="value"><fmt:formatNumber value="${stats.grossRevenue}" type="number"/>đ</div>
            <div class="hint">${stats.completedOrders} đơn hoàn thành, gồm phí ship</div></div>
        <div class="card">Tiền hàng<div class="value"><fmt:formatNumber value="${stats.goodsRevenue}" type="number"/>đ</div>
            <div class="hint">Không tính phí ship</div></div>
        <div class="card">Đã hoàn tiền<div class="value"><fmt:formatNumber value="${stats.refunds}" type="number"/>đ</div>
            <div class="hint">Yêu cầu trả hàng đã hoàn trong kỳ</div></div>
        <div class="card">Doanh thu thuần<div class="value"><fmt:formatNumber value="${stats.netRevenue}" type="number"/>đ</div>
            <div class="hint">Doanh thu trừ tiền đã hoàn</div></div>
        <div class="card">Khách đăng ký mới<div class="value">${stats.newCustomers}</div></div>
    </div>

    <h2>Việc đang chờ</h2>
    <ul>
        <li><a href="${ctx}/staff/orders?status=PENDING">${stats.pendingOrders} đơn chờ xác nhận</a></li>
        <li><a href="${ctx}/staff/returns?status=REQUESTED">${stats.requestedReturns} yêu cầu trả hàng chờ duyệt</a></li>
        <li><a href="${ctx}/staff/support?status=NEW">${stats.newSupportTickets} yêu cầu hỗ trợ mới</a></li>
        <li><a href="${ctx}/staff/alerts#low-stock">${alertSummary.lowStockCount} sản phẩm dưới ngưỡng tồn thấp</a>,
            <a href="${ctx}/staff/alerts#near-expiry">${alertSummary.nearExpiryLotCount} lô sắp hết hạn</a></li>
    </ul>

    <div class="cols">
        <div>
            <h2>Doanh thu theo ngày</h2>
            <table>
                <thead><tr><th>Ngày</th><th class="num">Đơn</th><th class="num">Doanh thu</th><th style="width:40%"></th></tr></thead>
                <tbody>
                <c:forEach var="d" items="${stats.dailyRevenue}">
                    <tr><td>${d.dayText}</td><td class="num">${d.orderCount}</td>
                        <td class="num"><fmt:formatNumber value="${d.amount}" type="number"/>đ</td>
                        <td><div class="bar" style="width:${d.barPercent}%"></div></td></tr>
                </c:forEach>
                <c:if test="${empty stats.dailyRevenue}"><tr><td colspan="4">Chưa có đơn hoàn thành trong khoảng này.</td></tr></c:if>
                </tbody>
            </table>
        </div>
        <div>
            <h2>Sản phẩm bán chạy</h2>
            <table>
                <thead><tr><th>Sản phẩm</th><th class="num">Đã bán</th><th class="num">Tiền hàng</th></tr></thead>
                <tbody>
                <c:forEach var="p" items="${stats.topProducts}">
                    <tr><td><a href="${ctx}/staff/products/${p.productId}"><c:out value="${p.name}"/></a>
                            <div class="hint"><c:out value="${p.sku}"/></div></td>
                        <td class="num">${p.quantity}</td>
                        <td class="num"><fmt:formatNumber value="${p.revenue}" type="number"/>đ</td></tr>
                </c:forEach>
                <c:if test="${empty stats.topProducts}"><tr><td colspan="3">Chưa có dữ liệu.</td></tr></c:if>
                </tbody>
            </table>
        </div>
        <div>
            <h2>Đơn đặt trong kỳ theo trạng thái</h2>
            <table>
                <tbody>
                <c:forEach var="s" items="${stats.ordersByStatus}">
                    <tr><td><a href="${ctx}/staff/orders?status=${s.code}">${s.label}</a></td><td class="num">${s.count}</td></tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        <div>
            <h2>Khách hàng theo hạng</h2>
            <table>
                <tbody>
                <c:forEach var="t" items="${stats.customersByTier}">
                    <tr><td>${t.label}</td><td class="num">${t.count}</td></tr>
                </c:forEach>
                </tbody>
            </table>
            <form method="post" action="${ctx}/admin/membership/recalculate">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button type="submit">Tính lại hạng ngay</button>
                <span class="hint">Job tự chạy mỗi ngày lúc 00:05</span>
            </form>
        </div>
    </div>
</c:if>

<h2>Quản trị</h2>
<ul>
    <li><a href="${ctx}/admin/employees">Tài khoản nhân viên</a> · <a href="${ctx}/admin/employees/new">Tạo tài khoản</a></li>
    <li><a href="${ctx}/staff">Trang tổng quan của nhân viên</a></li>
</ul>
</body>
</html>
