<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="cart" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán an toàn · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/checkout.css">
    </head>
    <body>

        <%-- 1. HEADER CHUNG --%>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <main class="checkout-page-wrapper">

            <!-- 2. BREADCRUMB & SSL BADGE -->
            <div class="checkout-topbar">
                <nav class="checkout-breadcrumb" aria-label="Breadcrumb">
                    <a href="${ctx}/">Trang chủ</a>
                    <span class="sep">&rsaquo;</span>
                    <a href="${ctx}/cart">Giỏ hàng</a>
                    <span class="sep">&rsaquo;</span>
                    <span class="current">Thanh toán an toàn</span>
                </nav>

                
            </div>

            <!-- 3. FORM CHÍNH BAO TRỌN 2 CỘT ĐỂ GỬI DỮ LIỆU ĐỒNG BỘ -->
            <form:form method="post" action="${ctx}/checkout" modelAttribute="checkoutForm" id="checkoutMainForm">
                <%-- Thêm đoạn này để giữ lại danh sách sản phẩm đã tick chọn từ giỏ --%>
                <c:forEach var="id" items="${checkoutForm.itemIds}">
                    <input type="hidden" name="itemIds" value="${id}"/>
                </c:forEach>
                <div class="checkout-grid">

                    <!-- CỘT TRÁI: THÔNG TIN GIAO HÀNG, PHƯƠNG THỨC THANH TOÁN & CAM KẾT -->
                    <div class="checkout-left-col">

                        <!-- BOX 1: THÔNG TIN GIAO HÀNG -->
                        <section class="checkout-card">
                            <div class="card-header-row">
                                <div class="step-title-group">
                                    <span class="step-badge">1</span>
                                    <div>
                                        <h2>Thông tin giao hàng</h2>
                                        <p class="step-sub">Kiểm tra thông tin nhận hàng của bạn</p>
                                    </div>
                                </div>

                            </div>

                            <div class="recipient-box">
                                <div class="recipient-info">
                                    <div class="recipient-line">
                                        <strong class="recipient-name"><c:out value="${currentUser.fullName}"/></strong>
                                        <c:choose>
                                            <c:when test="${not empty summary.customerPhone}">
                                                <span class="recipient-phone"><c:out value="${summary.customerPhone}"/></span>
                                                <span class="default-tag">Mặc định</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="phone-missing-badge">Chưa có số điện thoại</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <c:if test="${empty summary.customerPhone}">
                                        <p class="error-msg" style="margin-top: 6px;">
                                            <i class="fi fi-rr-exclamation"></i> Chưa có số điện thoại.
                                            <a href="${ctx}/profile">Cập nhật hồ sơ</a> để shipper liên hệ khi giao hàng.
                                        </p>
                                    </c:if>
                                </div>

                                <a href="${ctx}/profile" class="btn-outline-small">
                                    <i class="fi fi-rr-plus-small"></i> Cập nhật TT
                                </a>
                            </div>

                            <div class="form-group">
                                <label for="shippingAddress" class="form-label">
                                    <i class="fi fi-rr-marker"></i> Địa chỉ giao hàng (số nhà, đường, phường, thành phố)
                                </label>
                                <form:textarea path="shippingAddress"
                                               id="shippingAddress"
                                               rows="3"
                                               maxlength="500"
                                               cssClass="checkout-textarea"
                                               placeholder="Ví dụ: 124 Nguyễn Thị Minh Khai, Phường Bến Thành, Quận 1, TP. Hồ Chí Minh..."/>
                                <form:errors path="shippingAddress" cssClass="error-msg"/>
                            </div>

                            <div class="shipping-quote-bar">
                                <p class="shipping-rule-note">
                                    <i class="fi fi-rr-info"></i> Miễn phí giao hàng trong bán kính 5km quanh cửa hàng và đơn từ 150.000đ tiền hàng; các trường hợp khác phí 30.000đ.
                                </p>
                                <button type="submit" formaction="${ctx}/checkout/quote" class="btn-calc-shipping">
                                    <i class="fi fi-rr-calculator"></i> Tính phí giao hàng
                                </button>
                            </div>
                        </section>

                        <!-- BOX 2: PHƯƠNG THỨC THANH TOÁN -->
                        <section class="checkout-card">
                            <div class="card-header-row">
                                <div class="step-title-group">
                                    <span class="step-badge">2</span>
                                    <div>
                                        <h2>Phương thức thanh toán</h2>
                                        <p class="step-sub">An toàn, bảo mật theo chuẩn quốc tế</p>
                                    </div>
                                </div>
                                <span class="selected-method-pill" id="selectedMethodBadge">Bảo mật 100%</span>
                            </div>

                            <div class="payment-options-list">
                                <c:forEach var="m" items="${paymentMethods}">
                                    <c:set var="isVnpay" value="${m == 'VNPAY'}" />
                                    <c:set var="isDisabled" value="${isVnpay and not vnpayEnabled}" />

                                    <label class="payment-option-card ${isDisabled ? 'disabled' : ''}" onclick="highlightPaymentCard(this, '${m.label}')">
                                        <div class="payment-radio-col">
                                            <form:radiobutton path="paymentMethod" value="${m}" disabled="${isDisabled}"/>
                                        </div>
                                        <div class="payment-content-col">
                                            <div class="payment-title-row">
                                                <span class="payment-name">
                                                    <c:choose>
                                                        <c:when test="${isVnpay}">
                                                            <i class="fi fi-rr-qrcode" style="color: #F47721;"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fi fi-rr-money-bill-wave" style="color: #F47721;"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <c:out value="${m.label}"/>
                                                </span>

                                                <c:choose>
                                                    <c:when test="${isVnpay and vnpayEnabled}">
                                                        <span class="pay-tag warning">Giữ đơn 15 phút</span>
                                                    </c:when>
                                                    <c:when test="${isVnpay and not vnpayEnabled}">
                                                        <span class="pay-tag muted">Chưa cấu hình</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="pay-tag popular">Phổ biến</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <p class="payment-desc">
                                                <c:choose>
                                                    <c:when test="${isVnpay}">
                                                        Hỗ trợ quét mã VNPAY-QR qua 40+ ngân hàng, ví điện tử, thẻ ATM nội địa hoặc thẻ quốc tế Visa / MasterCard.
                                                    </c:when>
                                                    <c:otherwise>
                                                        Trả tiền mặt cho nhân viên giao hàng khi kiểm tra kiện thức ăn còn nguyên vẹn, đúng mã đơn hàng.
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>

                                            <c:if test="${isVnpay and vnpayEnabled}">
                                                <div class="payment-sub-alert">
                                                    <i class="fi fi-rr-clock"></i> Thanh toán trong 15 phút, quá hạn đơn tự huỷ.
                                                </div>
                                            </c:if>
                                        </div>
                                    </label>
                                </c:forEach>
                                <form:errors path="paymentMethod" cssClass="error-msg"/>
                            </div>
                        </section>

                        <!-- BOX 3: CAM KẾT DỊCH VỤ DƯỚI CÙNG CỘT TRÁI -->
                        <div class="service-guarantees-card">
                            <div class="guarantee-item">
                                <div class="guarantee-icon orange">
                                    <i class="fi fi-rr-rocket-lunch"></i>
                                </div>
                                <div class="guarantee-text">
                                    <strong>Giao hỏa tốc 2 Giờ</strong>
                                    <p>Áp dụng đơn nội thành TP. Hồ Chí Minh & Hà Nội. Đúng giờ bữa ăn cho thú cưng.</p>
                                </div>
                            </div>

                            <div class="guarantee-item">
                                <div class="guarantee-icon yellow">
                                    <i class="fi fi-rr-shield-check"></i>
                                </div>
                                <div class="guarantee-text">
                                    <strong>Đóng gói chuẩn 22°C</strong>
                                    <p>Vật liệu chống sốc & giữ ẩm tiêu chuẩn Châu Âu, bảo toàn trọn vẹn dinh dưỡng.</p>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- CỘT PHẢI: TÓM TẮT ĐƠN HÀNG -->
                    <aside class="checkout-right-col">
                        <section class="checkout-card summary-sticky-card">
                            <div class="summary-header">
                                <h2><i class="fi fi-rr-shopping-cart"></i> Tóm tắt đơn hàng</h2>
                                <span class="item-count-pill">${summary.lines.size()} sản phẩm</span>
                            </div>

                            <!-- DANH SÁCH SẢN PHẨM TRONG ĐƠN -->
                            <div class="order-items-list">
                                <c:forEach var="line" items="${summary.lines}">
                                    <div class="order-item-row ${line.flashSale ? 'flash-item' : ''}">
                                        <div class="item-thumb-icon">
                                            <i class="fi fi-rr-box-open"></i>
                                        </div>
                                        <div class="item-details">
                                            <div class="item-title-line">
                                                <c:if test="${line.flashSale}">
                                                    <span class="fs-mini-badge">Flash Sale</span>
                                                </c:if>
                                                <strong class="item-name"><c:out value="${line.name}"/></strong>
                                            </div>
                                            <div class="item-bottom-line">
                                                <span class="item-qty">Số lượng: ${line.quantity}</span>
                                                <strong class="item-line-total">
                                                    <fmt:formatNumber value="${line.lineTotal}" type="number"/>₫
                                                </strong>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- BẢNG TÍNH TIỀN -->
                            <div class="price-breakdown">
                                <div class="price-row">
                                    <span>Tạm tính:</span>
                                    <strong><fmt:formatNumber value="${summary.subtotal}" type="number"/>₫</strong>
                                </div>

                                <div class="price-row discount-row">
                                    <span>
                                        <i class="fi fi-rr-badge-percent"></i>
                                        Giảm giá hạng ${summary.tierLabel} (${summary.tierRate}%, không áp cho Flash Sale):
                                    </span>
                                    <strong class="discount-val">
                                        −<fmt:formatNumber value="${summary.discountTotal}" type="number"/>₫
                                    </strong>
                                </div>

                                <div class="price-row">
                                    <span>Phí vận chuyển:</span>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${summary.shipping == null}">
                                                <span class="quote-pending-text">Chưa tính phí</span>
                                            </c:when>
                                            <c:when test="${summary.shipping.fee == 0}">
                                                <span class="free-ship-text">0₫ (Freeship)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${summary.shipping.fee}" type="number"/>₫
                                            </c:otherwise>
                                        </c:choose>
                                    </strong>
                                </div>

                                <!-- GHI CHÚ KHOẢNG CÁCH & NGUỒN GEOAPIFY -->
                                <c:if test="${summary.shipping != null}">
                                    <div class="shipping-Result-box">
                                        <div><c:out value="${summary.shipping.note}"/></div>
                                        <c:if test="${summary.shipping.distanceKm != null}">
                                            <div>Khoảng cách tới cửa hàng: <strong>${summary.shipping.distanceText} km</strong></div>
                                            <div class="geo-attribution">
                                                Powered by <a href="https://www.geoapify.com/" target="_blank" rel="noopener">Geoapify</a>
                                                · &copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">OpenStreetMap</a> contributors
                                            </div>
                                        </c:if>
                                    </div>
                                </c:if>
                            </div>

                            <!-- TỔNG THANH TOÁN -->
                            <div class="grand-total-box">
                                <div>
                                    <span class="grand-total-label">Tổng thanh toán:</span>
                                    <small class="vat-note">Đã bao gồm VAT (nếu có)</small>
                                </div>
                                <strong class="grand-total-price">
                                    <c:choose>
                                        <c:when test="${summary.shipping != null}">
                                            <fmt:formatNumber value="${summary.total}" type="number"/>₫
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${summary.subtotal - summary.discountTotal}" type="number"/>₫
                                        </c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>

                            <!-- NÚT ĐẶT HÀNG HOẶC NHẮC TÍNH PHÍ GIAO HÀNG -->
                            <c:choose>
                                <c:when test="${summary.shipping != null and not empty summary.customerPhone}">
                                    <button type="submit" class="btn-place-order">
                                        <i class="fi fi-rr-shield-check"></i> Đặt hàng
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button type="submit" formaction="${ctx}/checkout/quote" class="btn-place-order">
                                        <i class="fi fi-rr-calculator"></i> Tính phí giao hàng để Đặt đơn
                                    </button>
                                </c:otherwise>
                            </c:choose>

                            <div class="terms-agreement-box">
                                <i class="fi fi-rr-shield-exclamation"></i>
                                <span>
                                    Bằng việc bấm Đặt hàng, bạn đồng ý với
                                    <a href="${ctx}/policy">Điều khoản mua sắm</a> và
                                    <a href="${ctx}/policy">chính sách cam kết HSD</a> của PetFood.
                                </span>
                            </div>
                        </section>
                    </aside>

                </div>
            </form:form>

        </main>

        <%-- 4. FOOTER CHUNG --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

        <%-- 5. NÚT CHAT NỔI CHUNG --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            function highlightPaymentCard(cardEl, labelText) {
                if (cardEl.classList.contains('disabled'))
                    return;
                document.querySelectorAll('.payment-option-card').forEach(el => el.classList.remove('active'));
                cardEl.classList.add('active');
                const badge = document.getElementById('selectedMethodBadge');
                if (badge && labelText) {
                    badge.textContent = 'Đã chọn: ' + labelText;
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                const checkedRadio = document.querySelector('.payment-option-card input[type="radio"]:checked');
                if (checkedRadio) {
                    const parentCard = checkedRadio.closest('.payment-option-card');
                    if (parentCard)
                        parentCard.classList.add('active');
                }
            });
        </script>

    </body>
</html>