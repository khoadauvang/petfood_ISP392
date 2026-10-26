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
        <link rel="preconnect" href="https://fonts.googleapis.com">
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
                    <%-- Lọc theo nhóm trạng thái ở BE (?status=...), giữ phân trang --%>
                    <div class="status-tabs" id="statusTabs">
                        <a href="${ctx}/orders" class="tab-btn ${empty status ? 'active' : ''}" style="text-decoration:none; text-align:center;">Tất cả</a>
                        <a href="${ctx}/orders?status=PENDING,CONFIRMED" class="tab-btn ${status == 'PENDING,CONFIRMED' ? 'active' : ''}" style="text-decoration:none; text-align:center;">Chờ xác nhận</a>
                        <a href="${ctx}/orders?status=PROCESSING,SHIPPED" class="tab-btn ${status == 'PROCESSING,SHIPPED' ? 'active' : ''}" style="text-decoration:none; text-align:center;">Đang giao hàng</a>
                        <a href="${ctx}/orders?status=COMPLETED" class="tab-btn ${status == 'COMPLETED' ? 'active' : ''}" style="text-decoration:none; text-align:center;">Hoàn thành</a>
                        <a href="${ctx}/orders?status=CANCELLED,RETURNED" class="tab-btn ${status == 'CANCELLED,RETURNED' ? 'active' : ''}" style="text-decoration:none; text-align:center;">Đã hủy</a>
                    </div>
                </div>

                <!-- KHỐI 2: THANH TÌM KIẾM (Không ghim, cuộn là trôi đi luôn) -->
                <div class="search-bar-card">
                    <div class="search-filter-row">
                        <div class="search-input-wrap">
                            <i class="fi fi-rr-search search-icon-input"></i>
                            <input type="text" id="orderSearchInput" placeholder="Tìm trong trang này theo mã đơn (#PFS-...) hoặc trạng thái..." oninput="filterOrders()">
                        </div>
                    </div>
                </div>

                <div class="orders-list-wrap">
                    <c:forEach var="o" items="${orders}">
                        <article class="order-card order-item" data-code="#PFS-${o.id}" data-status="${o.status.label} ${o.status.name()}" data-status-code="${o.status.name()}">

                            <!-- 1. HEADER CỦA CARD -->
                            <div class="order-card-header">
                                <div class="order-header-left">
                                    <span class="order-code-title">#PFS-${o.id}</span>
                                    <span class="dot-sep">•</span>
                                    <span class="order-date-text"><i class="fi fi-rr-calendar"></i> ${o.createdAtText}</span>
                                </div>
                                <span class="status-badge ${o.status.name()}">
                                    ${o.status.label}
                                </span>
                            </div>

                            <!-- 2. PHẦN HIỂN THỊ SẢN PHẨM -->
                            <div class="order-product-row" style="display:flex; flex-direction:column; gap:12px; padding: 16px; background: #FDF9F3; border: 1px solid #F3E6D8; border-radius: 8px;">
                                <c:choose>
                                    <c:when test="${not empty orderItems[o.id]}">
                                        <c:forEach var="item" items="${orderItems[o.id]}">
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
                                        <c:when test="${o.status.name() == 'COMPLETED'}">
                                            <a href="${ctx}/orders/${o.id}" class="btn-action-soft">
                                                <i class="fi fi-rr-star"></i> Đánh giá sản phẩm
                                            </a>
                                            <a href="${ctx}/products" class="btn-action-soft">
                                                <i class="fi fi-rr-refresh"></i> Mua lại
                                            </a>
                                        </c:when>
                                        <c:when test="${o.status.name() == 'PENDING' || o.status.name() == 'CONFIRMED'}">
                                            <form method="post" action="${ctx}/orders/${o.id}/cancel" style="margin:0; display:inline;">
                                                <c:if test="${not empty _csrf}">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                </c:if>
                                                <input type="hidden" name="cancelReason" value="Thay đổi ý định, không muốn mua nữa">
                                                <button type="submit" class="btn-action-ghost" onclick="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">Hủy đơn</button>
                                            </form>
                                        </c:when>
                                    </c:choose>

                                    <a href="${ctx}/orders/${o.id}" class="btn-action-primary">
                                        Xem chi tiết <i class="fi fi-rr-arrow-small-right"></i>
                                    </a>
                                </div>
                            </div>

                        </article>
                    </c:forEach>

                    <div id="noFilterMatch" class="order-card empty-state-card" style="${empty orders ? '' : 'display:none;'}">
                        <div class="empty-icon"><i class="fi fi-rr-search-alt"></i></div>
                        <h3>Không tìm thấy đơn hàng phù hợp</h3>
                        <p>Thử đổi từ khóa tìm kiếm hoặc chọn tab trạng thái khác nhé.</p>
                    </div>

                    <%-- Phân trang (10 đơn/trang), giữ tab trạng thái qua filterQuery --%>
                    <c:if test="${totalPages > 1}">
                        <nav class="status-tabs-card" style="display:flex; justify-content:center; gap:8px; padding:12px; margin-top:16px;">
                            <c:if test="${currentPage > 1}">
                                <a class="tab-btn" style="flex:0; text-decoration:none;" href="${ctx}/orders?${filterQuery}&page=${currentPage - 1}">‹ Trước</a>
                            </c:if>
                            <c:forEach begin="1" end="${totalPages}" var="n">
                                <a class="tab-btn ${n == currentPage ? 'active' : ''}" style="flex:0; text-decoration:none;" href="${ctx}/orders?${filterQuery}&page=${n}">${n}</a>
                            </c:forEach>
                            <c:if test="${currentPage < totalPages}">
                                <a class="tab-btn" style="flex:0; text-decoration:none;" href="${ctx}/orders?${filterQuery}&page=${currentPage + 1}">Sau ›</a>
                            </c:if>
                        </nav>
                    </c:if>
                </div>

            </main>
        </div>

        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            // Tìm nhanh trong các đơn của trang đang xem (tab trạng thái đã lọc ở BE)
            function filterOrders() {
                const searchInput = document.getElementById('orderSearchInput');
                const query = searchInput ? searchInput.value.toLowerCase().trim() : '';
                const items = document.querySelectorAll('.order-item');
                let visibleCount = 0;

                items.forEach(item => {
                    const code = (item.getAttribute('data-code') || '').toLowerCase();
                    const status = (item.getAttribute('data-status') || '').toLowerCase();

                    if (!query || code.includes(query) || status.includes(query)) {
                        item.style.display = '';
                        visibleCount++;
                    } else {
                        item.style.display = 'none';
                    }
                });

                const noMatchBox = document.getElementById('noFilterMatch');
                if (noMatchBox) {
                    noMatchBox.style.display = visibleCount === 0 ? 'block' : 'none';
                }
            }
        </script>
    </body>
</html>
