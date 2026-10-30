<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="policies" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chính sách khách hàng · PetFood</title>

    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-bold-rounded/css/uicons-bold-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${ctx}/css/policies.css">
</head>
<body>

    <%-- 1. HEADER CHUNG --%>
    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <%-- 2. HERO BANNER CHÍNH SÁCH (BASIC, DỄ ĐỌC, KHÔNG ÁNH CAM) --%>
    <section class="policy-hero">
        <div class="policy-hero-inner">
            <span class="policy-badge">
                <i class="fi fi-rr-shield-check"></i> PetFood &bull; Trung Tâm Chính Sách &amp; Quyền Lợi
            </span>
            <h1>Chính sách khách hàng PetFood</h1>
            <p>Hệ thống cửa hàng thức ăn &amp; chăm sóc thú cưng cao cấp. Các chính sách được thiết lập minh bạch và rõ ràng nhằm bảo đảm quyền lợi tối đa cho khách hàng khi mua sắm.</p>
        </div>
    </section>

    <%-- 3. THANH ĐIỀU HƯỚNG NHANH CÁC MỤC (STICKY NAV, KHUNG VUÔNG) --%>
    <nav class="policy-nav-sticky" aria-label="Menu chính sách">
        <div class="policy-nav-container">
            <a href="#shipping" class="policy-nav-tab active"><i class="fi fi-rr-shipping-fast"></i> 1. Giao hàng</a>
            <a href="#return" class="policy-nav-tab"><i class="fi fi-rr-undo"></i> 2. Đổi trả &amp; Hoàn tiền</a>
            <a href="#membership" class="policy-nav-tab"><i class="fi fi-rr-star"></i> 3. Thành viên &amp; Tích điểm</a>
            <a href="#fefo" class="policy-nav-tab"><i class="fi fi-rr-calendar-check"></i> 4. Quản lý hạn dùng FEFO</a>
            <a href="#privacy" class="policy-nav-tab"><i class="fi fi-rr-lock"></i> 5. Bảo mật thông tin</a>
        </div>
    </nav>

    <%-- 4. NỘI DUNG CHI TIẾT 5 CHÍNH SÁCH (KHUNG VUÔNG, KHÔNG SHADOW) --%>
    <main class="policy-container">

        <!-- ================= MỤC 1: CHÍNH SÁCH GIAO HÀNG ================= -->
        <article class="policy-card" id="shipping">
            <div class="policy-card-header">
                <div class="policy-card-icon"><i class="fi fi-rr-shipping-fast"></i></div>
                <div>
                    <span>Vận chuyển toàn quốc</span>
                    <h2>1. Chính sách giao hàng</h2>
                </div>
            </div>

            <p>
                <strong>Khu vực giao hàng:</strong> PetFood giao hàng toàn quốc thông qua các đơn vị vận chuyển đối tác liên kết uy tín.
            </p>

            <div class="shipping-grid">
                <div class="shipping-box">
                    <h4><i class="fi fi-rr-building"></i> Nội thành (các thành phố lớn)</h4>
                    <div class="shipping-time">1 – 2 ngày làm việc</div>
                    <p>Áp dụng tại Hà Nội, TP.HCM, Đà Nẵng, Cần Thơ. Hỗ trợ giao hỏa tốc cho các đơn hàng cần gấp.</p>
                </div>
                <div class="shipping-box">
                    <h4><i class="fi fi-rr-map-marker"></i> Ngoại thành / Tỉnh khác</h4>
                    <div class="shipping-time">2 – 5 ngày làm việc</div>
                    <p>Đơn hàng được bao bọc cẩn thận, bảo quản khô ráo và giữ nguyên chất lượng tới tận tay người nhận.</p>
                </div>
            </div>

            <p><strong>Phí giao hàng:</strong> Tính theo khu vực và trọng lượng đơn hàng, hiển thị cụ thể ở bước thanh toán trước khi khách xác nhận đặt hàng. Miễn phí giao hàng áp dụng cho đơn hàng đạt mức giá trị tối thiểu theo chương trình hiện hành.</p>
            <p><strong>Kiểm tra hàng khi nhận:</strong> Khách hàng được quyền kiểm tra tình trạng bên ngoài gói hàng trước khi thanh toán (đối với đơn COD) hoặc trước khi ký nhận.</p>

            <div class="policy-note-box">
                <i class="fi fi-rr-info"></i>
                <div>
                    <strong>Giao hàng không thành công:</strong> Nếu không liên hệ được khách sau <strong>3 lần giao</strong>, đơn hàng sẽ được hoàn về kho. Khách hàng có thể liên hệ CSKH qua <strong>khung chat hỗ trợ</strong> trực tuyến trên website để đặt lại lịch giao.
                </div>
            </div>
        </article>

        <!-- ================= MỤC 2: CHÍNH SÁCH ĐỔI TRẢ & HOÀN TIỀN ================= -->
        <article class="policy-card" id="return">
            <div class="policy-card-header">
                <div class="policy-card-icon"><i class="fi fi-rr-undo"></i></div>
                <div>
                    <span>Quyền lợi khách hàng</span>
                    <h2>2. Chính sách đổi trả &amp; Hoàn tiền</h2>
                </div>
            </div>

            <p><strong>Điều kiện đổi trả hợp lệ:</strong></p>
            <div class="conditions-list">
                <div class="condition-item">
                    <i class="fi fi-rr-check"></i>
                    <p>Sản phẩm bị lỗi, hư hỏng do vận chuyển, hoặc giao sai sản phẩm so với đơn đặt.</p>
                </div>
                <div class="condition-item">
                    <i class="fi fi-rr-check"></i>
                    <p>Sản phẩm còn nguyên bao bì, chưa sử dụng và còn hạn sử dụng.</p>
                </div>
                <div class="condition-item">
                    <i class="fi fi-rr-check"></i>
                    <p>Yêu cầu đổi trả được thực hiện trong vòng <strong>3 ngày</strong> kể từ khi nhận hàng.</p>
                </div>
            </div>

            <p><strong>Quy trình xử lý 5 bước:</strong> Khách hàng gửi yêu cầu đổi trả qua khung chat hỗ trợ trên website (hoặc gửi form hỗ trợ nếu chatbox không giải quyết được) — không cần gửi email.</p>

            <div class="return-steps-flow">
                <div class="step-card">
                    <div class="step-number">1</div>
                    <h5>Đã gửi yêu cầu</h5>
                    <p>Yêu cầu được ghi nhận trên hệ thống.</p>
                </div>
                <div class="step-card">
                    <div class="step-number">2</div>
                    <h5>CSKH xem xét</h5>
                    <p>Phản hồi Chấp nhận hoặc Từ chối (kèm lý do).</p>
                </div>
                <div class="step-card">
                    <div class="step-number">3</div>
                    <h5>Đã nhận hàng trả</h5>
                    <p>Khách gửi sản phẩm về kho sau khi được chấp nhận.</p>
                </div>
                <div class="step-card">
                    <div class="step-number">4</div>
                    <h5>Đang kiểm tra</h5>
                    <p>Sản phẩm được nhân viên kiểm tra thực tế.</p>
                </div>
                <div class="step-card">
                    <div class="step-number">5</div>
                    <h5>Đã hoàn tiền</h5>
                    <p>Hoàn vào ví/tài khoản trong 3–5 ngày làm việc (hoặc Đã đóng nếu không đủ ĐK).</p>
                </div>
            </div>

            <p style="font-size: 13.5px; color: #6B7280; margin-top: 14px;">
                Khách hàng có thể theo dõi trạng thái yêu cầu đổi trả trực tiếp trong trang <strong>Tài khoản &rarr; Đơn hàng của tôi</strong>.
            </p>
        </article>

        <!-- ================= MỤC 3: CHÍNH SÁCH THÀNH VIÊN & TÍCH ĐIỂM ================= -->
        <article class="policy-card" id="membership">
            <div class="policy-card-header">
                <div class="policy-card-icon"><i class="fi fi-rr-star"></i></div>
                <div>
                    <span>Chương trình thành viên</span>
                    <h2>3. Chính sách thành viên &amp; Tích điểm</h2>
                </div>
            </div>

            <p>
                Mọi đơn hàng thanh toán thành công đều được tích điểm thành viên. Hạng thành viên được xét tự động dựa trên tổng điểm tích lũy, mang lại mức ưu đãi giảm giá riêng cho mỗi hạng:
            </p>

            <div class="tier-cards-grid">
                <!-- Hạng BRONZE -->
                <div class="tier-card tier-bronze">
                    <div class="tier-icon"><i class="fi fi-rr-medal"></i></div>
                    <div class="tier-name">BRONZE</div>
                    <span class="tier-tag">Hạng mặc định</span>
                    <p class="tier-benefits">Áp dụng ngay khi đăng ký tài khoản thành công.</p>
                </div>

                <!-- Hạng SILVER -->
                <div class="tier-card tier-silver">
                    <div class="tier-icon"><i class="fi fi-rr-badge"></i></div>
                    <div class="tier-name">SILVER</div>
                    <span class="tier-tag">Thân thiết</span>
                    <p class="tier-benefits">Giảm giá ưu đãi trên mỗi đơn hàng.</p>
                </div>

                <!-- Hạng GOLD -->
                <div class="tier-card tier-gold">
                    <div class="tier-icon"><i class="fi fi-rr-star"></i></div>
                    <div class="tier-name">GOLD</div>
                    <span class="tier-tag">VIP</span>
                    <p class="tier-benefits">Mức giảm giá cao hơn + ưu tiên hỗ trợ đổi trả.</p>
                </div>

                <!-- Hạng DIAMOND -->
                <div class="tier-card tier-diamond">
                    <div class="tier-icon"><i class="fi fi-rr-gem"></i></div>
                    <div class="tier-name">DIAMOND</div>
                    <span class="tier-tag">Kim Cương</span>
                    <p class="tier-benefits">Mức giảm giá cao nhất + ưu tiên các chương trình Flash Sale.</p>
                </div>
            </div>

            <p>&bull; <strong>Hiển thị minh bạch:</strong> Điểm tích lũy và hạng thành viên hiện tại được hiển thị tại trang <strong>Tài khoản</strong>, kèm số điểm cần thêm để lên hạng kế tiếp.</p>
            <p>&bull; <strong>Tự động áp dụng:</strong> Mức giảm giá theo hạng được áp dụng tự động ngay tại bước thanh toán, không cần nhập mã.</p>
            <p>&bull; Hạng thành viên được xem xét lại định kỳ dựa trên lịch sử mua hàng.</p>
        </article>

        <!-- ================= MỤC 4: CHẤT LƯỢNG SẢN PHẨM (FEFO) ================= -->
        <article class="policy-card" id="fefo">
            <div class="policy-card-header">
                <div class="policy-card-icon"><i class="fi fi-rr-calendar-check"></i></div>
                <div>
                    <span>Tiêu chuẩn quản lý kho</span>
                    <h2>4. Chính sách chất lượng sản phẩm</h2>
                </div>
            </div>

            <p>
                Vì PetFood kinh doanh thức ăn và sản phẩm tiêu dùng cho thú cưng, hệ thống quản lý hàng tồn kho theo từng lô hàng (lô) với hạn sử dụng riêng biệt, áp dụng nguyên tắc xuất hàng gần hết hạn trước <strong>(FEFO – First-Expired-First-Out)</strong>:
            </p>

            <div class="fefo-details-grid">
                <div class="fefo-detail-box">
                    <h4><i class="fi fi-rr-box-alt"></i> Xuất kho tự động tối ưu</h4>
                    <p>Mỗi đơn hàng được hệ thống tự động ưu tiên xuất từ lô hàng có hạn sử dụng gần nhất còn đủ điều kiện bán, giúp hạn chế tồn đọng hàng cận hạn trong kho.</p>
                </div>
                <div class="fefo-detail-box">
                    <h4><i class="fi fi-rr-flame"></i> Ưu đãi Flash Sale giá tốt</h4>
                    <p>Các sản phẩm cận hạn sử dụng được ưu tiên đưa vào chương trình Flash Sale với giá ưu đãi, giúp khách hàng mua được sản phẩm chất lượng tốt với giá tốt hơn, trong khi vẫn đảm bảo hạn sử dụng còn đủ dài khi đến tay khách.</p>
                </div>
                <div class="fefo-detail-box">
                    <h4><i class="fi fi-rr-calendar"></i> Hạn sử dụng rõ ràng</h4>
                    <p>Hạn sử dụng của sản phẩm được hiển thị rõ trên trang sản phẩm và trên bao bì thực tế khi giao hàng.</p>
                </div>
            </div>

            <div class="zero-tolerance-box">
                <i class="fi fi-rr-shield-exclamation"></i>
                <div>
                    <strong>CAM KẾT PETFOOD:</strong> Sản phẩm quá hạn sử dụng không bao giờ được đưa ra bán, dù ở giá nào.
                </div>
            </div>
        </article>

        <!-- ================= MỤC 5: BẢO MẬT THÔNG TIN ================= -->
        <article class="policy-card" id="privacy">
            <div class="policy-card-header">
                <div class="policy-card-icon"><i class="fi fi-rr-lock"></i></div>
                <div>
                    <span>Bảo vệ quyền riêng tư</span>
                    <h2>5. Chính sách bảo mật thông tin</h2>
                </div>
            </div>

            <div class="security-points-grid">
                <div class="security-point">
                    <h4><i class="fi fi-rr-database"></i> Thông tin thu thập &amp; Mục đích</h4>
                    <p><strong>Thông tin:</strong> Họ tên, số điện thoại, địa chỉ giao hàng, email (nếu đăng nhập bằng Google), lịch sử đơn hàng.<br>
                    <strong>Mục đích:</strong> Chỉ để xử lý đơn hàng, giao hàng, chăm sóc khách hàng và cải thiện trải nghiệm mua sắm. PetFood không chia sẻ hay bán thông tin khách hàng cho bên thứ ba vì mục đích thương mại.</p>
                </div>
                <div class="security-point">
                    <h4><i class="fi fi-rr-shield-check"></i> Bảo mật tài khoản</h4>
                    <p>Mật khẩu được mã hóa trước khi lưu trữ; hỗ trợ đăng nhập an toàn qua Google OAuth2 hoặc tài khoản/mật khẩu riêng. Khách hàng có thể tự đặt lại mật khẩu qua mã xác thực OTP khi quên mật khẩu.</p>
                </div>
            </div>

            <div class="policy-note-box" style="margin-top: 18px;">
                <i class="fi fi-rr-user-check"></i>
                <div>
                    <strong>Quyền của khách hàng:</strong> Có thể xem, cập nhật hoặc yêu cầu xóa thông tin cá nhân bất kỳ lúc nào tại trang <strong>Tài khoản</strong>, hoặc liên hệ CSKH qua <strong>khung chat hỗ trợ</strong> để được xử lý.
                </div>
            </div>
        </article>

    </main>

    <%-- 5. FOOTER VÀ CHATBOX --%>
    <%@ include file="/WEB-INF/views/common/_footer.jspf" %>
    <%@ include file="/WEB-INF/views/common/_chat-widget.jspf" %>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const tabs = document.querySelectorAll(".policy-nav-tab");
            const sections = document.querySelectorAll(".policy-card");

            window.addEventListener("scroll", function() {
                let current = "";
                sections.forEach(section => {
                    const sectionTop = section.offsetTop - 140;
                    if (window.scrollY >= sectionTop) {
                        current = section.getAttribute("id");
                    }
                });

                tabs.forEach(tab => {
                    tab.classList.remove("active");
                    if (tab.getAttribute("href") === "#" + current) {
                        tab.classList.add("active");
                    }
                });
            });
        });
    </script>
</body>
</html>
