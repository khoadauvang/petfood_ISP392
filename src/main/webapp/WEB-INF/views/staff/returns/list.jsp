<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: returns, currentPage, totalPages, totalItems, statuses, filterStatus, filterQuery --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý trả hàng · PetFood</title>
    <meta name="description" content="Theo dõi yêu cầu đổi trả hàng, xác nhận hàng hoàn và xử lý tái nhập kho.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>KHO &amp; ĐỔI TRẢ</span> <span class="sep">&gt;</span> <span class="current">QUẢN LÝ TRẢ HÀNG</span>
            </div>
            <h1>QUẢN LÝ TRẢ HÀNG</h1>
            <p class="page-sub">Theo dõi yêu cầu đổi trả hàng, xác nhận hàng hoàn và xử lý tái nhập kho.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <a href="javascript:void(0)" class="export-btn"><i class="ti ti-file-spreadsheet"></i>Xuất file CSV</a>
            <a href="javascript:void(0)" class="export-btn"><i class="ti ti-book"></i>Quy trình xử lý hàng hoàn</a>
        </div>
    </div>

    <%-- 6 KPI Cards Screen 11 --%>
    <section class="grid" style="grid-template-columns: repeat(6, minmax(0, 1fr))">
        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Tổng yêu cầu</span><span class="kpi-ico orange"><i class="ti ti-files"></i></span></div>
            <div class="kpi-value">${returnCounts.total != null ? returnCounts.total : 0}</div>
            <div class="kpi-meta"><span class="badge orange">Tất cả kênh</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ duyệt</span><span class="kpi-ico yellow"><i class="ti ti-hourglass"></i></span></div>
            <div class="kpi-value" style="color:#d97706">${returnCounts.requested != null ? returnCounts.requested : 0}</div>
            <div class="kpi-meta"><span class="badge warn">Cần xem xét</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Đã duyệt</span><span class="kpi-ico blue"><i class="ti ti-truck-return"></i></span></div>
            <div class="kpi-value" style="color:#2563eb">${returnCounts.approved != null ? returnCounts.approved : 0}</div>
            <div class="kpi-meta"><span class="badge info">Chờ gửi/nhận hàng</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ kiểm tra hàng</span><span class="kpi-ico purple"><i class="ti ti-box"></i></span></div>
            <div class="kpi-value" style="color:#7c3aed">${returnCounts.received != null ? returnCounts.received : 0}</div>
            <div class="kpi-meta"><span class="badge purple">Đã đến kho · Chờ QC</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Chờ hoàn tiền</span><span class="kpi-ico green"><i class="ti ti-cash"></i></span></div>
            <div class="kpi-value" style="color:#10b981">${returnCounts.inspected != null ? returnCounts.inspected : 0}</div>
            <div class="kpi-meta"><span class="badge ok">Đã kiểm tra đạt</span></div>
        </div>

        <div class="panel kpi reveal">
            <div class="kpi-top"><span class="kpi-label">Đã hoàn tất</span><span class="kpi-ico green"><i class="ti ti-circle-check"></i></span></div>
            <div class="kpi-value" style="color:#10b981">${returnCounts.completed != null ? returnCounts.completed : 0}</div>
            <div class="kpi-meta"><span class="badge ok">Đã hoàn tiền &amp; xử lý kho</span></div>
        </div>
    </section>

    <%-- Filter bar Screen 11 --%>
    <form method="get" action="${ctx}/staff/returns" class="filters" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:200px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
            <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo Mã yêu cầu, Mã đơn hàng, Tên khách hàng... (Nhấn / để tìm)"
                   style="width:100%; padding:9px 12px 9px 36px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="status" style="padding:9px 12px; border-radius:12px; border:1px solid var(--line); font-size:13px; background:#fff">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="s" items="${statuses}">
                <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>

        <select name="reason" style="padding:9px 12px; border-radius:12px; border:1px solid var(--line); font-size:13px; background:#fff">
            <option value="">Tất cả lý do trả hàng</option>
            <c:forEach var="r" items="${reasons}">
                <option value="${r}" ${filterReason == r ? 'selected' : ''}>${r.label}</option>
            </c:forEach>
        </select>

        <div style="display:inline-flex; align-items:center; gap:6px; background:#fff; border:1px solid var(--line); border-radius:12px; padding:5px 10px; font-size:13px">
            <i class="ti ti-calendar" style="color:var(--color-primary)"></i>
            <input type="date" name="from" value="<c:out value='${filterFrom}'/>" style="border:none; outline:none; font-size:12.5px; color:var(--text-main); background:transparent" title="Từ ngày">
            <span style="color:var(--text-muted)">→</span>
            <input type="date" name="to" value="<c:out value='${filterTo}'/>" style="border:none; outline:none; font-size:12.5px; color:var(--text-main); background:transparent" title="Đến ngày">
        </div>

        <div style="display:inline-flex; gap:6px; align-items:center">
            <button type="submit" class="export-btn" style="background:#ea580c; color:#fff; border-color:#ea580c; cursor:pointer"><i class="ti ti-filter"></i> Lọc</button>
            <a href="${ctx}/staff/returns" class="act-icon" title="Đặt lại bộ lọc" style="display:inline-flex; align-items:center; justify-content:center; width:38px; height:38px; border-radius:12px; border:1px solid var(--line); background:#fff; color:var(--text-main); text-decoration:none"><i class="ti ti-rotate"></i></a>
        </div>
    </form>

    <%-- Split Layout: Danh sách yêu cầu & Chi tiết xử lý (Screen 11) --%>
    <div class="split-layout">
        <%-- Trái: Bảng yêu cầu trả hàng --%>
        <div class="split-panel">
            <div class="split-head">
                <div>
                    <h3 style="margin:0">Danh sách yêu cầu trả hàng <span class="pill-badge orange">${returnCounts.total != null ? returnCounts.total : (totalItems != null ? totalItems : 0)} yêu cầu</span></h3>
                    <small style="color:var(--text-muted)">Hàng đợi thẩm định và hoàn tiền</small>
                </div>
                <div style="font-size:12px; color:var(--text-muted)">Đồng bộ thời gian thực ●</div>
            </div>

            <table style="margin:0; border:0; border-radius:0; box-shadow:none">
                <thead>
                <tr>
                    <th style="width:30px">STT</th>
                    <th>MÃ YÊU CẦU</th>
                    <th>ĐƠN HÀNG</th>
                    <th>KHÁCH HÀNG</th>
                    <th>NGÀY GHI NHẬN</th>
                    <th>LÝ DO</th>
                    <th>TRẠNG THÁI</th>
                    <th style="text-align:right">THAO TÁC</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty returns}">
                        <c:forEach var="r" items="${returns}" varStatus="st">
                            <tr style="cursor:pointer">
                                <td>${st.count}</td>
                                <td><a href="${ctx}/staff/returns/${r.id}" style="font-weight:800; color:#ea580c">#RR-00${r.id}</a></td>
                                <td><a href="${ctx}/staff/orders/${r.orderId}">#ORD-${r.orderId}</a></td>
                                <td>
                                    <b><c:out value="${r.customerName}"/></b>
                                    <c:if test="${not empty r.customerEmail}"><br><small style="color:var(--text-muted)"><c:out value="${r.customerEmail}"/></small></c:if>
                                </td>
                                <td>${r.createdAtText}</td>
                                <td>${r.reason.label}</td>
                                <td><span class="pill-badge gold">${r.status.label}</span></td>
                                <td style="text-align:right">
                                    <a href="${ctx}/staff/returns/${r.id}" class="urgent-btn-fill" style="padding:4px 10px; font-size:11px">Xem chi tiết</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state" style="text-align:center; padding:45px 20px; color:var(--text-muted)">
                                    <i class="ti ti-truck-return" style="font-size:36px; display:block; margin-bottom:10px; opacity:0.5"></i>
                                    <b>Không có yêu cầu trả hàng nào</b>
                                    <p style="font-size:13px; margin-top:4px">Hiện tại không có yêu cầu phù hợp với bộ lọc.</p>
                                </div>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>

            <div class="panel-foot" style="padding:14px 20px">
                <span>Hiển thị trang <b>${currentPage}</b> / <b>${totalPages > 0 ? totalPages : 1}</b> (Tổng số <b>${totalItems != null ? totalItems : 0}</b> yêu cầu)</span>
                <div class="pager" style="margin:0">
                    <c:if test="${totalPages > 1}">
                        <c:if test="${currentPage > 1}"><a href="${ctx}/staff/returns?page=${currentPage - 1}${not empty filterQuery ? '&' : ''}${filterQuery}">‹</a></c:if>
                        <c:forEach begin="1" end="${totalPages}" var="n">
                            <c:choose>
                                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                                <c:otherwise><a href="${ctx}/staff/returns?page=${n}${not empty filterQuery ? '&' : ''}${filterQuery}">${n}</a></c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}"><a href="${ctx}/staff/returns?page=${currentPage + 1}${not empty filterQuery ? '&' : ''}${filterQuery}">›</a></c:if>
                    </c:if>
                </div>
            </div>
        </div>

        <%-- Phải: Detail Pane Yêu cầu trả hàng --%>
        <div class="detail-card" style="display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; padding:40px 24px; min-height:450px; background:#fff; border-radius:14px; border:1px solid var(--line); color:var(--text-muted)">
            <div class="kpi-ico orange" style="width:54px; height:54px; font-size:24px; margin-bottom:16px"><i class="ti ti-clipboard-list"></i></div>
            <h3 style="margin:0 0 8px 0; color:var(--text-main); font-size:16px">Quy trình xử lý trả hàng</h3>
            <p style="font-size:13px; max-width:320px; line-height:1.5; margin:0 0 20px 0">
                Nhấp vào <b>Xem chi tiết</b> hoặc mã yêu cầu ở danh sách bên trái để mở trang thẩm định sản phẩm và thực hiện hoàn tiền.
            </p>
            <div style="text-align:left; font-size:12px; background:#fffaf5; border:1px solid #fed7aa; border-radius:10px; padding:12px 16px; width:100%; max-width:340px; color:#9a3412">
                <b style="display:block; margin-bottom:6px">5 Bước xử lý trả hàng:</b>
                <div>① Duyệt yêu cầu từ khách</div>
                <div>② Xác nhận nhận kiện hàng hoàn</div>
                <div>③ Thẩm định chất lượng (QC)</div>
                <div>④ Xử lý tồn kho (Tái nhập / Tiêu hủy)</div>
                <div>⑤ Xác nhận hoàn tiền đơn hàng</div>
            </div>
        </div>
    </div>
</main>
</body>
</html>
