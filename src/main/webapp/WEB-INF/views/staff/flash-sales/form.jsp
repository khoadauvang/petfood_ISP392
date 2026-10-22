<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: flashSaleForm (name, startTime, endTime), saleId --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${saleId == null ? 'Tạo' : 'Sửa'} Flash Sale · PetFood</title>
    <meta name="description" content="Thiết lập chương trình khuyến mãi đặc biệt kích cầu thức ăn thú cưng cận hạn (< 90 ngày).">
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main>
    <c:choose>
        <c:when test="${saleId == null}">
            <c:set var="actionUrl" value="/staff/flash-sales/new"/>
        </c:when>
        <c:otherwise>
            <c:set var="actionUrl" value="/staff/flash-sales/${saleId}/edit"/>
        </c:otherwise>
    </c:choose>

    <form:form method="post" action="${ctx}${actionUrl}" modelAttribute="flashSaleForm" id="flashSaleWizardForm">
        <div class="page-head">
            <div>
                <div class="screen-bc">
                    <a href="${ctx}/staff/flash-sales" style="text-decoration:none; color:inherit;">
                        ‹ FLASH SALE
                    </a>
                    <span class="sep" style="margin: 0 6px;">&gt;</span>
                    <span class="current" style="color:var(--color-primary)">${saleId == null ? 'TẠO MỚI' : 'CHỈNH SỬA'}</span>
                </div>
                <h1 style="display:flex; align-items:center; gap:12px; margin-top:4px;">
                    ${saleId == null ? 'TẠO FLASH SALE MỚI' : 'CHỈNH SỬA FLASH SALE'}
                    <c:if test="${saleId != null}">
                        <span class="pill-badge gray" style="font-size:12px;">#FS-${saleId}</span>
                    </c:if>
                </h1>
                <p class="page-sub">Thiết lập chương trình khuyến mãi đặc biệt kích cầu thức ăn thú cưng cận hạn (&lt; 90 ngày).</p>
            </div>

            <div style="display:flex; align-items:center; gap:10px">
                <a href="${ctx}/staff/flash-sales" class="btn-pill-outline">
                    <i class="ti ti-x"></i> Hủy bỏ
                </a>
                <button type="submit" class="btn-flashsale">
                    <i class="ti ti-check"></i> ${saleId == null ? 'Tạo Flash Sale' : 'Lưu thay đổi'}
                </button>
            </div>
        </div>

        <%-- BƯỚC 1: Thông tin chương trình --%>
        <div class="fs-card-section">
            <div class="fs-section-title">
                <i class="ti ti-calendar" style="color:#ea580c"></i>
                <span>1. Thông tin chương trình</span>
                <small style="color:var(--text-muted); font-weight:normal; margin-left:auto">Tên hiển thị và khung thời gian áp dụng chiến dịch</small>
            </div>

            <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:16px; margin-bottom:14px">
                <div>
                    <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">Tên chương trình *</label>
                    <form:input path="name" maxlength="150" placeholder="Flash Sale Cuối tuần - Xả kho thức ăn hạt cận date"
                                style="width:100%; padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px"/>
                    <form:errors path="name" cssClass="err"/>
                </div>

                <div>
                    <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">Thời gian bắt đầu *</label>
                    <form:input path="startTime" type="datetime-local"
                                style="width:100%; padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px"/>
                    <form:errors path="startTime" cssClass="err"/>
                </div>

                <div>
                    <label style="display:block; font-weight:700; font-size:13px; margin-bottom:6px">Thời gian kết thúc *</label>
                    <form:input path="endTime" type="datetime-local"
                                style="width:100%; padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px"/>
                    <form:errors path="endTime" cssClass="err"/>
                </div>
            </div>

            <div class="note" style="background:#fffaf5; border:1px solid #ffd8b8; color:#9a3412">
                <i class="ti ti-info-circle" style="color:#ea580c"></i>
                <div>Khuyến nghị thời gian diễn ra từ <b>2 đến 5 ngày</b> để tạo tính khan hiếm và tối ưu tỷ lệ chuyển đổi.</div>
            </div>
        </div>

        <%-- BƯỚC 2: Hướng dẫn phân bổ sản phẩm Flash Sale --%>
        <div class="fs-card-section">
            <div class="fs-section-title">
                <i class="ti ti-package" style="color:#ea580c"></i>
                <span>2. Phân bổ suất bán &amp; Lô cận hạn (Bước tiếp theo)</span>
                <span class="pill-badge orange" style="margin-left:auto">Tự động FEFO</span>
            </div>

            <div class="note" style="background:#fffcf9; border:1px solid #fed7aa; color:#9a3412; margin-bottom:16px">
                <i class="ti ti-sparkles" style="color:#ea580c"></i>
                <div>
                    <b>Quy trình tạo chiến dịch Flash Sale:</b>
                    <ol style="margin: 8px 0 0 18px; padding: 0; line-height: 1.6;">
                        <li>Lưu thông tin chương trình và khung thời gian bắt đầu / kết thúc tại biểu mẫu này.</li>
                        <li>Hệ thống sẽ chuyển hướng ngay đến trang <b>Chi tiết chiến dịch</b>.</li>
                        <li>Tại trang chi tiết, chọn các lô hàng cận hạn thực tế (HSD từ 21 đến dưới 90 ngày) từ kho để thêm suất bán; giá Flash Sale do hệ thống tự tính theo HSD của lô.</li>
                    </ol>
                </div>
            </div>

            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:12px; padding:18px 20px; display:flex; align-items:center; gap:16px;">
                <div style="width:44px; height:44px; border-radius:10px; background:#fff7ed; color:#ea580c; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0;">
                    <i class="ti ti-shield-check"></i>
                </div>
                <div>
                    <b style="color:#0f172a; font-size:14px; display:block; margin-bottom:4px;">Bảo vệ tồn kho &amp; Cam kết chất lượng</b>
                    <span style="font-size:12px; color:#64748b; line-height:1.5; display:block;">
                        Chỉ các lô hàng thực tế đã nhập kho và còn hạn từ 21 đến 90 ngày mới được kích hoạt suất Flash Sale. Lô dưới 21 ngày sẽ tự động bị khóa bán, không bán dưới mọi hình thức (BR-51).
                    </span>
                </div>
            </div>
        </div>

        <%-- Action footer --%>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:24px; padding-top:20px; border-top:1px solid var(--line)">
            <a href="${ctx}/staff/flash-sales" class="btn-pill-outline">Hủy bỏ</a>
            <div style="display:flex; gap:10px">
                <button type="submit" class="btn-flashsale">
                    <i class="ti ti-check"></i>${saleId == null ? 'Tạo Flash Sale & Tiếp tục' : 'Lưu thay đổi'}
                </button>
            </div>
        </div>
    </form:form>
</main>
</body>
</html>
