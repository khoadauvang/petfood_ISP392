<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý danh mục · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>QUẢN LÝ BÁN HÀNG</span>
                <span class="sep">&gt;</span>
                <span class="current">QUẢN LÝ DANH MỤC</span>
            </div>
            <h1>QUẢN LÝ DANH MỤC <span class="pill-badge orange">PHÂN LOẠI THÚ CƯNG</span></h1>
            <p class="page-sub">Phân nhóm sản phẩm thức ăn hạt, pate dinh dưỡng, cát vệ sinh và đồ dùng dành cho Chó &amp; Mèo.</p>
        </div>

        <div>
            <a href="${ctx}/staff/categories/new" class="btn-flashsale">
                <i class="ti ti-plus"></i>Thêm danh mục mới
            </a>
        </div>
    </div>

    <%-- 4 Thẻ KPI thống kê danh mục --%>
    <c:set var="activeCount" value="0"/>
    <c:set var="dogCount" value="0"/>
    <c:set var="catCount" value="0"/>
    <c:forEach var="item" items="${categories}">
        <c:if test="${item.status == 'ACTIVE'}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
        <c:if test="${item.petType == 'DOG'}"><c:set var="dogCount" value="${dogCount + 1}"/></c:if>
        <c:if test="${item.petType == 'CAT'}"><c:set var="catCount" value="${catCount + 1}"/></c:if>
    </c:forEach>

    <section class="grid g-4">
        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Tổng số danh mục</span>
                <span class="kpi-ico orange"><i class="ti ti-category"></i></span>
            </div>
            <div class="kpi-value">${categories != null ? categories.size() : 0}</div>
            <div class="kpi-meta"><span class="badge orange">Toàn bộ danh mục</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Đang hiển thị</span>
                <span class="kpi-ico green"><i class="ti ti-eye"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">${activeCount}</div>
            <div class="kpi-meta"><span class="badge ok">Hoạt động trên trang khách</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Danh mục cho Chó</span>
                <span class="kpi-ico yellow"><i class="ti ti-dog"></i></span>
            </div>
            <div class="kpi-value" style="color:#d97706">${dogCount}</div>
            <div class="kpi-meta"><span class="badge warn">Dành riêng cho Chó cưng</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Danh mục cho Mèo</span>
                <span class="kpi-ico purple"><i class="ti ti-cat"></i></span>
            </div>
            <div class="kpi-value" style="color:#7c3aed">${catCount}</div>
            <div class="kpi-meta"><span class="badge purple">Dành riêng cho Mèo cưng</span></div>
        </div>
    </section>

    <%-- Bảng danh sách danh mục --%>
    <div class="panel" style="padding:0; overflow:hidden">
        <div class="split-head">
            <div>
                <h3 style="margin:0"><i class="ti ti-list" style="color:var(--color-primary)"></i>DANH SÁCH DANH MỤC SẢN PHẨM</h3>
                <small style="color:var(--text-muted)">Hiển thị theo loại thú cưng và số lượng sản phẩm liên kết</small>
            </div>
            <div style="font-size:13px; color:var(--text-muted)">
                Tổng cộng: <b style="color:var(--color-primary)">${categories != null ? categories.size() : 0}</b> danh mục
            </div>
        </div>

        <c:choose>
            <c:when test="${empty categories}">
                <div style="text-align:center; padding:48px 20px; color:var(--text-muted)">
                    <div style="width:54px; height:54px; border-radius:50%; background:#fff7ed; color:#ea580c; display:grid; place-items:center; font-size:24px; margin:0 auto 16px">
                        <i class="ti ti-category-2"></i>
                    </div>
                    <h3 style="margin:0 0 8px 0; color:var(--text-main)">Chưa có danh mục nào</h3>
                    <p style="font-size:13px; margin:0 0 16px 0">Hãy tạo danh mục đầu tiên để phân loại các sản phẩm trong kho.</p>
                    <a href="${ctx}/staff/categories/new" class="btn-flashsale">
                        <i class="ti ti-plus"></i>Tạo danh mục ngay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto">
                    <table style="box-shadow:none; border:0; margin:0; width:100%">
                        <thead>
                        <tr>
                            <th style="width:80px">MÃ</th>
                            <th>TÊN DANH MỤC</th>
                            <th>LOẠI THÚ CƯNG</th>
                            <th>TRẠNG THÁI</th>
                            <th class="num" style="text-align:center">SỐ SẢN PHẨM</th>
                            <th style="text-align:right; width:220px">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="cat" items="${categories}">
                            <tr>
                                <td>
                                    <span class="pill-badge gray" style="font-weight:800">#${cat.id}</span>
                                </td>
                                <td>
                                    <div style="display:flex; align-items:center; gap:10px">
                                        <div style="width:36px; height:36px; border-radius:10px; background:#fff7ee; color:#ea580c; display:grid; place-items:center; font-size:18px; border:1px solid #ffd8b8; flex-shrink:0">
                                            <i class="ti ti-folder"></i>
                                        </div>
                                        <div>
                                            <b style="font-size:14px; color:var(--text-main)"><c:out value="${cat.name}"/></b>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cat.petType == 'DOG'}">
                                            <span class="pill-badge orange"><i class="ti ti-dog"></i>${cat.petType.label}</span>
                                        </c:when>
                                        <c:when test="${cat.petType == 'CAT'}">
                                            <span class="pill-badge purple"><i class="ti ti-cat"></i>${cat.petType.label}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge blue"><i class="ti ti-paw"></i>${cat.petType.label}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${cat.status == 'ACTIVE'}">
                                            <span class="pill-badge green"><i class="ti ti-eye"></i>Đang hiển thị</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge gray"><i class="ti ti-eye-off"></i>Đang ẩn</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="num" style="text-align:center">
                                    <a href="${ctx}/staff/products?categoryId=${cat.id}"
                                       class="pill-badge ${cat.productCount > 0 ? 'orange' : 'gray'}"
                                       style="text-decoration:none"
                                       title="Nhấp để xem danh sách sản phẩm thuộc danh mục này">
                                        <i class="ti ti-package"></i>${cat.productCount} sản phẩm
                                    </a>
                                </td>
                                <td>
                                    <div style="display:flex; align-items:center; justify-content:flex-end; gap:8px">
                                        <a href="${ctx}/staff/categories/${cat.id}/edit" class="btn-pill-outline" style="padding:6px 14px; font-size:12px" title="Chỉnh sửa thông tin danh mục">
                                            <i class="ti ti-pencil"></i>Sửa
                                        </a>

                                        <form method="post" action="${ctx}/staff/categories/${cat.id}/toggle-status" style="display:inline">
                                            ${csrf}
                                            <button type="submit" class="btn-pill-outline" style="padding:6px 14px; font-size:12px"
                                                    title="${cat.status == 'ACTIVE' ? 'Ẩn khỏi trang mua sắm của khách' : 'Hiện lại trên trang mua sắm'}">
                                                <i class="ti ${cat.status == 'ACTIVE' ? 'ti-eye-off' : 'ti-eye'}"></i>
                                                ${cat.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}
                                            </button>
                                        </form>

                                        <%-- Chỉ xoá được danh mục chưa có sản phẩm; có sản phẩm thì chỉ ẩn --%>
                                        <c:if test="${cat.productCount == 0}">
                                            <form method="post" action="${ctx}/staff/categories/${cat.id}/delete" style="display:inline"
                                                  onsubmit="return confirm('Bạn có chắc chắn muốn xoá vĩnh viễn danh mục này?');">
                                                ${csrf}
                                                <button type="submit" class="btn-pill-danger" style="padding:6px 14px; font-size:12px" title="Xoá vĩnh viễn danh mục">
                                                    <i class="ti ti-trash"></i>Xoá
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

</body>
</html>
