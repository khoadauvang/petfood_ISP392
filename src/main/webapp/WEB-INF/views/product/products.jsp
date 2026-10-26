<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%-- Khai báo định danh trang hiện tại để header/footer tự sáng màu cam --%>
<c:set var="activePage" value="products" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sản phẩm - PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/products.css">
    </head>

    <body>

        <%-- Nhúng Header chung --%>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <main class="page-container">
            <%-- Trang / bộ lọc đang xem, để Guest đăng nhập xong quay lại (đọc bằng JS ở nút "Thêm vào giỏ") --%>
            <span id="loginRedirectPath" hidden data-path="<c:out value='/products?${filterQuery}&page=${currentPage}'/>"></span>
            <!-- Breadcrumb -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${ctx}/" class="breadcrumb-home">
                    <i class="fi fi-rr-home"></i>
                    <span>Trang chủ</span>
                </a>
                <span class="breadcrumb-separator">/</span>
                <span class="breadcrumb-current">Sản phẩm dinh dưỡng</span>
            </nav>

            <div class="catalog-layout">

                <aside class="filter-sidebar" aria-label="Bộ lọc sản phẩm">
                    <div class="filter-heading">
                        <h2><i class="fi fi-rr-settings-sliders"></i> Bộ lọc</h2>
                        <a href="${ctx}/products" class="clear-filter">Xóa</a>
                    </div>

                    <form id="product-filter-form" class="filter-form" method="get" action="${ctx}/products">
                        <div class="filter-group">
                            <label for="keyword"><strong>Tìm kiếm</strong></label>
                            <input id="keyword" type="search" name="keyword"
                                   value="<c:out value='${filter.keyword}'/>"
                                   placeholder="Tên, thương hiệu, SKU">
                        </div>

                        <div class="filter-group">
                            <label for="categoryId"><strong>Danh mục</strong></label>
                            <select id="categoryId" name="categoryId">
                                <option value="">Tất cả danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}" ${filter.categoryId == cat.id ? 'selected' : ''}>
                                        <c:out value="${cat.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="species"><strong>Loài</strong></label>
                            <select id="species" name="species">
                                <option value="">Chó và mèo</option>
                                <c:forEach var="s" items="${speciesList}">
                                    <option value="${s}" ${filter.species == s ? 'selected' : ''}>
                                        ${s.label}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="ageGroup"><strong>Độ tuổi</strong></label>
                            <select id="ageGroup" name="ageGroup">
                                <option value="">Mọi độ tuổi</option>
                                <c:forEach var="a" items="${ageGroups}">
                                    <option value="${a}" ${filter.ageGroup == a ? 'selected' : ''}>
                                        ${a.label}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="brand"><strong>Thương hiệu</strong></label>
                            <select id="brand" name="brand">
                                <option value="">Tất cả thương hiệu</option>
                                <c:forEach var="b" items="${brands}">
                                    <option value="<c:out value='${b}'/>" ${filter.brand == b ? 'selected' : ''}>
                                        <c:out value="${b}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group price-filter">
                            <strong>Khoảng giá</strong>
                            <div class="price-inputs">
                                <label>
                                    <span>Từ (đ)</span>
                                    <input type="number" name="minPrice" min="0" step="1000" placeholder="0" value="${filter.minPrice}">
                                </label>
                                <label>
                                    <span>Đến (đ)</span>
                                    <input type="number" name="maxPrice" min="0" step="1000" placeholder="Giá tối đa" value="${filter.maxPrice}">
                                </label>
                            </div>
                        </div>

                        <div class="filter-actions">
                            <a href="${ctx}/products" class="btn-reset">Đặt lại</a>
                            <button type="submit" class="btn-apply">Áp dụng</button>
                        </div>
                    </form>
                </aside>

                <section class="catalog-content" aria-label="Danh sách sản phẩm">
                    <div class="catalog-toolbar">
                        <div class="catalog-title">
                            <h2>Tất cả sản phẩm</h2>
                            <p class="results-count">${totalItems} sản phẩm</p>
                        </div>

                        <!-- Cụm nút chuyển nhanh Chó / Mèo nằm gọn bên phải -->
                        <div class="pet-filter-tabs">
                            <a href="${ctx}/products" 
                               class="pet-tab-item ${empty filter.species ? 'active' : ''}">
                                <i class="fi fi-rr-apps"></i> Tất cả
                            </a>
                            <a href="${ctx}/products?species=DOG" 
                               class="pet-tab-item ${filter.species == 'DOG' ? 'active' : ''}">
                                <i class="fi fi-rr-dog"></i> Chó cưng
                            </a>
                            <a href="${ctx}/products?species=CAT" 
                               class="pet-tab-item ${filter.species == 'CAT' ? 'active' : ''}">
                                <i class="fi fi-rr-cat"></i> Mèo cưng
                            </a>
                        </div>
                    </div>


                    <div class="product-grid">
                        <c:forEach var="p" items="${products}">
                            <article class="product-card">
                                <a href="${ctx}/products/${p.id}" class="product-image-link" aria-label="Xem chi tiết sản phẩm">
                                    <div class="product-image">
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl}">
                                                <img src="${ctx}${p.imageUrl}" alt="<c:out value='${p.name}'/>">
                                            </c:when>
                                            <c:otherwise>
                                                <span>Chưa có ảnh sản phẩm</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </a>

                                <div class="product-info">
                                    <p class="product-category"><c:out value="${p.brand}"/></p>
                                    <h3>
                                        <a href="${ctx}/products/${p.id}"><c:out value="${p.name}"/></a>
                                    </h3>
                                    <p class="product-price">
                                        <fmt:formatNumber value="${p.price}" type="number"/> ₫
                                    </p>
                                    <p class="stock-status ${p.inStock ? '' : 'out-of-stock'}">
                                        <span class="stock-dot"></span>
                                        <c:choose>
                                            <c:when test="${p.inStock}">Còn hàng</c:when>
                                            <c:otherwise>Hết hàng</c:otherwise>
                                        </c:choose>
                                    </p>

                                    <%-- Staff/Admin không có giỏ hàng; thêm xong quay lại đúng trang / bộ lọc đang xem --%>
                                    <c:choose>
                                        <c:when test="${p.inStock and (currentUser == null or currentUser.role == 'CUSTOMER')}">
                                            <form class="add-cart-form ajax-add-to-cart-form">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="productId" value="${p.id}">
                                                <input type="hidden" name="quantity" value="1">
                                                <button type="button" class="add-cart-btn ajax-submit-btn"
                                                        data-product-image="${not empty p.imageUrl ? ctx.concat(p.imageUrl) : ''}">
                                                    <i class="fi fi-rr-shopping-cart"></i> Thêm vào giỏ hàng
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${not p.inStock}">
                                            <button type="button" class="add-cart-btn" disabled>
                                                <i class="fi fi-rr-shopping-cart"></i> Hết hàng
                                            </button>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </article>
                        </c:forEach>
                    </div>


                    <c:if test="${totalPages > 1}">
                        <nav class="pagination" aria-label="Phân trang">
                            <c:if test="${currentPage > 1}">
                                <a class="page-arrow" href="${ctx}/products?${filterQuery}&page=${currentPage - 1}" aria-label="Trang trước">
                                    <i class="fi fi-rr-angle-left"></i>
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="n">
                                <c:choose>
                                    <c:when test="${n == currentPage}">
                                        <span class="page-number active" aria-current="page">${n}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="page-number" href="${ctx}/products?${filterQuery}&page=${n}">${n}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a class="page-arrow" href="${ctx}/products?${filterQuery}&page=${currentPage + 1}" aria-label="Trang sau">
                                    <i class="fi fi-rr-angle-right"></i>
                                </a>
                            </c:if>
                        </nav>
                    </c:if>
                </section>
            </div>
        </main>


        <%-- Nhúng Footer --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

        <%-- Nhúng Nút Chat nổi --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const forms = document.querySelectorAll(".add-cart-form");

                forms.forEach(form => {
                    const button = form.querySelector(".add-cart-btn");

                    button.addEventListener("click", function (e) {
                        e.preventDefault(); // Chặn việc submit form truyền thống gây reload trang

                        // 1. Lấy token CSRF và dữ liệu sản phẩm trong form
                        const csrfTokenInput = form.querySelector('input[name*="csrf"], input[name="_csrf"]');
                        const csrfToken = csrfTokenInput ? csrfTokenInput.value : '';

                        const productId = form.querySelector('input[name="productId"]').value;
                        const quantity = form.querySelector('input[name="quantity"]').value || "1";

                        const formData = new URLSearchParams();
                        formData.append("productId", productId);
                        formData.append("quantity", quantity);
                        if (csrfToken) {
                            formData.append("_csrf", csrfToken);
                        }

                        // 2. Gửi request ngầm lên Backend để thêm vào giỏ hàng
                        fetch('${ctx}/cart/add', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            body: formData.toString()
                        })
                                .then(response => {
                                    // Guest / phiên hết hạn: Spring Security không trả JSON -> sang trang đăng nhập
                                    const isJson = (response.headers.get('Content-Type') || '').includes('application/json');
                                    if (!isJson) {
                                        // đăng nhập xong quay lại đúng trang / bộ lọc đang xem
                                        const back = document.getElementById('loginRedirectPath').dataset.path;
                                        window.location.href = '${ctx}/login?redirect=' + encodeURIComponent(back);
                                        return null;
                                    }
                                    return response.json();
                                })
                                .then(data => {
                                    if (!data)
                                        return;
                                    if (data.ok) {
                                        // 3. Hiệu ứng đổi nút thành công ngay lập tức tại chỗ
                                        const originalHtml = this.innerHTML;
                                        this.innerHTML = '<i class="fi fi-rr-check"></i> Đã thêm!';
                                        this.classList.add("added");
                                        this.disabled = true;

                                        // 4. Cập nhật tổng số lượng trong giỏ trên icon ở header (cartItemCount do BE trả về)
                                        const cartIcon = document.querySelector('.header-cart');
                                        if (cartIcon) {
                                            let badge = cartIcon.querySelector('.cart-badge');
                                            if (!badge) {
                                                badge = document.createElement('span');
                                                badge.className = 'cart-badge';
                                                cartIcon.appendChild(badge);
                                            }
                                            badge.textContent = data.cartItemCount;
                                        }

                                        // Sau 1.2 giây trả lại trạng thái ban đầu cho nút bấm
                                        setTimeout(() => {
                                            this.innerHTML = originalHtml;
                                            this.classList.remove("added");
                                            this.disabled = false;
                                        }, 1200);

                                    } else {
                                        alert(data.message);
                                    }
                                })
                                .catch(err => {
                                    console.error("Lỗi:", err);
                                });
                    });
                });
            });
        </script>
    </body>
</html>