<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<%-- Khai báo định danh trang hiện tại để Header và Footer tự sáng màu cam ở mục Flash Sale --%>
<c:set var="activePage" value="flash-sale" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Flash Sale &amp; Khuyến Mãi - PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/flash-sale.css">
    </head>

    <body>

        <%-- Nhúng Header chung --%>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <main class="page-container">
            <!-- 1. Breadcrumb -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${ctx}/" class="breadcrumb-home">
                    <span>Trang chủ</span>
                </a>
                <span class="breadcrumb-separator">&rsaquo;</span>
                <span class="breadcrumb-current">Flash Sale &amp; Khuyến mãi</span>
            </nav>

            <!-- 2. Khung Banner Flash Sale & Đồng hồ đếm ngược -->
            <section class="flash-banner">
                <div class="flash-banner-top">
                    <div class="flash-title-group">
                        <div class="flash-heading">
                            <i class="fi fi-rr-flame flame-icon"></i>
                            <h1>Flash Sale &amp; Khuyến Mãi Đặc Biệt</h1>
                        </div>
                        <p class="flash-subtitle">
                            Số lượng ưu đãi có hạn &bull; Giảm giá sốc cho các sản phẩm chính hãng
                        </p>
                    </div>

                    
                </div>

                <div class="flash-policy-bar">
                    <i class="fi fi-rr-bolt"></i>
                    <p>
                        <strong>Toàn bộ sản phẩm được áp dụng chính sách cam kết chất lượng,</strong> bảo quản chuẩn nhiệt độ 22°C và minh bạch thông tin HSD chính xác tuyệt đối.
                    </p>
                </div>
            </section>

            <!-- 3. Thanh Tabs lọc nhanh -->
            <div class="flash-filter-tabs" role="tablist">
                <a href="${ctx}/flash-sale" 
                   class="flash-tab ${empty param.filter or param.filter == 'all' ? 'active' : ''}" 
                   data-filter="all">
                    Tất cả sản phẩm
                </a>
                <a href="${ctx}/flash-sale?filter=promo" 
                   class="flash-tab ${param.filter == 'promo' ? 'active' : ''}" 
                   data-filter="PROMO">
                    Chiến dịch Khuyến mãi
                </a>
                <a href="${ctx}/flash-sale?filter=flash" 
                   class="flash-tab ${param.filter == 'flash' ? 'active' : ''}" 
                   data-filter="FLASHSALE">
                    Flash Sale Xả kho
                </a>
                <a href="${ctx}/flash-sale?species=DOG&filter=dog" 
                   class="flash-tab ${param.species == 'DOG' or param.filter == 'dog' ? 'active' : ''}" 
                   data-filter="DOG">
                    Dành cho Chó
                </a>
                <a href="${ctx}/flash-sale?species=CAT&filter=cat" 
                   class="flash-tab ${param.species == 'CAT' or param.filter == 'cat' ? 'active' : ''}" 
                   data-filter="CAT">
                    Dành cho Mèo
                </a>
                <a href="${ctx}/flash-sale?minDiscount=30&filter=deep" 
                   class="flash-tab ${param.minDiscount == '30' or param.filter == 'deep' ? 'active' : ''}" 
                   data-filter="DEEP">
                    Mức giảm sâu &gt; 30%
                </a>
                
            </div>

            <!-- 4. Lưới sản phẩm Flash Sale (Đồng bộ product-card) -->
            <div class="flash-grid" id="flashProductGrid">
                <c:set var="hasActiveOffer" value="false" />
                <c:forEach var="o" items="${offers}">
                    <c:if test="${o.remainingQty > 0}">
                        <c:set var="hasActiveOffer" value="true" />
                        <article class="product-card flash-product-card"
                                 data-species="${o.species}"
                                 data-discount="${o.discountPercent}"
                                 data-promo="${o.promotion ? 'PROMO' : 'FLASHSALE'}"
                                 data-end-at="${o.endAt}">
                            <a href="${ctx}/products/${o.productId}" class="product-card-link" title="<c:out value='${o.productName}'/>">
                                <div class="product-image">
                                    <span class="flash-tag-discount" style="${o.promotion ? 'background:#2563eb;' : ''}">
                                        <i class="fi fi-rr-flame"></i> -${o.discountPercent}%
                                    </span>
                                    <span class="flash-tag-expiry" title="Hạn sử dụng: <c:out value='${o.expiryText}'/>">
                                        <i class="fi fi-rr-calendar"></i> HSD: <c:out value="${o.expiryText}"/>
                                    </span>
                                    <c:choose>
                                        <c:when test="${not empty o.imageUrl}">
                                            <img src="${ctx}${o.imageUrl}" alt="<c:out value='${o.productName}'/>" loading="lazy">
                                        </c:when>
                                        <c:otherwise><span class="no-img-text">Ảnh sản phẩm</span></c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="product-info">
                                    <span class="product-card-brand"><c:out value="${empty o.brand ? 'PetFood Official' : o.brand}"/></span>
                                    <h3 class="product-card-title"><c:out value="${o.productName}"/></h3>
                                    
                                    <div class="flash-card-meta">
                                        <span class="flash-days-pill"><i class="fi fi-rr-clock"></i> Còn ${o.daysLeft} ngày</span>
                                        <span class="flash-sale-name" title="<c:out value='${o.saleName}'/>">${o.promotion ? '🎁 ' : '⚡ '}<c:out value="${o.saleName}"/></span>
                                    </div>

                                    <div class="product-card-price-row">
                                        <div class="flash-price-stack">
                                            <span class="product-price flash-price"><fmt:formatNumber value="${o.salePrice}" type="number"/> ₫</span>
                                            <c:if test="${o.sellingPrice > o.salePrice}">
                                                <span class="product-old-price"><fmt:formatNumber value="${o.sellingPrice}" type="number"/> ₫</span>
                                            </c:if>
                                        </div>
                                        <span class="product-sold flash-stock-tag">Còn ${o.remainingQty} suất</span>
                                    </div>
                                </div>
                            </a>
                            <c:if test="${currentUser.role == 'CUSTOMER'}">
                                <div class="product-card-action">
                                    <form action="${ctx}/cart/add" method="post" class="add-cart-form">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="flashSaleItemId" value="${o.flashSaleItemId}">
                                        <input type="hidden" name="quantity" value="1">
                                        <button type="submit" class="flash-btn-buy">
                                            <i class="fi fi-rr-bolt"></i> ${o.promotion ? 'Mua giá Chương trình' : 'Mua giá Flash Sale'}
                                        </button>
                                    </form>
                                </div>
                            </c:if>
                        </article>
                    </c:if>
                </c:forEach>

                <c:if test="${not hasActiveOffer}">
                    <!-- Hiển thị thông báo nếu Database chưa có sản phẩm hoặc tất cả đã hết hàng -->
                    <div style="grid-column: 1 / -1; text-align: center; padding: 50px 20px; color: #817872; font-size: 15px; background: #FFF9F5; border-radius: 16px; border: 1.5px dashed #F8CBB0;">
                        <i class="fi fi-rr-box-open" style="font-size: 38px; display: block; margin-bottom: 12px; color: #F47721;"></i>
                        Hiện tại chưa có sản phẩm nào trong chương trình Flash Sale / Khuyến mãi.
                    </div>
                </c:if>
            </div>
        </main>

        <%-- Nhúng Footer & Chat Widget chung --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <!-- Script xử lý Đồng hồ đếm ngược, Lọc Tab nhanh & Chat Modal -->
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Chuyển đổi Tab lọc nhanh mượt mà ngay trên trang
                const tabs = document.querySelectorAll(".flash-tab");
                const cards = document.querySelectorAll(".flash-product-card");

                function applyTabFilter(filterType) {
                    cards.forEach(card => {
                        const species = card.getAttribute("data-species");
                        const discount = parseInt(card.getAttribute("data-discount") || "0", 10);
                        const promo = card.getAttribute("data-promo");

                        if (filterType === "all") {
                            card.style.display = "flex";
                        } else if (filterType === "PROMO" || filterType === "FLASHSALE") {
                            card.style.display = (promo === filterType) ? "flex" : "none";
                        } else if (filterType === "DOG" || filterType === "CAT") {
                            card.style.display = (species === filterType) ? "flex" : "none";
                        } else if (filterType === "DEEP") {
                            card.style.display = (discount >= 30) ? "flex" : "none";
                        }
                    });
                }

                tabs.forEach(tab => {
                    tab.addEventListener("click", function (e) {
                        const filterType = this.getAttribute("data-filter");
                        if (!filterType) return;
                        e.preventDefault();

                        tabs.forEach(t => t.classList.remove("active"));
                        this.classList.add("active");
                        applyTabFilter(filterType);
                    });
                });

                const initialActiveTab = document.querySelector(".flash-tab.active");
                if (initialActiveTab && initialActiveTab.getAttribute("data-filter")) {
                    applyTabFilter(initialActiveTab.getAttribute("data-filter"));
                }

                // 3. Nút Yêu thích (Trái tim)
                document.querySelectorAll(".wishlist-btn").forEach(btn => {
                    btn.addEventListener("click", function () {
                        this.classList.toggle("liked");
                    });
                });

                // 4. Bật/tắt khung Chat
                const toggleBtn = document.getElementById("chatToggleBtn");
                const closeBtn = document.getElementById("chatCloseBtn");
                const chatModal = document.getElementById("chatBoxModal");

                if (toggleBtn && chatModal && closeBtn) {
                    toggleBtn.addEventListener("click", () => chatModal.classList.toggle("active"));
                    closeBtn.addEventListener("click", () => chatModal.classList.remove("active"));
                }
            });
        </script>
    </body>
</html>
