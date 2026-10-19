<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<c:set var="activePage" value="home" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trang chủ - PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/home.css">
    </head>

    <body>

        <%@ include file="/WEB-INF/views/common/_header.jspf" %>
        <!-- ================= HERO SLIDER 3 BANNER (FULL MÀN HÌNH) ================= -->
        <div class="hero-slider-container">
            <div class="slider-wrapper">
                <!-- Slide 1 -->
                <div class="slide active" style="background-image: url('${ctx}/images/banner1.jpg');">
                    <div class="slide-content">
                        <h1>Nuôi cún mèo khỏe re,<br>Sen chẳng cần lo nghĩ!</h1>
                        <p>Hệ thống dinh dưỡng và chăm sóc thú cưng cao cấp hàng đầu Việt Nam.</p>
                        <a href="${ctx}/products" class="slide-btn">Khám phá ngay &rarr;</a>
                    </div>
                </div>
                <!-- Slide 2 -->
                <div class="slide" style="background-image: url('${ctx}/images/banner2.jpg');">
                    <div class="slide-content">
                        <h1>Bữa ăn ngon chuẩn vị,<br>Bé mi nhon hết ý!</h1>
                        <p>Khám phá ngay hàng trăm sản phẩm hạt, pate và ăn vặt.</p>
                        <a href="${ctx}/products" class="slide-btn">Xem ưu đãi ngay &rarr;</a>
                    </div>
                </div>
                <!-- Slide 3 -->
                <div class="slide" style="background-image: url('${ctx}/images/banner3.jpg');">
                    <div class="slide-content">
                        <h1>Boss ăn ngon miệng,<br>Sen nhận ngàn yêu thương!</h1>
                        <p>Chăm sóc thú cưng từ những điều nhỏ nhất cùng các thương hiệu uy tín.</p>
                        <a href="${ctx}/products?species=DOG" class="slide-btn">Xem sản phẩm cho Chó &amp; Mèo &rarr;</a>
                    </div>
                </div>
            </div>
            <!-- Nút chuyển slide qua lại -->
            <button class="slider-btn prev" onclick="moveSlide(-1)">&#10094;</button>
            <button class="slider-btn next" onclick="moveSlide(1)">&#10095;</button>
        </div>

        <!-- HERO SECTION GỐC -->
        <section class="hero">
            <div class="pet-card dog-card">
                <div class="pet-card-content">
                    <div class="pet-title">
                        <div class="pet-icon"><i class="fi fi-rr-dog"></i></div>
                        <div>
                            <span>Dành cho</span>
                            <h1>Chó</h1>
                        </div>
                    </div>
                    <p>Thức ăn, pate, chăm sóc cho chú cún khỏe mạnh mỗi ngày.</p>
                    <a href="${ctx}/products?species=DOG" class="pet-button">
                        Khám phá ngay <span>&rarr;</span>
                    </a>
                </div>
                <img src="${ctx}/images/cho.png" alt="Chó cưng" class="pet-image dog-image">
            </div>

            <div class="pet-card cat-card">
                <div class="pet-card-content">
                    <div class="pet-title">
                        <div class="pet-icon"><i class="fi fi-rr-cat"></i></div>
                        <div>
                            <span>Dành cho</span>
                            <h1>Mèo</h1>
                        </div>
                    </div>
                    <p>Thức ăn, pate, chăm sóc cho bé mèo luôn lanh lợi và khỏe mạnh.</p>
                    <a href="${ctx}/products?species=CAT" class="pet-button">
                        Khám phá ngay <span>&rarr;</span>
                    </a>
                </div>
                <img src="${ctx}/images/meo.png" alt="Mèo cưng" class="pet-image cat-image">
            </div>
        </section>

        <!-- BENEFITS SECTION GỐC -->
        <section class="benefits">
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-shipping-fast"></i></div>
                <div>
                    <h3>Mua hàng tận nơi</h3>
                    <p>Giao hàng nhanh chóng</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-shield-check"></i></div>
                <div>
                    <h3>Sản phẩm chất lượng</h3>
                    <p>Nguồn gốc chính hãng</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-heart"></i></div>
                <div>
                    <h3>Chăm sóc tận tâm</h3>
                    <p>Hỗ trợ nhiệt tình</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-tags"></i></div>
                <div>
                    <h3>Giá cả cạnh tranh</h3>
                    <p>Nhiều ưu đãi hấp dẫn</p>
                </div>
            </div>
        </section>

        <!-- SẢN PHẨM BÁN CHẠY & MỚI VỀ -->
        <section class="product-section">
            <div class="section-header">
                <div>
                    <span class="section-label">THƯƠNG HIỆU UY TÍN</span>
                    <h2>Sản phẩm bán chạy &amp; Mới về</h2>
                    <p>Khám phá các dòng sản phẩm dinh dưỡng tốt nhất được lựa chọn nhiều nhất.</p>
                </div>
                <a href="${ctx}/products" class="view-all">Xem tất cả sản phẩm &rarr;</a>
            </div>

            <div class="product-grid">
                <c:forEach var="p" items="${featuredProducts}">
                    <div class="product-card">
                        <a href="${ctx}/products/${p.id}" class="product-image">
                            <c:choose>
                                <c:when test="${not empty p.imageUrl}">
                                    <img src="${ctx}${p.imageUrl}" alt="${p.name}">
                                </c:when>
                                <c:otherwise><span>Ảnh sản phẩm</span></c:otherwise>
                            </c:choose>
                        </a>
                        <div class="product-info">
                            <h3><a href="${ctx}/products/${p.id}">${p.name}</a></h3>
                            <p class="product-price"><fmt:formatNumber value="${p.price}" type="number"/> ₫</p>

                            <div class="stock-status ${p.inStock ? '' : 'out-of-stock'}">
                                <span class="stock-dot"></span>
                                <span>${p.inStock ? 'Còn hàng' : 'Hết hàng'}</span>
                            </div>

                            <%-- Staff/Admin không có giỏ hàng (/cart/** chỉ cho CUSTOMER); Guest bấm thì được đưa tới trang đăng nhập --%>
                            <c:choose>
                                <c:when test="${p.inStock and (currentUser == null or currentUser.role == 'CUSTOMER')}">
                                    <form action="${ctx}/cart/add" method="post">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="productId" value="${p.id}">
                                        <input type="hidden" name="quantity" value="1">
                                        <input type="hidden" name="returnUrl" value="/">
                                        <button type="submit" class="add-cart-btn">
                                            <i class="fi fi-rr-shopping-cart"></i> Thêm vào giỏ
                                        </button>
                                    </form>
                                </c:when>
                                <c:when test="${not p.inStock}">
                                    <button type="button" class="add-cart-btn" disabled style="background: #d5cbc5; cursor: not-allowed;">
                                        Hết hàng
                                    </button>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>

        <!-- CTA SECTION GỐC -->
        <section class="cta">
            <div class="cta-content">
                <span>PETFOOD</span>
                <h2>Chăm sóc thú cưng bằng những điều tốt nhất</h2>
                <p>Khám phá ngay hàng trăm sản phẩm dinh dưỡng cao cấp, phụ kiện và thức ăn phù hợp cho từng giai đoạn phát triển của thú cưng.</p>
                <a href="${ctx}/products" class="cta-button">Khám phá sản phẩm</a>
            </div>
        </section>

        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                // 1. Giữ nguyên code bật/tắt nút Chat cũ của bạn
                const toggleBtn = document.getElementById("chatToggleBtn");
                const closeBtn = document.getElementById("chatCloseBtn");
                const chatModal = document.getElementById("chatBoxModal");

                if (toggleBtn && chatModal && closeBtn) {
                    toggleBtn.addEventListener("click", () => chatModal.classList.toggle("active"));
                    closeBtn.addEventListener("click", () => chatModal.classList.remove("active"));
                }

                // 2. Đổi màu Header khi cuộn chuột xuống
                const header = document.querySelector(".header");
                window.addEventListener("scroll", function() {
                    if (window.scrollY > 50) {
                        header.classList.add("scrolled");
                    } else {
                        header.classList.remove("scrolled");
                    }
                });
            });

            // 3. Code mới: Chuyển đổi qua lại 3 ảnh Banner tự động
            let currentSlide = 0;
            function showSlide(index) {
                const slides = document.querySelectorAll(".slide");
                if (slides.length === 0) return;
                slides.forEach(slide => slide.classList.remove("active"));
                currentSlide = (index + slides.length) % slides.length;
                slides[currentSlide].classList.add("active");
            }

            function moveSlide(direction) {
                showSlide(currentSlide + direction);
            }

            // Tự động chạy sang ảnh tiếp theo mỗi 5 giây
            setInterval(() => {
                showSlide(currentSlide + 1);
            }, 5000);
        </script>
    </body>
</html>