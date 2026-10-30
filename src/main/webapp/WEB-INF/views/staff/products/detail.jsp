<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: product (ProductDetailDto), lots (List<LotRow>, sắp theo FEFO) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title><c:out value="${product.sku}"/> · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/products" style="color:inherit; text-decoration:none;">QUẢN LÝ SẢN PHẨM</a> <span class="sep">&gt;</span> <span class="current">CHI TIẾT SẢN PHẨM</span>
            </div>
        </div>
    </div>
<h1><c:out value="${product.name}"/></h1>

<div class="filters">
    <a href="${ctx}/staff/products/${product.id}/edit">Sửa thông tin / thay ảnh</a>
    <c:if test="${product.status == 'ACTIVE'}"> · <a href="${ctx}/staff/lots/new?productId=${product.id}">Nhập lô</a></c:if>
    <form method="post" action="${ctx}/staff/products/${product.id}/toggle-status" class="inline">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit">${product.status == 'ACTIVE' ? 'Ẩn (ngừng kinh doanh)' : 'Mở bán lại'}</button>
    </form>
    <%-- Chỉ xoá được sản phẩm chưa có lô hàng (BR-11), service kiểm tra lại lần nữa --%>
    <c:if test="${empty lots}">
        <form method="post" action="${ctx}/staff/products/${product.id}/delete" class="inline"
              onsubmit="return confirm('Xoá hẳn sản phẩm này và 5 ảnh của nó?');">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit">Xoá</button>
        </form>
    </c:if>
</div>

<h2>Ảnh (${product.imageCount}/5)</h2>
<div class="gallery">
    <c:forEach var="url" items="${product.imageSlots}" varStatus="loop">
        <c:choose>
            <c:when test="${not empty url}">
                <img src="${ctx}<c:out value='${url}'/>" alt="Ảnh ${loop.index + 1}" title="Ảnh ${loop.index + 1}">
            </c:when>
            <c:otherwise><div class="noimg">Thiếu ảnh ${loop.index + 1}</div></c:otherwise>
        </c:choose>

    </c:forEach>
</div>

<h2>Thông tin</h2>
<table>
    <tr><th>SKU</th><td><c:out value="${product.sku}"/></td></tr>
    <tr><th>Mã vạch</th><td><c:out value="${product.barcode}"/></td></tr>
    <tr><th>Nhãn hàng</th><td><c:out value="${product.brand}"/></td></tr>
    <tr>
        <th>Danh mục</th>
        <td>
            <c:out value="${product.categoryName}"/> (${product.categoryPetType.label})
            <c:if test="${product.categoryStatus == 'HIDDEN'}"><span class="badge HIDDEN">Danh mục đang ẩn</span></c:if>
        </td>
    </tr>
    <tr>
        <th>Loài · Nhóm tuổi</th>
        <td>
            <c:choose>
                <c:when test="${product.species == 'DOG'}">
                    <span class="pill-badge orange"><i class="ti ti-dog"></i>${product.species.label}</span>
                </c:when>
                <c:when test="${product.species == 'CAT'}">
                    <span class="pill-badge purple"><i class="ti ti-cat"></i>${product.species.label}</span>
                </c:when>
                <c:otherwise>
                    <span class="pill-badge blue"><i class="ti ti-paw"></i>Chó và mèo</span>
                </c:otherwise>
            </c:choose>

            <span style="margin: 0 6px; color: var(--text-placeholder);">·</span>
            <span class="pill-badge gray">${product.ageGroup.label}</span>
        </td>
    </tr>
    <tr><th>Giá bán</th><td><fmt:formatNumber value="${product.sellingPrice}" type="number"/> ₫</td></tr>
    <tr><th>Trạng thái</th><td><span class="badge ${product.status}">${product.status.label}</span></td></tr>
    <tr><th>Ngày tạo</th><td>${product.createdAtText}</td></tr>
    <tr><th>Mô tả</th><td class="pre"><c:out value="${product.description}"/></td></tr>
</table>

<h2>Tồn kho</h2>
<table>
    <tr><th>Tồn thực tế (mọi lô)</th><td class="num">${product.stock.onHandQty}</td></tr>
    <tr><th>Tồn bán thường (lô còn từ 90 ngày)</th><td class="num">${product.stock.sellableQty}</td></tr>
    <tr>
        <th>Ngưỡng tồn thấp</th>
        <td class="num">
            ${product.lowStockThreshold}
            <c:if test="${product.lowStock}"><span class="badge low">Tồn thấp</span></c:if>
        </td>
    </tr>
</table>

<h2>Tồn theo lô (hết hạn trước đứng trước)</h2>
<c:choose>
    <c:when test="${empty lots}">
        <p>Chưa có lô nào.
            <c:if test="${product.status == 'ACTIVE'}"><a href="${ctx}/staff/lots/new?productId=${product.id}">Nhập lô đầu tiên</a></c:if>
        </p>
    </c:when>
    <c:otherwise>
        <table>
            <thead>
            <tr>
                <th>Lô</th><th>Hạn sử dụng</th><th class="num">Còn (ngày)</th><th>Mức</th>
                <th class="num">Nhập</th><th class="num">Còn trong kho</th><th>Ngày nhập</th><th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="lot" items="${lots}">
                <tr>
                    <td>#${lot.id}</td>
                    <td>${lot.expiryDateText}</td>
                    <td class="num">${lot.daysLeft}</td>
                    <td>
                        <c:choose>
                            <c:when test="${lot.depleted}"><span class="badge">Hết hàng</span></c:when>
                            <c:otherwise><span class="badge lv-${lot.level}">${lot.level.label}</span></c:otherwise>
                        </c:choose>

                    </td>
                    <td class="num">${lot.receivedQty}</td>
                    <td class="num">${lot.onHandQty}</td>
                    <td>${lot.receivedAtText}</td>
                    <td>
                        <%-- Lô chưa xuất hàng nào mới sửa / xoá được (nhập nhầm) --%>
                        <c:if test="${lot.untouched}">
                            <a href="${ctx}/staff/lots/${lot.id}/edit">Sửa</a>
                            <form method="post" action="${ctx}/staff/lots/${lot.id}/delete" class="inline"
                                  onsubmit="return confirm('Xoá lô nhập nhầm này?');">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button type="submit">Xoá</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>

</main>
</body>
</html>
