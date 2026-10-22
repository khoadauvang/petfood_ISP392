<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="cart" />
<%-- Trang tự hiện thông báo flash bên dưới, header không hiện lại --%>
<c:set var="ownFlash" value="true"/>
<%-- Model: cart (CartView: lines, subtotal, totalQuantity, hasProblems).
     Khách tick các dòng muốn mua; "Đặt hàng" gửi /checkout?itemIds=..., dòng không tick ở lại giỏ.
     Dòng hết hàng / vượt tồn không tick được. Lựa chọn được nhớ trong sessionStorage để không mất khi trang tải lại. --%>

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

        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <c:set var="regTotal" value="0" />
        <c:set var="flashTotal" value="0" />
        <c:set var="regCount" value="0" />
        <c:set var="flashCount" value="0" />
        <c:set var="unavailableCount" value="0" />

        <c:if test="${not empty cart and not empty cart.lines}">
            <c:forEach var="line" items="${cart.lines}">
                <c:choose>
                    <c:when test="${not empty line.problem}">
                        <c:set var="unavailableCount" value="${unavailableCount + 1}" />
                    </c:when>
                    <c:when test="${line.flashSale}">
                        <c:set var="flashCount" value="${flashCount + 1}" />
                        <c:set var="flashTotal" value="${flashTotal + line.lineTotal}" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="regCount" value="${regCount + 1}" />
                        <c:set var="regTotal" value="${regTotal + line.lineTotal}" />
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </c:if>

        <%-- Tạm tính của server: các dòng hợp lệ, chưa trừ giảm giá hạng (hạng mỗi khách khác nhau, tính ở bước đặt hàng) --%>
        <c:set var="finalTotal" value="${not empty cart ? cart.subtotal : 0}" />
        <c:set var="freeshipThreshold" value="150000" />
        <c:set var="freeshipPct" value="${(finalTotal >= freeshipThreshold) ? 100 : ((finalTotal * 100) / freeshipThreshold)}" />

        <main class="page-container">

            <c:if test="${not empty successMessage}">
                <div style="margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; background: #E9F6EE; border: 1px solid #A8DFB9; color: #266A3C; font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 8px;">
                    <i class="fi fi-rr-check-circle"></i>
                    <span><c:out value="${successMessage}"/></span>
                </div>
            </c:if>
            <c:if test="${not empty warningMessage}">
                <div style="margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; background: #FFF8E1; border: 1px solid #FFE08A; color: #8A5A00; font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 8px;">
                    <i class="fi fi-rr-info"></i>
                    <span><c:out value="${warningMessage}"/></span>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div style="margin-bottom: 16px; padding: 12px 18px; border-radius: 12px; background: #FDE8E4; border: 1px solid #F5C2B8; color: #B92B19; font-size: 13px; font-weight: 600; display: flex; align-items: center; gap: 8px;">
                    <i class="fi fi-rr-exclamation"></i>
                    <span><c:out value="${errorMessage}"/></span>
                </div>
            </c:if>

            <div class="cart-topbar">
                <nav class="breadcrumb" aria-label="Breadcrumb">
                    <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a>
                    <span class="sep">/</span>
                    <span class="current">Giỏ hàng của bạn</span>
                </nav>
                <div class="trust-pill">
                    <i class="fi fi-rr-shield-check"></i>
                    <span>Cam kết hạn dùng tối thiểu 90 ngày (hoặc minh bạch theo từng deal)</span>
                </div>
            </div>

            <section class="cart-hero-row">
                <div class="cart-title-area">
                    <div class="title-with-badge">
                        <h1>Giỏ hàng của bạn</h1>
                        <span class="item-count-badge" id="headerTotalBadge">${not empty cart.totalQuantity ? cart.totalQuantity : 0} sản phẩm</span>
                    </div>
                    <p>Điều chỉnh số lượng trực tiếp, giỏ hàng tự lưu và cập nhật lại giá, tồn kho.</p>
                </div>

                <div class="freeship-card">
                    <div class="freeship-top">
                        <span class="freeship-title">
                            <i class="fi fi-rr-shipping-fast"></i> Miễn phí giao hàng (đơn từ 150K, trong bán kính 5km)
                        </span>
                        <span class="freeship-numbers">
                            Đã đạt <strong id="freeshipCurrentText"><fmt:formatNumber value="${finalTotal}" type="number" maxFractionDigits="0"/></strong>đ / 150.000đ
                        </span>
                    </div>
                    <div class="freeship-bar">
                        <div class="freeship-fill" id="freeshipBarFill" style="width: ${freeshipPct}%; transition: width 0.25s ease;"></div>
                    </div>
                    <div class="freeship-status" id="freeshipStatusText">
                        <c:choose>
                            <c:when test="${finalTotal >= freeshipThreshold}">
                                <i class="fi fi-rr-check-circle"></i> Tạm tính đã đủ mức Freeship (áp dụng khi giao trong bán kính 5km)!
                            </c:when>
                            <c:otherwise>
                                <i class="fi fi-rr-info"></i> Mua thêm <strong><fmt:formatNumber value="${freeshipThreshold - finalTotal}" type="number" maxFractionDigits="0"/>đ</strong> để được Freeship!
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </section>

            <c:choose>
                <c:when test="${empty cart.lines}">
                    <div style="background: #FFFFFF; border: 1px solid #F4E3C9; border-radius: 18px; padding: 56px 24px; text-align: center; box-shadow: 0 6px 20px rgba(61,48,40,0.04);">
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
                                    <span>Chọn tất cả sản phẩm hợp lệ (<span id="selectedLineCount">0</span> dòng đã chọn)</span>
                                </label>
                                <span style="font-size: 12.5px; color: #817872;">
                                    <i class="fi fi-rr-bolt" style="color: #F47721;"></i> Gõ số hoặc bấm +/- để đổi số lượng tức thì
                                </span>
                            </div>

                            <!-- MỤC 1: HÀNG GIÁ THƯỜNG -->
                            <section class="cart-group-card regular-group">
                                <div class="group-header">
                                    <div class="group-title-wrap">
                                        <input type="checkbox" class="cart-checkbox group-select-checkbox" data-target-group="regular" checked title="Chọn cả nhóm hàng thường">
                                        <span class="group-icon regular-icon"><i class="fi fi-rr-shopping-bag"></i></span>
                                        <div>
                                            <h2>1. Hàng giá thường</h2>
                                            <p>Áp dụng giảm giá theo hạng thành viên</p>
                                        </div>
                                    </div>
                                    <span class="group-count-pill">${regCount} dòng sản phẩm</span>
                                </div>

                                <div class="group-items">
                                    <c:choose>
                                        <c:when test="${regCount > 0}">
                                            <c:forEach var="line" items="${cart.lines}">
                                                <c:if test="${not line.flashSale and empty line.problem}">
                                                    <div class="cart-item has-checkbox js-cart-item"
                                                         data-line-id="${line.id}"
                                                         data-line-total="${line.lineTotal}"
                                                         data-quantity="${line.quantity}"
                                                         data-flash-sale="false"
                                                         data-available="${line.availableQty}">

                                                        <%-- Tick để đặt dòng này; bỏ tick thì dòng ở lại giỏ --%>
                                                        <input type="checkbox" class="cart-checkbox js-item-checkbox" data-group="regular"
                                                               value="${line.id}" checked title="Chọn mua sản phẩm này">

                                                        <a href="${ctx}/products/${line.productId}" class="item-thumb">
                                                            <c:choose>
                                                                <c:when test="${not empty line.imageUrl}">
                                                                    <img src="${ctx}<c:out value='${line.imageUrl}'/>" alt="<c:out value='${line.name}'/>">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img src="${ctx}/images/cho.png" alt="<c:out value='${line.name}'/>">
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </a>

                                                        <div class="item-details">
                                                            <div class="item-tags">
                                                                <span class="tag-pill gray-tag">Hàng tiêu chuẩn</span>
                                                                <span class="tag-pill orange-outline-tag">
                                                                    <i class="fi fi-rr-badge-check"></i> Chính hãng
                                                                </span>
                                                                <c:if test="${line.availableQty > 0}">
                                                                    <span class="tag-pill muted-tag">Còn ${line.availableQty} gói</span>
                                                                </c:if>
                                                            </div>
                                                            <h3>
                                                                <a href="${ctx}/products/${line.productId}">
                                                                    <c:out value="${line.name}"/>
                                                                </a>
                                                            </h3>
                                                            <p class="unit-price">
                                                                Đơn giá: <strong><fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫</strong>
                                                            </p>
                                                        </div>

                                                        <div class="item-qty-wrapper">
                                                            <form method="post" action="${ctx}/cart/items/${line.id}/quantity" class="qty-form js-qty-form">
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
                                                        </div>

                                                        <div class="item-subtotal">
                                                            <span class="subtotal-price js-line-total">
                                                                <fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫
                                                            </span>
                                                            <span class="subtotal-note js-line-note">
                                                                <c:choose>
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
                                            <div style="padding: 24px 0; text-align: center; color: #817872; font-size: 13px;">
                                                Chưa có sản phẩm giá thường nào trong giỏ hàng.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="group-footer regular-footer">
                                    <div class="footer-note">
                                        <i class="fi fi-rr-tags"></i>
                                        <span>Được áp dụng chính sách giảm giá hạng thành viên tại bước thanh toán</span>
                                    </div>
                                    <div class="footer-subtotal">
                                        <span>Tạm tính nhóm thường (đã chọn):</span>
                                        <strong id="regGroupSubtotal"><fmt:formatNumber value="${regTotal}" type="number"/> ₫</strong>
                                    </div>
                                </div>
                            </section>

                            <!-- MỤC 2: HÀNG FLASH SALE -->
                            <section class="cart-group-card flash-group">
                                <div class="group-header flash-header">
                                    <div class="group-title-wrap">
                                        <input type="checkbox" class="cart-checkbox group-select-checkbox" data-target-group="flash" checked title="Chọn cả nhóm Flash Sale">
                                        <span class="group-icon flash-icon"><i class="fi fi-rr-flame"></i></span>
                                        <div>
                                            <div class="flash-title-line">
                                                <h2>2. Hàng Flash Sale</h2>
                                                <span class="flash-lightning-badge">GIÁ CHỚP NHOÁNG</span>
                                            </div>
                                            <p>Sản phẩm thuộc khung giờ xả kho vàng, số lượng giới hạn theo suất mua</p>
                                        </div>
                                    </div>

                                </div>

                                <div class="br-rule-notice">
                                    <i class="fi fi-rr-exclamation"></i>
                                    <p>
                                        <strong>Quy định BR-43:</strong> Sản phẩm Flash Sale <strong>không áp dụng gộp thêm chiết khấu hạng thành viên</strong> và tách riêng khỏi dòng giá thường (BR-65).
                                    </p>
                                </div>

                                <div class="group-items">
                                    <c:choose>
                                        <c:when test="${flashCount > 0}">
                                            <c:forEach var="line" items="${cart.lines}">
                                                <c:if test="${line.flashSale and empty line.problem}">
                                                    <div class="cart-item flash-item has-checkbox js-cart-item"
                                                         data-line-id="${line.id}"
                                                         data-line-total="${line.lineTotal}"
                                                         data-quantity="${line.quantity}"
                                                         data-flash-sale="true"
                                                         data-available="${line.availableQty}">

                                                        <%-- Tick để đặt dòng này; bỏ tick thì dòng ở lại giỏ --%>
                                                        <input type="checkbox" class="cart-checkbox js-item-checkbox" data-group="flash"
                                                               value="${line.id}" checked title="Chọn mua sản phẩm này">

                                                        <a href="${ctx}/products/${line.productId}" class="item-thumb">
                                                            <span class="item-discount-badge">SALE</span>
                                                            <c:choose>
                                                                <c:when test="${not empty line.imageUrl}">
                                                                    <img src="${ctx}<c:out value='${line.imageUrl}'/>" alt="<c:out value='${line.name}'/>">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img src="${ctx}/images/cho.png" alt="<c:out value='${line.name}'/>">
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </a>

                                                        <div class="item-details">
                                                            <div class="item-tags">
                                                                <span class="tag-pill flash-deal-tag">
                                                                    <i class="fi fi-rr-bolt"></i>
                                                                    <c:out value="${not empty line.flashSaleName ? line.flashSaleName : 'Flash Sale Deal'}"/>
                                                                </span>
                                                                <c:if test="${not empty line.expiryNote}">
                                                                    <span class="tag-pill expiry-tag">
                                                                        <i class="fi fi-rr-calendar"></i> <c:out value="${line.expiryNote}"/>
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                            <h3>
                                                                <a href="${ctx}/products/${line.productId}">
                                                                    <c:out value="${line.name}"/>
                                                                </a>
                                                            </h3>
                                                            <div class="flash-price-line">
                                                                <span class="flash-sale-price">
                                                                    <fmt:formatNumber value="${line.unitPrice}" type="number"/> ₫
                                                                </span>
                                                                <c:if test="${not empty line.regularPrice and line.regularPrice > line.unitPrice}">
                                                                    <span class="flash-old-price">
                                                                        <fmt:formatNumber value="${line.regularPrice}" type="number"/> ₫
                                                                    </span>
                                                                    <span class="save-pill">
                                                                        Tiết kiệm <fmt:formatNumber value="${line.regularPrice - line.unitPrice}" type="number"/> ₫
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                        </div>

                                                        <div class="item-qty-wrapper">
                                                            <form method="post" action="${ctx}/cart/items/${line.id}/quantity" class="qty-form js-qty-form">
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
                                                            <c:if test="${line.availableQty > 0}">
                                                                <span class="limit-note">Còn ${line.availableQty} suất</span>
                                                            </c:if>
                                                        </div>

                                                        <div class="item-subtotal">
                                                            <span class="subtotal-price flash-color js-line-total">
                                                                <fmt:formatNumber value="${line.lineTotal}" type="number"/> ₫
                                                            </span>
                                                            <span class="subtotal-note js-line-note">Giá chốt deal</span>
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
                                            <div style="padding: 24px 0; text-align: center; color: #817872; font-size: 13px;">
                                                Chưa có suất Flash Sale nào trong giỏ. <a href="${ctx}/flash-sale" style="color: #F47721; font-weight: 700;">Săn Flash Sale</a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="group-footer flash-footer">
                                    <div class="footer-note">
                                        <i class="fi fi-rr-lock"></i>
                                        <span>Giá Flash Sale áp dụng khi chiến dịch còn mở và còn suất lúc đặt hàng</span>
                                    </div>
                                    <div class="footer-subtotal">
                                        <span>Tạm tính Flash Sale (đã chọn):</span>
                                        <strong class="flash-color" id="flashGroupSubtotal"><fmt:formatNumber value="${flashTotal}" type="number"/> ₫</strong>
                                    </div>
                                </div>
                            </section>

                            <!-- ================= MỤC 3: SẢN PHẨM HẾT HÀNG HOẶC LỖI TỒN KHO (TẠCH RIÊNG Ở CUỐI) ================= -->
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
                                                <div class="cart-item has-checkbox" style="background: #FFF5F5; opacity: 0.85; border-radius: 12px; padding: 14px 10px; margin-bottom: 12px;">
                                                    <input type="checkbox" class="cart-checkbox" disabled title="Sản phẩm hết hàng hoặc vượt tồn, không chọn mua được">
                                                    <a href="${ctx}/products/${line.productId}" class="item-thumb">
                                                        <c:choose>
                                                            <c:when test="${not empty line.imageUrl}">
                                                                <img src="${ctx}<c:out value='${line.imageUrl}'/>" alt="<c:out value='${line.name}'/>">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="${ctx}/images/cho.png" alt="<c:out value='${line.name}'/>">
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
                                                        <%-- Không đặt max: dòng đang vượt tồn vẫn phải gửi được số nhỏ hơn; server kiểm tra --%>
                                                        <form method="post" action="${ctx}/cart/items/${line.id}/quantity" class="qty-form">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                            <input type="number" name="quantity" value="${line.quantity}" min="1" class="qty-input-editable" aria-label="Số lượng">
                                                            <button type="submit" class="qty-btn" title="Cập nhật số lượng"><i class="fi fi-rr-check"></i></button>
                                                        </form>
                                                        <c:if test="${line.availableQty > 0}">
                                                            <span class="limit-note">Còn ${line.availableQty}</span>
                                                        </c:if>
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
                                <a href="${ctx}/flash-sale" class="clear-cart-btn" style="color: #F47721; border-color: #F4E3C9; background: #FFF6EE;">
                                    <i class="fi fi-rr-flame"></i> Xem thêm deal Flash Sale
                                </a>
                            </div>

                        </div>

                        <aside class="cart-right-col">
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

                                    <div class="summary-row">
                                        <span>Tạm tính Flash Sale: <i class="fi fi-rr-flame text-orange"></i></span>
                                        <strong class="text-orange" id="summaryFlashTotal"><fmt:formatNumber value="${flashTotal}" type="number"/> ₫</strong>
                                    </div>

                                    <div class="summary-row">
                                        <span>Tổng tạm tính (<span id="summarySelectedQty">${cart.totalQuantity}</span> sản phẩm đã chọn):</span>
                                        <strong id="summaryRawSubtotal"><fmt:formatNumber value="${cart.subtotal}" type="number"/> ₫</strong>
                                    </div>

                                    <div class="vip-discount-box">
                                        <div class="vip-discount-row">
                                            <span class="vip-label">
                                                <i class="fi fi-rr-crown"></i> Ưu đãi thành viên:
                                            </span>
                                            <strong class="vip-amount">Tính khi đặt hàng</strong>
                                        </div>
                                        <p class="vip-rule-note">
                                            * Giảm giá theo hạng thành viên của bạn chỉ tính trên hàng giá thường, không áp dụng cho sản phẩm Flash Sale và phí ship (BR-43).
                                        </p>
                                    </div>

                                    <div class="summary-row shipping-row">
                                        <span>Phí vận chuyển nội thành:</span>
                                        <span class="shipping-calc-text" id="summaryShippingText">Tính tại bước đặt hàng</span>
                                    </div>
                                </div>

                                <div class="summary-total-section">
                                    <div class="total-row">
                                        <span>Tạm tính:</span>
                                        <strong class="grand-total" id="summaryFinalTotal"><fmt:formatNumber value="${cart.subtotal}" type="number"/> ₫</strong>
                                    </div>
                                    <span class="vat-note">(Chưa trừ giảm giá hạng, chưa gồm phí giao hàng)</span>
                                </div>

                                <%-- href / trạng thái do script bên dưới đặt theo các dòng đang tick --%>
                                <a href="${ctx}/checkout" id="checkoutBtnLink" class="checkout-btn">
                                    <span id="checkoutBtnText">Tiến hành đặt hàng</span>
                                    <i class="fi fi-rr-arrow-right"></i>
                                </a>
                                <c:if test="${cart.hasProblems}">
                                    <%-- Dòng lỗi không tick được nên không chặn đặt các dòng khác --%>
                                    <p style="margin-top: 8px; color: #B92B19; font-size: 12.5px;">
                                        Có sản phẩm hết hàng hoặc vượt số lượng còn lại, không chọn mua được. Sửa số lượng hoặc xoá nếu muốn mua.
                                    </p>
                                </c:if>
                            </div>

                            <div class="policy-card">
                                <h3><i class="fi fi-rr-shield-check"></i> Chính sách an tâm mua sắm</h3>
                                <ul class="policy-list">
                                    <li>
                                        <span class="policy-icon"><i class="fi fi-rr-refresh"></i></span>
                                        <div>
                                            <strong>Trả hàng trong 3 ngày</strong>
                                            <p>Trả hàng và hoàn tiền nếu sản phẩm lỗi bao bì, giao sai hoặc hạn dùng dưới cam kết.</p>
                                        </div>
                                    </li>
                                    <li>
                                        <span class="policy-icon"><i class="fi fi-rr-badge-check"></i></span>
                                        <div>
                                            <strong>Hàng chính hãng 100%</strong>
                                            <p>Nhập khẩu chính ngạch từ các thương hiệu dinh dưỡng thú cưng uy tín quốc tế.</p>
                                        </div>
                                    </li>
                                    <li>
                                        <span class="policy-icon"><i class="fi fi-rr-bolt"></i></span>
                                        <div>
                                            <strong>Freeship đơn từ 150K</strong>
                                            <p>Miễn phí giao hàng cho đơn từ 150.000đ (sau giảm giá hạng) trong bán kính 5km.</p>
                                        </div>
                                    </li>
                                </ul>
                            </div>
                        </aside>
                    </div>
                </c:otherwise>
            </c:choose>

        </main>

        
        <script>
            // Đổi số lượng: bấm +/- hoặc gõ số rồi chờ một chút thì gửi form (POST /cart/items/{id}/quantity, redirect về /cart).
            // Trang tải lại nên thành tiền, tạm tính, lỗi vượt tồn luôn lấy từ server.
            document.addEventListener("DOMContentLoaded", function () {
                document.querySelectorAll('.js-cart-item').forEach(function (itemEl) {
                    const form = itemEl.querySelector('.js-qty-form');
                    const qtyInput = itemEl.querySelector('.js-qty-input');
                    const minusBtn = itemEl.querySelector('.js-qty-minus');
                    const plusBtn = itemEl.querySelector('.js-qty-plus');
                    const maxAvailable = parseInt(itemEl.dataset.available || 0, 10);
                    const original = parseInt(qtyInput.value, 10);
                    let timer = null;

                    function scheduleSubmit() {
                        clearTimeout(timer);
                        timer = setTimeout(function () {
                            const val = parseInt(qtyInput.value, 10);
                            if (!isNaN(val) && val >= 1 && val !== original) {
                                form.submit();
                            }
                        }, 600);
                    }

                    minusBtn.addEventListener('click', function () {
                        const val = parseInt(qtyInput.value, 10) || 1;
                        if (val > 1) {
                            qtyInput.value = val - 1;
                            minusBtn.disabled = (val - 1 <= 1);
                            scheduleSubmit();
                        }
                    });
                    plusBtn.addEventListener('click', function () {
                        const val = parseInt(qtyInput.value, 10) || 1;
                        if (maxAvailable > 0 && val >= maxAvailable) {
                            return;
                        }
                        qtyInput.value = val + 1;
                        minusBtn.disabled = false;
                        scheduleSubmit();
                    });
                    qtyInput.addEventListener('input', scheduleSubmit);
                    qtyInput.addEventListener('blur', function () {
                        const val = parseInt(qtyInput.value, 10);
                        if (isNaN(val) || val < 1) {
                            qtyInput.value = original;
                        }
                    });
                });
            });

            // Chọn dòng để đặt: tạm tính lấy thành tiền từ server (data-line-total), chỉ cộng các dòng đang tick.
            // Dòng bỏ tick được nhớ trong sessionStorage (trang tải lại sau khi đổi số lượng vẫn giữ lựa chọn).
            document.addEventListener("DOMContentLoaded", function () {
                const STORE_KEY = 'petfood.cart.unchecked';
                const FREESHIP_THRESHOLD = ${freeshipThreshold};
                const checkoutUrl = '${ctx}/checkout';
                const fmtVND = function (n) { return Math.round(n).toLocaleString('vi-VN') + ' ₫'; };
                const items = Array.from(document.querySelectorAll('.js-cart-item'));
                const itemCheckboxes = Array.from(document.querySelectorAll('.js-item-checkbox'));
                const groupCheckboxes = Array.from(document.querySelectorAll('.group-select-checkbox'));
                const selectAll = document.getElementById('selectAllCheckbox');

                function loadUnchecked() {
                    try { return JSON.parse(sessionStorage.getItem(STORE_KEY) || '[]'); } catch (e) { return []; }
                }
                function saveUnchecked() {
                    const ids = itemCheckboxes.filter(function (cb) { return !cb.checked; }).map(function (cb) { return cb.value; });
                    try { sessionStorage.setItem(STORE_KEY, JSON.stringify(ids)); } catch (e) { /* trình duyệt chặn storage: chỉ mất phần nhớ lựa chọn */ }
                }
                function setText(id, text) {
                    const el = document.getElementById(id);
                    if (el) el.textContent = text;
                }

                function refresh() {
                    let regTotal = 0, flashTotal = 0, qty = 0;
                    const ids = [];
                    items.forEach(function (item) {
                        const cb = item.querySelector('.js-item-checkbox');
                        const checked = cb && cb.checked;
                        item.classList.toggle('unchecked-row', !checked);
                        if (!checked) return;
                        const total = parseFloat(item.dataset.lineTotal || 0);
                        if (item.dataset.flashSale === 'true') flashTotal += total; else regTotal += total;
                        qty += parseInt(item.dataset.quantity || 0, 10);
                        ids.push(cb.value);
                    });
                    const subtotal = regTotal + flashTotal;

                    setText('selectedLineCount', ids.length);
                    setText('regGroupSubtotal', fmtVND(regTotal));
                    setText('flashGroupSubtotal', fmtVND(flashTotal));
                    setText('summaryRegTotal', fmtVND(regTotal));
                    setText('summaryFlashTotal', fmtVND(flashTotal));
                    setText('summarySelectedQty', qty);
                    setText('summaryRawSubtotal', fmtVND(subtotal));
                    setText('summaryFinalTotal', fmtVND(subtotal));

                    // Thanh freeship theo tạm tính các dòng đã chọn (điều kiện thật còn trừ giảm giá hạng và khoảng cách)
                    setText('freeshipCurrentText', Math.round(subtotal).toLocaleString('vi-VN'));
                    const bar = document.getElementById('freeshipBarFill');
                    if (bar) bar.style.width = Math.min(100, subtotal * 100 / FREESHIP_THRESHOLD) + '%';
                    const status = document.getElementById('freeshipStatusText');
                    if (status) {
                        status.innerHTML = subtotal >= FREESHIP_THRESHOLD
                            ? '<i class="fi fi-rr-check-circle"></i> Tạm tính đã đủ mức Freeship (áp dụng khi giao trong bán kính 5km)!'
                            : '<i class="fi fi-rr-info"></i> Mua thêm <strong>' + Math.round(FREESHIP_THRESHOLD - subtotal).toLocaleString('vi-VN') + 'đ</strong> để được Freeship!';
                    }

                    const btn = document.getElementById('checkoutBtnLink');
                    if (btn) {
                        const none = ids.length === 0;
                        btn.style.pointerEvents = none ? 'none' : '';
                        btn.style.background = none ? '#D5CBC5' : '';
                        btn.style.boxShadow = none ? 'none' : '';
                        btn.href = none ? checkoutUrl : checkoutUrl + '?itemIds=' + ids.join(',');
                        setText('checkoutBtnText', none ? 'Vui lòng chọn sản phẩm' : 'Đặt hàng (' + ids.length + ' dòng đã chọn)');
                    }

                    if (selectAll) {
                        selectAll.checked = itemCheckboxes.length > 0 && itemCheckboxes.every(function (cb) { return cb.checked; });
                    }
                    groupCheckboxes.forEach(function (g) {
                        const own = itemCheckboxes.filter(function (cb) { return cb.dataset.group === g.dataset.targetGroup; });
                        g.checked = own.length > 0 && own.every(function (cb) { return cb.checked; });
                        g.disabled = own.length === 0;
                    });
                }

                const unchecked = loadUnchecked();
                itemCheckboxes.forEach(function (cb) {
                    if (unchecked.indexOf(cb.value) !== -1) cb.checked = false;
                    cb.addEventListener('change', function () { saveUnchecked(); refresh(); });
                });
                groupCheckboxes.forEach(function (g) {
                    g.addEventListener('change', function () {
                        itemCheckboxes.forEach(function (cb) {
                            if (cb.dataset.group === g.dataset.targetGroup) cb.checked = g.checked;
                        });
                        saveUnchecked();
                        refresh();
                    });
                });
                if (selectAll) {
                    selectAll.addEventListener('change', function () {
                        itemCheckboxes.forEach(function (cb) { cb.checked = selectAll.checked; });
                        saveUnchecked();
                        refresh();
                    });
                }
                refresh();
            });
        </script>
        <%-- Nhúng Footer --%>
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

        <%-- Nhúng Nút Chat nổi --%>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>
    </body>
</html>