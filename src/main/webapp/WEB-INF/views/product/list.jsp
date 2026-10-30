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
        <title>Trang chủ - PetFood Dinh Dưỡng Thú Cưng Cao Cấp</title>

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
                        <div class="slide-badge"><i class="fi fi-rr-sparkles"></i> Dinh Dưỡng Thú Cưng Hàng Đầu</div>
                        <h1>Nuôi cún mèo khỏe re,<br>Sen chẳng cần lo nghĩ!</h1>
                        <p>Hệ thống thức ăn và đồ ăn vặt thú cưng chính hãng hàng đầu Việt Nam. Cam kết date mới FEFO 90+ ngày.</p>
                        <a href="${ctx}/products" class="slide-btn">Khám phá ngay &rarr;</a>
                    </div>
                </div>
                <!-- Slide 2 -->
                <div class="slide" style="background-image: url('${ctx}/images/banner2.jpg');">
                    <div class="slide-content">
                        <div class="slide-badge"><i class="fi fi-rr-flame"></i> Ưu Đãi Giờ Vàng</div>
                        <h1>Bữa ăn ngon chuẩn vị,<br>Bé mi nhon hết ý!</h1>
                        <p>Khám phá ngay hàng trăm sản phẩm hạt, pate và ăn vặt chính hãng với chính sách đổi trả 3 ngày thảnh thơi.</p>
                        <a href="${ctx}/products" class="slide-btn">Xem ưu đãi ngay &rarr;</a>
                    </div>
                </div>
                <!-- Slide 3 -->
                <div class="slide" style="background-image: url('${ctx}/images/banner3.jpg');">
                    <div class="slide-content">
                        <div class="slide-badge"><i class="fi fi-rr-heart"></i> Yêu Thương Trọn Vẹn</div>
                        <h1>Boss ăn ngon miệng,<br>Sen nhận ngàn yêu thương!</h1>
                        <p>Chăm sóc thú cưng từ những điều nhỏ nhất cùng các thương hiệu uy tín hàng đầu quốc tế.</p>
                        <a href="${ctx}/products?species=DOG" class="slide-btn">Xem sản phẩm cho Chó &amp; Mèo &rarr;</a>
                    </div>
                </div>
            </div>
            <!-- Nút chuyển slide qua lại -->
            <button class="slider-btn prev" onclick="moveSlide(-1)" aria-label="Slide trước">&#10094;</button>
            <button class="slider-btn next" onclick="moveSlide(1)" aria-label="Slide sau">&#10095;</button>
        </div>

        <!-- HERO SECTION 3D: DOG & CAT -->
        <section class="hero">
            <div class="pet-card dog-card">
                <div class="pet-card-content">
                    <div class="pet-3d-badge">
                        <i class="fi fi-rr-bone"></i> Dành Riêng Cho Cún Cưng
                    </div>
                    <div class="pet-title">
                        <div class="pet-icon"><i class="fi fi-rr-dog"></i></div>
                        <div>
                            <span>Khám phá menu</span>
                            <h1>Chó Cưng</h1>
                        </div>
                    </div>
                    <p>Hạt dinh dưỡng, pate thượng hạng, snack gặm sạch răng và chăm sóc lông cho chú cún khỏe mạnh toàn diện.</p>
                    <a href="${ctx}/products?species=DOG" class="pet-button">
                        Khám phá ngay <span>&rarr;</span>
                    </a>
                </div>
                <img src="${ctx}/images/cho.png" alt="Chó cưng" class="pet-image dog-image">
            </div>

            <div class="pet-card cat-card">
                <div class="pet-card-content">
                    <div class="pet-3d-badge">
                        <i class="fi fi-rr-fish"></i> Dành Riêng Cho Hoàng Thượng
                    </div>
                    <div class="pet-title">
                        <div class="pet-icon"><i class="fi fi-rr-cat"></i></div>
                        <div>
                            <span>Khám phá menu</span>
                            <h1>Mèo Cưng</h1>
                        </div>
                    </div>
                    <p>Pate bổ sung nước, hạt ngừa búi lông, thức ăn chuyên dụng cho từng giống mèo luôn lanh lợi và mượt lông.</p>
                    <a href="${ctx}/products?species=CAT" class="pet-button">
                        Khám phá ngay <span>&rarr;</span>
                    </a>
                </div>
                <img src="${ctx}/images/meo.png" alt="Mèo cưng" class="pet-image cat-image">
            </div>
        </section>

        <!-- BENEFITS SECTION 3D: CAM KẾT VÀNG -->
        <section class="benefits">
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-shipping-fast"></i></div>
                <div>
                    <h3>Giao hỏa tốc 2 giờ</h3>
                    <p>Nhận ngay khi boss đói</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-shield-check"></i></div>
                <div>
                    <h3>100% Chính hãng</h3>
                    <p>Chuẩn FEFO date mới 90+ ngày</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-heart"></i></div>
                <div>
                    <h3>Chăm sóc tận tâm</h3>
                    <p>Tư vấn khẩu phần ăn 24/7</p>
                </div>
            </div>
            <div class="benefit-item">
                <div class="benefit-icon"><i class="fi fi-rr-tags"></i></div>
                <div>
                    <h3>Giá cả cạnh tranh</h3>
                    <p>Tích điểm đổi quà siêu hời</p>
                </div>
            </div>
        </section>

        <!-- FLASH SALE XẢ KHO CẬN DATE -->
        <c:if test="${not empty flashSaleOffers}">
            <section class="product-section flash-sale-section">
                <div class="section-header">
                    <div>
                        <span class="section-label flash-label">
                            <i class="fi fi-rr-flame"></i> GIỜ VÀNG GIÁ SỐC &bull; XẢ KHO CẬN DATE
                        </span>
                        <h2>Flash Sale Cận Date</h2>
                        <p>Số lượng có hạn &bull; Giảm sốc đến 70% &bull; Minh bạch HSD theo chuẩn FEFO.</p>
                    </div>
                    <a href="${ctx}/flash-sale" class="view-all flash-view-all">Xem tất cả Flash Sale &rarr;</a>
                </div>

                <div class="product-grid">
                    <c:forEach var="o" items="${flashSaleOffers}">
                        <c:if test="${o.remainingQty > 0}">
                            <article class="product-card flash-product-card" data-species="${o.species}" data-discount="${o.discountPercent}">
                                <a href="${ctx}/products/${o.productId}" class="product-card-link" title="<c:out value='${o.productName}'/>">
                                    <div class="product-image">
                                        <span class="flash-tag-discount">
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
                                            <span class="flash-sale-name" title="<c:out value='${o.saleName}'/>"><c:out value="${o.saleName}"/></span>
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
                                                <i class="fi fi-rr-bolt"></i> Mua giá Flash Sale
                                            </button>
                                        </form>
                                    </div>
                                </c:if>
                            </article>
                        </c:if>
                    </c:forEach>
                </div>
            </section>
        </c:if>

        <!-- SẢN PHẨM BÁN CHẠY & MỚI VỀ (3D PRODUCT SHOWCASE) -->
        <section class="product-section">
            <div class="section-header">
                <div>
                    <span class="section-label">THƯƠNG HIỆU UY TÍN &bull; DATE MỚI NHẤT</span>
                    <h2>Sản phẩm bán chạy &amp; Mới về</h2>
                    <p>Các dòng sản phẩm dinh dưỡng cao cấp đạt chuẩn FEFO, được hàng chục ngàn Sen tin chọn.</p>
                </div>
                <a href="${ctx}/products" class="view-all">Xem tất cả sản phẩm &rarr;</a>
            </div>

            <div class="product-grid">
                <c:forEach var="p" items="${featuredProducts}">
                    <article class="product-card ${p.inStock ? '' : 'out-of-stock'}">
                        <c:choose>
                            <c:when test="${p.inStock}">
                                <a href="${ctx}/products/${p.id}" class="product-card-link" title="<c:out value='${p.name}'/>">
                                    <div class="product-image">
                                        <span class="fefo-product-tag"><i class="fi fi-rr-calendar"></i> FEFO Date Mới</span>
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl}">
                                                <img src="${ctx}${p.imageUrl}" alt="<c:out value='${p.name}'/>" loading="lazy">
                                            </c:when>
                                            <c:otherwise><span class="no-img-text">Ảnh sản phẩm</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="product-info">
                                        <span class="product-card-brand"><c:out value="${empty p.brand ? 'PetFood Official' : p.brand}"/></span>
                                        <h3 class="product-card-title"><c:out value="${p.name}"/></h3>
                                        <div class="product-card-price-row">
                                            <span class="product-price"><fmt:formatNumber value="${p.price}" type="number"/> ₫</span>
                                            <span class="product-sold">Đã bán ${p.soldCount}</span>
                                        </div>
                                    </div>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <div class="product-card-disabled" title="Sản phẩm tạm hết hàng">
                                    <div class="product-image">
                                        <span class="badge-out-stock">Hết hàng</span>
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl}">
                                                <img src="${ctx}${p.imageUrl}" alt="<c:out value='${p.name}'/>" loading="lazy">
                                            </c:when>
                                            <c:otherwise><span class="no-img-text">Ảnh sản phẩm</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="product-info">
                                        <span class="product-card-brand"><c:out value="${empty p.brand ? 'PetFood Official' : p.brand}"/></span>
                                        <h3 class="product-card-title"><c:out value="${p.name}"/></h3>
                                        <div class="product-card-price-row">
                                            <span class="product-price"><fmt:formatNumber value="${p.price}" type="number"/> ₫</span>
                                            <span class="product-sold">Đã bán ${p.soldCount}</span>
                                        </div>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </article>
                </c:forEach>
            </div>
        </section>

        <!-- ================= KHỐI NỐI LIỀN MÀU KEM HỒNG: CHÍNH SÁCH ĐỔI TRẢ 3 NGÀY - AN TÂM MUA HÀNG ================= -->
        <section class="fefo-return-banner">
            <div class="fefo-banner-header">
                <span class="fefo-badge-pill">
                    <i class="fi fi-rr-badge-check"></i> AN TÂM MUA SẮM TUYỆT ĐỐI
                </span>
                <h2>Chính sách đổi trả trong vòng 3 ngày - An tâm mua hàng</h2>
                <p>Tại PetFood, sự hài lòng và sức khỏe của thú cưng là ưu tiên hàng đầu. Chúng tôi thiết lập tiêu chuẩn dịch vụ khắt khe nhất để Sen hoàn toàn yên tâm trong từng đơn hàng.</p>
            </div>

            <div class="fefo-cards-grid">
                <!-- Cột 1: Đổi trả 3 ngày -->
                <div class="fefo-card">
                    <div class="fefo-card-icon"><i class="fi fi-rr-rotate-right"></i></div>
                    <h4>Đổi trả 3 ngày thảnh thơi</h4>
                    <p>Bé không hợp khẩu vị hoặc bao bì có tì vết? Hỗ trợ đổi mới hoặc hoàn tiền ngay trong 3 ngày, thủ tục tinh gọn 100% online.</p>
                </div>

                <!-- Cột 2: Chuẩn Date mới FEFO -->
                <div class="fefo-card">
                    <div class="fefo-card-icon"><i class="fi fi-rr-calendar-check"></i></div>
                    <h4>Chuẩn FEFO Date mới</h4>
                    <p>Kiểm soát kho thông minh First-Expired-First-Out. Luôn cam kết hạn dùng xa trên 90 ngày, đảm bảo dinh dưỡng và mùi vị vẹn nguyên.</p>
                </div>

                <!-- Cột 3: Giao hỏa tốc 2 giờ -->
                <div class="fefo-card">
                    <div class="fefo-card-icon"><i class="fi fi-rr-box-alt"></i></div>
                    <h4>Đóng gói 3 lớp bảo quản</h4>
                    <p>Hàng hóa được bọc chống sốc và túi hút ẩm chuyên dụng, giữ hạt giòn tan và pate tươi ngon suốt hành trình vận chuyển.</p>
                </div>

                <!-- Cột 4: Tư vấn khẩu phần dinh dưỡng -->
                <div class="fefo-card">
                    <div class="fefo-card-icon"><i class="fi fi-rr-heart"></i></div>
                    <h4>Tư vấn khẩu phần tận tâm</h4>
                    <p>Hỗ trợ lựa chọn thức ăn hạt, pate và đồ ăn vặt chuẩn khẩu vị, độ tuổi và thể trạng cho từng boss, chăm sóc bữa ăn ngon miệng mỗi ngày.</p>
                </div>
            </div>
        </section>

        <!-- ================= MỤC CUỘN MỚI 1: DINH DƯỠNG THEO TỪNG GIAI ĐOẠN PHÁT TRIỂN (3D) ================= -->
        <section class="life-stage-section">
            <div class="section-header">
                <div>
                    <span class="section-label">CHẾ ĐỘ DINH DƯỠNG KHOA HỌC</span>
                    <h2>Chọn thức ăn chuẩn theo từng giai đoạn</h2>
                    <p>Mỗi lứa tuổi của Boss cần một công thức dinh dưỡng chuyên biệt để phát triển thể chất tối ưu.</p>
                </div>
            </div>

            <div class="life-stage-grid">
                <!-- Giai đoạn 1: Puppy & Kitten -->
                <div class="stage-card">
                    <div class="stage-top">
                        <span class="stage-badge"><i class="fi fi-rr-sparkles"></i> Bé Con Khởi Đầu</span>
                        <span class="stage-age">0 - 12 Tháng</span>
                    </div>
                    <h3>Puppy &amp; Kitten Khỏe Mạnh</h3>
                    <p>Giai đoạn vàng hình thành khung xương, phát triển trí não và thiết lập hệ miễn dịch non nớt.</p>
                    <ul class="stage-features">
                        <li><i class="fi fi-rr-check"></i> Hàm lượng Protein cao &gt; 32% từ thịt thật</li>
                        <li><i class="fi fi-rr-check"></i> Bổ sung DHA phát triển não bộ và thị lực</li>
                        <li><i class="fi fi-rr-check"></i> Canxi và Phốt-pho cân bằng cho xương răng chắc</li>
                    </ul>
                    <a href="${ctx}/products" class="stage-btn">Xem sản phẩm cho thú con &rarr;</a>
                </div>

                <!-- Giai đoạn 2: Trưởng thành -->
                <div class="stage-card">
                    <div class="stage-top">
                        <span class="stage-badge"><i class="fi fi-rr-bolt"></i> Năng Lượng Đỉnh Cao</span>
                        <span class="stage-age">1 - 7 Tuổi</span>
                    </div>
                    <h3>Thú Cưng Trưởng Thành</h3>
                    <p>Duy trì cơ bắp săn chắc, giữ bộ lông bóng mượt và hỗ trợ hệ tiêu hóa luôn ổn định tràn đầy năng lượng.</p>
                    <ul class="stage-features">
                        <li><i class="fi fi-rr-check"></i> Tỷ lệ năng lượng cân đối, chống béo phì</li>
                        <li><i class="fi fi-rr-check"></i> Omega 3 &amp; 6 nuôi dưỡng da và lông óng mượt</li>
                        <li><i class="fi fi-rr-check"></i> Men vi sinh Probiotics bảo vệ đường ruột</li>
                    </ul>
                    <a href="${ctx}/products" class="stage-btn">Xem sản phẩm trưởng thành &rarr;</a>
                </div>

                <!-- Giai đoạn 3: Cao tuổi -->
                <div class="stage-card">
                    <div class="stage-top">
                        <span class="stage-badge"><i class="fi fi-rr-shield-check"></i> Bảo Vệ Tuổi Vàng</span>
                        <span class="stage-age">7+ Tuổi</span>
                    </div>
                    <h3>Chăm Sóc Boss Cao Tuổi</h3>
                    <p>Công thức dịu nhẹ, hỗ trợ chức năng xương khớp, thận và tim mạch cho thú cưng bước vào độ tuổi xế chiều.</p>
                    <ul class="stage-features">
                        <li><i class="fi fi-rr-check"></i> Glucosamine &amp; Chondroitin tái tạo sụn khớp</li>
                        <li><i class="fi fi-rr-check"></i> Kiểm soát Natri và Phốt-pho bảo vệ thận</li>
                        <li><i class="fi fi-rr-check"></i> Hạt giòn xốp mềm, dễ nhai và dễ tiêu hóa</li>
                    </ul>
                    <a href="${ctx}/products" class="stage-btn">Xem sản phẩm chăm sóc khớp &rarr;</a>
                </div>
            </div>
        </section>

        <!-- ================= MỤC CUỘN MỚI 2: ĐÁNH GIÁ TỪ HỘI SEN (3D TESTIMONIALS) ================= -->
        <section class="testimonials-section">
            <div class="section-header">
                <div>
                    <span class="section-label">HỘI SEN TIN CHỌN</span>
                    <h2>Trải nghiệm thực tế từ khách hàng</h2>
                    <p>Hơn 25.000+ Sen trên khắp cả nước đã tin tưởng và an tâm mua sắm tại PetFood.</p>
                </div>
            </div>

            <div class="testimonials-grid">
                <!-- Review 1 -->
                <div class="testimonial-card">
                    <div class="testimonial-stars">
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                    </div>
                    <p class="testimonial-quote">
                        "Bé Poodle nhà mình kén ăn hạt kinh khủng. Được bạn tư vấn bên PetFood hướng dẫn trộn hạt với pate theo tỷ lệ chuẩn, giờ bé ăn sạch bát! Giao hàng siêu nhanh, date xa tít tắp đến tận năm sau."
                    </p>
                    <div class="testimonial-author">
                        <div class="author-avatar"><i class="fi fi-rr-dog"></i></div>
                        <div class="author-info">
                            <h5>Chị Minh Anh</h5>
                            <span>Sen của bé Bơ &amp; Miu (Hà Nội)</span>
                            <div class="verified-tag"><i class="fi fi-rr-badge-check"></i> Đã mua hàng</div>
                        </div>
                    </div>
                </div>

                <!-- Review 2 -->
                <div class="testimonial-card">
                    <div class="testimonial-stars">
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                    </div>
                    <p class="testimonial-quote">
                        "Chính sách đổi trả trong vòng 3 ngày làm mình cực kỳ an tâm. Có đợt đặt nhầm vị cho bé mèo, nhắn tin qua chatbox được các bạn hỗ trợ đổi vị cá hồi ngay trong ngày. Đóng gói rất cẩn thận!"
                    </p>
                    <div class="testimonial-author">
                        <div class="author-avatar"><i class="fi fi-rr-cat"></i></div>
                        <div class="author-info">
                            <h5>Anh Hoàng Long</h5>
                            <span>Sen của bé Mèo Mun (Đà Nẵng)</span>
                            <div class="verified-tag"><i class="fi fi-rr-badge-check"></i> Đã mua hàng</div>
                        </div>
                    </div>
                </div>

                <!-- Review 3 -->
                <div class="testimonial-card">
                    <div class="testimonial-stars">
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                        <i class="fi fi-rr-star"></i>
                    </div>
                    <p class="testimonial-quote">
                        "Biết PetFood áp dụng chuẩn kho FEFO nên mình toàn mua thùng về cho bé Corgi ăn dần. Date thức ăn luôn mới toanh, túi zip chắc chắn thơm phức. 10 điểm cho chất lượng và độ tận tâm!"
                    </p>
                    <div class="testimonial-author">
                        <div class="author-avatar"><i class="fi fi-rr-heart"></i></div>
                        <div class="author-info">
                            <h5>Bạn Thảo Vy</h5>
                            <span>Sen của bé Bắp (TP. Hồ Chí Minh)</span>
                            <div class="verified-tag"><i class="fi fi-rr-badge-check"></i> Đã mua hàng</div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA SECTION 3D: CHĂM SÓC THÚ CƯNG TOÀN DIỆN -->
        <section class="cta">
            <div class="cta-content">
                <span>PETFOOD &bull; AN TÂM DINH DƯỠNG</span>
                <h2>Chăm sóc thú cưng bằng những điều tốt nhất</h2>
                <p>Khám phá ngay hàng trăm sản phẩm dinh dưỡng cao cấp, hạt chuẩn date FEFO và phụ kiện chính hãng giúp Boss phát triển khỏe mạnh mỗi ngày.</p>
                <a href="${ctx}/products" class="cta-button">Khám phá sản phẩm ngay &rarr;</a>
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

            // 3. Chuyển đổi qua lại 3 ảnh Banner tự động
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
