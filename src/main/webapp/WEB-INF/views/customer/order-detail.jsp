<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Chi tiết đơn hàng #PFS-${order.id} · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/order-detail.css">
    </head>
    <body>

        <!-- HEADER DÙNG CHUNG -->
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <!-- BREADCRUMB -->
        <div class="breadcrumb-bar">
            <div>
                <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a> › 
                <a href="${ctx}/profile">Tài khoản</a> › 
                <a href="${ctx}/orders">Đơn hàng của tôi</a> › 
                <strong>Chi tiết đơn hàng #PFS-${order.id}</strong>
            </div>
        </div>

        <div class="page-container">

            <!-- SIDEBAR LEFT DÙNG CHUNG -->
            <c:set var="activeMenu" value="orders" />
            <c:set var="onProfilePage" value="${false}" />
            <%@ include file="/WEB-INF/views/common/_customer-sidebar.jspf" %>

            <!-- MAIN CONTENT -->
            <main class="main-content">

                <!-- THÔNG BÁO VNPAY -->
                <c:if test="${order.awaitingVnpay}">
                    <div class="vnpay-alert-box">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <i class="fi fi-rr-info" style="font-size: 20px;"></i>
                            <div>
                                <strong>Đơn đang chờ thanh toán VNPay:</strong> Hàng được giữ đến <strong>${order.vnpayHoldUntil}</strong>, quá hạn đơn sẽ tự hủy.
                            </div>
                        </div>
                        <form method="post" action="${ctx}/orders/${order.id}/pay" style="margin:0;">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            </c:if>
                            <button type="submit" class="btn-action-primary">
                                <i class="fi fi-rr-credit-card"></i> Tiếp tục thanh toán VNPay
                            </button>
                        </form>
                    </div>
                </c:if>

                <!-- CARD TOP: TIẾN TRÌNH XỬ LÝ ĐƠN HÀNG -->
                <div class="card-box">
                    <div class="header-top-row">
                        <div>
                            <h1 class="order-title">
                                <i class="fi fi-rr-box" style="color: var(--primary-orange, #f47721);"></i> Chi tiết đơn hàng #PFS-${order.id}
                            </h1>
                            <div style="font-size:13px; color:var(--text-secondary, #817872); margin-top:6px; display: flex; align-items: center; gap: 6px;">
                                <i class="fi fi-rr-calendar"></i> Ngày đặt: <strong>${order.createdAtText}</strong> · 
                                <i class="fi fi-rr-shipping-fast" style="margin-left: 4px;"></i> Hình thức: <strong>${order.shippingFee == 0 ? 'Giao tiêu chuẩn' : 'Giao nhanh 2H'}</strong>
                            </div>
                        </div>
                        <div style="display:flex; align-items:center; gap:10px;">
                            <span class="badge-status-pill ${order.status}">${not empty order.status.label ? order.status.label : order.status}</span>
                            <a href="${ctx}/orders" class="btn-action-secondary">
                                <i class="fi fi-rr-arrow-left"></i> Danh sách đơn hàng
                            </a>
                        </div>
                    </div>

                    <!-- TIMELINE -->
                    <div class="timeline-section">
                        <div class="timeline-title">
                            <i class="fi fi-rr-time-fast"></i> Tiến trình xử lý đơn hàng
                        </div>
                        <div class="timeline-steps">
                            <div class="step-item active">
                                <div class="step-icon"><i class="fi fi-rr-check"></i></div>
                                <div class="step-label">Đặt hàng thành công</div>
                                <div class="step-date">${order.createdAtText}</div>
                            </div>
                            <div class="step-item ${not empty order.confirmedAtText || not empty order.packedByName ? 'active' : ''}">
                                <div class="step-icon"><i class="fi fi-rr-check"></i></div>
                                <div class="step-label">Kiểm soát FEFO & Kho</div>
                                <div class="step-date">
                                    <c:out value="${not empty order.confirmedAtText ? order.confirmedAtText : 'Đang xử lý'}" />
                                </div>
                            </div>
                            <div class="step-item ${not empty order.shippedAtText ? 'active' : ''}">
                                <div class="step-icon"><i class="fi fi-rr-check"></i></div>
                                <div class="step-label">Đang vận chuyển</div>
                                <div class="step-date">
                                    <c:out value="${not empty order.shippedAtText ? order.shippedAtText : 'Chờ bàn giao'}" />
                                </div>
                            </div>
                            <div class="step-item ${not empty order.completedAtText ? 'active' : ''}">
                                <div class="step-icon"><i class="fi fi-rr-check"></i></div>
                                <div class="step-label">Giao thành công</div>
                                <div class="step-date">
                                    <c:out value="${not empty order.completedAtText ? order.completedAtText : 'Chờ cập nhật'}" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- GRID 2 CARDS: ĐỊA CHỈ & VẬN CHUYỂN (ĐẶT NGAY SAU TIẾN TRÌNH) -->
                <div class="info-grid-2">
                    <div class="info-card">
                        <div class="info-card-header">
                            <i class="fi fi-rr-marker"></i> Địa chỉ nhận hàng
                        </div>
                        <div class="info-card-content" style="font-size:14px; line-height:1.6;">
                            <div style="font-weight:700;"><c:out value="${order.customerName}"/></div>
                            <div style="color:var(--text-secondary, #817872); font-size:13px;"><c:out value="${order.customerPhone}"/></div>
                            <div style="margin-top:8px;"><c:out value="${order.shippingAddress}"/></div>
                        </div>
                    </div>

                    <div class="info-card">
                        <div class="info-card-header">
                            <i class="fi fi-rr-truck-side"></i> Đơn vị vận chuyển
                        </div>
                        <div class="info-card-content" style="font-size:13px; line-height:1.6;">
                            <div>Đơn vị: <strong>PetFood Express Hỏa tốc 2H</strong></div>
                            <div>Mã vận đơn: <strong>PFS-EXP-${order.id}</strong></div>
                            <div class="shipping-guarantee-badge">
                                <i class="fi fi-rr-shield-check" style="font-size: 14px;"></i> Cam kết giao đúng hẹn 100% (Hoàn phí nếu chậm trễ)
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MỘT CARD DUY NHẤT: SẢN PHẨM + TRẠNG THÁI & THANH TOÁN -->
                <div class="card-box order-items-payment-card">
                    <c:set var="customerView" value="${true}" />
                    <%@ include file="/WEB-INF/views/common/_order-detail.jspf" %>
                </div>

                <!-- BOTTOM ACTIONS -->
                <div class="action-bottom-bar" style="display:flex; justify-content:flex-end; gap:12px; margin-bottom: 24px;">
                    <c:if test="${canRequestReturn}">
                        <a href="${ctx}/orders/${order.id}/returns/new" class="btn-action-secondary">
                            <i class="fi fi-rr-rotate-left"></i> Yêu cầu trả hàng & hoàn tiền
                        </a>
                    </c:if>

                    <a href="${ctx}/products" class="btn-action-primary">
                        <i class="fi fi-rr-shopping-bag"></i> Mua lại / Tiếp tục mua sắm
                    </a>
                </div>

                <!-- KHỐI YÊU CẦU TRẢ HÀNG ĐÃ GỬI -->
                <c:if test="${not empty returns}">
                    <div class="card-box">
                        <h3 style="font-size: 15px; font-weight: 800; color: var(--text-primary, #3d3028); margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                            <i class="fi fi-rr-rotate-left" style="color: var(--primary-orange, #f47721);"></i> Yêu cầu trả hàng / hoàn tiền đã gửi:
                        </h3>
                        <ul style="list-style: none; padding: 0; margin: 0; font-size: 13px;">
                            <c:forEach var="r" items="${returns}">
                                <li class="return-item-row">
                                    <div>
                                        <a href="${ctx}/orders/${order.id}/returns/${r.id}" style="color: var(--primary-orange, #f47721); font-weight: 700; text-decoration: none;">
                                            #${r.id}
                                        </a>
                                        <span style="color: var(--text-secondary, #817872); margin-left: 8px;">
                                            · ${r.createdAtText} · Lý do: <c:out value="${r.reason.label}"/>
                                        </span>
                                    </div>
                                    <span class="return-status-tag">
                                        <c:out value="${r.status.label}"/>
                                    </span>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>

                <!-- KHỐI HỦY ĐƠN HÀNG / GỬI YÊU CẦU HỦY -->
                <c:if test="${order.customerCanCancel or order.customerCanRequestCancel}">
                    <div class="card-box cancel-card-box" style="margin-bottom: 40px;">
                        <h3 style="font-size:15px; font-weight: 800; color:#b91c1c; margin:0 0 6px; display: flex; align-items: center; gap: 8px;">
                            <i class="fi fi-rr-ban"></i> ${order.customerCanCancel ? 'Hủy đơn hàng' : 'Gửi yêu cầu hủy đơn hàng'}
                        </h3>
                        <c:if test="${order.customerCanRequestCancel}">
                            <p style="font-size:12.5px; color:#7f1d1d; margin-bottom:12px;">
                                Đơn đang được kho đóng gói nên cần cửa hàng xác nhận trước khi hủy.
                            </p>
                        </c:if>

                        <form method="post" action="${ctx}/orders/${order.id}/cancel">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            </c:if>

                            <div style="margin-bottom:12px;">
                                <label for="cancelReasonSelect" style="display:block; font-size:12.5px; font-weight:600; color:#7f1d1d; margin-bottom:6px;">Chọn lý do hủy đơn:</label>
                                <select id="cancelReasonSelect" name="cancelReason" class="cancel-select" required style="width:100%; border:1px solid #fca5a5; border-radius:12px; padding:10px 14px; font-size:13px; outline:none; background:#fff; color:var(--text-primary, #3d3028);">
                                    <option value="" disabled selected>-- Vui lòng chọn lý do hủy --</option>
                                    <option value="Thay đổi ý định, không muốn mua nữa">Thay đổi ý định, không muốn mua nữa</option>
                                    <option value="Tìm thấy giá rẻ hơn ở nơi khác">Tìm thấy giá rẻ hơn ở nơi khác</option>
                                    <option value="Đặt nhầm sản phẩm / nhầm số lượng">Đặt nhầm sản phẩm / nhầm số lượng</option>
                                    <option value="Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng">Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng</option>
                                    <option value="Lý do cá nhân khác">Lý do cá nhân khác</option>
                                </select>
                            </div>

                            <button type="submit" class="btn-cancel-submit">
                                <i class="fi fi-rr-check"></i> ${order.customerCanCancel ? 'Xác nhận hủy đơn' : 'Gửi yêu cầu hủy'}
                            </button>
                        </form>
                    </div>
                </c:if>

            </main>
        </div>

        <!-- FOOTER DÙNG CHUNG -->
        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

    </body>
</html>