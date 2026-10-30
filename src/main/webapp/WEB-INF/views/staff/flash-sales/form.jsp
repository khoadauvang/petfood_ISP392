<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: flashSaleForm, saleId, normalLots (List<NormalLotOption>) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${saleId == null ? 'Tạo chương trình giảm giá' : 'Sửa chương trình'} · PetFood</title>
    <meta name="description" content="Thiết lập chương trình khuyến mãi giảm giá dành cho các dịp lễ hoặc tạo theo mong muốn của Admin.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .form-section-card {
            background: #fff;
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .form-section-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 12px;
        }
        .form-section-title {
            font-size: 16px;
            font-weight: 800;
            color: var(--text-logo);
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
        }
        .form-label {
            display: block;
            font-weight: 700;
            font-size: 13px;
            margin-bottom: 6px;
            color: #334155;
        }
        .form-control {
            width: 100%;
            padding: 9px 14px;
            border-radius: 10px;
            border: 1px solid var(--line);
            font-size: 14px;
            box-sizing: border-box;
            background: #fff;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--color-primary);
        }
        .lot-select-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 10px;
        }
        .lot-select-table th {
            background: #f8fafc;
            padding: 10px 14px;
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            border-bottom: 1px solid var(--line);
        }
        .lot-select-table td {
            padding: 12px 14px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 13px;
            vertical-align: middle;
        }
        .lot-select-table tr:hover {
            background: #fcfdfe;
        }
        .lot-checkbox {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: var(--color-primary);
        }
        .price-badge-computed {
            font-weight: 800;
            color: #ea580c;
            font-size: 14px;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <c:choose>
        <c:when test="${saleId == null}">
            <c:set var="actionUrl" value="/staff/flash-sales/new"/>
        </c:when>
        <c:otherwise>
            <c:set var="actionUrl" value="/staff/flash-sales/${saleId}/edit"/>
        </c:otherwise>
    </c:choose>

    <form:form method="post" action="${ctx}${actionUrl}" modelAttribute="flashSaleForm" id="promotionForm">
        <div class="page-head" style="margin-bottom:20px">
            <div>
                <div class="screen-bc">
                    <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/flash-sales" style="text-decoration:none; color:inherit;">CHƯƠNG TRÌNH</a> <span class="sep">&gt;</span> <span class="current">${saleId == null ? 'TẠO MỚI' : 'CHỈNH SỬA'}</span><!--
                        ‹ CHƯƠNG TRÌNH
                    </a>
                    <span class="sep" style="margin: 0 6px;">&gt;</span>
                    <span class="current" style="color:var(--color-primary)">${saleId == null ? 'TẠO MỚI' : 'CHỈNH SỬA'}</span>-->
                </div>
                <h1 style="display:flex; align-items:center; gap:12px; margin-top:4px;">
                    ${saleId == null ? 'TẠO CHƯƠNG TRÌNH GIẢM GIÁ' : 'CHỈNH SỬA CHƯƠNG TRÌNH'}
                    <span class="pill-badge promotion-type" style="font-size:12px; font-weight:700">
                        <i class="ti ti-tag"></i>Giảm giá thường / Dịp lễ
                    </span>
                </h1>
                <p class="page-sub">
                    Chương trình khuyến mãi áp dụng chung 1 mức giảm giá (%) cho toàn bộ các lô hàng bình thường bảo đảm hạn dùng trên 90 ngày.
                </p>
            </div>

            <div style="display:flex; align-items:center; gap:10px">
                <a href="${ctx}/staff/flash-sales" class="btn-pill-outline">
                    <i class="ti ti-x"></i>Hủy bỏ
                </a>
                <c:if test="${saleId != null}">
                    <button type="submit" name="activate" value="true" class="btn-flashsale" style="background:linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow:0 4px 12px rgba(16,185,129,0.3)" title="Lưu thông tin và phát hành chiến dịch mở bán ngay lập tức">
                        <i class="ti ti-player-play"></i>Lưu &amp; Mở bán ngay
                    </button>
                </c:if>
                <button type="submit" class="btn-flashsale" style="box-shadow: 0 4px 12px rgba(234, 88, 12, 0.25)">
                    <i class="ti ti-check"></i>${saleId == null ? 'Tạo chương trình' : 'Lưu bản nháp'}
                </button>
            </div>
        </div>

        <%-- Card 1: Thông tin chiến dịch & Mức giảm giá chung --%>
        <div class="form-section-card">
            <div class="form-section-head">
                <h3 class="form-section-title">
                    <i class="ti ti-calendar" style="color:var(--color-primary)"></i>
                    1. Thông tin chương trình &amp; Mức giảm chung
                </h3>
                <span class="pill-badge orange">Áp dụng toàn chương trình</span>
            </div>

            <div style="display:grid; grid-template-columns: 2fr 1fr; gap:16px; margin-bottom:16px">
                <div>
                    <label class="form-label">Tên chương trình khuyến mãi *</label>
                    <form:input path="name" maxlength="150" placeholder="VD: Đại Tiệc Mèo Cưng Dịp Lễ 30/4 &amp; 1/5..."
                                cssClass="form-control" style="font-weight:600"/>
                    <form:errors path="name" cssClass="err" style="color:#ef4444; font-size:12px; margin-top:4px"/>
                </div>

                <div>
                    <label class="form-label">Mức giảm giá chung toàn chương trình (%) *</label>
                    <div style="position:relative">
                        <form:input path="discountPercent" id="discountPercentInput" type="number" min="1" max="99"
                                    cssClass="form-control" style="padding-right:36px; font-weight:800; color:#ea580c"
                                    oninput="recalculateDiscountedPrices()"/>
                        <span style="position:absolute; right:14px; top:50%; transform:translateY(-50%); font-weight:800; color:#ea580c">%</span>
                    </div>
                    <form:errors path="discountPercent" cssClass="err" style="color:#ef4444; font-size:12px; margin-top:4px"/>
                </div>
            </div>

            <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:16px; margin-bottom:16px">
                <div>
                    <label class="form-label">Mô tả / Ghi chú chiến dịch</label>
                    <form:input path="description" maxlength="255" placeholder="VD: Giảm giá đặc biệt toàn bộ thức ăn khô dịp lễ..."
                                cssClass="form-control"/>
                    <form:errors path="description" cssClass="err" style="color:#ef4444; font-size:12px; margin-top:4px"/>
                </div>

                <div>
                    <label class="form-label">Thời gian bắt đầu *</label>
                    <form:input path="startTime" type="datetime-local" cssClass="form-control"/>
                    <form:errors path="startTime" cssClass="err" style="color:#ef4444; font-size:12px; margin-top:4px"/>
                </div>

                <div>
                    <label class="form-label">Thời gian kết thúc *</label>
                    <form:input path="endTime" type="datetime-local" cssClass="form-control"/>
                    <form:errors path="endTime" cssClass="err" style="color:#ef4444; font-size:12px; margin-top:4px"/>
                </div>
            </div>

            <div class="note" style="background:#fffaf5; border:1px solid #fed7aa; color:#9a3412; padding:12px 16px; border-radius:10px; display:flex; align-items:center; gap:10px">
                <i class="ti ti-info-circle" style="color:#ea580c; font-size:18px"></i>
                <div style="font-size:13px">
                    Mức giảm giá trên sẽ được áp dụng đồng bộ cho tất cả các lô hàng được chọn bên dưới. Giá bán khuyến mãi = <b>Giá gốc &times; (100 - % giảm)</b>.
                </div>
            </div>
        </div>

        <%-- Card 2: Chọn các lô hàng bình thường (> 90 ngày) --%>
        <div class="form-section-card">
            <div class="form-section-head">
                <h3 class="form-section-title">
                    <i class="ti ti-check-circle" style="color:#10b981"></i>
                    2. Chọn các lô hàng bình thường áp dụng (Hạn dùng &gt; 90 ngày)
                </h3>
                <div style="display:flex; align-items:center; gap:8px">
                    <span id="selectedCountText" class="pill-badge green">Đã chọn: 0 lô hàng</span>
                    <button type="button" class="btn-pill-outline" onclick="toggleSelectAllLots(true)" style="padding:4px 10px; font-size:12px">Chọn tất cả</button>
                    <button type="button" class="btn-pill-outline" onclick="toggleSelectAllLots(false)" style="padding:4px 10px; font-size:12px">Bỏ chọn</button>
                </div>
            </div>

            <div style="margin-bottom:12px; display:flex; align-items:center; justify-content:space-between; gap:12px">
                <div style="flex:1; max-width:400px; position:relative">
                    <i class="ti ti-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-placeholder)"></i>
                    <input type="search" id="lotFilterInput" placeholder="Tìm theo tên sản phẩm, SKU hoặc mã lô..."
                           class="form-control" style="padding-left:34px" oninput="filterNormalLots()">
                </div>
                <small style="color:var(--text-muted)">
                    <i class="ti ti-shield-check" style="color:#10b981"></i> 100% lô hiển thị đều cam kết HSD &gt; 90 ngày (BR-12/54)
                </small>
            </div>

            <div style="max-height: 420px; overflow-y: auto; border: 1px solid var(--line); border-radius: 12px">
                <table class="lot-select-table">
                    <thead>
                    <tr>
                        <th style="width:40px; text-align:center">
                            <input type="checkbox" id="masterCheckbox" class="lot-checkbox" onchange="toggleSelectAllLots(this.checked)">
                        </th>
                        <th>SẢN PHẨM &amp; SKU</th>
                        <th>MÃ LÔ &amp; HẠN DÙNG</th>
                        <th style="text-align:center">TỒN KHO</th>
                        <th style="text-align:center; min-width:140px">SL KHUYẾN MÃI</th>
                        <th>GIÁ GỐC</th>
                        <th>GIÁ SAU GIẢM (DỰ KIẾN)</th>
                    </tr>
                    </thead>
                    <tbody id="lotTableBody">
                    <c:choose>
                        <c:when test="${not empty normalLots}">
                            <c:forEach var="l" items="${normalLots}">
                                <tr class="lot-row"
                                    data-name="<c:out value='${l.productName}'/>"
                                    data-sku="<c:out value='${l.sku}'/>"
                                    data-lot="lot-${l.lotId} #${l.lotId}">
                                    <td style="text-align:center">
                                        <c:set var="isLotSelected" value="false"/>
                                        <c:if test="${not empty flashSaleForm.selectedLotIds}">
                                            <c:forEach var="sId" items="${flashSaleForm.selectedLotIds}">
                                                <c:if test="${sId == l.lotId}">
                                                    <c:set var="isLotSelected" value="true"/>
                                                </c:if>
                                            </c:forEach>
                                        </c:if>
                                        <input type="checkbox" name="selectedLotIds" value="${l.lotId}" class="lot-checkbox item-checkbox"
                                               data-price="${l.sellingPrice}" onchange="handleLotCheckboxChange(this, '${l.lotId}')"
                                               <c:if test="${isLotSelected}">checked</c:if>>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:10px">
                                            <div style="width:36px; height:36px; border-radius:6px; background:#f8fafc; border:1px solid var(--line); display:flex; align-items:center; justify-content:center; overflow:hidden">
                                                <c:choose>
                                                    <c:when test="${not empty l.imageUrl}">
                                                        <img src="${l.imageUrl.startsWith('http') ? l.imageUrl : ctx.concat(l.imageUrl)}" alt="${l.productName}" style="width:100%; height:100%; object-fit:cover" onerror="this.onerror=null; this.parentElement.innerHTML='<i class=\'ti ti-bone\'></i>';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="ti ti-bone" style="color:var(--color-primary)"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <b style="color:#0f172a; font-size:13px"><c:out value="${l.productName}"/></b>
                                                <div style="font-size:11px; color:var(--text-muted); font-family:monospace">SKU: <c:out value="${l.sku}"/></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-family:monospace; font-weight:700; color:#334155">#LOT-${l.lotId}</div>
                                        <span class="pill-badge green" style="font-size:11px; padding:2px 8px">
                                            <i class="ti ti-calendar"></i>${l.expiryDate} (Còn ${l.daysLeft} ngày)
                                        </span>
                                    </td>
                                    <td style="text-align:center">
                                        <span class="pill-badge gray" style="font-weight:700">${l.onHandQty} đơn vị</span>
                                    </td>
                                    <td style="text-align:center">
                                        <c:set var="currentQty" value="${not empty flashSaleForm.lotQuantities[l.lotId] ? flashSaleForm.lotQuantities[l.lotId] : l.onHandQty}"/>
                                        <div style="display:inline-flex; align-items:center; justify-content:center; gap:4px">
                                            <input type="number"
                                                   name="lotQuantities[${l.lotId}]"
                                                   id="qty-input-${l.lotId}"
                                                   min="1"
                                                   max="${l.onHandQty}"
                                                   value="${currentQty}"
                                                   class="form-control lot-qty-input"
                                                   style="width:75px; text-align:center; padding:5px 8px; font-weight:700; ${isLotSelected ? '' : 'display:none;'}"
                                                   oninput="validateLotQty(this, ${l.onHandQty})"
                                                   title="Nhập số lượng suất bán áp dụng cho sản phẩm này">
                                            <span id="qty-placeholder-${l.lotId}" style="color:var(--text-placeholder); font-size:13px; ${isLotSelected ? 'display:none;' : ''}">-</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="color:#64748b; font-weight:600">
                                            <fmt:formatNumber value="${l.sellingPrice}" pattern="#,##0"/>đ
                                        </span>
                                    </td>
                                    <td>
                                        <span class="price-badge-computed" id="computed-price-${l.lotId}">
                                            <fmt:formatNumber value="${l.sellingPrice}" pattern="#,##0"/>đ
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" style="text-align:center; padding:32px; color:var(--text-muted)">
                                    Không có lô hàng bình thường nào đủ điều kiện (&gt;90 ngày) trong kho.
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </form:form>
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

    function recalculateDiscountedPrices() {
        const discountInput = document.getElementById('discountPercentInput');
        let discount = parseInt(discountInput?.value || 0, 10);
        if (isNaN(discount) || discount < 0) discount = 0;
        if (discount > 99) discount = 99;

        const checkboxes = document.querySelectorAll('.item-checkbox');
        checkboxes.forEach(cb => {
            const rawPrice = parseFloat(cb.getAttribute('data-price') || 0);
            const lotId = cb.value;
            const discounted = Math.round(rawPrice * (100 - discount) / 100);
            const span = document.getElementById('computed-price-' + lotId);
            if (span) {
                span.textContent = discounted.toLocaleString('vi-VN') + 'đ';
            }
        });
    }

    function handleLotCheckboxChange(checkbox, lotId) {
        const qtyInput = document.getElementById('qty-input-' + lotId);
        const qtyPlaceholder = document.getElementById('qty-placeholder-' + lotId);
        if (qtyInput && qtyPlaceholder) {
            if (checkbox.checked) {
                qtyInput.style.display = 'inline-block';
                qtyPlaceholder.style.display = 'none';
            } else {
                qtyInput.style.display = 'none';
                qtyPlaceholder.style.display = 'inline-block';
            }
        }
        updateSelectedCount();
    }

    function validateLotQty(input, maxQty) {
        let val = parseInt(input.value, 10);
        if (isNaN(val) || val < 1) {
            val = 1;
        } else if (val > maxQty) {
            val = maxQty;
        }
        input.value = val;
    }

    function toggleSelectAllLots(checked) {
        const checkboxes = document.querySelectorAll('.item-checkbox');
        checkboxes.forEach(cb => {
            const row = cb.closest('tr');
            if (row && row.style.display !== 'none') {
                cb.checked = checked;
                handleLotCheckboxChange(cb, cb.value);
            }
        });
        updateSelectedCount();
    }

    function updateSelectedCount() {
        const checkboxes = document.querySelectorAll('.item-checkbox:checked');
        const countSpan = document.getElementById('selectedCountText');
        if (countSpan) {
            countSpan.textContent = 'Đã chọn: ' + checkboxes.length + ' lô hàng';
        }
    }

    function filterNormalLots() {
        const keyword = removeVietnameseTones((document.getElementById('lotFilterInput')?.value || '').trim());
        const rows = document.querySelectorAll('.lot-row');

        rows.forEach(row => {
            const name = removeVietnameseTones(row.getAttribute('data-name') || '');
            const sku = (row.getAttribute('data-sku') || '').toLowerCase();
            const lot = (row.getAttribute('data-lot') || '').toLowerCase();

            const match = !keyword || name.includes(keyword) || sku.includes(keyword) || lot.includes(keyword);
            row.style.display = match ? '' : 'none';
        });
    }

    // Khởi tạo tính giá lúc tải trang
    document.addEventListener('DOMContentLoaded', () => {
        recalculateDiscountedPrices();
        updateSelectedCount();
    });
</script>
</body>
</html>
