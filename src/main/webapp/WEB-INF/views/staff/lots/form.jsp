<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: lotForm (productId, expiryDate, receivedQty), lotId (null = nhập lô mới),
            products (List<ProductOption>, chỉ khi nhập mới), lot (LotRow, chỉ khi sửa),
            shelfLifeDays, quarantineDays --%>
<c:choose>
    <c:when test="${empty lotId}">
        <c:set var="pageHeading" value="Nhập lô hàng mới"/>
        <c:url var="formAction" value="/staff/lots/new"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Sửa lô hàng #${lotId}"/>
        <c:url var="formAction" value="/staff/lots/${lotId}/edit"/>
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${pageHeading}"/> · PetFood Cổng Quản Trị</title>
    <meta name="description" content="Quản lý và tiếp nhận lô hàng nhập kho theo phương thức FEFO cho PetFood Shop.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .form-focus-wrap:focus-within {
            border-color: #ea580c !important;
            box-shadow: 0 0 0 3px rgba(234, 88, 12, 0.15) !important;
        }
        .btn-quick-val {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 3px 8px;
            font-size: 11px;
            font-weight: 700;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .btn-quick-val:hover {
            border-color: #ea580c;
            color: #ea580c;
            background: #fff7ed;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div style="max-width: 1200px; margin: 0 auto; padding-bottom: 40px;">
        <%-- Breadcrumbs --%>
        <div class="screen-bc" style="margin-bottom: 10px;">
            <span>QUẢN LÝ KHO &amp; ĐỔI TRẢ</span> 
            <span class="sep">&gt;</span> 
            <a href="${ctx}/staff/lots" style="color:var(--text-muted); text-decoration:none;">TỒN KHO</a> 
            <span class="sep">&gt;</span> 
            <span class="current"><c:out value="${pageHeading}"/></span>
        </div>

        <%-- Header Bar --%>
        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:22px; flex-wrap:wrap; gap:16px;">
            <div>
                <h1 style="font-size:24px; font-weight:900; color:#1e293b; margin:0 0 6px 0; display:flex; align-items:center; gap:12px;">
                    <span style="width:40px; height:40px; border-radius:12px; background:linear-gradient(135deg, #ffedd5, #fed7aa); color:#ea580c; display:flex; align-items:center; justify-content:center; font-size:22px; box-shadow:0 2px 8px rgba(234,88,12,0.18);">
                        <i class="ti ti-package-import"></i>
                    </span>
                    <c:out value="${pageHeading}"/>
                </h1>
                <p style="font-size:13.5px; color:#64748b; margin:0;">
                    Tiếp nhận lô hàng mới vào kho theo phương pháp FEFO (First-Expired, First-Out). Tự động phân loại luồng bán hàng &amp; hạn dùng.
                </p>
            </div>
            <div style="display:flex; align-items:center; gap:10px;">
                <a href="${ctx}/staff/lots" class="btn-pill-outline" style="background:#fff; border:1px solid #cbd5e1; border-radius:99px; padding:9px 18px; font-size:13px; font-weight:700; color:#334155; text-decoration:none; display:inline-flex; align-items:center; gap:6px; cursor:pointer;">
                    <i class="ti ti-arrow-left" style="font-size:16px;"></i> Quay lại danh sách tồn kho
                </a>
                <a href="${ctx}/staff/alerts" class="btn-pill-outline" style="background:#fff; border:1px solid #cbd5e1; border-radius:99px; padding:9px 18px; font-size:13px; font-weight:700; color:#334155; text-decoration:none; display:inline-flex; align-items:center; gap:6px; cursor:pointer;">
                    <i class="ti ti-alert-triangle" style="font-size:16px; color:#ea580c;"></i> Cảnh báo HSD
                </a>
            </div>
        </div>

        <%-- Banner Thông báo chính sách FEFO --%>
        <div style="background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%); border: 1px solid #fed7aa; border-radius: 16px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
            <div style="display:flex; align-items:center; gap:14px;">
                <div style="width:42px; height:42px; border-radius:12px; background:#ea580c; color:#fff; display:grid; place-items:center; font-size:22px; flex-shrink:0; box-shadow: 0 2px 6px rgba(234,88,12,0.3);">
                    <i class="ti ti-shield-check"></i>
                </div>
                <div>
                    <h4 style="margin:0 0 3px 0; font-size:14.5px; font-weight:800; color:#9a3412;">Chính sách phân luồng hàng hóa theo hạn sử dụng (FEFO - BR-51)</h4>
                    <p style="margin:0; font-size:12.5px; color:#7c2d12; line-height:1.4;">
                        Lô hàng khi nhập kho sẽ được hệ thống kiểm soát tự động: Còn hạn <b>&gt; ${shelfLifeDays} ngày</b> được bán lẻ bình thường; <b>${quarantineDays} - ${shelfLifeDays} ngày</b> chuyển sang bán Flash Sale; <b>&lt; ${quarantineDays} ngày</b> lập tức cách ly cấm bán.
                    </p>
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <span style="background:#fff; border:1px solid #fed7aa; padding:6px 14px; border-radius:10px; font-size:12px; font-weight:700; color:#c2410c;">
                    Cam kết HSD xuất kho: <b>${shelfLifeDays} ngày</b>
                </span>
                <span style="background:#fff; border:1px solid #fecaca; padding:6px 14px; border-radius:10px; font-size:12px; font-weight:700; color:#dc2626;">
                    Ngưỡng cách ly: <b>${quarantineDays} ngày</b>
                </span>
            </div>
        </div>

        <%-- Master Form Layout (2 Columns: Form Trái, Hướng dẫn & Tiêu chuẩn Phải) --%>
        <div style="display:grid; grid-template-columns: minmax(0, 1.8fr) minmax(0, 1.2fr); gap:24px; align-items:start;">
            <%-- Cột Trái: Phiếu nhập lô --%>
            <div style="background:#fff; border-radius:18px; border:1px solid var(--line); padding:26px 28px; box-shadow:0 1px 4px rgba(0,0,0,0.02);">
                <div style="display:flex; align-items:center; justify-content:space-between; padding-bottom:16px; margin-bottom:22px; border-bottom:1px solid #f1f5f9;">
                    <div style="display:flex; align-items:center; gap:10px;">
                        <div style="width:36px; height:36px; border-radius:10px; background:#fff7ed; color:#ea580c; display:grid; place-items:center; font-size:18px;">
                            <i class="ti ti-file-text"></i>
                        </div>
                        <div>
                            <h3 style="margin:0; font-size:16px; font-weight:800; color:#1e293b;">Phiếu thông tin nhập lô hàng</h3>
                            <p style="margin:2px 0 0 0; font-size:12px; color:#64748b;">Điền đầy đủ thông tin bên dưới để khởi tạo hoặc cập nhật lô hàng</p>
                        </div>
                    </div>
                    <span style="background:#f8fafc; border:1px solid #e2e8f0; color:#475569; padding:5px 12px; border-radius:8px; font-size:12px; font-weight:700; display:inline-flex; align-items:center; gap:5px;">
                        <c:choose>
                            <c:when test="${empty lotId}"><span style="width:7px; height:7px; border-radius:50%; background:#16a34a;"></span> Nhập lô mới</c:when>
                            <c:otherwise><span style="width:7px; height:7px; border-radius:50%; background:#ea580c;"></span> Hiệu chỉnh lô #${lotId}</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <form:form method="post" action="${formAction}" modelAttribute="lotForm" id="lotMainForm">
                    <%-- Field 1: Sản phẩm --%>
                    <div style="margin-bottom:20px;">
                        <label for="lotProductId" style="display:block; font-size:12.5px; font-weight:800; color:#475569; margin-bottom:7px; text-transform:uppercase; letter-spacing:0.3px;">
                            Sản phẩm tiếp nhận <span style="color:#ef4444;">*</span>
                        </label>

                        <c:choose>
                            <c:when test="${empty lotId}">
                                <div style="display:flex; align-items:center; border:1.5px solid #cbd5e1; border-radius:12px; padding:2px 14px; background:#fff;" class="form-focus-wrap">
                                    <i class="ti ti-barcode" style="font-size:18px; color:#ea580c; margin-right:10px; flex-shrink:0;"></i>
                                    <form:select path="productId" id="lotProductId" style="width:100%; border:none; outline:none; font-size:14px; font-weight:600; color:#1e293b; padding:11px 0; background:transparent; cursor:pointer;" onchange="onProductSelectChange(this)">
                                        <form:option value="" label="-- Bấm vào đây để chọn sản phẩm cần nhập lô --"/>
                                        <c:forEach var="p" items="${products}">
                                            <form:option value="${p.id}" disabled="${p.status != 'ACTIVE'}" data-sku="${p.sku}" data-name="${p.name}" data-status="${p.status}">
                                                [${p.sku}] - ${p.name} <c:if test="${p.status != 'ACTIVE'}">(Ngừng kinh doanh)</c:if>
                                            </form:option>
                                        </c:forEach>
                                    </form:select>
                                </div>
                                <form:errors path="productId" cssStyle="color:#ef4444; font-size:12.5px; font-weight:700; margin-top:5px; display:block;"/>

                                <%-- Thẻ hiển thị thông tin sản phẩm đã chọn --%>
                                <div id="productSelectedCard" style="display:none; background:#f8fafc; border:1px solid #e2e8f0; border-radius:12px; padding:12px 16px; margin-top:10px;">
                                    <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px;">
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <span id="previewSkuBadge" style="background:#ea580c; color:#fff; font-size:11.5px; font-weight:800; padding:3px 8px; border-radius:6px; letter-spacing:0.3px;">SKU</span>
                                            <span id="previewProductName" style="font-size:13.5px; font-weight:700; color:#1e293b;">Tên sản phẩm</span>
                                        </div>
                                        <span id="previewStatusBadge" style="background:#dcfce7; color:#166534; font-size:11.5px; font-weight:700; padding:3px 8px; border-radius:99px; display:inline-flex; align-items:center; gap:4px;">
                                            <i class="ti ti-check"></i> Đang kinh doanh
                                        </span>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form:hidden path="productId"/>
                                <div style="background:#f8fafc; border:1.5px solid #cbd5e1; border-radius:12px; padding:14px 18px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:10px;">
                                    <div style="display:flex; align-items:center; gap:12px;">
                                        <div style="width:38px; height:38px; border-radius:10px; background:#fed7aa; color:#c2410c; display:grid; place-items:center; font-size:20px; flex-shrink:0;">
                                            <i class="ti ti-lock"></i>
                                        </div>
                                        <div>
                                            <div style="font-size:14px; font-weight:800; color:#1e293b;">
                                                [<c:out value="${lot.sku}"/>] - <c:out value="${lot.productName}"/>
                                            </div>
                                            <div style="font-size:12px; color:#64748b; margin-top:2px;">
                                                Tiếp nhận ngày <b>${lot.receivedAtText}</b> &bull; Tồn khả dụng hiện tại: <b>${lot.onHandQty}</b> / ${lot.receivedQty} đơn vị
                                            </div>
                                        </div>
                                    </div>
                                    <a href="${ctx}/staff/products/${lot.productId}" target="_blank" style="font-size:12.5px; font-weight:700; color:#ea580c; text-decoration:none; display:inline-flex; align-items:center; gap:4px;">
                                        Xem sản phẩm <i class="ti ti-external-link"></i>
                                    </a>
                                </div>
                                <div style="font-size:12px; color:#94a3b8; font-weight:600; margin-top:6px; font-style:italic;">
                                    * Lưu ý: Nếu nhập nhầm sản phẩm, vui lòng xóa lô hàng này và khởi tạo lại phiếu nhập mới.
                                </div>
                                <form:errors path="productId" cssStyle="color:#ef4444; font-size:12.5px; font-weight:700; margin-top:5px; display:block;"/>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%-- Field 2: Số lượng nhập kho --%>
                    <div style="margin-bottom:20px;">
                        <label for="lotReceivedQty" style="display:block; font-size:12.5px; font-weight:800; color:#475569; margin-bottom:7px; text-transform:uppercase; letter-spacing:0.3px;">
                            Số lượng nhập kho <span style="color:#ef4444;">*</span>
                        </label>
                        <div style="display:flex; align-items:center; border:1.5px solid #cbd5e1; border-radius:12px; padding:2px 14px; background:#fff;" class="form-focus-wrap">
                            <i class="ti ti-packages" style="font-size:18px; color:#ea580c; margin-right:10px; flex-shrink:0;"></i>
                            <form:input path="receivedQty" id="lotReceivedQty" type="number" min="1" step="1" required="required" placeholder="Nhập số lượng thực nhận..." style="width:100%; border:none; outline:none; font-size:15px; font-weight:700; color:#1e293b; padding:11px 0; background:transparent;"/>
                            <span style="font-size:12.5px; font-weight:700; color:#64748b; background:#f1f5f9; padding:4px 10px; border-radius:8px; white-space:nowrap;">Đơn vị / Gói</span>
                        </div>
                        <form:errors path="receivedQty" cssStyle="color:#ef4444; font-size:12.5px; font-weight:700; margin-top:5px; display:block;"/>

                        <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-top:8px;">
                            <span style="font-size:12px; color:#64748b; font-weight:600; display:inline-flex; align-items:center; gap:4px;">
                                <i class="ti ti-info-circle" style="color:#ea580c;"></i> Số lượng còn trong kho (Tồn khả dụng) của lô sẽ tự động bằng số lượng nhập.
                            </span>
                            <div style="display:flex; align-items:center; gap:6px;">
                                <span style="font-size:11px; font-weight:700; color:#94a3b8; text-transform:uppercase;">Cộng nhanh:</span>
                                <button type="button" class="btn-quick-val" onclick="addQuickQty(50)">+50</button>
                                <button type="button" class="btn-quick-val" onclick="addQuickQty(100)">+100</button>
                                <button type="button" class="btn-quick-val" onclick="addQuickQty(200)">+200</button>
                                <button type="button" class="btn-quick-val" onclick="addQuickQty(500)">+500</button>
                            </div>
                        </div>
                    </div>

                    <%-- Field 3: Hạn sử dụng (Expiry Date) --%>
                    <div style="margin-bottom:20px;">
                        <label for="lotExpiryDate" style="display:block; font-size:12.5px; font-weight:800; color:#475569; margin-bottom:7px; text-transform:uppercase; letter-spacing:0.3px;">
                            Hạn sử dụng (In trên bao bì) <span style="color:#ef4444;">*</span>
                        </label>
                        <div style="display:flex; align-items:center; border:1.5px solid #cbd5e1; border-radius:12px; padding:2px 14px; background:#fff;" class="form-focus-wrap">
                            <i class="ti ti-calendar" style="font-size:18px; color:#ea580c; margin-right:10px; flex-shrink:0;"></i>
                            <form:input path="expiryDate" id="lotExpiryDate" type="date" required="required" style="width:100%; border:none; outline:none; font-size:15px; font-weight:700; color:#1e293b; padding:11px 0; background:transparent; cursor:pointer;" onchange="updateFefoLiveCalculator()"/>
                        </div>
                        <form:errors path="expiryDate" cssStyle="color:#ef4444; font-size:12.5px; font-weight:700; margin-top:5px; display:block;"/>

                        <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-top:8px;">
                            <span style="font-size:12px; color:#64748b; font-weight:600;">
                                Hạn sử dụng bắt buộc phải sau ngày tiếp nhận vào kho.
                            </span>
                            <div style="display:flex; align-items:center; gap:6px;">
                                <span style="font-size:11px; font-weight:700; color:#94a3b8; text-transform:uppercase;">Gợi ý nhanh HSD:</span>
                                <button type="button" class="btn-quick-val" onclick="setQuickExpiryMonths(6)">+6 Tháng</button>
                                <button type="button" class="btn-quick-val" onclick="setQuickExpiryMonths(12)">+1 Năm (12T)</button>
                                <button type="button" class="btn-quick-val" onclick="setQuickExpiryMonths(18)">+18 Tháng</button>
                                <button type="button" class="btn-quick-val" onclick="setQuickExpiryMonths(24)">+2 Năm (24T)</button>
                            </div>
                        </div>
                    </div>

                    <%-- Dynamic Live FEFO Calculator Card --%>
                    <div id="fefoLiveCard" style="display:none; border-radius:14px; padding:16px 18px; margin-bottom:26px; align-items:flex-start; gap:14px;">
                        <div id="fefoLiveIconWrap" style="width:38px; height:38px; border-radius:10px; display:grid; place-items:center; font-size:20px; flex-shrink:0;">
                            <i id="fefoLiveIcon" class="ti ti-clock"></i>
                        </div>
                        <div style="flex:1;">
                            <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-bottom:4px;">
                                <h4 id="fefoLiveTitle" style="margin:0; font-size:14px; font-weight:800;">Đánh giá thời hạn sử dụng FEFO</h4>
                                <span id="fefoLiveBadge" style="font-size:11.5px; font-weight:800; padding:3px 10px; border-radius:99px;">Đang tính...</span>
                            </div>
                            <p id="fefoLiveDesc" style="margin:0; font-size:12.5px; line-height:1.4;">Vui lòng chọn ngày hết hạn để hệ thống tính toán số ngày còn lại.</p>
                        </div>
                    </div>

                    <%-- Form Action Buttons --%>
                    <div style="display:flex; align-items:center; gap:12px; padding-top:20px; border-top:1px dashed #e2e8f0;">
                        <button type="submit" class="btn-flashsale" style="padding:12px 30px; font-size:14px; font-weight:800; cursor:pointer;">
                            <i class="ti ti-check" style="font-size:18px;"></i>
                            <c:choose>
                                <c:when test="${empty lotId}">Xác nhận nhập kho lô hàng</c:when>
                                <c:otherwise>Lưu thay đổi lô #${lotId}</c:otherwise>
                            </c:choose>
                        </button>
                        <a href="${ctx}/staff/lots" class="btn-pill-outline" style="background:#fff; border:1px solid #cbd5e1; border-radius:99px; padding:11px 22px; font-size:13.5px; font-weight:700; color:#475569; text-decoration:none; cursor:pointer; display:inline-flex; align-items:center; gap:6px;">
                            <i class="ti ti-x" style="font-size:16px;"></i> Hủy bỏ
                        </a>
                    </div>
                </form:form>
            </div>

            <%-- Cột Phải: Bảng phân cấp hạn sử dụng & Quy trình nghiệp vụ --%>
            <div style="display:flex; flex-direction:column; gap:20px;">
                <%-- Card 1: Bảng phân cấp hạn sử dụng FEFO --%>
                <div style="background:#fff; border-radius:18px; border:1px solid var(--line); padding:22px; box-shadow:0 1px 3px rgba(0,0,0,0.02);">
                    <div style="display:flex; align-items:center; gap:10px; margin-bottom:16px; padding-bottom:12px; border-bottom:1px solid #f1f5f9;">
                        <div style="width:34px; height:34px; border-radius:10px; background:#dcfce7; color:#166534; display:grid; place-items:center; font-size:18px;">
                            <i class="ti ti-clock-check"></i>
                        </div>
                        <div>
                            <h4 style="margin:0; font-size:14.5px; font-weight:800; color:#1e293b;">Bảng phân cấp hạn sử dụng</h4>
                            <p style="margin:2px 0 0 0; font-size:11.5px; color:#64748b;">Quy định xuất kho tự động (FEFO)</p>
                        </div>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <%-- Cấp 1: Hạn an toàn --%>
                        <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:12px; padding:12px 14px;">
                            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px;">
                                <span style="font-size:12.5px; font-weight:800; color:#166534; display:inline-flex; align-items:center; gap:5px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#16a34a;"></span> Hạn dùng an toàn (Chuẩn xuất)
                                </span>
                                <span style="font-size:12px; font-weight:800; color:#166534;">&gt; ${shelfLifeDays} ngày</span>
                            </div>
                            <p style="margin:0; font-size:11.5px; color:#15803d; line-height:1.4;">
                                Đạt tiêu chuẩn xuất kho bán lẻ thông thường, hiển thị đầy đủ trên Web/App cho khách hàng mua sắm.
                            </p>
                        </div>

                        <%-- Cấp 2: Flash Sale --%>
                        <div style="background:#fff7ed; border:1px solid #fed7aa; border-radius:12px; padding:12px 14px;">
                            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px;">
                                <span style="font-size:12.5px; font-weight:800; color:#c2410c; display:inline-flex; align-items:center; gap:5px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#ea580c;"></span> Cận hạn dùng (Flash Sale)
                                </span>
                                <span style="font-size:12px; font-weight:800; color:#c2410c;">${quarantineDays} - ${shelfLifeDays} ngày</span>
                            </div>
                            <p style="margin:0; font-size:11.5px; color:#9a3412; line-height:1.4;">
                                Không xuất bán đơn lẻ giá gốc. Ưu tiên đưa vào các đợt Flash Sale giảm giá sâu nhằm thu hồi vốn nhanh (BR-51).
                            </p>
                        </div>

                        <%-- Cấp 3: Cách ly --%>
                        <div style="background:#fef2f2; border:1px solid #fecaca; border-radius:12px; padding:12px 14px;">
                            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:4px;">
                                <span style="font-size:12.5px; font-weight:800; color:#b91c1c; display:inline-flex; align-items:center; gap:5px;">
                                    <span style="width:8px; height:8px; border-radius:50%; background:#ef4444;"></span> Cách ly &amp; Cấm xuất bán
                                </span>
                                <span style="font-size:12px; font-weight:800; color:#b91c1c;">&lt; ${quarantineDays} ngày</span>
                            </div>
                            <p style="margin:0; font-size:11.5px; color:#991b1b; line-height:1.4;">
                                Hàng quá cận hạn hoặc hết hạn. Hệ thống tự động khóa tồn, cách ly kho, trả về nhà cung cấp hoặc tiêu hủy.
                            </p>
                        </div>
                    </div>
                </div>

                <%-- Card 2: Quy trình tiếp nhận hàng kho --%>
                <div style="background:#fff; border-radius:18px; border:1px solid var(--line); padding:22px; box-shadow:0 1px 3px rgba(0,0,0,0.02);">
                    <div style="display:flex; align-items:center; gap:10px; margin-bottom:16px; padding-bottom:12px; border-bottom:1px solid #f1f5f9;">
                        <div style="width:34px; height:34px; border-radius:10px; background:#eff6ff; color:#1d4ed8; display:grid; place-items:center; font-size:18px;">
                            <i class="ti ti-list-check"></i>
                        </div>
                        <div>
                            <h4 style="margin:0; font-size:14.5px; font-weight:800; color:#1e293b;">Quy trình tiếp nhận hàng kho</h4>
                            <p style="margin:2px 0 0 0; font-size:11.5px; color:#64748b;">Quy chuẩn kiểm đếm chuẩn SOP</p>
                        </div>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:11px; font-size:12.5px; color:#334155;">
                        <div style="display:flex; align-items:flex-start; gap:8px;">
                            <i class="ti ti-circle-check" style="color:#16a34a; font-size:16px; margin-top:2px; flex-shrink:0;"></i>
                            <span><b>1. Ngoại quan bao bì:</b> Nguyên vẹn niêm phong, không móp méo, rách vỡ hoặc ẩm ướt.</span>
                        </div>
                        <div style="display:flex; align-items:flex-start; gap:8px;">
                            <i class="ti ti-circle-check" style="color:#16a34a; font-size:16px; margin-top:2px; flex-shrink:0;"></i>
                            <span><b>2. Đối chiếu số lô &amp; HSD:</b> Kiểm tra date in laser/dập nổi trên từng thùng hàng khớp với date nhập.</span>
                        </div>
                        <div style="display:flex; align-items:flex-start; gap:8px;">
                            <i class="ti ti-circle-check" style="color:#16a34a; font-size:16px; margin-top:2px; flex-shrink:0;"></i>
                            <span><b>3. Kiểm đếm thực tế:</b> Đếm số lượng kiện hàng thực tế trước khi bấm xác nhận nhập kho.</span>
                        </div>
                        <div style="display:flex; align-items:flex-start; gap:8px;">
                            <i class="ti ti-circle-check" style="color:#16a34a; font-size:16px; margin-top:2px; flex-shrink:0;"></i>
                            <span><b>4. Xếp dỡ kệ kho:</b> Sắp xếp lô mới theo nguyên tắc FEFO (date gần xếp ngoài, date xa xếp trong).</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    const SHELF_LIFE_DAYS = parseInt('${shelfLifeDays}') || 90;
    const QUARANTINE_DAYS = parseInt('${quarantineDays}') || 21;

    function onProductSelectChange(selectEl) {
        const selectedOpt = selectEl.options[selectEl.selectedIndex];
        const previewCard = document.getElementById('productSelectedCard');
        if (!previewCard) return;

        if (selectedOpt && selectedOpt.value) {
            const sku = selectedOpt.getAttribute('data-sku') || '';
            const name = selectedOpt.getAttribute('data-name') || selectedOpt.text;
            const status = selectedOpt.getAttribute('data-status') || 'ACTIVE';

            document.getElementById('previewSkuBadge').innerText = sku;
            document.getElementById('previewProductName').innerText = name.replace('[' + sku + '] - ', '');
            
            const statusBadge = document.getElementById('previewStatusBadge');
            if (status === 'ACTIVE') {
                statusBadge.style.background = '#dcfce7';
                statusBadge.style.color = '#166534';
                statusBadge.innerHTML = '<i class="ti ti-check"></i> Đang kinh doanh';
            } else {
                statusBadge.style.background = '#fee2e2';
                statusBadge.style.color = '#991b1b';
                statusBadge.innerHTML = '<i class="ti ti-ban"></i> Ngừng kinh doanh';
            }
            previewCard.style.display = 'block';
        } else {
            previewCard.style.display = 'none';
        }
    }

    function addQuickQty(delta) {
        const qtyInput = document.getElementById('lotReceivedQty');
        if (!qtyInput) return;
        const currentVal = parseInt(qtyInput.value) || 0;
        qtyInput.value = currentVal + delta;
        qtyInput.focus();
    }

    function setQuickExpiryMonths(months) {
        const d = new Date();
        d.setMonth(d.getMonth() + months);
        const yyyy = d.getFullYear();
        const mm = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        const expiryInput = document.getElementById('lotExpiryDate');
        if (expiryInput) {
            expiryInput.value = yyyy + '-' + mm + '-' + dd;
            updateFefoLiveCalculator();
        }
    }

    function updateFefoLiveCalculator() {
        const expiryInput = document.getElementById('lotExpiryDate');
        const liveCard = document.getElementById('fefoLiveCard');
        if (!expiryInput || !liveCard) return;

        const val = expiryInput.value;
        if (!val) {
            liveCard.style.display = 'none';
            return;
        }

        const expDate = new Date(val + 'T00:00:00');
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const diffTime = expDate.getTime() - today.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        const iconWrap = document.getElementById('fefoLiveIconWrap');
        const icon = document.getElementById('fefoLiveIcon');
        const title = document.getElementById('fefoLiveTitle');
        const badge = document.getElementById('fefoLiveBadge');
        const desc = document.getElementById('fefoLiveDesc');

        liveCard.style.display = 'flex';

        if (diffDays <= 0) {
            // Đã quá hạn
            liveCard.style.background = '#fef2f2';
            liveCard.style.border = '1px solid #fecaca';
            iconWrap.style.background = '#fee2e2';
            iconWrap.style.color = '#dc2626';
            icon.className = 'ti ti-alert-octagon';
            title.style.color = '#991b1b';
            title.innerText = 'Hạn dùng không hợp lệ (Đã quá hạn ' + Math.abs(diffDays) + ' ngày)';
            badge.style.background = '#b91c1c';
            badge.style.color = '#fff';
            badge.innerText = 'ĐÃ HẾT HẠN';
            desc.style.color = '#b91c1c';
            desc.innerText = 'Hàng hóa đã hết hạn sử dụng. Không được phép tiếp nhận vào kho hàng theo quy chế chất lượng.';
        } else if (diffDays < QUARANTINE_DAYS) {
            // Dưới ngưỡng cách ly (< 21 ngày)
            liveCard.style.background = '#fef2f2';
            liveCard.style.border = '1px solid #fecaca';
            iconWrap.style.background = '#fee2e2';
            iconWrap.style.color = '#dc2626';
            icon.className = 'ti ti-ban';
            title.style.color = '#991b1b';
            title.innerText = 'Quá cận hạn (Còn ' + diffDays + ' ngày - Dưới ' + QUARANTINE_DAYS + ' ngày)';
            badge.style.background = '#b91c1c';
            badge.style.color = '#fff';
            badge.innerText = 'CÁCH LY / CẤM BÁN';
            desc.style.color = '#b91c1c';
            desc.innerText = 'Lô hàng có hạn dùng dưới ngưỡng an toàn (' + QUARANTINE_DAYS + ' ngày). Không đủ điều kiện lưu thông bán lẻ, nếu nhập sẽ bị đưa thẳng vào khu cách ly.';
        } else if (diffDays <= SHELF_LIFE_DAYS) {
            // Cảnh báo cận hạn: Flash Sale (21 - 90 ngày)
            liveCard.style.background = '#fff7ed';
            liveCard.style.border = '1px solid #fed7aa';
            iconWrap.style.background = '#ffedd5';
            iconWrap.style.color = '#ea580c';
            icon.className = 'ti ti-bolt';
            title.style.color = '#9a3412';
            title.innerText = 'Cảnh báo cận hạn (Còn ' + diffDays + ' ngày)';
            badge.style.background = '#ea580c';
            badge.style.color = '#fff';
            badge.innerText = 'CHỈ BÁN QUA FLASH SALE';
            desc.style.color = '#c2410c';
            desc.innerText = 'Lô hàng còn hạn dưới cam kết xuất kho (' + SHELF_LIFE_DAYS + ' ngày). Theo quy tắc BR-51, lô này không bán giá thông thường mà chỉ được bán qua các chiến dịch Flash Sale giảm giá.';
        } else {
            // An toàn (> 90 ngày)
            liveCard.style.background = '#f0fdf4';
            liveCard.style.border = '1px solid #bbf7d0';
            iconWrap.style.background = '#dcfce7';
            iconWrap.style.color = '#16a34a';
            icon.className = 'ti ti-circle-check';
            title.style.color = '#166534';
            title.innerText = 'Hạn dùng đạt chuẩn xuất kho (Còn ' + diffDays + ' ngày)';
            badge.style.background = '#16a34a';
            badge.style.color = '#fff';
            badge.innerText = 'XUẤT KHO THÔNG THƯỜNG';
            desc.style.color = '#15803d';
            desc.innerText = 'Lô hàng có hạn sử dụng an toàn dài hạn (trên ' + SHELF_LIFE_DAYS + ' ngày). Đạt đầy đủ tiêu chuẩn xuất kho bán lẻ bình thường theo thứ tự FEFO.';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const productSelect = document.getElementById('lotProductId');
        if (productSelect && productSelect.value) {
            onProductSelectChange(productSelect);
        }
        const expiryInput = document.getElementById('lotExpiryDate');
        if (expiryInput && expiryInput.value) {
            updateFefoLiveCalculator();
        }
    });
</script>
</body>
</html>
