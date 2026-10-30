<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Đơn hàng của tôi · PetFood</title>
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${ctx}/css/orders.css">
    </head>
    <body>

        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <div class="breadcrumb-bar">
            <div>
                <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a> › 
                <a href="${ctx}/profile">Tài khoản</a> › 
                <strong>Đơn hàng của tôi</strong>
            </div>
            
        </div>

        <div class="page-container">
            <c:set var="activeMenu" value="orders"/>
            <c:set var="onProfilePage" value="${false}"/>
            <%@ include file="/WEB-INF/views/common/_customer-sidebar.jspf" %>

            <main class="main-content">
                
                <!-- KHỐI 1: TAB TRẠNG THÁI (Sẽ được ghim dính) -->
                <div class="status-tabs-card">
                    <div class="status-tabs" id="statusTabs">
                        <button type="button" class="tab-btn active" data-filter="ALL" onclick="selectStatusTab(this)">Tất cả</button>
                        <button type="button" class="tab-btn" data-filter="PENDING,CONFIRMED" onclick="selectStatusTab(this)">Chờ xác nhận</button>
                        <button type="button" class="tab-btn" data-filter="PROCESSING,SHIPPED" onclick="selectStatusTab(this)">Đang giao hàng</button>
                        <button type="button" class="tab-btn" data-filter="COMPLETED" onclick="selectStatusTab(this)">Hoàn thành</button>
                        <button type="button" class="tab-btn" data-filter="CANCELLED,RETURNED,CANCEL_REQUESTED,RETURN_REQUESTED" onclick="selectStatusTab(this)">Đã hủy/Hoàn trả</button>
                    </div>
                </div>

                <!-- KHỐI 2: THANH TÌM KIẾM (Không ghim, cuộn là trôi đi luôn) -->
                <div class="search-bar-card">
                    <div class="search-filter-row">
                        <div class="search-input-wrap">
                            <i class="fi fi-rr-search search-icon-input"></i>
                            <input type="text" id="orderSearchInput" placeholder="Tìm theo mã đơn hàng (#PFS-...) hoặc trạng thái..." oninput="filterOrders()">
                        </div>
                    </div>
                </div>

                <div class="orders-list-wrap">
                    <c:forEach var="o" items="${orders}">
                        <article class="order-card order-item" 
                                 data-code="#PFS-${o.id}" 
                                 data-status="${o.effectiveStatusLabel} ${o.effectiveStatusCode}" 
                                 data-status-code="${o.effectiveStatusCode}">

                            <!-- 1. HEADER CỦA CARD -->
                            <div class="order-card-header">
                                <div class="order-header-left">
                                    <span class="order-code-title">#PFS-${o.id}</span>
                                    <span class="dot-sep">•</span>
                                    <span class="order-date-text"><i class="fi fi-rr-calendar"></i> ${o.createdAtText}</span>
                                </div>
                                <c:choose>
                                    <c:when test="${o.cancelRequested}">
                                        <span class="status-badge CANCEL_REQUESTED">
                                            <i class="fi fi-rr-clock"></i> Chờ duyệt hủy
                                        </span>
                                    </c:when>
                                    <c:when test="${o.returned}">
                                        <span class="status-badge RETURNED">
                                            <i class="fi fi-rr-rotate-left"></i> Đã hoàn trả
                                        </span>
                                    </c:when>
                                    <c:when test="${o.returnPending}">
                                        <span class="status-badge RETURN_REQUESTED">
                                            <i class="fi fi-rr-time-past"></i> Đang xử lý hoàn trả
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge ${o.status.name()}">
                                            ${o.status.label}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- 2. PHẦN HIỂN THỊ SẢN PHẨM -->
                            <div class="order-product-row" style="display:flex; flex-direction:column; gap:12px; padding: 16px; background: #FDF9F3; border: 1px solid #F3E6D8; border-radius: 8px;">
                                <c:set var="currentItems" value="${not empty o.items ? o.items : orderItems[o.id]}" />
                                <c:choose>
                                    <c:when test="${not empty currentItems}">
                                        <c:forEach var="item" items="${currentItems}">
                                             <div style="display: flex; align-items: center; gap: 14px; width: 100%;">
                                                 <img src="${not empty item.imageUrl ? ctx.concat(item.imageUrl) : 'https://via.placeholder.com/56?text=PetFood'}" 
                                                      onerror="this.src='https://via.placeholder.com/56?text=PetFood'"
                                                      alt="Product" 
                                                      style="width: 56px; height: 56px; border-radius: 8px; object-fit: cover; border: 1px solid #EADBC8; background: #fff; flex-shrink: 0;">
                                                 <div style="flex: 1; min-width: 0;">
                                                     <div style="font-size: 14px; font-weight: 700; color: #3D3028;"><c:out value="${item.productName}"/></div>
                                                     <div style="font-size: 12.5px; color: #817872; margin-top: 2px;">Số lượng: x${item.quantity}</div>
                                                 </div>
                                                 <div style="font-size: 14.5px; font-weight: 800; color: #3D3028; text-align: right;">
                                                     <fmt:formatNumber value="${item.subtotal}" type="number"/> ₫
                                                 </div>
                                             </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="display: flex; align-items: center; gap: 14px; width: 100%;">
                                            <div class="product-thumb-box">
                                                <i class="fi fi-rr-box-open-full"></i>
                                            </div>
                                            <div class="product-info-col">
                                                <div class="product-name-txt">Kiện hàng dinh dưỡng thú cưng (#PFS-${o.id})</div>
                                                <div class="product-sub-txt">Thanh toán: ${o.paymentMethodLabel} · Trạng thái: ${o.paymentStatusLabel}</div>
                                                <div class="product-qty-txt">Tổng số lượng: x${o.totalQuantity} sản phẩm (${o.lineCount} dòng loại)</div>
                                            </div>
                                            <div class="product-price-col">
                                                <fmt:formatNumber value="${o.totalAmount}" type="number"/> ₫
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- 3. FOOTER CỦA CARD (TỔNG TIỀN & NÚT) ĐÃ ĐƯỢC KHÔI PHỤC -->
                            <div class="order-card-footer">
                                <div>
                                    <span class="footer-total-label">Tổng thanh toán (${o.totalQuantity} sản phẩm):</span>
                                    <div class="total-price-text">
                                        <fmt:formatNumber value="${o.totalAmount}" type="number"/> ₫
                                    </div>
                                </div>

                                <div class="footer-btns">
                                    <c:choose>
                                        <c:when test="${o.returned}">
                                            <c:if test="${not empty o.returnId}">
                                                <a href="${ctx}/orders/${o.id}/returns/${o.returnId}" class="btn-action-soft">
                                                    <i class="fi fi-rr-rotate-left"></i> Chi tiết hoàn trả
                                                </a>
                                            </c:if>
                                        </c:when>
                                        <c:when test="${o.returnPending}">
                                            <c:if test="${not empty o.returnId}">
                                                <a href="${ctx}/orders/${o.id}/returns/${o.returnId}" class="btn-action-soft">
                                                    <i class="fi fi-rr-rotate-left"></i> Tiến trình hoàn trả
                                                </a>
                                            </c:if>
                                        </c:when>
                                        <c:when test="${o.cancelRequested}">
                                            <span class="cancel-pending-tag">
                                                <i class="fi fi-rr-info"></i> Đang chờ duyệt hủy
                                            </span>
                                        </c:when>
                                        <c:when test="${o.status.name() == 'COMPLETED'}">
                                            <a href="${ctx}/orders/${o.id}" class="btn-action-soft">
                                                <i class="fi fi-rr-star"></i> Đánh giá sản phẩm
                                            </a>
                                        </c:when>
                                        <c:when test="${o.status.name() == 'PENDING' || o.status.name() == 'CONFIRMED'}">
                                            <button type="button" class="btn-action-ghost" onclick="openOrderCancelModal('${o.id}', 'PFS-${o.id}', ${o.status.name() == 'CONFIRMED'})">
                                                ${o.status.name() == 'CONFIRMED' ? 'Yêu cầu hủy' : 'Hủy đơn'}
                                            </button>
                                        </c:when>
                                    </c:choose>

                                    <a href="${ctx}/orders/${o.id}" class="btn-action-primary">
                                        Xem chi tiết <i class="fi fi-rr-arrow-small-right"></i>
                                    </a>
                                </div>
                            </div>

                        </article>
                    </c:forEach>

                    <div id="noFilterMatch" class="order-card empty-state-card" style="display:none;">
                        <div class="empty-icon"><i class="fi fi-rr-search-alt"></i></div>
                        <h3>Không tìm thấy đơn hàng phù hợp</h3>
                        <p>Thử đổi từ khóa tìm kiếm hoặc chọn tab trạng thái khác nhé.</p>
                    </div>
                </div>

            </main>
        </div>

        <!-- MODAL HỦY ĐƠN HÀNG TRÊN TRANG ORDERS -->
        <div id="cancelOrderModal" class="order-cancel-modal-overlay" style="display: none;">
            <div class="order-cancel-modal-card">
                <div class="order-cancel-modal-header">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span class="cancel-modal-icon"><i class="fi fi-rr-ban"></i></span>
                        <div>
                            <h3 id="cancelModalTitle" style="margin: 0; font-size: 16px; font-weight: 800; color: #b91c1c;">Hủy đơn hàng</h3>
                            <span id="cancelModalOrderCode" style="font-size: 12.5px; color: #817872;">Đơn hàng: #...</span>
                        </div>
                    </div>
                    <button type="button" class="cancel-modal-close" onclick="closeOrderCancelModal()">&times;</button>
                </div>

                <p id="cancelModalNote" style="font-size: 13px; color: #7f1d1d; margin: 14px 0; background: #fff5f5; border: 1px solid #fecaca; padding: 10px 12px; border-radius: 8px; line-height: 1.4;">
                    Vui lòng chọn lý do bạn muốn hủy đơn hàng để shop cải thiện chất lượng phục vụ.
                </p>

                <form id="cancelOrderForm" method="post" action="">
                    <c:if test="${not empty _csrf}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    </c:if>

                    <div style="margin-bottom: 20px;">
                        <label for="modalCancelReasonSelect" style="display: block; font-size: 13px; font-weight: 600; color: #3d3028; margin-bottom: 8px;">Chọn lý do hủy đơn: <span style="color: #ef4444;">*</span></label>
                        <select id="modalCancelReasonSelect" name="cancelReason" required class="cancel-select" style="width: 100%; border: 1px solid #fca5a5; border-radius: 10px; padding: 11px 14px; font-size: 13px; outline: none; background: #fff; color: #3d3028; box-sizing: border-box;">
                            <option value="" disabled selected>-- Vui lòng chọn lý do hủy --</option>
                            <option value="Thay đổi ý định, không muốn mua nữa">Thay đổi ý định, không muốn mua nữa</option>
                            <option value="Tìm thấy giá rẻ hơn ở nơi khác">Tìm thấy giá rẻ hơn ở nơi khác</option>
                            <option value="Đặt nhầm sản phẩm / nhầm số lượng">Đặt nhầm sản phẩm / nhầm số lượng</option>
                            <option value="Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng">Muốn thay đổi địa chỉ hoặc số điện thoại nhận hàng</option>
                            <option value="Lý do cá nhân khác">Lý do cá nhân khác</option>
                        </select>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 10px;">
                        <button type="button" class="btn-action-ghost" onclick="closeOrderCancelModal()" style="padding: 10px 18px; font-size: 13px; border-radius: 10px; cursor: pointer; border: 1px solid #d5cbc5; background: #fff;">Đóng</button>
                        <button type="submit" id="cancelModalSubmitBtn" class="btn-cancel-submit" style="padding: 10px 20px; font-size: 13px; border-radius: 10px; background: #ef4444; color: #fff; border: none; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);">
                            <i class="fi fi-rr-check"></i> Xác nhận hủy đơn
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <style>
            .order-cancel-modal-overlay {
                position: fixed;
                top: 0; left: 0; right: 0; bottom: 0;
                background: rgba(0, 0, 0, 0.48);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 99999;
                backdrop-filter: blur(2px);
            }
            .order-cancel-modal-card {
                background: #FFFFFF;
                border-radius: 16px;
                width: 90%;
                max-width: 480px;
                padding: 24px;
                box-shadow: 0 16px 36px rgba(0, 0, 0, 0.2);
                animation: animCancelFade 0.2s ease-out;
            }
            @keyframes animCancelFade {
                from { opacity: 0; transform: translateY(-10px) scale(0.98); }
                to { opacity: 1; transform: translateY(0) scale(1); }
            }
            .order-cancel-modal-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding-bottom: 14px;
                border-bottom: 1px solid #f1ece6;
            }
            .cancel-modal-icon {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                background: #fee2e2;
                color: #b91c1c;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                flex-shrink: 0;
            }
            .cancel-modal-close {
                background: transparent;
                border: none;
                font-size: 26px;
                color: #817872;
                cursor: pointer;
                line-height: 1;
                padding: 0 4px;
            }
            .cancel-modal-close:hover {
                color: #3d3028;
            }
        </style>

        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            let currentTabFilter = 'ALL';

            function selectStatusTab(btn) {
                document.querySelectorAll('#statusTabs .tab-btn').forEach(b => {
                    b.classList.remove('active');
                });
                btn.classList.add('active');
                currentTabFilter = btn.getAttribute('data-filter') || 'ALL';
                filterOrders();
            }

            function filterOrders() {
                const searchInput = document.getElementById('orderSearchInput');
                const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
                const items = document.querySelectorAll('.order-item');
                let visibleCount = 0;
                const filterList = currentTabFilter.split(',').map(s => s.trim());

                items.forEach(item => {
                    const code = (item.getAttribute('data-code') || '').toLowerCase();
                    const status = (item.getAttribute('data-status') || '').toLowerCase();
                    const statusCode = (item.getAttribute('data-status-code') || '').trim();

                    const matchSearch = !query || code.includes(query) || status.includes(query);
                    const matchTab = (currentTabFilter === 'ALL' || filterList.includes(statusCode));

                    if (matchSearch && matchTab) {
                        item.style.display = '';
                        visibleCount++;
                    } else {
                        item.style.display = 'none';
                    }
                });

                const noMatchBox = document.getElementById('noFilterMatch');
                if (noMatchBox) {
                    noMatchBox.style.display = (visibleCount === 0 && items.length > 0) ? 'block' : 'none';
                }
            }

            function openOrderCancelModal(orderId, orderCode, isConfirmed) {
                const modal = document.getElementById('cancelOrderModal');
                const form = document.getElementById('cancelOrderForm');
                const title = document.getElementById('cancelModalTitle');
                const note = document.getElementById('cancelModalNote');
                const codeEl = document.getElementById('cancelModalOrderCode');
                const submitBtn = document.getElementById('cancelModalSubmitBtn');
                const select = document.getElementById('modalCancelReasonSelect');

                if (!modal || !form) return;

                form.action = '${ctx}/orders/' + orderId + '/cancel';
                if (codeEl) codeEl.textContent = 'Đơn hàng: #' + (orderCode || orderId);
                if (select) select.selectedIndex = 0;

                if (isConfirmed) {
                    if (title) title.textContent = 'Gửi yêu cầu hủy đơn hàng';
                    if (note) note.innerHTML = '<i class="fi fi-rr-info"></i> Đơn hàng đang được kho chuẩn bị đóng gói nên cần gửi yêu cầu cho cửa hàng xác nhận trước khi hủy.';
                    if (submitBtn) submitBtn.innerHTML = '<i class="fi fi-rr-check"></i> Gửi yêu cầu hủy';
                } else {
                    if (title) title.textContent = 'Hủy đơn hàng';
                    if (note) note.innerHTML = 'Vui lòng chọn lý do bạn muốn hủy đơn hàng để shop cải thiện chất lượng phục vụ.';
                    if (submitBtn) submitBtn.innerHTML = '<i class="fi fi-rr-check"></i> Xác nhận hủy đơn';
                }

                modal.style.display = 'flex';
            }

            function closeOrderCancelModal() {
                const modal = document.getElementById('cancelOrderModal');
                if (modal) modal.style.display = 'none';
            }

            window.addEventListener('click', function(e) {
                const modal = document.getElementById('cancelOrderModal');
                if (modal && e.target === modal) {
                    closeOrderCancelModal();
                }
            });

            window.addEventListener('DOMContentLoaded', () => {
                const urlParams = new URLSearchParams(window.location.search);
                const statusParam = urlParams.get('status');
                if (statusParam) {
                    const targetBtn = Array.from(document.querySelectorAll('#statusTabs .tab-btn'))
                        .find(btn => (btn.getAttribute('data-filter') || '').includes(statusParam.toUpperCase()));
                    if (targetBtn) {
                        selectStatusTab(targetBtn);
                        return;
                    }
                }
                filterOrders();
            });
        </script>
    </body>
</html>
