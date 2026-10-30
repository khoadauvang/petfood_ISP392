<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="products" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><c:out value="${product.name}"/> · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <!-- CSS chung của hệ thống (Header/Footer) và CSS riêng của trang Chi tiết -->
        <link rel="stylesheet" href="${ctx}/css/detail.css?v=3">
    </head>
    <body>

        <%-- 1. HEADER CHUNG CỦA HỆ THỐNG --%>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <main class="detail-page-wrapper">

            <!-- 2. BREADCRUMB ĐỒNG BỘ VỚI TRANG PRODUCTS.JSP -->
            <nav class="breadcrumb" aria-label="Breadcrumb">
                <a href="${ctx}/" class="breadcrumb-home">
                    <i class="fi fi-rr-home"></i>
                    <span>Trang chủ</span>
                </a>
                <span class="breadcrumb-separator">/</span>
                <a href="${ctx}/products">
                    <span>Sản phẩm</span>
                </a>
                <span class="breadcrumb-separator">/</span>
                <a href="${ctx}/products?categoryId=${product.categoryId}">
                    <span><c:out value="${product.categoryName}"/></span>
                </a>
                <span class="breadcrumb-separator">/</span>
                <span class="breadcrumb-current"><c:out value="${product.name}"/></span>
            </nav>

            <!-- 3. KHUNG CHÍNH: ẢNH GALLERY TRÁI & THÔNG TIN MUA HÀNG PHẢI -->
            <div class="detail-main-card">

                <!-- CỘT TRÁI: HÌNH ẢNH SẢN PHẨM -->
                <section class="detail-gallery">
                    <div class="main-img-box">
                        <span class="gallery-floating-tag"><i class="fi fi-rr-badge-check"></i> CHÍNH HÃNG</span>
                        <c:choose>
                            <c:when test="${not empty product.imageUrls}">
                                <img id="mainImage" src="${ctx}<c:out value='${product.imageUrls[0]}'/>" alt="<c:out value='${product.name}'/>">
                            </c:when>
                            <c:otherwise>
                                <div class="no-img-placeholder">Chưa có ảnh sản phẩm</div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:if test="${not empty product.imageUrls and product.imageUrls.size() > 1}">
                        <div class="thumb-row">
                            <c:forEach var="url" items="${product.imageUrls}" varStatus="loop">
                                <div class="thumb-box ${loop.index == 0 ? 'active' : ''}" onclick="switchMainImg(this, '${ctx}<c:out value="${url}"/>')">
                                    <img src="${ctx}<c:out value='${url}'/>" alt="Ảnh ${loop.index + 1}">
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>

                    <div class="fefo-gallery-note">
                        <i class="fi fi-rr-boxes"></i>
                        <span>Kho vận hành theo quy chuẩn <strong>FEFO (First-Expired, First-Out)</strong> tự động xuất lô có hạn sử dụng đảm bảo chuẩn châu Âu.</span>
                    </div>
                </section>

                <!-- CỘT PHẢI: THÔNG TIN CHI TIẾT & NÚT THÊM GIỎ / MUA NGAY -->
                <section class="detail-info-col">

                    <div class="info-top-meta">
                        <div class="brand-sku-line">
                            <span><c:out value="${empty product.brand ? 'PETFOOD OFFICIAL' : product.brand}"/></span>
                            <span class="sku-code">· SKU: <c:out value="${product.sku}"/></span>
                        </div>

                        <%-- HIỂN THỊ RÕ TRẠNG THÁI TỒN KHO --%>
                        <c:choose>
                            <c:when test="${product.inStock}">
                                <span class="stock-pill in-stock">
                                    <i class="fi fi-rr-check-circle"></i> Còn hàng
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="stock-pill out-stock">
                                    <i class="fi fi-rr-cross-circle"></i> Tạm hết hàng
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h1 class="detail-product-title"><c:out value="${product.name}"/></h1>

                    <div class="detail-rating-bar">
                        <span class="rating-badge">
                            <i class="fi fi-br-star"></i>
                            <c:out value="${reviewSummary.count > 0 ? reviewSummary.averageText : '5.0'}"/>
                        </span>
                        <span>(<c:out value="${reviewSummary.count}"/> đánh giá thực tế)</span>
                        <span>· Danh mục: <strong><c:out value="${product.categoryName}"/></strong></span>
                    </div>

                    <!-- GIÁ BÁN -->
                    <div class="detail-price-box">
                        <span class="main-price-val"><fmt:formatNumber value="${product.price}" type="number"/> ₫</span>
                        <span class="price-sub-note">Giá đã bao gồm thuế VAT. Miễn phí vận chuyển nội thành cho đơn từ 150.000đ.</span>
                    </div>

                    <%-- PHẦN CHỌN BIẾN THỂ / QUY CÁCH SẢN PHẨM (TRÊN SỐ LƯỢNG) --%>
                    <c:if test="${not empty variants and variants.size() > 1}">
                        <div class="product-variants-wrapper">
                            <span class="variant-field-label">Quy cách / Biến thể:</span>
                            <div class="variant-options-list">
                                <c:forEach var="v" items="${variants}">
                                    <a href="${ctx}/products/${v.id}"
                                       class="variant-pill-btn ${v.id == product.id ? 'active' : ''} ${v.sellableQty <= 0 ? 'out-of-stock' : ''}"
                                       title="<c:out value='${not empty v.spec ? v.spec : v.name}'/> - <fmt:formatNumber value='${v.sellingPrice}' type='number'/> ₫">
                                        <span class="variant-text"><c:out value="${not empty v.spec ? v.spec : v.name}"/></span>
                                        <c:if test="${v.sellableQty <= 0}">
                                            <span class="variant-out-badge">Hết hàng</span>
                                        </c:if>
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <!-- BỘ NÚT MUA HÀNG: HÀNG 1 LÀ SỐ LƯỢNG + TỒN KHO KHẢ DỤNG; HÀNG 2 LÀ MUA NGAY & THÊM GIỎ -->
                    <div class="purchase-action-area">
                        <c:if test="${product.inStock}">
                            <c:choose>
                                <c:when test="${currentUser != null and currentUser.role == 'CUSTOMER'}">
                                    <form method="post" action="${ctx}/cart/add" id="detailAddCartForm">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="productId" value="${product.id}">
                                        <input type="hidden" name="returnUrl" id="detailReturnUrl" value="${pageContext.request.requestURI}">
                                        <input type="hidden" name="buyNow" id="detailBuyNow" value="false">

                                        <%-- HÀNG 1: Nút số lượng + Tồn kho khả dụng kế bên --%>
                                        <div class="qty-and-stock-row">
                                            <div class="qty-stepper-wrap">
                                                <span class="qty-field-label">Số lượng:</span>
                                                <div class="detail-qty-stepper">
                                                    <button type="button" class="stepper-btn" onclick="changeDetailQty(-1)">&minus;</button>
                                                    <input type="number"
                                                           id="detailQtyInput"
                                                           name="quantity"
                                                           value="1"
                                                           min="1"
                                                           max="${product.sellableQty}"
                                                           class="stepper-input"
                                                           required>
                                                    <button type="button" class="stepper-btn" onclick="changeDetailQty(1)">&plus;</button>
                                                </div>
                                            </div>
                                            <div class="avail-stock-pill">
                                                <span>Tồn kho khả dụng: <strong>${product.sellableQty} sản phẩm</strong></span>
                                            </div>
                                        </div>

                                        <%-- HÀNG 2: Mua ngay và Thêm vào giỏ hàng chuyển xuống dưới --%>
                                        <div class="purchase-buttons-row">
                                            <button type="button" class="btn-add-to-cart" onclick="addToCartFly(this)">
                                                <i class="fi fi-rr-shopping-cart-add"></i> Thêm vào giỏ hàng
                                            </button>
                                            <button type="submit" class="btn-buy-now" onclick="return setBuyMode(true)">
                                                Mua ngay
                                            </button>
                                        </div>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <%-- Khi chưa đăng nhập (hoặc không phải CUSTOMER): vẫn hiển thị đầy đủ Stepper số lượng + Tồn kho + 2 nút Mua hàng & Thêm giỏ --%>
                                    <div class="qty-and-stock-row">
                                        <div class="qty-stepper-wrap">
                                            <span class="qty-field-label">Số lượng:</span>
                                            <div class="detail-qty-stepper">
                                                <button type="button" class="stepper-btn" onclick="changeDetailQty(-1)">&minus;</button>
                                                <input type="number"
                                                       id="detailQtyInput"
                                                       name="quantity"
                                                       value="1"
                                                       min="1"
                                                       max="${product.sellableQty}"
                                                       class="stepper-input">
                                                <button type="button" class="stepper-btn" onclick="changeDetailQty(1)">&plus;</button>
                                            </div>
                                        </div>
                                        <div class="avail-stock-pill">
                                            <span>Tồn kho khả dụng: <strong>${product.sellableQty} sản phẩm</strong></span>
                                        </div>
                                    </div>

                                    <%-- Khi chưa đăng nhập bấm vào 1 trong 2 nút thì chuyển hướng sang trang đăng nhập --%>
                                    <div class="purchase-buttons-row">
                                        <button type="button" class="btn-add-to-cart" onclick="redirectToLogin()">
                                            <i class="fi fi-rr-shopping-cart-add"></i> Thêm vào giỏ hàng
                                        </button>
                                        <button type="button" class="btn-buy-now" onclick="redirectToLogin()">
                                            Mua ngay
                                        </button>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>

                </section>
            </div>

            <!-- 4. CHƯƠNG TRÌNH KHUYẾN MÃI & FLASH SALE ĐANG CHẠY CỦA SẢN PHẨM NÀY (BR-65) -->
            <c:if test="${not empty flashSaleOffers}">
                <section class="detail-section-card flash-offer-card">
                    <h2><i class="fi fi-rr-flame"></i> Suất Chương trình &amp; Flash Sale đang mở bán cho sản phẩm này</h2>
                    <c:forEach var="o" items="${flashSaleOffers}">
                        <div class="flash-offer-item">
                            <div>
                                <span style="display:inline-block; padding:2px 8px; border-radius:99px; font-size:11px; font-weight:700; margin-right:6px; background:${o.promotion ? '#e0f2fe' : '#fee2e2'}; color:${o.promotion ? '#0369a1' : '#b91c1c'};">
                                    ${o.promotion ? 'Chương trình' : 'Flash Sale'}
                                </span>
                                <span class="flash-offer-price"><fmt:formatNumber value="${o.salePrice}" type="number"/> ₫</span>
                                <span class="flash-offer-meta">
                                    (Giảm −${o.discountPercent}%) · HSD lô: <strong>${o.expiryText}</strong>
                                    <span style="display:inline-block; padding:2px 8px; border-radius:99px; font-size:11px; font-weight:700; background:${o.daysLeft >= 90 ? '#e6f9ed' : '#fee2e2'}; color:${o.daysLeft >= 90 ? '#166534' : '#b91c1c'};">còn ${o.daysLeft} ngày</span>
                                    · Còn <strong>${o.remainingQty}</strong> suất · Kết thúc: ${o.endText}
                                </span>
                            </div>
                            <c:if test="${empty currentUser or currentUser.role == 'CUSTOMER'}">
                                <form method="post" action="${ctx}/cart/add" class="flash-inline-form" onsubmit="return requireLogin()">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="flashSaleItemId" value="${o.flashSaleItemId}">
                                    <input type="number" name="quantity" value="1" min="1" max="${o.remainingQty}" class="flash-qty-input" required>
                                    <button type="submit" class="btn-add-to-cart" style="height: 38px; padding: 0 18px; font-size: 13px;">
                                        <i class="fi fi-rr-bolt"></i> ${o.promotion ? 'Mua giá Chương trình' : 'Mua giá Flash Sale'}
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </c:forEach>
                </section>
            </c:if>

            <!-- 5. MÔ TẢ SẢN PHẨM & BẢNG THÔNG SỐ KỸ THUẬT -->
            <div class="desc-specs-grid">
                <section class="detail-section-card" style="margin-bottom: 0;">
                    <h2><i class="fi fi-rr-document"></i> Mô tả chi tiết sản phẩm</h2>
                    <c:choose>
                        <c:when test="${not empty product.description}">
                            <div class="product-desc-text"><c:out value="${product.description}"/></div>
                        </c:when>
                        <c:otherwise>
                            <p class="product-desc-text">Sản phẩm dinh dưỡng chính hãng được tuyển chọn kỹ lưỡng, đảm bảo đầy đủ dưỡng chất thiết yếu và an toàn tiêu hóa cho thú cưng của bạn.</p>
                        </c:otherwise>
                    </c:choose>
                </section>

                <section class="detail-section-card" style="margin-bottom: 0;">
                    <h2><i class="fi fi-rr-list-check"></i> Thông số kỹ thuật</h2>
                    <table class="specs-table">
                        <tr>
                            <td>Thương hiệu</td>
                            <td><c:out value="${empty product.brand ? '—' : product.brand}"/></td>
                        </tr>
                        <tr>
                            <td>Danh mục</td>
                            <td><c:out value="${product.categoryName}"/></td>
                        </tr>
                        <tr>
                            <td>Thú cưng phù hợp</td>
                            <td>${product.speciesLabel}</td>
                        </tr>
                        <tr>
                            <td>Độ tuổi khuyên dùng</td>
                            <td>${product.ageGroupLabel}</td>
                        </tr>
                        <tr>
                            <td>Cam kết hạn dùng</td>
                            <td>Tối thiểu ${shelfLifeDays} ngày</td>
                        </tr>
                    </table>
                </section>
            </div>

            <!-- 5. ĐÁNH GIÁ CỦA KHÁCH HÀNG (MODULE 8) -->
            <section class="detail-section-card">
                <h2>
                    <i class="fi fi-rr-comment-alt"></i> Đánh giá từ khách hàng
                    <c:if test="${reviewSummary.count > 0}">
                        · <span style="color: #F47721;">${reviewSummary.averageText}/5 ★</span> (${reviewSummary.count} đánh giá)
                    </c:if>
                </h2>

                <c:if test="${reviewSummary.count == 0}">
                    <p style="color: #817872; font-size: 14px; margin: 0;">Chưa có đánh giá nào cho sản phẩm này.</p>
                </c:if>

                <c:forEach var="r" items="${reviewSummary.reviews}">
                    <div class="review-item">
                        <div>
                            <span class="review-stars"><c:forEach begin="1" end="${r.rating}">★</c:forEach></span>
                            <strong><c:out value="${r.title}"/></strong>
                            <span class="review-meta">· <c:out value="${r.customerName}"/> · ${r.createdAtText}</span>
                        </div>
                        <c:if test="${not empty r.content}">
                            <div class="review-body"><c:out value="${r.content}"/></div>
                        </c:if>
                        <c:if test="${not empty r.replyContent}">
                            <div class="shop-reply-box">
                                <strong>Phản hồi từ PetFood:</strong> <c:out value="${r.replyContent}"/>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </section>

            <!-- 6. MỤC ĐỀ XUẤT CÁC SẢN PHẨM CÙNG DANH MỤC (KHOẢNG 3 DÒNG) - ĐỒNG BỘ CARD PRODUCT -->
            <c:if test="${not empty relatedProducts}">
                <section class="related-products-section">
                    <div class="related-section-header">
                        <div class="related-title-group">
                            <span class="related-sub-badge"><i class="fi fi-rr-sparkles"></i> Gợi ý dành riêng cho bạn</span>
                            
                        </div>
                        <a href="${ctx}/products?categoryId=${product.categoryId}" class="btn-view-all-top">
                            Xem tất cả (${product.categoryName}) <i class="fi fi-rr-arrow-right"></i>
                        </a>
                    </div>

                    <!-- LƯỚI SẢN PHẨM: 3 DÒNG X 4 SẢN PHẨM = 12 SẢN PHẨM -->
                    <div class="related-products-grid">
                        <c:forEach var="rp" items="${relatedProducts}">
                            <article class="product-card ${rp.inStock ? '' : 'out-of-stock'}">
                                <c:choose>
                                    <c:when test="${rp.inStock}">
                                        <a href="${ctx}/products/${rp.id}" class="product-card-link" title="<c:out value='${rp.name}'/>">
                                            <div class="product-image">
                                                <c:choose>
                                                    <c:when test="${not empty rp.imageUrl}">
                                                        <img src="${ctx}<c:out value='${rp.imageUrl}'/>" 
                                                             alt="<c:out value='${rp.name}'/>" 
                                                             loading="lazy"
                                                             onerror="this.src='https://via.placeholder.com/220x220/fff4df/f47721?text=PetFood'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="no-img-text">Chưa có ảnh</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="product-info">
                                                <span class="product-card-brand"><c:out value="${empty rp.brand ? 'PetFood Official' : rp.brand}"/></span>
                                                <h3 class="product-card-title"><c:out value="${rp.name}"/></h3>
                                                <div class="product-card-price-row">
                                                    <span class="product-price">
                                                        <fmt:formatNumber value="${rp.price}" type="number"/> ₫
                                                    </span>
                                                    <span class="product-sold">Đã bán ${rp.soldCount}</span>
                                                </div>
                                            </div>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="product-card-disabled" title="Sản phẩm tạm hết hàng">
                                            <div class="product-image">
                                                <span class="badge-out-stock">Hết hàng</span>
                                                <c:choose>
                                                    <c:when test="${not empty rp.imageUrl}">
                                                        <img src="${ctx}<c:out value='${rp.imageUrl}'/>" 
                                                             alt="<c:out value='${rp.name}'/>" 
                                                             loading="lazy"
                                                             onerror="this.src='https://via.placeholder.com/220x220/fff4df/f47721?text=PetFood'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="no-img-text">Chưa có ảnh</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="product-info">
                                                <span class="product-card-brand"><c:out value="${empty rp.brand ? 'PetFood Official' : rp.brand}"/></span>
                                                <h3 class="product-card-title"><c:out value="${rp.name}"/></h3>
                                                <div class="product-card-price-row">
                                                    <span class="product-price">
                                                        <fmt:formatNumber value="${rp.price}" type="number"/> ₫
                                                    </span>
                                                    <span class="product-sold">Đã bán ${rp.soldCount}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </article>
                        </c:forEach>
                    </div>

                    <!-- NÚT XEM THÊM LỚN Ở CUỐI TRANG -->
                    <div class="related-bottom-more">
                        <a href="${ctx}/products?categoryId=${product.categoryId}" class="btn-see-more-large">
                            <span>Khám phá thêm sản phẩm </span>
                            <i class="fi fi-rr-arrow-right"></i>
                        </a>
                    </div>
                </section>
            </c:if>

        </main>

        <!-- JAVASCRIPT ĐỔI ẢNH, TĂNG GIẢM SỐ LƯỢNG & HIỆU ỨNG BAY VÀO GIỎ HÀNG -->
        <script>
            function switchMainImg(thumbEl, imgUrl) {
                const mainImg = document.getElementById('mainImage');
                if (mainImg) {
                    mainImg.src = imgUrl;
                }
                document.querySelectorAll('.thumb-box').forEach(el => el.classList.remove('active'));
                if (thumbEl) {
                    thumbEl.classList.add('active');
                }
            }

            function changeDetailQty(delta) {
                const input = document.getElementById('detailQtyInput');
                if (!input)
                    return;
                const max = parseInt(input.getAttribute('max'), 10) || 999;
                let val = parseInt(input.value, 10) || 1;
                val += delta;
                if (val < 1)
                    val = 1;
                if (val > max)
                    val = max;
                input.value = val;
            }

            function redirectToLogin() {
                window.location.href = '${ctx}/login';
            }

            // Guest: chưa có giỏ -> sang đăng nhập, xong quay lại đúng trang sản phẩm này (RoleBasedLoginSuccessHandler)
            const IS_GUEST = ${empty currentUser};
            const LOGIN_URL = '${ctx}/login?redirect=' + encodeURIComponent('/products/${product.id}');

            function requireLogin() {
                if (IS_GUEST) {
                    window.location.href = LOGIN_URL;
                    return false;
                }
                return true;
            }

            // "Mua ngay": thêm vào giỏ rồi sang thẳng trang đặt hàng chỉ với sản phẩm này (CartController, buyNow)
            function setBuyMode(isBuyNow) {
                if (!requireLogin())
                    return false;
                const buyNowInput = document.getElementById('detailBuyNow');
                if (buyNowInput)
                    buyNowInput.value = isBuyNow ? 'true' : 'false';
                return true;
            }

            // Số trên icon giỏ ở header = tổng số lượng trong giỏ (cartItemCount do BE trả về, giống CartCountAdvice)
            function updateCartBadge(cartIcon, cartItemCount) {
                if (!cartIcon)
                    return;
                let badge = cartIcon.querySelector('.cart-badge');
                if (!badge) {
                    badge = document.createElement('span');
                    badge.className = 'cart-badge';
                    cartIcon.appendChild(badge);
                }
                badge.textContent = cartItemCount;
                cartIcon.style.transition = 'transform 0.25s ease';
                cartIcon.style.transform = 'scale(1.35)';
                setTimeout(() => {
                    cartIcon.style.transform = 'scale(1)';
                }, 250);
            }

            // HÀM THÊM VÀO GIỎ NGẦM + HIỆU ỨNG BAY LÊN ICON GIỎ HÀNG TRÊN HEADER
            function addToCartFly(btnEl) {
                const form = document.getElementById('detailAddCartForm');
                if (!form || !requireLogin())
                    return;

                // 1. Gửi ngầm lên /cart/add (X-Requested-With -> BE trả JSON {ok, message, cartItemCount}),
                //    chỉ chạy hiệu ứng khi BE báo thêm được; lỗi (vượt tồn...) thì báo đúng lý do
                const formData = new URLSearchParams(new FormData(form));
                fetch(form.action, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: formData.toString()
                })
                        .then(response => {
                            // phiên hết hạn: Spring Security trả trang đăng nhập (HTML) thay vì JSON
                            if (!(response.headers.get('Content-Type') || '').includes('application/json')) {
                                window.location.href = LOGIN_URL;
                                return null;
                            }
                            return response.json();
                        })
                        .then(data => {
                            if (!data)
                                return;
                            if (data.ok) {
                                playAddedEffect(btnEl, data.cartItemCount);
                            } else {
                                alert(data.message);
                            }
                        })
                        .catch(err => console.error(err));
            }

            // Hiệu ứng ảnh bay lên icon giỏ + đổi chữ nút (chỉ khi BE đã thêm thành công)
            function playAddedEffect(btnEl, cartItemCount) {

                // 2. Tìm ảnh sản phẩm và icon giỏ hàng trên thanh Header
                const sourceImg = document.getElementById('mainImage');
                const cartIcon = document.querySelector('.header-cart, .header-icons a[href*="/cart"], .header a[href*="/cart"]');

                if (sourceImg && cartIcon) {
                    const imgRect = sourceImg.getBoundingClientRect();
                    const cartRect = cartIcon.getBoundingClientRect();

                    // Tạo bản sao thu nhỏ của ảnh sản phẩm để bay lên giỏ
                    const flyImg = sourceImg.cloneNode(true);
                    Object.assign(flyImg.style, {
                        position: 'fixed',
                        left: (imgRect.left + imgRect.width / 2 - 35) + 'px',
                        top: (imgRect.top + imgRect.height / 2 - 35) + 'px',
                        width: '70px',
                        height: '70px',
                        objectFit: 'contain',
                        background: '#FFFFFF',
                        borderRadius: '50%',
                        border: '2px solid #F47721',
                        boxShadow: '0 8px 24px rgba(244, 119, 33, 0.45)',
                        zIndex: '9999',
                        pointerEvents: 'none',
                        transition: 'all 0.75s cubic-bezier(0.2, 0.8, 0.2, 1)'
                    });
                    document.body.appendChild(flyImg);

                    // Kích hoạt đường bay về đúng tọa độ icon giỏ hàng trên Header
                    requestAnimationFrame(() => {
                        flyImg.style.left = (cartRect.left + cartRect.width / 2 - 12) + 'px';
                        flyImg.style.top = (cartRect.top + cartRect.height / 2 - 12) + 'px';
                        flyImg.style.width = '24px';
                        flyImg.style.height = '24px';
                        flyImg.style.opacity = '0.25';
                        flyImg.style.transform = 'scale(0.3) rotate(15deg)';
                    });

                    // Khi bay tới nơi: xoá ảnh bay, nảy nhẹ icon giỏ hàng và cập nhật số
                    setTimeout(() => {
                        flyImg.remove();
                        updateCartBadge(cartIcon, cartItemCount);
                    }, 750);
                } else {
                    // sản phẩm chưa có ảnh (không có #mainImage): không có hiệu ứng bay, cập nhật số ngay
                    updateCartBadge(cartIcon, cartItemCount);
                }

                // 3. Đổi chữ trên nút bấm 1.2 giây để báo hiệu đã thêm thành công
                const originalHtml = btnEl.innerHTML;
                btnEl.innerHTML = '<i class="fi fi-rr-check"></i> Đã thêm vào giỏ!';
                btnEl.style.background = '#266A3C';
                btnEl.disabled = true;
                setTimeout(() => {
                    btnEl.innerHTML = originalHtml;
                    btnEl.style.background = '';
                    btnEl.disabled = false;
                }, 1200);
            }
        </script>
        <%-- Nhúng Footer --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

        <%-- Nhúng Nút Chat nổi --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

    </body>
</html>
