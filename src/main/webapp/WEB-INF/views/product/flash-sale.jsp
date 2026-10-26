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
        <title>Flash Sale Xả Kho Cận Date - PetFood</title>

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
                <span class="breadcrumb-current">Flash Sale xả kho cận date</span>
            </nav>

            <!-- 2. Khung Banner Flash Sale & Đồng hồ đếm ngược -->
            <section class="flash-banner">
                <div class="flash-banner-top">
                    <div class="flash-title-group">
                        <div class="flash-heading">
                            <i class="fi fi-rr-flame flame-icon"></i>
                            <h1>Flash Sale – Giờ Vàng Xả Kho Cận Date</h1>
                        </div>
                        <p class="flash-subtitle">
                            Số lượng xả kho có hạn &bull; Giảm giá sốc cho các sản phẩm chính hãng
                        </p>
                    </div>

                    <div class="countdown-box" aria-label="Thời gian còn lại">
                        <span class="countdown-label">Kết thúc sau:</span>
                        <div class="countdown-timer">
                            <span class="time-badge" id="cd-hours">00</span>
                            <span class="time-colon">:</span>
                            <span class="time-badge" id="cd-minutes">00</span>
                            <span class="time-colon">:</span>
                            <span class="time-badge" id="cd-seconds">00</span>
                        </div>
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
                <a href="${ctx}/flash-sale?species=DOG&filter=dog" 
                   class="flash-tab ${param.species == 'DOG' or param.filter == 'dog' ? 'active' : ''}" 
                   data-filter="DOG">
                    <span>🐶</span> Dành cho Chó
                </a>
                <a href="${ctx}/flash-sale?species=CAT&filter=cat" 
                   class="flash-tab ${param.species == 'CAT' or param.filter == 'cat' ? 'active' : ''}" 
                   data-filter="CAT">
                    <span>🐱</span> Dành cho Mèo
                </a>
                <a href="${ctx}/flash-sale?minDiscount=30&filter=deep" 
                   class="flash-tab ${param.minDiscount == '30' or param.filter == 'deep' ? 'active' : ''}" 
                   data-filter="DEEP">
                    <span>🔥</span> Mức giảm sâu &gt; 30%
                </a>
            </div>

            <!-- 4. Lưới sản phẩm Flash Sale (Lấy từ Database 100%) -->
            <div class="flash-grid" id="flashProductGrid">
                <c:choose>
                    <c:when test="${not empty offers}">
                        <%-- offers: List<FlashSaleOffer> từ FlashSaleController (suất đang mở bán, BR-65) --%>
                        <c:forEach var="o" items="${offers}">
                            <article class="flash-card"
                                     data-species="${o.species}"
                                     data-discount="${o.discountPercent}"
                                     data-end-at="${o.endAt}">

                                <div class="card-top-badges">
                                    <span class="discount-badge">-${o.discountPercent}%</span>
                                    <button type="button" class="wishlist-btn" aria-label="Yêu thích">
                                        <i class="fi fi-rr-heart"></i>
                                    </button>
                                </div>

                                <a href="${ctx}/products/${o.productId}" class="flash-image-link">
                                    <div class="flash-image">
                                        <c:choose>
                                            <c:when test="${not empty o.imageUrl}">
                                                <img src="${ctx}${o.imageUrl}" alt="<c:out value='${o.productName}'/>">
                                            </c:when>
                                            <c:otherwise>
                                                <span>Ảnh sản phẩm</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </a>

                                <div class="flash-info">
                                    <div class="expiry-pill">
                                        <i class="fi fi-rr-calendar"></i>
                                        <span>HSD: <c:out value="${o.expiryText}"/> (còn ${o.daysLeft} ngày)</span>
                                    </div>

                                    <h3>
                                        <a href="${ctx}/products/${o.productId}"><c:out value="${o.productName}"/></a>
                                    </h3>

                                    <div class="price-row">
                                        <span class="sale-price">
                                            <fmt:formatNumber value="${o.salePrice}" type="number"/>đ
                                        </span>
                                        <c:if test="${o.sellingPrice > o.salePrice}">
                                            <span class="old-price">
                                                <fmt:formatNumber value="${o.sellingPrice}" type="number"/>đ
                                            </span>
                                        </c:if>
                                    </div>

                                    <c:set var="soldPct" value="${o.soldPercent}" />
                                    <div class="progress-info">
                                        <div class="progress-labels">
                                            <span class="sold-text">Đã bán: ${soldPct}% · còn ${o.remainingQty} suất</span>
                                            <span class="status-text ${soldPct >= 80 ? 'urgent' : ''}">
                                                <c:choose>
                                                    <c:when test="${soldPct >= 90}">Sắp hết hàng</c:when>
                                                    <c:when test="${soldPct >= 80}">Gần hết</c:when>
                                                    <c:otherwise>Đang bán chạy</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="progress-track">
                                            <div class="progress-fill" style="width: ${soldPct}%;"></div>
                                        </div>
                                    </div>

                                    <c:choose>
                                        <c:when test="${o.remainingQty > 0 and (empty currentUser or currentUser.role == 'CUSTOMER')}">
                                            <%-- Thêm dòng Flash Sale (tách riêng khỏi dòng giá thường, BR-65); Guest bị chuyển tới /login --%>
                                            <form action="${ctx}/cart/add" method="post" class="add-cart-form">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="flashSaleItemId" value="${o.flashSaleItemId}">
                                                <input type="hidden" name="quantity" value="1">
                                                <input type="hidden" name="returnUrl" value="/flash-sale">
                                                <button type="submit" class="add-cart-btn">
                                                    <i class="fi fi-rr-shopping-cart"></i> Thêm vào giỏ
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:when test="${o.remainingQty > 0}">
                                            <button type="button" class="add-cart-btn" disabled>Chỉ khách hàng mua được</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="add-cart-btn" disabled>
                                                Hết hàng
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </article>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <!-- Hiển thị thông báo nếu Database chưa có sản phẩm Flash Sale nào -->
                        <div style="grid-column: span 4; text-align: center; padding: 40px; color: #817872; font-size: 15px;">
                            <i class="fi fi-rr-box-open" style="font-size: 32px; display: block; margin-bottom: 10px; color: #F47721;"></i>
                            Hiện tại chưa có sản phẩm nào trong chương trình Flash Sale.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <%-- Nhúng Footer & Chat Widget chung --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <!-- Script xử lý Đồng hồ đếm ngược, Lọc Tab nhanh & Chat Modal -->
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // 1. Đồng hồ đếm ngược tới suất kết thúc sớm nhất (data-end-at của từng card)
                const now = Date.now();
                const ends = Array.from(document.querySelectorAll(".flash-card[data-end-at]"))
                        .map(c => new Date(c.dataset.endAt).getTime())
                        .filter(t => !isNaN(t) && t > now);
                let totalSeconds = ends.length ? Math.floor((Math.min(...ends) - now) / 1000) + 1 : 1;
                const hoursEl = document.getElementById("cd-hours");
                const minutesEl = document.getElementById("cd-minutes");
                const secondsEl = document.getElementById("cd-seconds");

                function updateCountdown() {
                    if (totalSeconds <= 0) return;
                    totalSeconds--;
                    const h = Math.floor(totalSeconds / 3600);
                    const m = Math.floor((totalSeconds % 3600) / 60);
                    const s = totalSeconds % 60;

                    if (hoursEl) hoursEl.textContent = String(h).padStart(2, '0');
                    if (minutesEl) minutesEl.textContent = String(m).padStart(2, '0');
                    if (secondsEl) secondsEl.textContent = String(s).padStart(2, '0');
                }
                updateCountdown();
                setInterval(updateCountdown, 1000);

                // 2. Chuyển đổi Tab lọc nhanh mượt mà ngay trên trang
                const tabs = document.querySelectorAll(".flash-tab");
                const cards = document.querySelectorAll(".flash-card");

                tabs.forEach(tab => {
                    tab.addEventListener("click", function (e) {
                        const filterType = this.getAttribute("data-filter");
                        if (!filterType) return;
                        e.preventDefault();

                        tabs.forEach(t => t.classList.remove("active"));
                        this.classList.add("active");

                        cards.forEach(card => {
                            const species = card.getAttribute("data-species");
                            const discount = parseInt(card.getAttribute("data-discount") || "0", 10);

                            if (filterType === "all") {
                                card.style.display = "flex";
                            } else if (filterType === "DOG" || filterType === "CAT") {
                                card.style.display = (species === filterType) ? "flex" : "none";
                            } else if (filterType === "DEEP") {
                                card.style.display = (discount >= 30) ? "flex" : "none";
                            }
                        });
                    });
                });

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