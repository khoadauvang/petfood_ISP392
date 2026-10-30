<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Yêu cầu trả hàng · Đơn #PFS-${orderId} · PetFood</title>
    
    <!-- Font & Icon -->
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- LINK GỌI FILE CSS RIÊNG CỦA BÀ Ở ĐÂY -->
    <link rel="stylesheet" href="${ctx}/css/return-form.css">
</head>
<body>

    <!-- HEADER DÙNG CHUNG -->
    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <!-- BREADCRUMB -->
    <div class="breadcrumb-bar">
        <div>
            <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a> › 
            <a href="${ctx}/orders">Đơn hàng của tôi</a> › 
            <a href="${ctx}/orders/${orderId}">Đơn #PFS-${orderId}</a> › 
            <strong>Yêu cầu trả hàng</strong>
        </div>
    </div>

    <div class="page-container">
        <!-- SIDEBAR TRÁI DÙNG CHUNG -->
        <c:set var="activeMenu" value="orders"/>
        <c:set var="onProfilePage" value="${false}"/>
        <%@ include file="/WEB-INF/views/common/_customer-sidebar.jspf" %>

        <!-- NỘI DUNG CHÍNH BÊN PHẢI -->
        <main class="main-content">
            
            <!-- CARD GIỚI THIỆU & CHÍNH SÁCH -->
            <div class="card-box">
                <span class="intro-badge-top">
                    <i class="fi fi-rr-undo"></i> Hỗ trợ đổi trả & hoàn tiền
                </span>
                <div class="intro-header-row">
                    <h1 class="intro-title">Yêu cầu trả hàng</h1>
                    <a href="${ctx}/orders/${orderId}" class="order-ref-tag">
                        <i class="fi fi-rr-arrow-small-left"></i> Quay lại Đơn #PFS-${orderId}
                    </a>
                </div>
                <div class="highlight-notice-box">
                    <div class="notice-icon"><i class="fi fi-rr-shield-exclamation"></i></div>
                    <div>
                        <h4>Lưu ý chính sách trả hàng</h4>
                        <p>Trả trong <strong>3 ngày</strong> kể từ khi giao thành công. Hàng mua qua chương trình <strong>Flash Sale</strong> không áp dụng trả hàng với lý do hạn sử dụng.</p>
                    </div>
                </div>
            </div>

            <!-- FORM TRẢ HÀNG -->
            <form:form method="post" action="${ctx}/orders/${orderId}/returns/new" modelAttribute="returnForm" enctype="multipart/form-data" cssClass="main-content">
                
                <!-- BƯỚC 1: CHỌN SẢN PHẨM MUỐN TRẢ -->
                <div class="product-list-wrapper">
                    <c:forEach var="l" items="${returnableLines}" varStatus="s">
                        
                        <!-- Nếu là Flash Sale thì thêm class 'flash-sale-disabled' để làm xám khung -->
                        <div class="product-item-card ${l.flashSale ? 'flash-sale-disabled' : ''}" id="prodCard_${s.index}">
                            <div class="product-item-left">
                                <form:hidden path="lines[${s.index}].orderItemId"/>
                                <input type="hidden" name="lines[${s.index}].quantity" value="${l.quantity}"/>
                                
                                <!-- Phân luồng: Khóa checkbox nếu là Flash Sale -->
                                <c:choose>
                                    <c:when test="${l.flashSale}">
                                        <form:checkbox path="lines[${s.index}].selected" disabled="true"
                                                       cssClass="item-checkbox" aria-label="Chọn sản phẩm này để trả"/>
                                    </c:when>
                                    <c:otherwise>
                                        <form:checkbox path="lines[${s.index}].selected" cssClass="item-checkbox"
                                                       aria-label="Chọn sản phẩm này để trả"
                                                       onchange="toggleCardHighlight(${s.index}, this.checked)"/>
                                    </c:otherwise>
                                </c:choose>

                                <div class="product-item-info">
                                    <h5>
                                        <c:out value="${l.productName}"/>
                                        <c:if test="${l.promotion}">
                                            <span class="flash-badge"><i class="fi fi-rr-bolt"></i> Chương trình</span>
                                        </c:if>
                                        <c:if test="${l.flashSale}">
                                            <span class="flash-badge"><i class="fi fi-rr-bolt"></i> Flash Sale (Không hỗ trợ trả)</span>
                                        </c:if>
                                    </h5>
                                    <p>Số lượng đã mua: <strong>x${l.quantity}</strong></p>
                                </div>
                            </div>

                            <div class="product-item-right">
                                <div class="qty-control-box">
                                    <span>Số lượng trả:</span>
                                    <strong>x${l.quantity} (toàn bộ)</strong>
                                </div>
                                <label class="opened-pkg-check">
                                    <!-- Phân luồng: Khóa checkbox mở bao bì nếu là Flash Sale -->
                                    <c:choose>
                                        <c:when test="${l.flashSale}">
                                            <form:checkbox path="lines[${s.index}].opened" disabled="true"/>
                                        </c:when>
                                        <c:otherwise>
                                            <form:checkbox path="lines[${s.index}].opened"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <span>Đã mở bao bì</span>
                                </label>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- BƯỚC 2: LÝ DO & MÔ TẢ CHI TIẾT (ĐÃ ĐƯỢC LÀM GỌN GÀNG, ĐẸP MẮT) -->
                <div class="card-box">
                    <div class="step-title-header">
                        <div class="step-title-left">
                            <span class="step-circle">2</span>
                            <span>Lý do & Mô tả tình trạng</span>
                        </div>
                        <span class="step-badge-tag">Bắt buộc</span>
                    </div>

                    <div class="form-group-custom">
                        <label for="reason" class="form-label-custom">Lý do trả hàng <span class="required-star">*</span></label>
                        <div class="select-wrapper">
                            <form:select path="reason" id="reason" cssClass="select-custom">
                                <form:option value="">-- Chọn lý do trả hàng phù hợp --</form:option>
                                <c:forEach var="r" items="${reasons}">
                                    <form:option value="${r}">${r.label}</form:option>
                                </c:forEach>
                            </form:select>
                            <i class="fi fi-rr-angle-small-down select-arrow-icon"></i>
                        </div>
                        <form:errors path="reason" cssClass="error-hint"/>
                    </div>

                    <div class="form-group-custom">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <label for="description" class="form-label-custom">Mô tả thêm chi tiết</label>
                            <span class="char-counter" id="descCounter">0 / 2000 ký tự</span>
                        </div>
                        <form:textarea path="description" id="description" rows="3" maxlength="2000" cssClass="textarea-custom" placeholder="Nhập chi tiết tình trạng sản phẩm, bao bì hoặc vấn đề bạn gặp phải..." oninput="updateCharCount(this)"/>
                        <form:errors path="description" cssClass="error-hint"/>
                    </div>
                </div>

                <!-- BƯỚC 3: HÌNH ẢNH / VIDEO BẰNG CHỨNG (TÍCH HỢP NÚT CHỌN & PREVIEW ẢNH) -->
                <div class="card-box">
                    <div class="step-title-header">
                        <div class="step-title-left">
                            <span class="step-circle">3</span>
                            <span>Ảnh / Video bằng chứng</span>
                        </div>
                        <span class="step-badge-tag">Từ 1 đến 5 tệp</span>
                    </div>

                    <div class="upload-area-wrap">
                        <label for="media" class="upload-dropzone" id="dropzoneLabel">
                            <div class="dropzone-icon"><i class="fi fi-rr-cloud-upload-alt"></i></div>
                            <div class="dropzone-title">Nhấn để chọn ảnh hoặc video minh họa</div>
                            <div class="dropzone-sub">Hỗ trợ JPG, PNG, WEBP hoặc video MP4, MOV, WEBM (Tối đa 5MB/tệp)</div>
                            <span class="btn-choose-file">
                                <i class="fi fi-rr-picture"></i> Chọn tệp từ thiết bị
                            </span>
                            <input type="file" id="media" name="media" multiple accept="image/jpeg,image/png,image/webp,video/mp4,video/quicktime,video/webm" style="display:none;" onchange="handleFilesSelected(this)">
                        </label>

                        <!-- KHUNG PREVIEW DANH SÁCH FILE ĐÃ CHỌN -->
                        <div id="mediaPreviewContainer" class="media-preview-grid" style="display:none;"></div>
                    </div>
                    <form:errors path="media" cssClass="error-hint"/>
                </div>

                <!-- BƯỚC 4: TÀI KHOẢN NHẬN TIỀN HOÀN (NẾU ĐƠN COD) -->
                <c:if test="${cod}">
                    <div class="card-box">
                        <div class="step-title-header">
                            <div class="step-title-left">
                                <span class="step-circle">4</span>
                                <span>Tài khoản nhận tiền hoàn (Đơn COD)</span>
                            </div>
                            <span class="step-badge-tag">Chuyển khoản ngân hàng</span>
                        </div>

                        <div class="refund-method-card">
                            <div class="bank-input-grid">
                                <div class="bank-input-group">
                                    <label>Tên Ngân hàng</label>
                                    <form:input path="refundBankName" maxlength="100" cssClass="bank-input-control" placeholder="VD: Vietcombank, MB Bank..."/>
                                </div>
                                <div class="bank-input-group">
                                    <label>Số tài khoản</label>
                                    <form:input path="refundAccountNo" maxlength="30" cssClass="bank-input-control" placeholder="Nhập số tài khoản nhận tiền"/>
                                </div>
                                <div class="bank-input-group">
                                    <label>Chủ tài khoản</label>
                                    <form:input path="refundAccountHolder" maxlength="100" cssClass="bank-input-control" placeholder="VD: NGUYEN VAN A"/>
                                </div>
                            </div>
                            <form:errors path="refundBankName" cssClass="error-hint"/>
                        </div>
                    </div>
                </c:if>

                <!-- NÚT GỬI YÊU CẦU -->
                <div class="card-box" style="padding: 18px 28px;">
                    <div class="form-submit-actions" style="margin-top: 0;">
                        <a href="${ctx}/orders/${orderId}" class="btn-cancel-return">Hủy bỏ</a>
                        <button type="submit" class="btn-submit-return">
                            <i class="fi fi-rr-paper-plane"></i> Gửi yêu cầu trả hàng
                        </button>
                    </div>
                </div>

            </form:form>

        </main>
    </div>

    <!-- FOOTER -->
    <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
    <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

    <!-- SCRIPT TƯƠNG TÁC -->
    <script>
        function toggleCardHighlight(index, isChecked) {
            const card = document.getElementById('prodCard_' + index);
            if (card) {
                if (isChecked) {
                    card.classList.add('selected');
                } else {
                    card.classList.remove('selected');
                }
            }
        }

        function updateCharCount(el) {
            const counter = document.getElementById('descCounter');
            if (counter) {
                counter.innerText = el.value.length + ' / 2000 ký tự';
            }
        }

        function handleFilesSelected(input) {
            const container = document.getElementById('mediaPreviewContainer');
            if (!container) return;
            container.innerHTML = '';

            if (!input.files || input.files.length === 0) {
                container.style.display = 'none';
                return;
            }

            container.style.display = 'flex';
            const fileCountNotice = document.createElement('div');
            fileCountNotice.className = 'preview-summary-text';
            fileCountNotice.innerHTML = '<i class="fi fi-rr-check"></i> Đã chọn <strong>' + input.files.length + '</strong> tệp bằng chứng:';
            container.appendChild(fileCountNotice);

            const listWrap = document.createElement('div');
            listWrap.className = 'preview-thumbnails-row';

            Array.from(input.files).forEach((file) => {
                const item = document.createElement('div');
                item.className = 'preview-thumb-item';

                if (file.type.startsWith('image/')) {
                    const img = document.createElement('img');
                    img.src = URL.createObjectURL(file);
                    img.className = 'thumb-img';
                    item.appendChild(img);
                } else {
                    const vidIcon = document.createElement('div');
                    vidIcon.className = 'thumb-video-icon';
                    vidIcon.innerHTML = '<i class="fi fi-rr-video-camera"></i><span class="vid-name">' + file.name.substring(0, 10) + '</span>';
                    item.appendChild(vidIcon);
                }

                listWrap.appendChild(item);
            });

            container.appendChild(listWrap);
        }
    </script>
</body>
</html>
