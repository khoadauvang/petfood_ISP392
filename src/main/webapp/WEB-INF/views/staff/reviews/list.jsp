<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đánh giá sản phẩm · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        .review-card {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: var(--shadow-card);
            padding: 22px;
            margin-bottom: 16px;
            transition: all var(--transition);
        }
        .review-card:hover {
            box-shadow: var(--shadow-pop);
            border-color: #ffd8b8;
        }
        .review-card.is-hidden {
            opacity: 0.72;
            background: #fafafa;
        }
        .review-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 14px;
            flex-wrap: wrap;
        }
        .review-user {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .review-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: #ffedd5;
            color: #ea580c;
            display: grid;
            place-items: center;
            font-weight: 800;
            font-size: 16px;
            flex-shrink: 0;
            border: 2px solid #fed7aa;
        }
        .stars-gold {
            color: #f59e0b;
            font-size: 16px;
            display: inline-flex;
            gap: 2px;
            align-items: center;
        }
        .stars-empty {
            color: #e5e7eb;
        }
        .review-prod-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            background: var(--surface-soft);
            border: 1px solid var(--line);
            border-radius: 10px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-main);
            text-decoration: none;
            margin-bottom: 12px;
            transition: all var(--transition);
        }
        .review-prod-tag:hover {
            border-color: var(--color-primary);
            color: var(--color-primary);
            background: #fff7ee;
        }
        .review-body {
            font-size: 14px;
            line-height: 1.6;
            color: var(--text-main);
            margin: 8px 0 16px;
            white-space: pre-line;
        }
        .reply-box {
            background: #fffcf9;
            border-left: 3px solid #ea580c;
            border-radius: 0 12px 12px 0;
            padding: 12px 16px;
            margin-top: 14px;
            border: 1px solid #fed7aa;
            border-left-width: 4px;
            border-left-color: #ea580c;
        }
        .reply-meta {
            font-size: 12px;
            font-weight: 700;
            color: #c2410c;
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 4px;
        }
        .reply-text {
            font-size: 13px;
            color: var(--text-main);
            line-height: 1.5;
        }
        .reply-form {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 14px;
            flex-wrap: wrap;
        }
        .reply-input {
            flex: 1;
            min-width: 260px;
            padding: 9px 14px;
            border-radius: var(--radius-pill);
            border: 1px solid var(--line);
            font-size: 13px;
            background: var(--surface-soft);
        }
        .reply-input:focus {
            background: #fff;
            border-color: var(--color-primary);
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>CHĂM SÓC KHÁCH HÀNG</span>
                <span class="sep">&gt;</span>
                <span class="current">ĐÁNH GIÁ SẢN PHẨM</span>
            </div>
            <h1>ĐÁNH GIÁ SẢN PHẨM <span class="pill-badge orange">PHẢN HỒI &amp; KIỂM DUYỆT</span></h1>
            <p class="page-sub">Theo dõi ý kiến phản hồi từ khách mua hàng, trả lời thắc mắc và kiểm duyệt hiển thị công khai.</p>
        </div>

        <div style="display:flex; align-items:center; gap:10px">
            <a href="${ctx}/staff/reviews" class="btn-pill-outline" title="Làm mới danh sách">
                <i class="ti ti-rotate"></i>Làm mới
            </a>
        </div>
    </div>

    <%-- 4 Thẻ KPI thống kê đánh giá --%>
    <c:set var="star5Count" value="0"/>
    <c:set var="starLowCount" value="0"/>
    <c:set var="unrepliedCount" value="0"/>
    <c:forEach var="item" items="${reviews}">
        <c:if test="${item.rating == 5}"><c:set var="star5Count" value="${star5Count + 1}"/></c:if>
        <c:if test="${item.rating <= 2}"><c:set var="starLowCount" value="${starLowCount + 1}"/></c:if>
        <c:if test="${empty item.replyContent}"><c:set var="unrepliedCount" value="${unrepliedCount + 1}"/></c:if>
    </c:forEach>

    <section class="grid g-4">
        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Tổng đánh giá</span>
                <span class="kpi-ico orange"><i class="ti ti-star"></i></span>
            </div>
            <div class="kpi-value">${totalItems != null ? totalItems : 0}</div>
            <div class="kpi-meta"><span class="badge orange">Tất cả thời gian</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Hài lòng tuyệt đối (5★)</span>
                <span class="kpi-ico green"><i class="ti ti-star-filled"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">${star5Count}</div>
            <div class="kpi-meta"><span class="badge ok">5 sao · Rất hài lòng</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Cần hỗ trợ (≤ 2★)</span>
                <span class="kpi-ico red"><i class="ti ti-mood-sad"></i></span>
            </div>
            <div class="kpi-value" style="color:#ef4444">${starLowCount}</div>
            <div class="kpi-meta"><span class="badge red">Chú ý · Đánh giá thấp</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Chưa phản hồi</span>
                <span class="kpi-ico yellow"><i class="ti ti-message-dots"></i></span>
            </div>
            <div class="kpi-value" style="color:#d97706">${unrepliedCount}</div>
            <div class="kpi-meta"><span class="badge warn">Cần trả lời khách hàng</span></div>
        </div>
    </section>

    <%-- Bộ lọc đánh giá --%>
    <form class="filters" method="get" action="${ctx}/staff/reviews" style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
        <div style="flex:1; min-width:240px; position:relative">
            <i class="ti ti-search" style="position:absolute; left:14px; top:50%; transform:translateY(-50%); color:var(--text-placeholder); font-size:16px"></i>
            <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>"
                   placeholder="Tìm theo Tên hoặc SKU sản phẩm..."
                   style="width:100%; padding:9px 14px 9px 38px; border-radius:12px; border:1px solid var(--line); font-size:13px">
        </div>

        <select name="status" style="padding:9px 14px; border-radius:12px; border:1px solid var(--line); font-size:13px">
            <option value="">Mọi trạng thái hiển thị</option>
            <c:forEach var="s" items="${statuses}">
                <option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option>
            </c:forEach>
        </select>

        <label style="display:inline-flex; align-items:center; gap:6px; font-size:13px; font-weight:700; color:var(--text-main); cursor:pointer; background:var(--surface-soft); padding:8px 14px; border-radius:12px; border:1px solid var(--line)">
            <input type="checkbox" name="unreplied" value="true" ${filterUnreplied ? 'checked' : ''} style="cursor:pointer; accent-color:#ea580c">
            Chưa phản hồi
        </label>

        <button type="submit" class="btn-pill-primary">
            <i class="ti ti-filter"></i>Lọc
        </button>

        <a href="${ctx}/staff/reviews" class="act-icon" title="Đặt lại bộ lọc"><i class="ti ti-rotate"></i></a>
    </form>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px">
        <div style="font-size:13px; color:var(--text-muted)">
            Tìm thấy <b>${totalItems}</b> đánh giá sản phẩm
        </div>
    </div>

    <%-- Danh sách các thẻ đánh giá --%>
    <c:choose>
        <c:when test="${not empty reviews}">
            <c:forEach var="r" items="${reviews}">
                <div class="review-card ${r.status == 'HIDDEN' ? 'is-hidden' : ''}">
                    <div class="review-head">
                        <div class="review-user">
                            <div class="review-avatar">
                                <c:out value="${empty r.customerName ? 'K' : r.customerName.substring(0, 1)}"/>
                            </div>
                            <div>
                                <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap">
                                    <b style="font-size:15px; color:var(--text-main)"><c:out value="${r.customerName}"/></b>
                                    <span class="pill-badge green" style="font-size:10px; padding:2px 8px">
                                        <i class="ti ti-circle-check"></i>Đã mua hàng
                                    </span>
                                    <span class="pill-badge gray" style="font-size:10px; padding:2px 6px">#RV-${r.id}</span>
                                </div>
                                <div style="font-size:12px; color:var(--text-muted); margin-top:2px">
                                    Đánh giá lúc: ${r.createdAtText}
                                    <c:if test="${r.edited}">
                                        <span style="color:#ea580c; font-style:italic"> (đã chỉnh sửa)</span>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <div style="display:flex; align-items:center; gap:12px">
                            <%-- Hiển thị sao đánh giá --%>
                            <div class="stars-gold" title="${r.rating} / 5 sao">
                                <c:forEach begin="1" end="${r.rating}">
                                    <i class="ti ti-star-filled"></i>
                                </c:forEach>
                                <c:forEach begin="${r.rating + 1}" end="5">
                                    <i class="ti ti-star stars-empty"></i>
                                </c:forEach>
                            </div>

                            <%-- Badge trạng thái --%>
                            <c:choose>
                                <c:when test="${r.status == 'VISIBLE'}">
                                    <span class="pill-badge green"><i class="ti ti-eye"></i>Đang hiển thị</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="pill-badge gray"><i class="ti ti-eye-off"></i>Đã ẩn</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Tag dẫn tới sản phẩm --%>
                    <div>
                        <a href="${ctx}/products/${r.productId}" class="review-prod-tag" target="_blank" rel="noopener">
                            <i class="ti ti-package" style="color:#ea580c"></i>
                            <c:out value="${r.productName}"/>
                            <i class="ti ti-external-link" style="font-size:11px; color:var(--text-placeholder)"></i>
                        </a>
                    </div>

                    <%-- Nội dung đánh giá --%>
                    <c:if test="${not empty r.title}">
                        <div style="font-weight:800; font-size:15px; color:var(--text-logo); margin-bottom:4px">
                            <c:out value="${r.title}"/>
                        </div>
                    </c:if>

                    <c:if test="${not empty r.content}">
                        <div class="review-body">
                            <c:out value="${r.content}"/>
                        </div>
                    </c:if>

                    <%-- Phản hồi của cửa hàng --%>
                    <c:choose>
                        <c:when test="${not empty r.replyContent}">
                            <div class="reply-box">
                                <div class="reply-meta">
                                    <i class="ti ti-brand-telegram"></i>
                                    Phản hồi từ <b><c:out value="${r.replyByName}"/></b> (${r.replyAtText}):
                                </div>
                                <div class="reply-text">
                                    <c:out value="${r.replyContent}"/>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="${ctx}/staff/reviews/${r.id}/reply" class="reply-form">
                                ${csrf}
                                <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
                                <input type="text" name="content" class="reply-input" maxlength="2000"
                                       placeholder="Nhập nội dung phản hồi từ PetFood (mỗi đánh giá một lần)..." required>
                                <button type="submit" class="btn-pill-primary">
                                    <i class="ti ti-send"></i>Gửi phản hồi
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>

                    <%-- Nút ẩn/hiện đánh giá dưới cùng --%>
                    <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:14px; padding-top:12px; border-top:1px dashed var(--line)">
                        <form method="post" action="${ctx}/staff/reviews/${r.id}/${r.status == 'VISIBLE' ? 'hide' : 'show'}" style="display:inline">
                            ${csrf}
                            <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
                            <c:choose>
                                <c:when test="${r.status == 'VISIBLE'}">
                                    <button type="submit" class="btn-pill-outline" style="color:#dc2626; border-color:#fca5a5"
                                            onclick="return confirm('Ẩn đánh giá này khỏi trang sản phẩm của khách hàng?')">
                                        <i class="ti ti-eye-off"></i>Ẩn đánh giá
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button type="submit" class="btn-pill-outline">
                                        <i class="ti ti-eye"></i>Hiện lại đánh giá
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="panel" style="text-align:center; padding:48px 20px; color:var(--text-muted)">
                <div style="width:56px; height:56px; border-radius:50%; background:#fff7ed; color:#ea580c; display:grid; place-items:center; font-size:24px; margin:0 auto 16px">
                    <i class="ti ti-star-off"></i>
                </div>
                <h3 style="margin:0 0 8px 0; color:var(--text-main)">Không tìm thấy đánh giá nào</h3>
                <p style="font-size:13px; margin:0">Thử tìm kiếm với từ khóa khác hoặc xóa bớt tiêu chí lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>

    <%-- Phân trang Pagination --%>
    <c:if test="${totalPages > 1}">
        <div style="display:flex; justify-content:center; margin-top:24px">
            <nav class="pager">
                <c:if test="${currentPage > 1}">
                    <a href="?${filterQuery}&page=${currentPage - 1}">‹</a>
                </c:if>
                <c:forEach begin="1" end="${totalPages}" var="n">
                    <c:choose>
                        <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                        <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${currentPage < totalPages}">
                    <a href="?${filterQuery}&page=${currentPage + 1}">›</a>
                </c:if>
            </nav>
        </div>
    </c:if>
</main>

</body>
</html>
