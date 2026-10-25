<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: productForm (ProductForm), productId (null = thêm mới), product (ProductDetailDto, chỉ khi sửa),
            categories (List<CategoryRow>), speciesList, ageGroups, productStatuses

     Form có file nên phải enctype="multipart/form-data".
     Token CSRF gắn thêm vào URL action (?_csrf=...): nếu ảnh vượt giới hạn 5MB, Spring không đọc được phần thân
     request, token trong ô ẩn bị mất và bị chặn 403; token trên URL thì vẫn đọc được nên hiện đúng thông báo "ảnh quá lớn". --%>
<c:choose>
    <c:when test="${not empty parentProduct}">
        <c:set var="pageHeading" value="Thêm biến thể mới"/>
        <c:url var="formAction" value="/staff/products/new">
            <c:param name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:url>
    </c:when>
    <c:when test="${empty productId}">
        <c:set var="pageHeading" value="Thêm sản phẩm mới"/>
        <c:url var="formAction" value="/staff/products/new">
            <c:param name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:url>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Sửa sản phẩm ${product.sku}"/>
        <c:url var="formAction" value="/staff/products/${productId}/edit">
            <c:param name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:url>
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${pageHeading}"/> · PetFood</title>
    <meta name="description" content="Quản lý và cập nhật thông tin sản phẩm, hình ảnh và thiết lập giá bán.">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .form-layout {
            display: grid;
            grid-template-columns: minmax(0, 1.8fr) minmax(0, 1.2fr);
            gap: 24px;
            align-items: start;
            margin-bottom: 30px;
        }
        @media (max-width: 1080px) {
            .form-layout {
                grid-template-columns: 1fr;
            }
        }
        .form-card {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 24px;
            box-shadow: var(--shadow-card);
            margin-bottom: 24px;
        }
        .form-card-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--line);
        }
        .form-card-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
            font-weight: 800;
            color: var(--text-logo);
        }
        .form-card-title .ti {
            font-size: 20px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group:last-child {
            margin-bottom: 0;
        }
        .form-label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--text-logo);
            margin-bottom: 6px;
        }
        .form-label .req {
            color: #ef4444;
            margin-left: 2px;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border-radius: 12px;
            border: 1px solid var(--line);
            font-size: 14px;
            font-family: inherit;
            background: #fff;
            color: var(--text-main);
            box-sizing: border-box;
            transition: border-color var(--transition), box-shadow var(--transition);
        }
        .form-control:focus {
            outline: none;
            border-color: var(--color-primary);
            box-shadow: 0 0 0 3px rgba(244, 119, 33, 0.15);
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        @media (max-width: 640px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }
        .form-input-prefix {
            position: relative;
            display: flex;
            align-items: center;
        }
        .form-input-prefix input {
            padding-left: 36px;
        }
        .form-input-prefix .prefix-icon {
            position: absolute;
            left: 12px;
            font-size: 16px;
            color: var(--text-placeholder);
            pointer-events: none;
        }
        .pill-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            border-radius: 99px;
            font-size: 11px;
            font-weight: 800;
        }
        .pill-badge.green { background: #e6f9ed; color: #166534; }
        .pill-badge.orange { background: #ffedd5; color: #c2410c; }
        .pill-badge.gray { background: #f1f5f9; color: #475569; }

        /* Bộ 5 ảnh */
        .slots-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 12px;
            margin-top: 14px;
        }
        @media (max-width: 860px) {
            .slots-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        @media (max-width: 560px) {
            .slots-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        .slot-box {
            border: 1px dashed #fed7aa;
            background: #fffcf9;
            border-radius: 14px;
            padding: 10px;
            text-align: center;
            transition: all var(--transition);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .slot-box:hover {
            border-color: var(--color-primary);
            background: var(--orange-50);
            box-shadow: 0 4px 12px rgba(244, 119, 33, 0.08);
        }
        .slot-preview-wrap {
            width: 100%;
            aspect-ratio: 1;
            border-radius: 10px;
            background: #fff;
            border: 1px solid var(--line);
            margin: 8px 0;
            display: grid;
            place-items: center;
            overflow: hidden;
            position: relative;
            cursor: pointer;
        }
        .slot-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            background: #fff;
        }
        .slot-placeholder {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 10px;
            color: var(--text-muted);
        }
        .slot-upload-trigger {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            width: 100%;
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 11.5px;
            font-weight: 700;
            background: #fff;
            color: var(--text-main);
            border: 1px solid var(--line);
            cursor: pointer;
            transition: all var(--transition);
        }
        .slot-upload-trigger:hover {
            border-color: var(--color-primary);
            color: var(--color-primary);
            background: #fff;
        }

        /* Bottom Action Bar */
        .sticky-action-bar {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 16px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-card);
            gap: 16px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <a href="${ctx}/staff/products" style="text-decoration:none; color:inherit;">
                    ‹ QUẢN LÝ SẢN PHẨM &amp; BIẾN THỂ
                </a>
                <span class="sep" style="margin: 0 6px;">&gt;</span>
                <span class="current" style="color:var(--color-primary)">${not empty parentProduct ? 'THÊM BIẾN THỂ' : (empty productId ? 'THÊM MỚI' : 'CHỈNH SỬA')}</span>
            </div>
            <h1 style="display:flex; align-items:center; gap:12px; margin-top:4px;">
                <c:out value="${pageHeading}"/>
                <c:if test="${not empty productId}">
                    <span class="pill-badge orange" style="font-size:12px;">ID #${productId}</span>
                </c:if>
                <c:if test="${not empty parentProduct}">
                    <span class="pill-badge orange" style="font-size:12px;"><i class="ti ti-layers-subtract"></i> Biến thể quy cách</span>
                </c:if>
            </h1>
            <p class="page-sub">
                <c:choose>
                    <c:when test="${not empty parentProduct}">
                        Khai báo quy cách mới, điều chỉnh mã SKU và thiết lập định giá bán cho dòng sản phẩm đang chọn.
                    </c:when>
                    <c:when test="${empty productId}">
                        Khai báo thông tin sản phẩm mới, thiết lập định giá bán, phân loại và tải lên bộ 5 ảnh sản phẩm.
                    </c:when>
                    <c:otherwise>
                        Cập nhật thông tin chi tiết, trạng thái kinh doanh và điều chỉnh hình ảnh đại diện sản phẩm.
                    </c:otherwise>
                </c:choose>
            </p>
        </div>

        <div style="display:flex; align-items:center; gap:10px;">
            <a href="${empty productId ? ctx.concat('/staff/products') : ctx.concat('/staff/products/').concat(productId)}" class="export-btn" style="text-decoration:none">
                <i class="ti ti-x"></i> Hủy bỏ
            </a>
            <button type="submit" form="productMainForm" class="export-btn" style="background:var(--btn-primary-gradient); color:#fff; border-color:transparent; font-weight:800; box-shadow:var(--shadow-btn); cursor:pointer;">
                <i class="ti ti-check"></i> Lưu sản phẩm
            </button>
        </div>
    </div>

    <c:if test="${not empty parentProduct}">
        <div class="note" style="background:#eff6ff; border:1px solid #bfdbfe; color:#1e40af; margin-bottom:20px; padding:14px 18px; border-radius:14px; display:flex; align-items:center; gap:14px; font-size:13.5px; box-shadow:0 2px 8px rgba(37,99,235,0.06);">
            <i class="ti ti-layers-subtract" style="color:#2563eb; font-size:26px; flex-shrink:0;"></i>
            <div style="line-height:1.5;">
                <span style="font-weight:800; font-size:14px; color:#1d4ed8;">ĐANG TẠO BIẾN THỂ MỚI CHO: <c:out value="${parentProduct.name}"/></span><br>
                <span>Hệ thống đã tự động kế thừa <b>Danh mục</b>, <b>Thương hiệu</b>, <b>Loài &amp; Độ tuổi</b>, <b>Mô tả</b> và <b>bộ 5 ảnh</b> từ sản phẩm gốc. Bạn chỉ cần điền quy cách vào tên, hoàn tất SKU, giá bán và bấm Lưu.</span>
            </div>
        </div>
    </c:if>

    <form:form id="productMainForm" method="post" action="${formAction}" modelAttribute="productForm" enctype="multipart/form-data">
        <form:hidden path="variantOf" id="variantOf"/>
        <div class="form-layout">
            <%-- ========================================================
                 CỘT TRÁI (LEFT COLUMN): Thông tin chính & Hình ảnh & Lô
                 ======================================================== --%>
            <div>
                <%-- CARD 1: Thông tin cơ bản --%>
                <div class="form-card">
                    <div class="form-card-head">
                        <div class="form-card-title">
                            <i class="ti ti-file-description" style="color:var(--color-primary)"></i>
                            <span>1. Thông tin mô tả sản phẩm</span>
                        </div>
                        <span class="pill-badge orange">Bắt buộc</span>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="name">Tên sản phẩm <span class="req">*</span></label>
                        <form:input path="name" id="name" maxlength="200" cssClass="form-control" style="font-size:15px; font-weight:700;" placeholder="Ví dụ: Hạt cho mèo con Royal Canin Kitten 36 2kg" required="required"/>
                        <form:errors path="name" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="description">Mô tả chi tiết sản phẩm</label>
                        <form:textarea path="description" id="description" rows="6" cssClass="form-control" placeholder="Mô tả công dụng dinh dưỡng, thành phần, nguồn gốc xuất xứ và hướng dẫn bảo quản..."/>
                        <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Hỗ trợ tối đa 4.000 ký tự.</span>
                        <form:errors path="description" cssClass="err"/>
                    </div>
                </div>

                <%-- CARD 2: Bộ 5 ảnh sản phẩm --%>
                <div class="form-card">
                    <div class="form-card-head">
                        <div class="form-card-title">
                            <i class="ti ti-photo" style="color:var(--color-primary)"></i>
                            <span>2. Bộ sưu tập hình ảnh (Đủ 5 ảnh)</span>
                        </div>
                        <span class="pill-badge green">Tối đa 5MB/ảnh</span>
                    </div>

                    <div class="note" style="background:#fffaf5; border:1px solid #ffd8b8; color:#9a3412; margin-bottom:14px; padding:10px 14px; border-radius:12px; display:flex; align-items:flex-start; gap:10px; font-size:13px;">
                        <i class="ti ti-info-circle" style="color:#ea580c; font-size:18px; margin-top:2px;"></i>
                        <div style="line-height:1.5;">
                            <b>Yêu cầu hình ảnh:</b> Định dạng JPG, PNG hoặc WEBP, tối thiểu 300×300 px. Hệ thống tự động chuyển sang JPG nền trắng chuẩn hóa cạnh dài tối đa 900 px.
                            <c:if test="${not empty productId}"><br><span style="color:#c2410c;">(Chế độ sửa: Chỉ cần chọn ở vị trí muốn thay, để trống sẽ giữ nguyên ảnh cũ).</span></c:if>
                            <c:if test="${not empty parentProduct}"><br><span style="color:#2563eb;">(Chế độ biến thể: Hệ thống đã nạp sẵn 5 ảnh từ dòng sản phẩm chính. Bạn có thể giữ nguyên hoặc bấm "Thay đổi" nếu có ảnh quy cách riêng).</span></c:if>
                        </div>
                    </div>

                    <div class="slots-grid">
                        <c:forEach begin="1" end="5" var="slot">
                            <div class="slot-box">
                                <div style="display:flex; justify-content:center; margin-bottom:4px;">
                                    <c:choose>
                                        <c:when test="${slot == 1}">
                                            <span class="pill-badge orange" style="font-size:10px;"><i class="ti ti-star"></i> Ảnh đại diện</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge gray" style="font-size:10px;">Vị trí ${slot}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <c:remove var="currentUrl"/>
                                <c:if test="${not empty product}">
                                    <c:set var="currentUrl" value="${product.imageSlots[slot - 1]}"/>
                                </c:if>
                                <c:if test="${empty currentUrl and not empty parentProduct}">
                                    <c:if test="${not empty parentProduct.imageSlots and not empty parentProduct.imageSlots[slot - 1]}">
                                        <c:set var="currentUrl" value="${parentProduct.imageSlots[slot - 1]}"/>
                                    </c:if>
                                </c:if>

                                <div class="slot-preview-wrap" onclick="document.getElementById('fileSlot${slot}').click()" title="Bấm để chọn ảnh cho vị trí ${slot}">
                                    <img id="previewSlot${slot}" class="slot-img"
                                         src="${not empty currentUrl ? ctx.concat(currentUrl) : ''}"
                                         alt="Ảnh ${slot}"
                                         style="display:${not empty currentUrl ? 'block' : 'none'};">

                                    <div id="placeholderSlot${slot}" class="slot-placeholder" style="display:${not empty currentUrl ? 'none' : 'flex'};">
                                        <i class="ti ti-cloud-upload" style="font-size:26px; color:#ea580c; opacity:0.7;"></i>
                                        <span style="font-size:11px; margin-top:4px; font-weight:700;">Tải ảnh</span>
                                        <span style="font-size:10px; color:var(--text-placeholder);">JPG, PNG</span>
                                    </div>
                                </div>

                                <input type="file" name="image${slot}" id="fileSlot${slot}" accept="image/jpeg,image/png,image/webp"
                                       style="display:none;" onchange="handleImagePreview(this, ${slot})"
                                       <c:if test="${empty productId and empty parentProduct}">required</c:if>>

                                <button type="button" class="slot-upload-trigger" onclick="document.getElementById('fileSlot${slot}').click()">
                                    <i class="ti ti-upload"></i>
                                    <span id="btnTextSlot${slot}">${not empty currentUrl ? 'Thay đổi' : 'Chọn tệp'}</span>
                                </button>
                                <form:errors path="image${slot}" cssClass="err"/>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <%-- CARD 3: Lô đầu tiên (chỉ khi thêm mới) --%>
                <c:if test="${empty productId}">
                    <div class="form-card" style="background:#fffcf9; border-color:#fed7aa;">
                        <div class="form-card-head" style="border-bottom-color:#fed7aa;">
                            <div class="form-card-title">
                                <i class="ti ti-building-warehouse" style="color:var(--color-primary)"></i>
                                <span>3. Nhập lô hàng đầu tiên (Không bắt buộc)</span>
                            </div>
                            <span class="pill-badge gray">Tùy chọn</span>
                        </div>

                        <p class="hint" style="margin-top:0; margin-bottom:16px; font-size:13px; color:var(--text-muted);">
                            Nếu hàng đã về kho cùng thời điểm tạo sản phẩm, bạn có thể nhập luôn thông tin lô đầu tiên tại đây. Nếu chưa có hàng, có thể để trống và thực hiện tại mục <b>Quản lý Lô</b> sau.
                        </p>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="firstLotExpiryDate">Hạn sử dụng lô</label>
                                <form:input path="firstLotExpiryDate" id="firstLotExpiryDate" type="date" cssClass="form-control"/>
                                <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Cam kết HSD xuất bán thường ≥ 90 ngày.</span>
                                <form:errors path="firstLotExpiryDate" cssClass="err"/>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="firstLotQty">Số lượng nhập kho</label>
                                <form:input path="firstLotQty" id="firstLotQty" type="number" min="1" step="1" cssClass="form-control" placeholder="Ví dụ: 100"/>
                                <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Đơn vị tính: sản phẩm.</span>
                                <form:errors path="firstLotQty" cssClass="err"/>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>

            <%-- ========================================================
                 CỘT PHẢI (RIGHT COLUMN): Phân loại & Định giá & Kho
                 ======================================================== --%>
            <div>
                <%-- CARD 4: Phân loại & Định danh --%>
                <div class="form-card">
                    <div class="form-card-head">
                        <div class="form-card-title">
                            <i class="ti ti-category" style="color:var(--color-primary)"></i>
                            <span>Định danh &amp; Phân loại</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="sku">Mã SKU <span class="req">*</span></label>
                        <form:input path="sku" id="sku" maxlength="50" cssClass="form-control" style="font-family:monospace; font-weight:700; text-transform:uppercase;" placeholder="RC-KITTEN36-400G" required="required"/>
                        <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Chữ in hoa, số và dấu gạch ngang (Dùng làm thư mục lưu ảnh).</span>
                        <form:errors path="sku" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="barcode">Mã vạch Barcode</label>
                        <form:input path="barcode" id="barcode" maxlength="50" cssClass="form-control" style="font-family:monospace;" placeholder="8938500000000"/>
                        <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Không bắt buộc, quét mã máy đọc vạch.</span>
                        <form:errors path="barcode" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="categoryId">Danh mục sản phẩm <span class="req">*</span></label>
                        <form:select path="categoryId" id="categoryId" cssClass="form-control">
                            <form:option value="" label="-- Chọn danh mục --"/>
                            <c:forEach var="cat" items="${categories}">
                                <form:option value="${cat.id}"><c:out value="${cat.name}"/> (${cat.petType.label})<c:if test="${cat.status == 'HIDDEN'}"> [Đang ẩn]</c:if></form:option>
                            </c:forEach>
                        </form:select>
                        <form:errors path="categoryId" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="brand">Nhãn hàng / Thương hiệu</label>
                        <form:input path="brand" id="brand" maxlength="100" cssClass="form-control" placeholder="Ví dụ: Royal Canin, Whiskas..."/>
                        <form:errors path="brand" cssClass="err"/>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="species">Loài thú cưng <span class="req">*</span></label>
                            <form:select path="species" id="species" cssClass="form-control">
                                <form:option value="" label="-- Chọn loài --"/>
                                <form:options items="${speciesList}" itemLabel="label"/>
                            </form:select>
                            <form:errors path="species" cssClass="err"/>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="ageGroup">Nhóm tuổi <span class="req">*</span></label>
                            <form:select path="ageGroup" id="ageGroup" cssClass="form-control">
                                <form:option value="" label="-- Chọn độ tuổi --"/>
                                <form:options items="${ageGroups}" itemLabel="label"/>
                            </form:select>
                            <form:errors path="ageGroup" cssClass="err"/>
                        </div>
                    </div>
                </div>

                <%-- CARD 5: Giá bán & Cảnh báo tồn kho --%>
                <div class="form-card">
                    <div class="form-card-head">
                        <div class="form-card-title">
                            <i class="ti ti-coin" style="color:var(--color-primary)"></i>
                            <span>Giá bán &amp; Tồn kho</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="sellingPrice">Giá bán lẻ (VNĐ) <span class="req">*</span></label>
                        <div class="form-input-prefix">
                            <span class="prefix-icon" style="font-weight:800; color:#ea580c">₫</span>
                            <form:input path="sellingPrice" id="sellingPrice" type="number" min="1" step="1" cssClass="form-control" style="font-weight:800; font-size:15px; color:#ea580c;" placeholder="142000" required="required"/>
                        </div>
                        <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Nhập số nguyên, không dấu phẩy hay chấm.</span>
                        <form:errors path="sellingPrice" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="lowStockThreshold">Ngưỡng cảnh báo tồn thấp <span class="req">*</span></label>
                        <form:input path="lowStockThreshold" id="lowStockThreshold" type="number" min="0" step="1" cssClass="form-control" placeholder="10" required="required"/>
                        <span class="hint" style="font-size:12px; color:var(--text-muted); display:block; margin-top:4px;">Khi số lượng tồn có HSD ≥ 90 ngày ≤ mức này, hệ thống sẽ kích hoạt cảnh báo kho.</span>
                        <form:errors path="lowStockThreshold" cssClass="err"/>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="status">Trạng thái kinh doanh <span class="req">*</span></label>
                        <form:select path="status" id="status" cssClass="form-control">
                            <form:options items="${productStatuses}" itemLabel="label"/>
                        </form:select>
                        <form:errors path="status" cssClass="err"/>
                    </div>
                </div>
            </div>
        </div>

        <%-- BOTTOM ACTION BAR --%>
        <div class="sticky-action-bar">
            <div style="display:flex; align-items:center; gap:8px; font-size:13px; color:var(--text-muted);">
                <i class="ti ti-shield-check" style="font-size:18px; color:#16a34a;"></i>
                <span>Vui lòng kiểm tra kỹ tất cả các trường thông tin và 5 ảnh sản phẩm trước khi lưu.</span>
            </div>

            <div style="display:flex; align-items:center; gap:12px;">
                <a href="${empty productId ? ctx.concat('/staff/products') : ctx.concat('/staff/products/').concat(productId)}" class="export-btn" style="text-decoration:none">
                    Hủy bỏ
                </a>
                <button type="submit" class="export-btn" style="background:var(--btn-primary-gradient); color:#fff; border-color:transparent; font-weight:800; box-shadow:var(--shadow-btn); cursor:pointer;">
                    <i class="ti ti-check"></i> Lưu sản phẩm
                </button>
            </div>
        </div>
    </form:form>
</main>

<script>
    // Xem trước hình ảnh tức thời khi nhân viên chọn tệp từ máy
    function handleImagePreview(input, slot) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            var reader = new FileReader();
            reader.onload = function (e) {
                var previewEl = document.getElementById('previewSlot' + slot);
                var placeholderEl = document.getElementById('placeholderSlot' + slot);
                var btnTextEl = document.getElementById('btnTextSlot' + slot);

                if (previewEl) {
                    previewEl.src = e.target.result;
                    previewEl.style.display = 'block';
                }
                if (placeholderEl) {
                    placeholderEl.style.display = 'none';
                }
                if (btnTextEl) {
                    btnTextEl.innerText = 'Thay đổi';
                }
            };
            reader.readAsDataURL(file);
        }
    }
</script>
</body>
</html>
