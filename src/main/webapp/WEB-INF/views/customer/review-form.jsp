<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đánh giá sản phẩm · Đơn #PFS-${orderId} · PetFood</title>
    
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/3.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/css/orders.css">
    <style>
        .review-page-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #f4e3c9;
            padding: 28px 32px;
            max-width: 640px;
            margin: 0 auto;
            box-shadow: 0 4px 16px rgba(61, 48, 40, 0.04);
        }
        .review-header-box {
            margin-bottom: 22px;
            padding-bottom: 16px;
            border-bottom: 1px solid #f3ece5;
        }
        .review-header-box h2 {
            font-size: 20px;
            font-weight: 800;
            color: #3d3028;
            margin-bottom: 6px;
        }
        .review-product-name-highlight {
            font-size: 15px;
            font-weight: 700;
            color: #f47721;
        }
        .review-star-group {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 12px 0 20px;
        }
        .review-stars {
            display: flex;
            gap: 6px;
            font-size: 32px;
            color: #e2d9d2;
            cursor: pointer;
        }
        .review-stars .star-btn {
            transition: color .15s;
        }
        .review-stars .star-btn.active {
            color: #f59e0b;
        }
        .form-label-bold {
            display: block;
            font-size: 13.5px;
            font-weight: 700;
            color: #3d3028;
            margin-bottom: 8px;
        }
        .form-input-clean, .form-textarea-clean {
            width: 100%;
            border: 1px solid #e3d5c8;
            border-radius: 8px;
            padding: 11px 14px;
            font-size: 13.5px;
            color: #3d3028;
            background: #fff;
            outline: none;
            box-sizing: border-box;
            transition: border-color .2s, box-shadow .2s;
        }
        .form-input-clean:focus, .form-textarea-clean:focus {
            border-color: #f47721;
            box-shadow: 0 0 0 3px rgba(244,119,33,0.12);
        }
        .btn-submit-review {
            background: #f47721;
            color: #fff;
            border: none;
            padding: 12px 28px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 3px 8px rgba(244,119,33,0.2);
            transition: .2s;
        }
        .btn-submit-review:hover {
            background: #e96816;
            transform: translateY(-1px);
        }
        .btn-cancel-link {
            padding: 12px 20px;
            border-radius: 8px;
            border: 1px solid #d8c7b8;
            background: #fff;
            color: #57483a;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
        }
    </style>
</head>
<body>

    <%@ include file="/WEB-INF/views/common/_header.jspf" %>

    <div class="breadcrumb-bar">
        <div>
            <a href="${ctx}/"><i class="fi fi-rr-home"></i> Trang chủ</a> › 
            <a href="${ctx}/orders">Đơn hàng của tôi</a> › 
            <a href="${ctx}/orders/${orderId}">Đơn #PFS-${orderId}</a> › 
            <strong>Đánh giá sản phẩm</strong>
        </div>
    </div>

    <div class="page-container" style="max-width: 900px; margin: 30px auto; padding: 0 16px;">
        <main class="review-page-card">
            <div class="review-header-box">
                <h2>Đánh giá sản phẩm</h2>
                <div class="review-product-name-highlight">
                    <i class="fi fi-rr-box-alt"></i> <c:out value="${productName}"/>
                </div>
            </div>

            <form:form method="post" action="${ctx}/orders/${orderId}/items/${itemId}/review" modelAttribute="reviewForm">
                <div style="margin-bottom: 20px;">
                    <label class="form-label-bold">Chất lượng sản phẩm <span style="color:#d9381e;">*</span></label>
                    <form:hidden path="rating" id="pageRatingInput" />
                    <div class="review-star-group">
                        <div class="review-stars" id="pageStars">
                            <span class="star-btn active" data-val="1" onclick="selectPageStar(1)"><i class="fi fi-sr-star"></i></span>
                            <span class="star-btn active" data-val="2" onclick="selectPageStar(2)"><i class="fi fi-sr-star"></i></span>
                            <span class="star-btn active" data-val="3" onclick="selectPageStar(3)"><i class="fi fi-sr-star"></i></span>
                            <span class="star-btn active" data-val="4" onclick="selectPageStar(4)"><i class="fi fi-sr-star"></i></span>
                            <span class="star-btn active" data-val="5" onclick="selectPageStar(5)"><i class="fi fi-sr-star"></i></span>
                        </div>
                        <span id="pageRatingText" style="font-size: 13.5px; font-weight: 700; color: #d97706;">Tuyệt vời (5/5)</span>
                    </div>
                    <form:errors path="rating" cssClass="error" style="color:#d9381e; font-size:12px;" />
                </div>

                <div style="margin-bottom: 18px;">
                    <label class="form-label-bold" for="title">Tiêu đề đánh giá</label>
                    <form:input path="title" id="title" class="form-input-clean" placeholder="Tóm tắt cảm nhận (VD: Bé cún rất thích, đóng gói cẩn thận)..." maxlength="150"/>
                    <form:errors path="title" cssClass="error" style="color:#d9381e; font-size:12px;" />
                </div>

                <div style="margin-bottom: 26px;">
                    <label class="form-label-bold" for="content">Nội dung nhận xét</label>
                    <form:textarea path="content" id="content" rows="4" class="form-textarea-clean" placeholder="Hãy chia sẻ chi tiết về mùi vị, tình trạng date, phản ứng của thú cưng để giúp đỡ các phụ huynh khác nhé..." maxlength="2000"/>
                    <form:errors path="content" cssClass="error" style="color:#d9381e; font-size:12px;" />
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                    <a href="${ctx}/orders/${orderId}" class="btn-cancel-link">Quay lại</a>
                    <button type="submit" class="btn-submit-review">Gửi đánh giá</button>
                </div>
            </form:form>
        </main>
    </div>

    <%@ include file="/WEB-INF/views/common/_footer.jspf" %>

    <script>
        const pageLabels = {
            1: 'Rất tệ (1/5)',
            2: 'Không hài lòng (2/5)',
            3: 'Bình thường (3/5)',
            4: 'Hài lòng (4/5)',
            5: 'Tuyệt vời (5/5)'
        };

        function selectPageStar(val) {
            document.getElementById('pageRatingInput').value = val;
            document.getElementById('pageRatingText').innerText = pageLabels[val] || (val + '/5');
            const stars = document.querySelectorAll('#pageStars .star-btn');
            stars.forEach((star, idx) => {
                if (idx < val) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
        }

        window.addEventListener('DOMContentLoaded', () => {
            const currentRating = parseInt(document.getElementById('pageRatingInput').value) || 5;
            selectPageStar(currentRating);
        });
    </script>
</body>
</html>
