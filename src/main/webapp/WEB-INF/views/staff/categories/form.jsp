<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: categoryForm (name, petType, status), categoryId (null = thêm mới), petTypes, categoryStatuses --%>
<c:choose>
    <c:when test="${empty categoryId}">
        <c:set var="pageHeading" value="Thêm danh mục mới"/>
        <c:url var="formAction" value="/staff/categories/new"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Chỉnh sửa danh mục #${categoryId}"/>
        <c:url var="formAction" value="/staff/categories/${categoryId}/edit"/>
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${pageHeading} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/categories" style="color:inherit; text-decoration:none;">QUẢN LÝ DANH MỤC</a>
                <span class="sep">&gt;</span>
                <span class="current">${pageHeading}</span>
            </div>
            <h1>${pageHeading}</h1>
            <p class="page-sub">Cấu hình thông tin tên danh mục, loại thú cưng áp dụng và trạng thái hiển thị.</p>
        </div>

        <div>
            <a href="${ctx}/staff/categories" class="btn-pill-outline">
                <i class="ti ti-arrow-left"></i>Quay lại danh mục
            </a>
        </div>
    </div>

    <div class="panel" style="max-width:800px; padding:28px">
        <%-- form:form tự thêm ô ẩn _csrf --%>
        <form:form method="post" action="${formAction}" modelAttribute="categoryForm">
            <div class="grid-form" style="padding:0; background:transparent; border:0; box-shadow:none">
                <label for="name" style="font-size:14px">Tên danh mục <span style="color:#ef4444">*</span></label>
                <div>
                    <form:input path="name" maxlength="100" placeholder="Ví dụ: Thức ăn hạt dinh dưỡng cho chó con..."
                                style="width:100%; padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px" required="required"/>
                    <form:errors path="name" cssClass="err"/>
                </div>

                <label for="petType" style="font-size:14px">Loại thú cưng <span style="color:#ef4444">*</span></label>
                <div>
                    <form:select path="petType" style="padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px">
                        <form:option value="" label="-- Chọn loại thú cưng --"/>
                        <form:options items="${petTypes}" itemLabel="label"/>
                    </form:select>
                    <div class="hint" style="margin-top:6px">
                        <i class="ti ti-info-circle"></i> Danh mục Chó / Mèo chỉ chứa sản phẩm loài đó; chọn "Chó và mèo" để dùng chung cho cả 2 loài.
                    </div>
                    <form:errors path="petType" cssClass="err"/>
                </div>

                <label for="status" style="font-size:14px">Trạng thái hiển thị</label>
                <div>
                    <form:select path="status" style="padding:10px 14px; border-radius:12px; border:1px solid var(--line); font-size:14px">
                        <form:options items="${categoryStatuses}" itemLabel="label"/>
                    </form:select>
                    <div class="hint" style="margin-top:6px">
                        <i class="ti ti-alert-triangle"></i> Khi chọn "Đang ẩn", các sản phẩm trong danh mục này cũng sẽ được ẩn khỏi trang của khách hàng.
                    </div>
                    <form:errors path="status" cssClass="err"/>
                </div>
            </div>

            <div style="display:flex; align-items:center; gap:12px; margin-top:28px; padding-top:20px; border-top:1px dashed var(--line)">
                <button type="submit" class="btn-flashsale">
                    <i class="ti ti-device-floppy"></i>Lưu thông tin danh mục
                </button>
                <a href="${ctx}/staff/categories" class="btn-pill-outline">Huỷ bỏ</a>
            </div>
        </form:form>
    </div>
</main>

</body>
</html>
