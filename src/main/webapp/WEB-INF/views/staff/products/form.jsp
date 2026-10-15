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
    <c:when test="${empty productId}">
        <c:set var="pageHeading" value="Thêm sản phẩm"/>
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
    <title><c:out value="${pageHeading}"/> · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<h1><c:out value="${pageHeading}"/></h1>

<form:form method="post" action="${formAction}" modelAttribute="productForm" enctype="multipart/form-data">

    <h2>Thông tin sản phẩm</h2>
    <div class="grid-form">
        <label for="sku">SKU</label>
        <div>
            <form:input path="sku" maxlength="50" size="30" placeholder="RC-KITTEN36-400G" required="required"/>
            <span class="hint">Chữ in hoa, số, dấu gạch ngang. Dùng làm tên thư mục ảnh.</span>
            <form:errors path="sku" cssClass="err"/>
        </div>

        <label for="barcode">Mã vạch</label>
        <div>
            <form:input path="barcode" maxlength="50" size="30"/>
            <span class="hint">Không bắt buộc.</span>
            <form:errors path="barcode" cssClass="err"/>
        </div>

        <label for="name">Tên sản phẩm</label>
        <div>
            <form:input path="name" maxlength="200" size="70" required="required"/>
            <form:errors path="name" cssClass="err"/>
        </div>

        <label for="brand">Nhãn hàng</label>
        <div>
            <form:input path="brand" maxlength="100" size="30"/>
            <form:errors path="brand" cssClass="err"/>
        </div>

        <label for="categoryId">Danh mục</label>
        <div>
            <form:select path="categoryId">
                <form:option value="" label="-- Chọn danh mục --"/>
                <c:forEach var="cat" items="${categories}">
                    <form:option value="${cat.id}"><c:out value="${cat.name}"/> (${cat.petType.label})<c:if test="${cat.status == 'HIDDEN'}"> - đang ẩn</c:if></form:option>
                </c:forEach>
            </form:select>
            <form:errors path="categoryId" cssClass="err"/>
        </div>

        <label for="species">Loài</label>
        <div>
            <form:select path="species">
                <form:option value="" label="-- Chọn --"/>
                <form:options items="${speciesList}" itemLabel="label"/>
            </form:select>
            <form:errors path="species" cssClass="err"/>
        </div>

        <label for="ageGroup">Nhóm tuổi</label>
        <div>
            <form:select path="ageGroup">
                <form:option value="" label="-- Chọn --"/>
                <form:options items="${ageGroups}" itemLabel="label"/>
            </form:select>
            <form:errors path="ageGroup" cssClass="err"/>
        </div>

        <label for="sellingPrice">Giá bán (đồng)</label>
        <div>
            <form:input path="sellingPrice" type="number" min="1" step="1" required="required"/>
            <span class="hint">Gõ số liền, ví dụ 142000.</span>
            <form:errors path="sellingPrice" cssClass="err"/>
        </div>

        <label for="lowStockThreshold">Ngưỡng tồn thấp</label>
        <div>
            <form:input path="lowStockThreshold" type="number" min="0" step="1" required="required"/>
            <span class="hint">Tồn bán thường (lô còn từ 90 ngày) bằng hoặc dưới số này thì báo tồn thấp.</span>
            <form:errors path="lowStockThreshold" cssClass="err"/>
        </div>

        <label for="status">Trạng thái</label>
        <div>
            <form:select path="status">
                <form:options items="${productStatuses}" itemLabel="label"/>
            </form:select>
            <form:errors path="status" cssClass="err"/>
        </div>

        <label for="description">Mô tả</label>
        <div>
            <form:textarea path="description" rows="5" cols="70"/>
            <form:errors path="description" cssClass="err"/>
        </div>
    </div>

    <h2>Ảnh sản phẩm: đủ 5 ảnh, ảnh 1 là ảnh đại diện</h2>
    <p class="hint">
        Chọn ảnh JPG, PNG hoặc WEBP từ máy, tối đa 5MB mỗi ảnh, tối thiểu 300×300 px.
        Hệ thống tự chuyển sang JPG nền trắng, cạnh dài tối đa 900 px.
        <c:if test="${not empty productId}"><br>Chỉ chọn ảnh ở vị trí muốn thay; ô bỏ trống thì giữ ảnh cũ.</c:if>
        <br>Nếu form báo lỗi, trình duyệt sẽ xoá các ảnh đã chọn: hãy chọn lại ảnh trước khi lưu.
    </p>
    <div class="slots">
        <c:forEach begin="1" end="5" var="slot">
            <div class="slot">
                <strong>Ảnh ${slot}<c:if test="${slot == 1}"> (đại diện)</c:if></strong>
                <c:remove var="currentUrl"/>
                <c:if test="${not empty product}">
                    <c:set var="currentUrl" value="${product.imageSlots[slot - 1]}"/>
                </c:if>
                <c:choose>
                    <c:when test="${not empty currentUrl}">
                        <img src="${ctx}<c:out value='${currentUrl}'/>" alt="Ảnh ${slot}">
                    </c:when>
                    <c:otherwise>
                        <div class="noimg">Chưa có ảnh</div>
                    </c:otherwise>
                </c:choose>
                <%-- name="image1".."image5" khớp ProductForm.image1..image5 --%>
                <input type="file" name="image${slot}" accept="image/jpeg,image/png,image/webp"
                       <c:if test="${empty productId}">required</c:if>>
                <form:errors path="image${slot}" cssClass="err"/>
            </div>
        </c:forEach>
    </div>

    <c:if test="${empty productId}">
        <h2>Lô đầu tiên (không bắt buộc)</h2>
        <p class="hint">Hàng về cùng lúc thêm sản phẩm thì nhập luôn ở đây. Chưa có hàng thì để trống, sau này vào "Nhập lô".</p>
        <div class="grid-form">
            <label for="firstLotExpiryDate">Hạn sử dụng</label>
            <div>
                <form:input path="firstLotExpiryDate" type="date"/>
                <form:errors path="firstLotExpiryDate" cssClass="err"/>
            </div>

            <label for="firstLotQty">Số lượng nhập</label>
            <div>
                <form:input path="firstLotQty" type="number" min="1" step="1"/>
                <form:errors path="firstLotQty" cssClass="err"/>
            </div>
        </div>
    </c:if>

    <p>
        <button type="submit">Lưu sản phẩm</button>
        <c:choose>
            <c:when test="${empty productId}"><a href="${ctx}/staff/products">Huỷ</a></c:when>
            <c:otherwise><a href="${ctx}/staff/products/${productId}">Huỷ</a></c:otherwise>
        </c:choose>
    </p>
</form:form>
</body>
</html>
