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
        <title>Chi tiết yêu cầu trả hàng #RR-${ret.id} · PetFood</title>

        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${ctx}/css/return-detail.css?v=3">
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
                <a href="${ctx}/orders/${ret.orderId}">Chi tiết đơn hàng #PFS-${ret.orderId}</a> › 
                <strong>Yêu cầu trả hàng #RR-${ret.id}</strong>
            </div>
        </div>

        <div class="page-container">

            <!-- SIDEBAR LEFT DÙNG CHUNG -->
            <c:set var="activeMenu" value="orders" />
            <c:set var="onProfilePage" value="${false}" />
            <%@ include file="/WEB-INF/views/common/_customer-sidebar.jspf" %>

            <!-- MAIN CONTENT -->
            <main class="main-content">

                <!-- CARD TOP: HEADER THÔNG TIN YÊU CẦU & NÚT QUAY LẠI -->
                <div class="card-box">
                    <div class="header-top-row">
                        <div>
                            <h1 class="detail-title" style="display: flex; align-items: center; gap: 8px; margin: 0;">
                                <i class="fi fi-rr-rotate-left" style="color: var(--primary-orange, #f47721);"></i> Yêu cầu hoàn trả
                            </h1>
                            <div style="font-size:13px; color:var(--text-secondary, #817872); margin-top:6px; display: flex; align-items: center; gap: 6px;">
                                <i class="fi fi-rr-calendar"></i> Ngày tạo: <strong>${ret.createdAtText}</strong> · 
                                <i class="fi fi-rr-box" style="margin-left: 4px;"></i> Đơn hàng gốc: 
                                <a href="${ctx}/orders/${ret.orderId}" style="color: var(--primary-orange, #f47721); font-weight: 700; text-decoration: underline;">
                                    #PFS-${ret.orderId}
                                </a>
                            </div>
                        </div>
                        <!-- STATUS -->
                        <div style="display:flex; align-items:center; gap:10px;">
                            <span class="badge-status-pill ${ret.status}">
                                <c:out value="${not empty ret.status.label ? ret.status.label : ret.status}"/>
                            </span>
                        </div>
                    </div>

                    <!-- THÔNG BÁO DUYỆT / TỪ CHỐI NẾU CÓ -->
                    <c:if test="${ret.status == 'APPROVED'}">
                        <div class="alert-box-notice success" style="margin-top: 14px;">
                            <div class="alert-icon"><i class="fi fi-rr-check-circle"></i></div>
                            <div class="alert-content">
                                <strong>Yêu cầu trả hàng đã được duyệt!</strong>
                                <div>Vui lòng gửi hàng về cửa hàng trong vòng 3 ngày làm việc, cửa hàng sẽ thẩm định và hoàn tiền.</div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${ret.status == 'REJECTED'}">
                        <div class="alert-box-notice danger" style="margin-top: 14px;">
                            <div class="alert-icon"><i class="fi fi-rr-cross-circle"></i></div>
                            <div class="alert-content">
                                <strong>Yêu cầu hoàn trả đã bị từ chối</strong>
                                <div>Lý do: <strong><c:out value="${empty ret.rejectReason ? 'Không đáp ứng điều kiện hoàn trả theo quy định' : ret.rejectReason}"/></strong></div>
                            </div>
                        </div>
                    </c:if>
                </div>

                <!-- CARD 2: SẢN PHẨM TRONG YÊU CẦU HOÀN TRẢ -->
                <div class="card-box">
                    <div class="rd-section-title">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <i class="fi fi-rr-box-alt" style="color: var(--primary-orange, #f47721);"></i> Sản phẩm trong yêu cầu hoàn trả
                        </div>
                        <div style="font-size:12px; font-weight:400; color:var(--text-secondary, #817872);">
                            Đơn hàng gốc: <strong>#PFS-${ret.orderId}</strong> (${ret.lines.size()} sản phẩm hoàn trả)
                        </div>
                    </div>

                    <table class="rd-table">
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th class="num">SL trả / Đã mua</th>
                                <th>Bao bì</th>
                                <th class="num">Tối đa hoàn</th>
                                <th class="col-inspect">Thẩm định & Ghi chú</th>
                                <th class="num">Hoàn thực tế</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="l" items="${ret.lines}">
                                <tr>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <img src="${ctx}/images/products/${l.sku}/1.jpg" 
                                                 class="product-thumb-img" 
                                                 alt="${l.productName}" 
                                                 onerror="this.src='https://via.placeholder.com/64/fff4df/f47721?text=PetFood'">
                                            <div>
                                                <strong style="color:var(--text-primary, #3d3028); font-size:14px;"><c:out value="${l.productName}"/></strong>
                                                <c:if test="${l.flashSale}">
                                                    <span style="color:#b91c1c; font-size:11px; font-weight:700;"> (Flash Sale)</span>
                                                </c:if>
                                                <div style="font-size:11px; color:var(--text-secondary, #817872); margin-top:2px;">
                                                    Mã SKU: <c:out value="${l.sku}"/>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="num">
                                        <strong style="color: var(--primary-orange, #f47721); font-size: 14px;">${l.quantity}</strong> / ${l.orderedQty}
                                    </td>
                                    <td>
                                        <span style="display:inline-block; padding:3px 8px; border-radius:6px; font-size:11px; font-weight:600; background:${l.opened ? '#fee2e2' : '#dcfce7'}; color:${l.opened ? '#991b1b' : '#166534'};">
                                            ${l.opened ? 'Đã mở bao bì' : 'Nguyên vẹn'}
                                        </span>
                                    </td>
                                    <td class="num">
                                        <fmt:formatNumber value="${l.maxRefund}" type="number"/> ₫
                                    </td>
                                    
                                    <td class="col-inspect">
                                        <c:choose>
                                            <c:when test="${not empty l.inspectionNote}">
                                                <div style="font-size: 12px; color: #3d3028; background: #fdfbf7; border: 1px solid #eadfd7; padding: 6px 10px; border-radius: 8px; line-height: 1.4;">
                                                    <i class="fi fi-rr-edit"></i> <c:out value="${l.inspectionNote}"/>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--text-secondary, #817872); font-size: 12px;">Đang kiểm tra</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="num">
                                        <c:choose>
                                            <c:when test="${l.refundAmount != null}">
                                                <strong style="color:var(--primary-orange, #f47721); font-size:14px;">
                                                    <fmt:formatNumber value="${l.refundAmount}" type="number"/> ₫
                                                </strong>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <c:if test="${ret.status == 'INSPECTED' or ret.status == 'REFUNDED' or ret.status == 'CLOSED'}">
                            <tfoot>
                                <tr style="border-top: 2px solid var(--border-card, #f4e3c9);">
                                    <td colspan="5" class="num" style="font-size:14px;"><strong>TỔNG TIỀN HOÀN TRẢ:</strong></td>
                                    <td class="num" style="font-size:16px; color:var(--primary-orange, #f47721);">
                                        <strong><fmt:formatNumber value="${ret.refundTotal}" type="number"/> ₫</strong>
                                    </td>
                                </tr>
                            </tfoot>
                        </c:if>
                    </table>
                </div>

                <!-- CARD 3: LÝ DO & HỒ SƠ MINH CHỨNG -->
                <div class="card-box">
                    <h3 style="font-size:15px; font-weight:700; color:var(--text-primary, #3d3028); margin-bottom:12px; display: flex; align-items: center; gap: 8px;">
                        <i class="fi fi-rr-document" style="color: var(--primary-orange, #f47721);"></i> Lý do & Hồ sơ minh chứng
                    </h3>

                    <div style="background:#fffbe0; border:1px solid #ffe0b2; padding:12px 16px; border-radius:10px; color:#b45309; font-size:13px; font-weight:700; margin-bottom:12px; display: flex; gap: 8px;">
                        <i class="fi fi-rr-triangle-warning" style="margin-top: 2px;"></i> LÝ DO HOÀN TRẢ: <c:out value="${ret.reason.label}"/>
                    </div>

                    <div style="font-size:12px; font-weight:700; color:var(--text-secondary, #817872); margin-bottom:6px;">
                        MÔ TẢ CHI TIẾT TỪ KHÁCH HÀNG:
                    </div>
                    <div style="background:#fdfbf7; border:1px solid var(--border-search, #eadfd7); padding:12px 16px; border-radius:10px; font-size:13px; color:var(--text-primary, #3d3028); margin-bottom:12px; line-height:1.5;">
                        "<c:out value="${empty ret.description ? 'Không có mô tả chi tiết' : ret.description}"/>"
                    </div>

                    <c:if test="${not empty ret.media}">
                        <div style="font-size:12px; font-weight:700; color:var(--text-secondary, #817872); margin-top:14px; margin-bottom:6px; display: flex; align-items: center; gap: 6px;">
                            <i class="fi fi-rr-camera"></i> ẢNH / VIDEO MINH CHỨNG (${ret.media.size()} files):
                        </div>
                        <div class="rd-media-grid">
                            <c:forEach var="m" items="${ret.media}">
                                <c:choose>
                                    <c:when test="${m.video}">
                                        <video src="${ctx}<c:out value='${m.url}'/>" controls preload="metadata"></video>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${ctx}<c:out value='${m.url}'/>" target="_blank" title="Bấm để xem ảnh lớn">
                                            <img src="${ctx}<c:out value='${m.url}'/>" alt="Minh chứng">
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>

                <!-- THANH ĐIỀU HƯỚNG CUỐI TRANG -->
                <div class="action-bottom-bar" style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 30px;">
                    <a href="${ctx}/orders/${ret.orderId}" class="btn-action-secondary">
                        <i class="fi fi-rr-arrow-left"></i> Quay lại chi tiết đơn hàng #PFS-${ret.orderId}
                    </a>
                    <a href="${ctx}/products" class="btn-action-primary">
                        <i class="fi fi-rr-shopping-bag"></i> Mua lại / Tiếp tục mua sắm
                    </a>
                </div>

            </main>
        </div>

    </body>
</html>
