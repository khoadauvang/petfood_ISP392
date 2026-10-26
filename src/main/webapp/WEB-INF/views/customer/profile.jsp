<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<fmt:setLocale value="vi_VN" />
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hồ sơ & Hạng hội viên · PetFood</title>
        <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <!-- TÁCH CSS -->
        <link rel="stylesheet" href="${ctx}/css/profile.css">
    </head>
    <body>

        <c:set var="ownFlash" value="true"/>
        <%@ include file="/WEB-INF/views/common/_header.jspf" %>

        <div class="breadcrumb-bar">
            <div>
                <a href="${ctx}/">Trang chủ</a> › <a href="${ctx}/profile">Tài khoản</a> › <strong id="breadcrumb-title">Hồ sơ của tôi</strong>
            </div>
        </div>

        <div class="page-container">
            <c:set var="activeMenu" value="profile" />
            <c:set var="onProfilePage" value="${true}" />
            <%@ include file="/WEB-INF/views/common/_customer-sidebar.jspf" %>

            <main class="main-card">
                <!-- TAB 1: HỒ SƠ -->
                <div id="tab-info" class="tab-content active">
                    <div class="card-header-tabs">
                        <div>
                            <h2 id="tab-heading">Hồ sơ của tôi</h2>
                            <p id="tab-subheading">Quản lý thông tin định danh phụ huynh thú cưng, thông tin liên lạc và bảo mật tài khoản.</p>
                        </div>
                        <div class="tab-btn-group">
                            <button type="button" id="subtab-btn-info" class="tab-btn active" onclick="switchSubTab('info')">Thông tin cá nhân</button>
                            <button type="button" id="subtab-btn-pwd" class="tab-btn" onclick="switchSubTab('password')">Đổi mật khẩu</button>
                        </div>
                    </div>

                    <!-- THÔNG BÁO FLASH MESSAGE -->
                    <c:if test="${not empty successMessage}">
                        <div class="profile-alert alert-success">
                            <i class="fi fi-rr-check-circle"></i>
                            <span><c:out value="${successMessage}"/></span>
                        </div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="profile-alert alert-error">
                            <i class="fi fi-rr-exclamation"></i>
                            <span><c:out value="${errorMessage}"/></span>
                        </div>
                    </c:if>

                    <!-- KHỐI 1: THÔNG TIN CÁ NHÂN -->
                    <div id="subtab-info">
                        <form:form method="post" action="${ctx}/profile" modelAttribute="profileForm" enctype="multipart/form-data">
                            <div class="avatar-edit-box">
                                <c:choose>
                                    <c:when test="${not empty profile.avatarUrl}">
                                        <img class="avatar-preview-lg" src="${ctx}<c:out value='${profile.avatarUrl}'/>" alt="Avatar">
                                    </c:when>
                                    <c:otherwise>
                                        <img class="avatar-preview-lg" src="https://ui-avatars.com/api/?name=${not empty currentUser.fullName ? currentUser.fullName : 'Customer'}" alt="Avatar">
                                    </c:otherwise>
                                </c:choose>
                                <div>
                                    <h4 style="font-size:15px;color:var(--text-primary);font-weight:700;">Ảnh đại diện</h4>
                                    <p style="font-size:12px;color:var(--text-secondary);margin:4px 0 10px;">Hỗ trợ định dạng PNG, JPG, WEBP. Khuyến nghị ảnh vuông tối đa 5MB.</p>
                                    <div style="display:flex; gap:12px; align-items:center;">
                                        <label for="avatarFile" style="padding:7px 16px;background:var(--primary-orange);color:#fff;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;box-shadow:var(--btn-shadow);">Đổi ảnh</label>
                                        <input type="file" id="avatarFile" name="avatar" style="display:none;" accept="image/jpeg,image/png,image/webp">
                                        <c:if test="${not empty profile.avatarUrl}">
                                            <label style="font-size:13px; cursor:pointer; color:var(--text-secondary); display:flex; align-items:center; gap:6px;">
                                                <form:checkbox path="removeAvatar" /> Gỡ ảnh
                                            </label>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <div class="form-grid">
                                <div class="form-group">
                                    <label class="form-label">Họ và tên</label>
                                    <form:input path="fullName" class="form-control" placeholder="Nhập họ và tên..." maxlength="100" />
                                    <form:errors path="fullName" cssClass="error" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Địa chỉ email <span style="font-weight:400;color:var(--text-secondary);">(Tài khoản chính)</span></label>
                                    <input type="text" class="form-control" value="${profile.email}" disabled readonly style="background:#f5eee8;">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Số điện thoại</label>
                                    <div class="phone-input-box">
                                        <span class="phone-prefix">+84</span>
                                        <form:input path="phone" class="form-control" placeholder="908 123 456" maxlength="12" />
                                    </div>
                                    <form:errors path="phone" cssClass="error" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Hạng thành viên</label>
                                    <input type="text" class="form-control" value="Hội viên ${profile.tierLabel}" disabled readonly style="background:#f5eee8;font-weight:600;color:var(--primary-orange);">
                                </div>
                            </div>

                            <div class="form-bottom-actions">
                                <a href="${ctx}/profile" class="btn-cancel">Hủy thay đổi</a>
                                <button type="submit" class="btn-save">Lưu thay đổi</button>
                            </div>
                        </form:form>
                    </div>

                    <!-- KHỐI 2: ĐỔI MẬT KHẨU (GỌN GÀNG CHUẨN SHOPEE) -->
                    <div id="subtab-password" style="display: none;">
                        <c:choose>
                            <c:when test="${profile.hasPassword}">
                                <%-- Đổi mật khẩu: mật khẩu hiện tại + mật khẩu mới 2 lần (BR-02). Quên mật khẩu hiện tại thì
                                     dùng luồng OTP như ở trang đăng nhập. --%>
                                <form:form method="post" action="${ctx}/profile/change-password" modelAttribute="changePasswordForm">
                                    <div class="pwd-form-table">
                                        <div class="pwd-form-row">
                                            <label class="pwd-form-label" for="currentPassword">Mật khẩu hiện tại <span style="color:#d9381e;">*</span></label>
                                            <div class="pwd-form-input-col">
                                                <div class="password-input-wrap">
                                                    <form:password path="currentPassword" id="currentPassword" class="form-control" placeholder="Nhập mật khẩu đang dùng" autocomplete="current-password" />
                                                    <button type="button" class="btn-toggle-eye" onclick="togglePasswordVisibility('currentPassword')" tabindex="-1"><i class="fi fi-rr-eye"></i></button>
                                                </div>
                                                <form:errors path="currentPassword" cssClass="error" />
                                                <a href="${ctx}/forgot-password" style="display:inline-block; margin-top:6px; font-size:13px; color:#F47721; font-weight:600;">Quên mật khẩu hiện tại?</a>
                                            </div>
                                        </div>

                                        <div class="pwd-form-row">
                                            <label class="pwd-form-label" for="newPassword">Mật khẩu mới <span style="color:#d9381e;">*</span></label>
                                            <div class="pwd-form-input-col">
                                                <div class="password-input-wrap">
                                                    <form:password path="newPassword" id="newPassword" class="form-control" placeholder="8–64 ký tự, gồm cả chữ và số" autocomplete="new-password" />
                                                    <button type="button" class="btn-toggle-eye" onclick="togglePasswordVisibility('newPassword')" tabindex="-1"><i class="fi fi-rr-eye"></i></button>
                                                </div>
                                                <form:errors path="newPassword" cssClass="error" />
                                            </div>
                                        </div>

                                        <div class="pwd-form-row">
                                            <label class="pwd-form-label" for="confirmPassword">Xác nhận mật khẩu <span style="color:#d9381e;">*</span></label>
                                            <div class="pwd-form-input-col">
                                                <div class="password-input-wrap">
                                                    <form:password path="confirmPassword" id="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới" autocomplete="new-password" />
                                                    <button type="button" class="btn-toggle-eye" onclick="togglePasswordVisibility('confirmPassword')" tabindex="-1"><i class="fi fi-rr-eye"></i></button>
                                                </div>
                                                <form:errors path="confirmPassword" cssClass="error" />
                                            </div>
                                        </div>

                                        <div class="pwd-form-actions">
                                            <button type="submit" class="btn-save">Xác nhận</button>
                                            <button type="button" class="btn-cancel" onclick="switchSubTab('info')">Quay lại</button>
                                        </div>
                                    </div>
                                </form:form>
                            </c:when>
                            <c:otherwise>
                                <%-- Tài khoản chỉ đăng nhập Google chưa có mật khẩu: tạo mật khẩu bằng OTP qua email (mục 9.11) --%>
                                <div class="pwd-form-table">
                                    <div class="password-notice-box" style="margin-bottom: 8px;">
                                        <i class="fi fi-rr-info"></i>
                                        <div>Tài khoản đăng nhập qua Google chưa thiết lập mật khẩu riêng. Bạn có thể tạo mật khẩu bằng mã OTP gửi tới email <strong><c:out value="${profile.email}"/></strong> để đăng nhập bằng email &amp; mật khẩu.</div>
                                    </div>
                                    <div class="pwd-form-actions">
                                        <a href="${ctx}/forgot-password" class="btn-save" style="text-decoration:none; display:inline-block;">Nhận mã OTP</a>
                                        <button type="button" class="btn-cancel" onclick="switchSubTab('info')">Quay lại</button>
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- TAB 2: HẠNG HỘI VIÊN -->
                <div id="tab-tier" class="tab-content">
                    <div style="margin-bottom:20px;">
                        <h2 style="font-size:22px;font-weight:700;color:var(--text-primary);"><i class="fi fi-sr-star" style="color: var(--primary-orange);"></i> Hạng Thành Viên & Chi Tiêu Tích Lũy</h2>
                        <p style="font-size:13px;color:var(--text-secondary);margin-top:4px;">Theo dõi cấp bậc hội viên và quyền lợi ưu đãi dựa trên chi tiêu thực tế tại PetFood.</p>
                    </div>

                    <div class="tier-banner">
                        <div>
                            <div style="font-size:12px;opacity:0.9;font-weight:600;letter-spacing:0.5px;">HỘI VIÊN ${profile.tierLabel.toUpperCase()}</div>
                            <h3 style="font-size:24px;font-weight:800;margin:6px 0;"><c:out value="${not empty profile.fullName ? profile.fullName : 'Quý khách'}" /></h3>
                            <div style="margin-top:16px;font-size:13px;line-height:1.8;">
                                <div><i class="fi fi-rr-check"></i> Cam kết ưu tiên xuất kho lô sản xuất mới nhất (FEFO)</div>
                                <div><i class="fi fi-rr-check"></i> Quyền lợi bảo hành đổi trả trong vòng 3 ngày</div>
                                <div><i class="fi fi-rr-check"></i> Tích lũy chi tiêu tự động sau mỗi đơn hàng hoàn tất</div>
                            </div>
                        </div>
                        <div style="background:rgba(255,255,255,0.18);padding:20px;border-radius:12px;display:flex;flex-direction:column;justify-content:space-between;backdrop-filter:blur(4px);">
                            <div>
                                <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:700;">
                                    <span>HẠNG HIỆN TẠI</span>
                                    <span>${profile.tierLabel}</span>
                                </div>
                                <div style="background:rgba(255,255,255,0.3);height:10px;border-radius:5px;margin:12px 0;overflow:hidden;">
                                    <div style="background:#fff;height:100%;width:75%;border-radius:5px;"></div>
                                </div>
                            </div>
                            <div style="font-size:12px;line-height:1.5;background:rgba(0,0,0,0.15);padding:10px;border-radius:8px;">
                                <i class="fi fi-rr-bulb"></i> Hệ thống tự động tính lại hạng vào 00:05 mỗi ngày dựa trên đơn đã hoàn tất.
                            </div>
                        </div>
                    </div>

                    <h3 style="font-size:16px;font-weight:700;margin-bottom:14px;color:var(--text-primary);">Các bậc quyền lợi hội viên PetFood</h3>
                    <div class="tier-cards-grid">
                        <div class="tier-card ${profile.tierLabel == 'Đồng' ? 'current' : ''}">
                            <c:if test="${profile.tierLabel == 'Đồng'}"><span class="tier-badge-label">HẠNG HIỆN TẠI</span></c:if>
                            <h4 style="font-size:15px;font-weight:700;">Đồng</h4>
                            <div style="color:var(--text-secondary);margin-bottom:8px;font-size:11px;">Mức khởi điểm</div>
                            <p><i class="fi fi-rr-check"></i> Tích lũy chi tiêu đơn hàng<br><i class="fi fi-rr-check"></i> Tư vấn chăm sóc</p>
                        </div>
                        <div class="tier-card ${profile.tierLabel == 'Bạc' ? 'current' : ''}">
                            <c:if test="${profile.tierLabel == 'Bạc'}"><span class="tier-badge-label">HẠNG HIỆN TẠI</span></c:if>
                            <h4 style="font-size:15px;font-weight:700;">Bạc</h4>
                            <div style="color:var(--text-secondary);margin-bottom:8px;font-size:11px;">Chi tiêu từ 1.200.000₫</div>
                            <p><i class="fi fi-rr-check"></i> Giảm 3% giá thường<br><i class="fi fi-rr-check"></i> Hỗ trợ ưu tiên</p>
                        </div>
                        <div class="tier-card ${profile.tierLabel == 'Vàng' ? 'current' : ''}">
                            <c:if test="${profile.tierLabel == 'Vàng'}"><span class="tier-badge-label">HẠNG HIỆN TẠI</span></c:if>
                            <h4 style="font-size:15px;font-weight:700;">Vàng</h4>
                            <div style="color:var(--text-secondary);margin-bottom:8px;font-size:11px;">Chi tiêu từ 4.000.000₫</div>
                            <p><i class="fi fi-rr-check"></i> Giảm 5% giá thường<br><i class="fi fi-rr-check"></i> Ưu tiên FEFO mới nhất<br><i class="fi fi-rr-check"></i> CSKH riêng biệt</p>
                        </div>
                        <div class="tier-card ${profile.tierLabel == 'Kim cương' ? 'current' : ''}">
                            <c:if test="${profile.tierLabel == 'Kim cương'}"><span class="tier-badge-label">HẠNG HIỆN TẠI</span></c:if>
                            <h4 style="font-size:15px;font-weight:700;">Kim Cương</h4>
                            <div style="color:var(--text-secondary);margin-bottom:8px;font-size:11px;">Chi tiêu từ 10.000.000₫</div>
                            <p><i class="fi fi-rr-check"></i> Giảm 10% giá thường<br><i class="fi fi-rr-check"></i> Miễn phí ship đặc quyền<br><i class="fi fi-rr-check"></i> Quà sinh nhật thú cưng</p>
                        </div>
                    </div>

                    <div style="text-align:right;margin-top:16px;">
                        <a href="${ctx}/orders" class="btn-cancel" style="display:inline-block;text-decoration:none;">Xem lịch sử đơn hàng & chi tiêu →</a>
                    </div>
                </div>
            </main>
        </div>

        <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
        <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

        <script>
            function switchTab(tabName) {
                document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
                const btnInfo = document.getElementById('btn-side-info');
                const btnTier = document.getElementById('btn-side-tier');
                if (btnInfo)
                    btnInfo.classList.remove('active');
                if (btnTier)
                    btnTier.classList.remove('active');

                if (tabName === 'info') {
                    document.getElementById('tab-info').classList.add('active');
                    if (btnInfo)
                        btnInfo.classList.add('active');
                    const bc = document.getElementById('breadcrumb-title');
                    if (bc)
                        bc.innerText = 'Hồ sơ của tôi';
                } else if (tabName === 'tier') {
                    document.getElementById('tab-tier').classList.add('active');
                    if (btnTier)
                        btnTier.classList.add('active');
                    const bc = document.getElementById('breadcrumb-title');
                    if (bc)
                        bc.innerText = 'Hạng hội viên & Chi tiêu tích lũy';
                }
            }

            function switchSubTab(subTab) {
                const btnInfo = document.getElementById('subtab-btn-info');
                const btnPwd = document.getElementById('subtab-btn-pwd');
                const contentInfo = document.getElementById('subtab-info');
                const contentPwd = document.getElementById('subtab-password');
                const heading = document.getElementById('tab-heading');
                const subheading = document.getElementById('tab-subheading');

                if (subTab === 'password') {
                    if (btnInfo) btnInfo.classList.remove('active');
                    if (btnPwd) btnPwd.classList.add('active');
                    if (contentInfo) contentInfo.style.display = 'none';
                    if (contentPwd) contentPwd.style.display = 'block';
                    if (heading) heading.innerText = 'Đổi mật khẩu tài khoản';
                    if (subheading) subheading.innerText = 'Để bảo mật tài khoản, vui lòng không chia sẻ mật khẩu cho người khác.';
                } else {
                    if (btnInfo) btnInfo.classList.add('active');
                    if (btnPwd) btnPwd.classList.remove('active');
                    if (contentInfo) contentInfo.style.display = 'block';
                    if (contentPwd) contentPwd.style.display = 'none';
                    if (heading) heading.innerText = 'Hồ sơ của tôi';
                    if (subheading) subheading.innerText = 'Quản lý thông tin định danh phụ huynh thú cưng, thông tin liên lạc và bảo mật tài khoản.';
                }
            }

            function togglePasswordVisibility(fieldId) {
                const input = document.getElementById(fieldId);
                if (!input) return;
                input.type = input.type === 'password' ? 'text' : 'password';
            }

            window.addEventListener('DOMContentLoaded', () => {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('tab') === 'tier' || window.location.hash === '#tab-tier') {
                    switchTab('tier');
                }
                const activeSubTab = '${activeSubTab}';
                if (activeSubTab === 'password' || window.location.hash === '#password') {
                    switchSubTab('password');
                }
            });
        </script>
    </body>
</html>
