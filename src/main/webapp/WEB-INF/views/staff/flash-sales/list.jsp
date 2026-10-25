<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: sales (List<FlashSaleRow>) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Flash Sale · PetFood</title>
    <meta name="description" content="Quản lý các chương trình khuyến mãi đặc biệt và flash sale kích cầu thức ăn thú cưng cận hạn.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>TỔNG QUAN</span> <span class="sep">&gt;</span> <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <span class="current">FLASH SALE</span>
            </div>
            <h1>FLASH SALE <span class="pill-badge orange">REAL-TIME PROMOTION</span></h1>
            <p class="page-sub">Quản lý các chương trình khuyến mãi đặc biệt và flash sale kích cầu thức ăn thú cưng cận hạn.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap">
            <a href="javascript:void(0)" class="btn-pill-outline" onclick="exportFlashSaleCSV()"><i class="ti ti-file-spreadsheet"></i>Xuất báo cáo (CSV)</a>
            <%-- Staff chỉ xem; tạo chiến dịch chỉ Admin --%>
            <c:if test="${currentUser.role == 'ADMIN'}">
                <a href="${ctx}/staff/flash-sales/new" class="btn-flashsale">
                    <i class="ti ti-plus"></i>Tạo Flash Sale
                </a>
            </c:if>
        </div>
    </div>

    <%-- Tính toán KPI chuẩn xác từ danh sách sales --%>
    <c:set var="totalSales" value="${not empty sales ? sales.size() : 0}"/>
    <c:set var="calcActive" value="0"/>
    <c:set var="calcDraft" value="0"/>
    <c:set var="calcEnded" value="0"/>
    <c:forEach var="item" items="${sales}">
        <c:if test="${item.status == 'ACTIVE'}"><c:set var="calcActive" value="${calcActive + 1}"/></c:if>
        <c:if test="${item.status == 'DRAFT' or item.status == 'PAUSED'}"><c:set var="calcDraft" value="${calcDraft + 1}"/></c:if>
        <c:if test="${item.status == 'ENDED'}"><c:set var="calcEnded" value="${calcEnded + 1}"/></c:if>
    </c:forEach>

    <%-- 4 Thẻ KPI Screen 5 --%>
    <section class="grid g-4">
        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Tổng chương trình</span>
                <span class="kpi-ico orange"><i class="ti ti-bolt"></i></span>
            </div>
            <div class="kpi-value">${totalSales}</div>
            <div class="kpi-meta"><span class="badge orange">Toàn bộ chiến dịch</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Đang diễn ra</span>
                <span class="kpi-ico green"><i class="ti ti-clock-play"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">${calcActive}</div>
            <div class="kpi-meta"><span class="badge ok">Đang chạy xả kho</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Bản nháp / Sắp chạy</span>
                <span class="kpi-ico blue"><i class="ti ti-calendar-event"></i></span>
            </div>
            <div class="kpi-value" style="color:#2563eb">${calcDraft}</div>
            <div class="kpi-meta"><span class="badge info">Chưa kích hoạt hoặc đã lên lịch</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Đã kết thúc</span>
                <span class="kpi-ico gray"><i class="ti ti-archive"></i></span>
            </div>
            <div class="kpi-value" style="color:#6b7280">${calcEnded}</div>
            <div class="kpi-meta"><span class="badge gray">Chiến dịch hoàn tất • Lưu trữ</span></div>
        </div>
    </section>

    <%-- Filter bar Screen 5 --%>
    <div class="filters" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap">
        <div style="flex:1; min-width:260px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:14px; top:50%; transform:translateY(-50%); color:var(--text-placeholder); font-size:16px"></i>
            <input type="search" id="fs-filter-keyword" placeholder="Tìm theo tên chương trình, mã chiến dịch (#FS-...)"
                   style="width:100%; padding:9px 14px 9px 38px; border-radius:12px; border:1px solid var(--line); font-size:13px"
                   oninput="filterFlashSales()">
        </div>

        <select id="fs-filter-status" onchange="filterFlashSales()" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Tất cả trạng thái</option>
            <option value="ACTIVE">Đang diễn ra (Đang chạy)</option>
            <option value="DRAFT">Bản nháp</option>
            <option value="PAUSED">Tạm dừng</option>
            <option value="ENDED">Đã kết thúc</option>
        </select>

        <button type="button" class="btn-pill-primary" onclick="filterFlashSales()">
            <i class="ti ti-filter"></i>Lọc
        </button>
        <button type="button" class="act-icon" title="Đặt lại bộ lọc" onclick="resetFlashSaleFilters()">
            <i class="ti ti-rotate"></i>
        </button>
    </div>

    <%-- Bảng danh sách Flash sale campaigns Screen 5 --%>
    <div class="panel" style="padding:0; overflow:hidden">
        <table style="margin:0; border:0; border-radius:0; box-shadow:none; width:100%">
            <thead>
            <tr>
                <th style="width:50px; text-align:center">STT</th>
                <th>TÊN CHƯƠNG TRÌNH &amp; MÔ TẢ</th>
                <th>THỜI GIAN BẮT ĐẦU – KẾT THÚC</th>
                <th>SỐ SẢN PHẨM</th>
                <th>MỨC GIẢM</th>
                <th>TRẠNG THÁI</th>
                <th style="text-align:right">THAO TÁC</th>
            </tr>
            </thead>
            <tbody id="fs-table-body">
            <c:choose>
                <c:when test="${not empty sales}">
                    <c:forEach var="s" items="${sales}" varStatus="st">
                        <tr class="fs-row"
                            data-name="<c:out value='${s.name}'/>"
                            data-code="fs-${s.id} fs-2026-0${s.id} #${s.id}"
                            data-creator="<c:out value='${s.createdByName}'/>"
                            data-status="${s.status.name()}">
                            <td class="fs-stt" style="text-align:center">${st.count}</td>
                            <td>
                                <div style="display:flex; align-items:center; gap:10px">
                                    <div class="kpi-ico orange" style="width:36px; height:36px; font-size:16px"><i class="ti ti-bolt"></i></div>
                                    <div>
                                        <a href="${ctx}/staff/flash-sales/${s.id}" style="font-weight:800; color:var(--text-logo)">
                                            <c:out value="${s.name}"/>
                                        </a>
                                        <div style="font-size:12px; color:var(--text-muted)">
                                            #FS-2026-0${s.id} • Người tạo: <c:out value="${s.createdByName}"/>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <b>${s.startText}</b> – ${s.endText}
                                <div style="margin-top:2px">
                                    <c:choose>
                                        <c:when test="${s.status == 'ACTIVE'}">
                                            <span class="pill-badge green"><i class="ti ti-clock-play"></i>Đang chạy xả kho</span>
                                        </c:when>
                                        <c:when test="${s.status == 'ENDED'}">
                                            <span class="pill-badge gray"><i class="ti ti-archive"></i>Đã đóng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge orange"><i class="ti ti-clock"></i>Đang theo dõi</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td><span class="pill-badge gray">${s.itemCount} SKUs</span></td>
                            <td><span class="pill-badge red">-30% đến -50%</span></td>
                            <td>
                                <span class="pill-badge ${s.status == 'ACTIVE' ? 'green' : (s.status == 'DRAFT' ? 'gold' : 'gray')}">
                                    ● ${s.status.label}
                                </span>
                            </td>
                            <td style="text-align:right">
                                <div class="action-icons">
                                    <a href="${ctx}/staff/flash-sales/${s.id}" class="act-icon" title="Chi tiết"><i class="ti ti-eye"></i></a>
                                    <%-- Chỉ sửa được chiến dịch nháp, và chỉ Admin --%>
                                    <c:if test="${currentUser.role == 'ADMIN' && s.status == 'DRAFT'}">
                                        <a href="${ctx}/staff/flash-sales/${s.id}/edit" class="act-icon" title="Chỉnh sửa"><i class="ti ti-edit"></i></a>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr id="fs-filter-empty" style="display:none">
                        <td colspan="7">
                            <div style="text-align:center; padding:36px 20px; color:var(--text-muted)">
                                <i class="ti ti-search-off" style="font-size:32px; display:block; margin-bottom:8px; opacity:0.6"></i>
                                <b>Không tìm thấy chương trình Flash Sale nào phù hợp với bộ lọc</b>
                                <p style="font-size:13px; margin:4px 0 12px 0">Thử tìm kiếm với từ khoá khác hoặc đặt lại bộ lọc.</p>
                                <button type="button" class="btn-pill-outline" onclick="resetFlashSaleFilters()">
                                    <i class="ti ti-rotate"></i>Đặt lại bộ lọc
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="7">
                            <div class="empty-state" style="text-align:center; padding:45px 20px; color:var(--text-muted)">
                                <i class="ti ti-bolt-off" style="font-size:36px; display:block; margin-bottom:10px; opacity:0.5"></i>
                                <b>Chưa có chương trình Flash Sale nào</b>
                                <p style="font-size:13px; margin-top:4px">Bấm nút "Tạo Flash Sale" ở góc trên để tạo chiến dịch mới.</p>
                            </div>
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>

        <div class="panel-foot" style="padding:14px 20px">
            <span>Hiển thị <b id="fs-visible-count">${totalSales}</b> trong tổng số <b>${totalSales}</b> chương trình Flash Sale</span>
        </div>
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

    function filterFlashSales() {
        const keywordInput = document.getElementById('fs-filter-keyword');
        const statusSelect = document.getElementById('fs-filter-status');
        if (!keywordInput || !statusSelect) return;

        const rawKeyword = (keywordInput.value || '').trim();
        const normKeyword = removeVietnameseTones(rawKeyword);
        const selectedStatus = (statusSelect.value || '').trim();

        const rows = document.querySelectorAll('.fs-row');
        let visibleCount = 0;

        rows.forEach(row => {
            const rawName = row.getAttribute('data-name') || '';
            const normName = removeVietnameseTones(rawName);
            const code = (row.getAttribute('data-code') || '').toLowerCase();
            const rawCreator = row.getAttribute('data-creator') || '';
            const normCreator = removeVietnameseTones(rawCreator);
            const rowStatus = row.getAttribute('data-status') || '';

            // Kiểm tra khớp từ khoá (tìm theo tên, mã FS, hoặc người tạo)
            let matchKeyword = true;
            if (rawKeyword) {
                matchKeyword = rawName.toLowerCase().includes(rawKeyword.toLowerCase())
                    || normName.includes(normKeyword)
                    || code.includes(rawKeyword.toLowerCase())
                    || normCreator.includes(normKeyword);
            }

            // Kiểm tra khớp trạng thái
            let matchStatus = true;
            if (selectedStatus) {
                matchStatus = (rowStatus === selectedStatus);
            }

            if (matchKeyword && matchStatus) {
                row.style.display = '';
                visibleCount++;
                const sttEl = row.querySelector('.fs-stt');
                if (sttEl) sttEl.textContent = visibleCount;
            } else {
                row.style.display = 'none';
            }
        });

        const emptyRow = document.getElementById('fs-filter-empty');
        if (emptyRow) {
            emptyRow.style.display = (visibleCount === 0 && rows.length > 0) ? '' : 'none';
        }

        const countFoot = document.getElementById('fs-visible-count');
        if (countFoot) {
            countFoot.textContent = visibleCount;
        }
    }

    function resetFlashSaleFilters() {
        const keywordInput = document.getElementById('fs-filter-keyword');
        const statusSelect = document.getElementById('fs-filter-status');
        if (keywordInput) keywordInput.value = '';
        if (statusSelect) statusSelect.value = '';
        filterFlashSales();
    }

    function exportFlashSaleCSV() {
        const rows = document.querySelectorAll('.fs-row');
        if (!rows || rows.length === 0) {
            alert('Không có dữ liệu Flash Sale để xuất file.');
            return;
        }
        let csv = '\uFEFFSTT,Tên chiến dịch,Mã,Người tạo,Trạng thái\n';
        let idx = 1;
        rows.forEach(row => {
            if (row.style.display !== 'none') {
                const name = (row.getAttribute('data-name') || '').replace(/"/g, '""');
                const code = row.getAttribute('data-code') || '';
                const creator = (row.getAttribute('data-creator') || '').replace(/"/g, '""');
                const status = row.getAttribute('data-status') || '';
                csv += idx++ + ',"' + name + '","' + code + '","' + creator + '","' + status + '"\n';
            }
        });
        const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'flash_sales_' + new Date().toISOString().slice(0, 10) + '.csv';
        a.click();
        URL.revokeObjectURL(url);
    }

    // Lắng nghe sự kiện Enter trong ô tìm kiếm
    document.addEventListener('DOMContentLoaded', function () {
        const keywordInput = document.getElementById('fs-filter-keyword');
        if (keywordInput) {
            keywordInput.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterFlashSales();
                }
            });
        }
    });
</script>
</body>
</html>
