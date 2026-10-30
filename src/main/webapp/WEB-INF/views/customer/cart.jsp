<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="cart" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Giỏ hàng của bạn · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/cart.css">
    </head>

    <body>

        <c:set var="ownFlash" value="true"/>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <c:set var="regTotal" value="0" />
        <c:set var="flashTotal" value="0" />
        <c:set var="promoTotal" value="0" />
        <c:set var="regCount" value="0" />
        <c:set var="flashCount" value="0" />
        <c:set var="promoCount" value="0" />
        <c:set var="unavailableCount" value="0" />
        <c:set var="tierRate" value="${empty cart ? 0 : cart.tierDiscountRate}" />
        <c:set var="vipDiscountAmount" value="0" />

        <c:if test="${not empty cart and not empty cart.lines}">
            <c:forEach var="line" items="${cart.lines}">
                <c:set var="fsNameLower" value="${fn:toLowerCase(line.flashSaleName)}"/>
                <c:set var="isPromoLine" value="${line.flashSale and not (fn:contains(fsNameLower, 'flash sale') or fn:contains(fsNameLower, 'flashsale') or fn:contains(fsNameLower, 'cận hạn') or fn:contains(fsNameLower, 'cận date') or fn:contains(fsNameLower, 'xả hàng') or fn:contains(fsNameLower, 'xả tồn'))}"/>
                <c:choose>
                    <c:when test="${not empty line.problem}">
                        <c:set var="unavailableCount" value="${unavailableCount + 1}" />
                    </c:when>
                    <c:when test="${line.flashSale}">
                        <c:set var="flashCount" value="${flashCount + 1}" />
                        <c:choose>
                            <c:when test="${isPromoLine}">
                                <c:set var="promoCount" value="${promoCount + 1}" />
                                <c:set var="promoTotal" value="${promoTotal + line.lineTotal}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="flashTotal" value="${flashTotal + line.lineTotal}" />
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <c:set var="regCount" value="${regCount + 1}" />
                        <c:set var="regTotal" value="${regTotal + line.lineTotal}" />
                        <fmt:formatNumber value="${(line.lineTotal * tierRate) / 100}" maxFractionDigits="0" groupingUsed="false" var="lineVipDisc"/>
                        <c:set var="vipDiscountAmount" value="${vipDiscountAmount + lineVipDisc}" />
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </c:if>

        <%-- Giảm giá hạng lấy từ BE (cart.tierDiscountRate, đơn vị %), chỉ tính trên hàng giá thường làm tròn từng dòng (BR-39, BR-43).
             Ngưỡng Freeship lấy từ cấu hình petfood.shipping.free-min-subtotal. Số chốt cuối cùng vẫn do trang checkout tính. --%>
        <c:set var="finalTotal" value="${regTotal + flashTotal + promoTotal - vipDiscountAmount}" />
        <c:set var="freeshipThreshold" value="${freeShipMinSubtotal}" />
        <c:set var="freeshipPct" value="${(finalTotal >= freeshipThreshold) ? 100 : ((finalTotal * 100) / freeshipThreshold)}" />

        <main class="page-container">

            <div class="cart-topbar">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a>
                    <span class="sep">/</span>
                    <span class="current">Giỏ hàng của bạn</span>
                </nav>
            </div>

            <c:choose>
                <c:when test="${empty cart.lines}">
                    <div style="background: #FFFFFF; border: 1px solid #F4E3C9; border-radius: 4px; padding: 56px 24px; text-align: center; box-shadow: 0 6px 20px rgba(61,48,40,0.04);">
                        <i class="fi fi-rr-shopping-cart" style="font-size: 42px; color: #F47721; display: block; margin-bottom: 14px;"></i>
                        <h2 style="font-size: 20px; font-weight: 800; margin-bottom: 8px; color: #3D3028;">Giỏ hàng của bạn đang trống</h2>
                        <p style="font-size: 14px; color: #817872; margin-bottom: 24px;">Hãy chọn thêm thức ăn dinh dưỡng hoặc săn deal Flash Sale hấp dẫn cho Boss nhé!</p>
                        <div style="display: inline-flex; gap: 12px;">
                            <a href="${ctx}/products" class="checkout-btn" style="padding: 0 28px; width: auto; margin-bottom: 0;">
                                <span>Xem sản phẩm</span>
                            </a>
                            <a href="${ctx}/flash-sale" class="clear-cart-btn" style="height: 46px; padding: 0 22px; font-size: 13.5px; color: #F47721; border-color: #F4E3C9; background: #FFF6EE;">
                                <i class="fi fi-rr-flame"></i> Săn Flash Sale
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="cart-layout">

                        <div class="cart-left-col">
                            <div class="select-all-bar">
                                <label class="custom-checkbox-label">
                                    <input type="checkbox" id="selectAllCheckbox" class="cart-checkbox" checked>
                                    <span>Sản phẩm (<span id="selectedLineCount">${regCount + flashCount}</span>)</span>
                                </label>
                                <div class="select-all-right">
                                    <div class="col-qty">Số Lượng</div>
                                    <div class="col-subtotal">Số Tiền</div>
                                </div>
                            </div>

                            <!-- DANH SÁCH SẢN PHẨM GIỎ HÀNG -->
                            <section class="cart-group-card">
                                <div class="group-items">
                                    <c:set var="validCount" value="${regCount + flashCount}" />
                                    <c:choose>
                                        <c:when test="${validCount > 0}">
                                            <c:forEach var="line" items="${cart.lines}">
                                                <c:if test="${empty line.problem}">
                                                    <c:set var="fsNameLower" value="${fn:toLowerCase(line.flashSaleName)}"/>
                                                    <c:set var="isPromoLine" value="${line.flashSale and not (fn:contains(fsNameLower, 'flash sale') or fn:contains(fsNameLower, 'flashsale') or fn:contains(fsNameLower, 'cận hạn') or fn:contains(fsNameLower, 'cận date') or fn:contains(fsNameLower, 'xả hàng') or fn:contains(fsNameLower, 'xả tồn'))}"/>
                                                    <div class="cart-item js-cart-item ${line.flashSale ? 'flash-item' : ''}"
                                                         data-line-id="${line.id}"
                                                         data-product-id="${line.productId}"
                                                         data-unit-price="${line.unitPrice}"
                                                         data-flash-sale="${line.flashSale}"
                                                         data-promo-sale="${isPromoLine}"
                                                         data-available="${line.availableQty}"
                                                         data-prev-qty="${line.quantity}">

                                                        <input type="checkbox"
                                                               class="cart-checkbox js-item-checkbox"
                                                               data-group="${line.flashSale ? 'flash' : 'regular'}"
                                                               data-product-id="${line.productId}"
                                                               value="${line.id}"
                                                               checked
                                                               title="Chọn mua sản phẩm này">

                                                        <a href="${ctx}/products/${line.productId}" class="item-thumb">
                                                            <%-- Tag giảm giá flash sale nếu có --%>
                                                            <c:if test="${line.flashSale and not empty line.regularPrice and line.regularPrice > line.unitPrice}">
                                                                <c:set var="discPct" value="${((line.regularPrice - line.unitPrice) * 100) / line.regularPrice}"/>
                                                                <span class="item-discount-badge">-<fmt:formatNumber value="${discPct}" maxFractionDigits="0"/>%</span>
                                                            </c:if>

                                                            <%-- Xử lý hiển thị ảnh hoặc ô xám nếu chưa có ảnh --%>
                                                            <c:choose>
                                                                <c:when test="${not empty line.imageUrl}">
                                                                    <img src="${ctx}<c:out value='${line.imageUrl}'/>"
                                                                         alt="<c:out value='${line.name}'/>"
                                                                         onerror="this.style.display='none'; if(this.nextElementSibling) this.nextElementSibling.style.display='flex';">
                                                                    <div class="no-image-placeholder" style="display: none;">
                                                                        <i class="fi fi-rr-picture"></i>
                                                                        <span>Chưa có ảnh sản phẩm</span>
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="no-image-placeholder">
                                                                        <i class="fi fi-rr-picture"></i>
                                                                        <span>Chưa có ảnh sản phẩm</span>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </a>

                                                        <div class="item-details">
                                                            <h3>
                                                                <a href="${ctx}/products/${line.productId}">
                                                                    <c:out value="${line.name}"/>
                                                                </a>
                                                            </h3>

                                                            <c:if test="${line.flashSale}">
                                                                <div class="item-flash-subtag">
                                                                    <span class="flash-sale-badge" style="text-transform:none">${isPromoLine ? 'Chương trình' : 'Flash Sale'}</span>
                                                                    <c:if test="${not empty line.expiryNote}">
                                                                        <span class="flash-expiry-badge"><i class="fi fi-rr-calendar"></i> <c:out value="${line.expiryNote}"/></span>
                                                                    </c:if>
                                                                </div>
                                                            </c:if>

                                                            <c:choose>
                                                                <c:when test="${line.flashSale}">
                                                                    <div class="flash-price-line">
                                                                        <span class="flash-sale-price">
                                                                            <fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫
                                                                        </span>
                                                                        <c:if test="${not empty line.regularPrice and line.regularPrice > line.unitPrice}">
                                                                            <span class="flash-old-price">
                                                                                <fmt:formatNumber value="${line.regularPrice}" type="number"/> ₫
                                                                            </span>
                                                                        </c:if>
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <p class="unit-price">
                                                                        Đơn giá: <strong><fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫</strong>
                                                                    </p>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>

                                                        <div class="item-qty-wrapper">
                                                            <form method="post" action="${ctx}/cart/items/${line.id}/quantity" class="qty-form js-qty-form" onsubmit="return false;">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                <button type="button" class="qty-btn js-qty-minus" ${line.quantity <= 1 ? 'disabled' : ''}>&minus;</button>
                                                                <input type="number"
                                                                       name="quantity"
                                                                       value="${line.quantity}"
                                                                       min="1"
                                                                       max="999"
                                                                       class="qty-input-editable js-qty-input"
                                                                       aria-label="Số lượng">
                                                                <button type="button" class="qty-btn js-qty-plus">&plus;</button>
                                                            </form>
                                                            <div class="stock-exceed-msg js-stock-warning" style="display: none; color: #d9381e; font-size: 11.5px; font-weight: 600; margin-top: 4px; line-height: 1.3;">
                                                                <i class="fi fi-rr-exclamation"></i> Vượt tồn kho (tối đa <span class="js-max-avail">${line.availableQty}</span>)
                                                            </div>
                                                            <c:if test="${line.flashSale and line.availableQty > 0}">
                                                                <span class="limit-note">Còn ${line.availableQty} suất</span>
                                                            </c:if>
                                                            <span class="saving-indicator js-saving-badge"><i class="fi fi-rr-check"></i> Đã lưu</span>
                                                        </div>

                                                        <div class="item-subtotal">
                                                            <span class="subtotal-price ${line.flashSale ? 'flash-color' : ''} js-line-total">
                                                                <fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫
                                                            </span>
                                                            <span class="subtotal-note js-line-note">
                                                                <c:choose>
                                                                    <c:when test="${line.flashSale}">
                                                                        ${isPromoLine ? 'Giá Chương trình' : 'Giá Flash Sale'}
                                                                    </c:when>
                                                                    <c:when test="${line.quantity > 1}">
                                                                        ${line.quantity} &times; <fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫
                                                                    </c:when>
                                                                    <c:otherwise>Thành tiền</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>

                                                        <form method="post" action="${ctx}/cart/items/${line.id}/delete" class="remove-form">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                            <button type="submit" class="remove-btn" title="Xoá khỏi giỏ">
                                                                <i class="fi fi-rr-trash"></i>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div style="padding: 32px 0; text-align: center; color: #817872; font-size: 13.5px;">
                                                Chưa có sản phẩm hợp lệ nào trong giỏ hàng.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- KHỐI CHÍNH SÁCH ĐỔI TRẢ NỐI LIỀN DƯỚI CÙNG SẢN PHẨM -->
                                <div class="cart-policy-strip">
                                    <div class="policy-strip-left">
                                        <span class="policy-badge">Đổi trả 3 ngày</span>
                                        <strong class="policy-strip-title">
                                            <i class="fi fi-rr-shield-check"></i>
                                            Chính sách đổi trả trong vòng 3 ngày - An tâm mua hàng
                                        </strong>
                                        <span class="policy-strip-desc">
                                            • Đổi mới 100% nếu cận date hoặc bao bì lỗi
                                        </span>
                                    </div>
                                    <div class="policy-strip-right">
                                        <span class="policy-feature-pill"><i class="fi fi-rr-badge-check"></i> Hàng chính hãng 100%</span>
                                        <span class="policy-feature-pill muted"><i class="fi fi-rr-box-check"></i> Đồng kiểm khi nhận</span>
                                    </div>
                                </div>
                            </section>

                            <!-- ================= MỤC SẢN PHẨM HẾT HÀNG HOẶC LỖI TỒN KHO ================= -->
                            <c:if test="${unavailableCount > 0}">
                                <section class="cart-group-card unavailable-group">
                                    <div class="unavailable-header">
                                        <div class="group-title-wrap">
                                            <span class="group-icon" style="background: #FDE8E4; color: #B92B19;"><i class="fi fi-rr-exclamation"></i></span>
                                            <div>
                                                <h2 style="color: #B92B19; font-size: 16px;">Sản phẩm hết hàng hoặc không khả dụng (${unavailableCount})</h2>
                                                <p style="color: #817872; font-size: 12.5px; margin: 0;">Các sản phẩm này đã hết hàng trong kho hoặc vượt quá số lượng cho phép, không thể chọn mua ngay.</p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="group-items">
                                        <c:forEach var="line" items="${cart.lines}">
                                            <c:if test="${not empty line.problem}">
                                                <div class="cart-item" style="background: #FFF5F5; opacity: 0.85; border-radius: 4px; padding: 14px 10px; margin-bottom: 12px;">
                                                    <input type="checkbox" class="cart-checkbox" disabled title="Không thể chọn sản phẩm hết hàng">

                                                    <a href="${ctx}/products/${line.productId}" class="item-thumb">
                                                        <c:choose>
                                                            <c:when test="${not empty line.imageUrl}">
                                                                <img src="${ctx}<c:out value='${line.imageUrl}'/>"
                                                                     alt="<c:out value='${line.name}'/>"
                                                                     onerror="this.style.display='none'; if(this.nextElementSibling) this.nextElementSibling.style.display='flex';">
                                                                <div class="no-image-placeholder" style="display: none;">
                                                                    <i class="fi fi-rr-picture"></i>
                                                                    <span>Chưa có ảnh sản phẩm</span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="no-image-placeholder">
                                                                    <i class="fi fi-rr-picture"></i>
                                                                    <span>Chưa có ảnh sản phẩm</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </a>

                                                    <div class="item-details">
                                                        <div class="item-tags">
                                                            <span class="tag-pill" style="background: #FDE8E4; color: #B92B19;">Hết hàng / Lỗi tồn kho</span>
                                                        </div>
                                                        <h3>
                                                            <a href="${ctx}/products/${line.productId}" style="color: #6C5E55;">
                                                                <c:out value="${line.name}"/>
                                                            </a>
                                                        </h3>
                                                        <p style="margin-top: 6px; color: #B92B19; font-size: 13px; font-weight: 700;">
                                                            <i class="fi fi-rr-exclamation"></i> <c:out value="${line.problem}"/>
                                                        </p>
                                                    </div>

                                                    <div class="item-qty-wrapper">
                                                        <span style="font-size: 13px; font-weight: 700; color: #817872;">SL: ${line.quantity}</span>
                                                    </div>

                                                    <div class="item-subtotal">
                                                        <span class="subtotal-price" style="color: #817872;">
                                                            <fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫
                                                        </span>
                                                        <span class="subtotal-note">Tạm dừng</span>
                                                    </div>

                                                    <form method="post" action="${ctx}/cart/items/${line.id}/delete" class="remove-form">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <button type="submit" class="remove-btn" title="Xoá khỏi giỏ">
                                                            <i class="fi fi-rr-trash"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </section>
                            </c:if>

                            <div class="cart-actions-bar">
                                <a href="${ctx}/products" class="continue-shopping-link">
                                    <i class="fi fi-rr-arrow-left"></i> Tiếp tục chọn thêm thức ăn
                                </a>
                            </div>

                        </div>

                        <aside class="cart-right-col">
                            <div class="freeship-card">
                                <div class="freeship-top">
                                    <span class="freeship-title">
                                        <i class="fi fi-rr-shipping-fast"></i> Miễn phí vận chuyển nội thành (Đơn từ 150K)
                                    </span>
                                    <span class="freeship-numbers">
                                        Đã đạt <strong id="freeshipCurrentText"><fmt:formatNumber value="${finalTotal}" type="number" maxFractionDigits="0"/></strong>đ / <fmt:formatNumber value="${freeshipThreshold}" type="number" maxFractionDigits="0"/>đ
                                    </span>
                                </div>
                                <div class="freeship-bar">
                                    <div class="freeship-fill" id="freeshipBarFill" style="width: ${freeshipPct}%; transition: width 0.25s ease;"></div>
                                </div>
                                <div class="freeship-status" id="freeshipStatusText">
                                    <c:choose>
                                        <c:when test="${finalTotal >= freeshipThreshold}">
                                            <i class="fi fi-rr-check-circle"></i> Đơn hàng của bạn đã đủ điều kiện Freeship nội thành!
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fi fi-rr-info"></i> Mua thêm <strong><fmt:formatNumber value="${freeshipThreshold - finalTotal}" type="number" maxFractionDigits="0"/>đ</strong> để được Freeship nội thành!
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="summary-card">
                                <div class="summary-header">
                                    <h2>Tóm tắt đơn hàng</h2>
                                    <i class="fi fi-rr-receipt"></i>
                                </div>

                                <div class="summary-lines">
                                    <div class="summary-row">
                                        <span>Tạm tính hàng thường:</span>
                                        <strong id="summaryRegTotal"><fmt:formatNumber value="${regTotal}" type="number"/> ₫</strong>
                                    </div>

                                    <c:if test="${promoCount > 0}">
                                        <div class="summary-row" id="summaryPromoRow">
                                            <span>Tạm tính Chương trình: <i class="fi fi-rr-badge-percent text-orange"></i></span>
                                            <strong class="text-orange" id="summaryPromoTotal"><fmt:formatNumber value="${promoTotal}" type="number"/> ₫</strong>
                                        </div>
                                    </c:if>

                                    <div class="summary-row">
                                        <span>Tạm tính Flash Sale: <i class="fi fi-rr-flame text-orange"></i></span>
                                        <strong class="text-orange" id="summaryFlashTotal"><fmt:formatNumber value="${flashTotal}" type="number"/> ₫</strong>
                                    </div>

                                    <div class="summary-row">
                                        <span>Tổng tạm tính (<span id="summarySelectedQty">${regCount + flashCount}</span> sản phẩm chọn):</span>
                                        <strong id="summaryRawSubtotal"><fmt:formatNumber value="${regTotal + flashTotal + promoTotal}" type="number"/> ₫</strong>
                                    </div>

                                    <div class="vip-discount-box">
                                        <div class="vip-discount-row">
                                            <span class="vip-label">
                                                <i class="fi fi-rr-crown"></i> Ưu đãi hạng <c:out value="${cart.tierLabel}"/> (<fmt:formatNumber value="${tierRate}" maxFractionDigits="2"/>%):
                                            </span>
                                            <strong class="vip-amount" id="summaryVipDiscount">-<fmt:formatNumber value="${vipDiscountAmount}" type="number" maxFractionDigits="0"/> ₫</strong>
                                        </div>
                                        <p class="vip-rule-note">
                                            * Giảm giá theo hạng thành viên chỉ tính trên hàng thường được chọn. Không áp dụng cho sản phẩm Flash Sale / Chương trình.
                                        </p>
                                    </div>

                                    <div class="summary-row shipping-row">
                                        <span>Phí vận chuyển nội thành:</span>
                                        <span class="shipping-calc-text" id="summaryShippingText">Tính tại bước đặt hàng</span>
                                    </div>
                                </div>

                                <div class="summary-total-section">
                                    <div class="total-row">
                                        <span>Tổng cộng thanh toán:</span>
                                        <strong class="grand-total" id="summaryFinalTotal"><fmt:formatNumber value="${finalTotal}" type="number"/> ₫</strong>
                                    </div>
                                    <span class="vat-note">(Đã bao gồm thuế VAT)</span>
                                </div>

                                <a href="${ctx}/checkout" id="checkoutBtnLink" class="checkout-btn">
                                    <span id="checkoutBtnText">Mua hàng (${regCount + flashCount})</span>
                                    <i class="fi fi-rr-arrow-right"></i>
                                </a>
                            </div>
                        </aside>
                    </div>
                </c:otherwise>
            </c:choose>

        </main>


        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const FREESHIP_THRESHOLD = ${freeshipThreshold};
                const TIER_RATE = ${tierRate};
                const fmtVND = (num) => Math.round(num).toLocaleString('vi-VN');

                let holdSeconds = 14 * 60 + 54;
                const timerEl = document.getElementById("cartHoldTimer");
                if (timerEl) {
                    setInterval(() => {
                        if (holdSeconds <= 0)
                            return;
                        holdSeconds--;
                        const m = Math.floor(holdSeconds / 60);
                        const s = holdSeconds % 60;
                        timerEl.textContent = String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
                    }, 1000);
                }

                function recalculateCartTotals() {
                    const items = document.querySelectorAll('.js-cart-item');
                    let regTotal = 0;
                    let flashTotal = 0;
                    let promoTotal = 0;
                    let vipDiscount = 0;
                    let selectedQty = 0;
                    let selectedLines = 0;
                    let selectedIds = [];
                    let hasOverStock = false;

                    items.forEach(item => {
                        const checkbox = item.querySelector('.js-item-checkbox');
                        const qtyInput = item.querySelector('.js-qty-input');
                        const unitPrice = parseFloat(item.dataset.unitPrice || 0);
                        const isFlash = item.dataset.flashSale === 'true';
                        const isPromo = item.dataset.promoSale === 'true';
                        const maxAvailable = parseInt(item.dataset.available || 0, 10);
                        let qty = parseInt(qtyInput ? qtyInput.value : 0, 10);
                        if (isNaN(qty) || qty < 1)
                            qty = 1;

                        const lineTotal = unitPrice * qty;

                        const lineTotalEl = item.querySelector('.js-line-total');
                        if (lineTotalEl) {
                            lineTotalEl.textContent = fmtVND(lineTotal) + ' ₫';
                        }
                        const lineNoteEl = item.querySelector('.js-line-note');
                        if (lineNoteEl && !isFlash) {
                            lineNoteEl.innerHTML = qty > 1 ? (qty + ' &times; ' + fmtVND(unitPrice) + ' ₫') : 'Thành tiền';
                        }

                        if (checkbox && checkbox.checked && !checkbox.disabled) {
                            item.classList.remove('unchecked-row');
                            selectedLines++;
                            selectedQty += qty;
                            selectedIds.push(checkbox.value);

                            if (maxAvailable > 0 && qty > maxAvailable) {
                                hasOverStock = true;
                            }

                            if (isFlash) {
                                if (isPromo) {
                                    promoTotal += lineTotal;
                                } else {
                                    flashTotal += lineTotal;
                                }
                            } else {
                                regTotal += lineTotal;
                                // làm tròn theo từng dòng như CheckoutService
                                vipDiscount += Math.round(lineTotal * TIER_RATE / 100);
                            }
                        } else {
                            item.classList.add('unchecked-row');
                        }
                    });

                    const rawSubtotal = regTotal + flashTotal + promoTotal;
                    const finalTotal = rawSubtotal - vipDiscount;

                    const setTxt = (id, val) => {
                        const el = document.getElementById(id);
                        if (el)
                            el.textContent = val;
                    };

                    setTxt('selectedLineCount', selectedLines);
                    setTxt('summaryRegTotal', fmtVND(regTotal) + ' ₫');
                    setTxt('summaryPromoTotal', fmtVND(promoTotal) + ' ₫');
                    setTxt('summaryFlashTotal', fmtVND(flashTotal) + ' ₫');
                    setTxt('summarySelectedQty', selectedQty);
                    setTxt('summaryRawSubtotal', fmtVND(rawSubtotal) + ' ₫');
                    setTxt('summaryVipDiscount', '-' + fmtVND(vipDiscount) + ' ₫');
                    setTxt('summaryFinalTotal', fmtVND(finalTotal) + ' ₫');

                    setTxt('freeshipCurrentText', fmtVND(finalTotal));
                    const pct = finalTotal >= FREESHIP_THRESHOLD ? 100 : Math.min(100, (finalTotal * 100) / FREESHIP_THRESHOLD);
                    const barFill = document.getElementById('freeshipBarFill');
                    if (barFill)
                        barFill.style.width = pct + '%';

                    const statusEl = document.getElementById('freeshipStatusText');
                    const shippingTxt = document.getElementById('summaryShippingText');
                    if (statusEl) {
                        if (selectedLines === 0) {
                            statusEl.innerHTML = '<i class="fi fi-rr-info"></i> Vui lòng tích chọn ít nhất 1 sản phẩm để tính Freeship nội thành (từ <strong>' + fmtVND(FREESHIP_THRESHOLD) + 'đ</strong>).';
                            if (shippingTxt)
                                shippingTxt.textContent = 'Chưa chọn sản phẩm';
                        } else if (finalTotal >= FREESHIP_THRESHOLD) {
                            statusEl.innerHTML = '<i class="fi fi-rr-check-circle"></i> Đơn hàng của bạn đã đủ điều kiện <strong>Freeship nội thành (từ ' + fmtVND(FREESHIP_THRESHOLD) + 'đ)</strong>!';
                            if (shippingTxt)
                                shippingTxt.innerHTML = '<strong style="color: #266A3C;">Miễn phí (0 ₫)</strong>';
                        } else {
                            const missing = FREESHIP_THRESHOLD - finalTotal;
                            statusEl.innerHTML = '<i class="fi fi-rr-info"></i> Mua thêm <strong>' + fmtVND(missing) + 'đ</strong> để được Freeship nội thành!';
                            if (shippingTxt)
                                shippingTxt.textContent = 'Tính tại bước đặt hàng';
                        }
                    }

                    const checkoutBtn = document.getElementById('checkoutBtnLink');
                    const checkoutBtnText = document.getElementById('checkoutBtnText');
                    if (checkoutBtn) {
                        if (selectedLines === 0) {
                            checkoutBtn.style.pointerEvents = 'none';
                            checkoutBtn.style.background = '#D5CBC5';
                            checkoutBtn.style.boxShadow = 'none';
                            if (checkoutBtnText)
                                checkoutBtnText.textContent = 'Vui lòng chọn sản phẩm';
                        } else if (hasOverStock) {
                            checkoutBtn.style.pointerEvents = 'none';
                            checkoutBtn.style.background = '#D5CBC5';
                            checkoutBtn.style.boxShadow = 'none';
                            if (checkoutBtnText)
                                checkoutBtnText.textContent = 'Số lượng vượt tồn kho';
                        } else {
                            checkoutBtn.style.pointerEvents = 'auto';
                            checkoutBtn.style.background = '';
                            checkoutBtn.style.boxShadow = '';
                            checkoutBtn.href = '${ctx}/checkout?itemIds=' + selectedIds.join(',');
                            if (checkoutBtnText)
                                checkoutBtnText.textContent = 'Mua hàng (' + selectedLines + ')';
                        }
                    }
                }

                const selectAllCb = document.getElementById('selectAllCheckbox');
                const itemCheckboxes = document.querySelectorAll('.js-item-checkbox:not(:disabled)');

                // Kiểm tra URL param ?selectProduct=... (từ nút Mua ngay ở trang chi tiết)
                const urlParams = new URLSearchParams(window.location.search);
                const selectProdId = urlParams.get('selectProduct');
                if (selectProdId) {
                    let matchedCount = 0;
                    itemCheckboxes.forEach(cb => {
                        const itemEl = cb.closest('.js-cart-item');
                        const prodId = itemEl ? (itemEl.dataset.productId || cb.dataset.productId) : cb.dataset.productId;
                        if (prodId && String(prodId) === String(selectProdId)) {
                            cb.checked = true;
                            matchedCount++;
                        } else {
                            cb.checked = false;
                        }
                    });
                    if (selectAllCb) {
                        selectAllCb.checked = (matchedCount > 0 && matchedCount === itemCheckboxes.length);
                    }
                }

                if (selectAllCb) {
                    selectAllCb.addEventListener('change', function () {
                        itemCheckboxes.forEach(cb => cb.checked = selectAllCb.checked);
                        recalculateCartTotals();
                    });
                }

                itemCheckboxes.forEach(cb => {
                    cb.addEventListener('change', function () {
                        if (selectAllCb) {
                            selectAllCb.checked = Array.from(itemCheckboxes).every(c => c.checked);
                        }
                        recalculateCartTotals();
                    });
                });

                let debounceTimers = {};
                function syncQuantityToServer(itemEl, newQty) {
                    const form = itemEl.querySelector('.js-qty-form');
                    const minusBtn = itemEl.querySelector('.js-qty-minus');
                    const qtyInput = itemEl.querySelector('.js-qty-input');
                    const savingBadge = itemEl.querySelector('.js-saving-badge');
                    const lineId = itemEl.dataset.lineId;

                    if (minusBtn) {
                        minusBtn.disabled = (newQty <= 1);
                    }

                    recalculateCartTotals();

                    clearTimeout(debounceTimers[lineId]);
                    debounceTimers[lineId] = setTimeout(() => {
                        const formData = new URLSearchParams();
                        const csrfInput = form.querySelector('input[type="hidden"]');
                        if (csrfInput) {
                            formData.append(csrfInput.name, csrfInput.value);
                        }
                        formData.append('quantity', newQty);

                        fetch(form.action, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            body: formData.toString()
                        }).then(res => res.json()).then(data => {
                            if (data && data.ok) {
                                itemEl.dataset.prevQty = data.quantity;
                                if (savingBadge) {
                                    savingBadge.style.color = '';
                                    savingBadge.innerHTML = '<i class="fi fi-rr-check"></i> Đã lưu';
                                    savingBadge.classList.add('show');
                                    setTimeout(() => savingBadge.classList.remove('show'), 1400);
                                }
                                if (typeof data.cartItemCount === 'number') {
                                    document.querySelectorAll('.cart-badge').forEach(b => b.textContent = data.cartItemCount);
                                }
                            } else {
                                const fallbackQty = parseInt(itemEl.dataset.prevQty || 1, 10);
                                if (qtyInput) {
                                    qtyInput.value = fallbackQty;
                                }
                                if (minusBtn) {
                                    minusBtn.disabled = (fallbackQty <= 1);
                                }
                                recalculateCartTotals();
                                if (savingBadge) {
                                    savingBadge.style.color = '#B92B19';
                                    savingBadge.innerHTML = '<i class="fi fi-rr-exclamation"></i> ' + ((data && data.message) ? data.message : 'Vượt số lượng tồn kho');
                                    savingBadge.classList.add('show');
                                    setTimeout(() => {
                                        savingBadge.classList.remove('show');
                                        savingBadge.style.color = '';
                                        savingBadge.innerHTML = '<i class="fi fi-rr-check"></i> Đã lưu';
                                    }, 3200);
                                }
                            }
                        }).catch(err => console.error('Lỗi lưu số lượng:', err));
                    }, 350);
                }

                document.querySelectorAll('.js-cart-item').forEach(itemEl => {
                    const minusBtn = itemEl.querySelector('.js-qty-minus');
                    const plusBtn = itemEl.querySelector('.js-qty-plus');
                    const qtyInput = itemEl.querySelector('.js-qty-input');
                    const warnEl = itemEl.querySelector('.js-stock-warning');
                    const maxAvailable = parseInt(itemEl.dataset.available || 0, 10);

                    function checkStockWarning(val) {
                        if (maxAvailable > 0 && val > maxAvailable) {
                            if (warnEl) warnEl.style.display = 'block';
                            if (qtyInput) {
                                qtyInput.style.borderColor = '#d9381e';
                                qtyInput.style.color = '#d9381e';
                            }
                            return false;
                        } else {
                            if (warnEl) warnEl.style.display = 'none';
                            if (qtyInput) {
                                qtyInput.style.borderColor = '';
                                qtyInput.style.color = '';
                            }
                            return true;
                        }
                    }

                    // Kiểm tra cảnh báo ngay khi tải trang
                    if (qtyInput) {
                        const initVal = parseInt(qtyInput.value, 10) || 1;
                        checkStockWarning(initVal);
                    }

                    if (minusBtn && qtyInput) {
                        minusBtn.addEventListener('click', () => {
                            let val = parseInt(qtyInput.value, 10) || 1;
                            if (val > 1) {
                                val = val - 1;
                                qtyInput.value = val;
                                checkStockWarning(val);
                                syncQuantityToServer(itemEl, val);
                            }
                        });
                    }

                    if (plusBtn && qtyInput) {
                        plusBtn.addEventListener('click', () => {
                            let val = parseInt(qtyInput.value, 10) || 1;
                            let nextVal = val + 1;
                            if (maxAvailable > 0 && nextVal > maxAvailable) {
                                checkStockWarning(nextVal);
                                recalculateCartTotals();
                                return;
                            }
                            qtyInput.value = nextVal;
                            checkStockWarning(nextVal);
                            syncQuantityToServer(itemEl, nextVal);
                        });
                    }

                    if (qtyInput) {
                        qtyInput.addEventListener('input', () => {
                            let val = parseInt(qtyInput.value, 10);
                            if (isNaN(val) || val < 1) {
                                return;
                            }
                            const valid = checkStockWarning(val);
                            if (valid) {
                                syncQuantityToServer(itemEl, val);
                            } else {
                                recalculateCartTotals();
                            }
                        });

                        qtyInput.addEventListener('blur', () => {
                            let val = parseInt(qtyInput.value, 10);
                            if (isNaN(val) || val < 1) {
                                qtyInput.value = 1;
                                checkStockWarning(1);
                                syncQuantityToServer(itemEl, 1);
                            } else {
                                checkStockWarning(val);
                            }
                        });
                    }
                });

                recalculateCartTotals();
            });
        </script>
        <%-- Nhúng Footer --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

        <%-- Nhúng Nút Chat nổi --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>
    </body>
</html>
