<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đánh giá · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>.review { border-bottom: 1px solid #e5e5e5; padding: 10px 0; } .stars { color: #e6a700; }
        .reply { background: #f6f6f6; padding: 6px 10px; margin-top: 6px; border-radius: 4px; }
        .hidden-review { opacity: .6; }</style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<h1>Đánh giá sản phẩm</h1>

<form class="filters" method="get" action="${ctx}/staff/reviews">
    <select name="status">
        <option value="">Mọi trạng thái</option>
        <c:forEach var="s" items="${statuses}"><option value="${s}" ${filterStatus == s ? 'selected' : ''}>${s.label}</option></c:forEach>
    </select>
    <label><input type="checkbox" name="unreplied" value="true" ${filterUnreplied ? 'checked' : ''}> Chưa phản hồi</label>
    <input type="search" name="keyword" value="<c:out value='${filterKeyword}'/>" placeholder="Tên hoặc SKU sản phẩm">
    <button type="submit">Lọc</button>
</form>
<p>${totalItems} đánh giá</p>

<c:forEach var="r" items="${reviews}">
    <div class="review ${r.status == 'HIDDEN' ? 'hidden-review' : ''}">
        <strong>#${r.id}</strong> · <a href="${ctx}/products/${r.productId}"><c:out value="${r.productName}"/></a>
        · <span class="stars"><c:forEach begin="1" end="${r.rating}">★</c:forEach></span>
        · <c:out value="${r.customerName}"/> · ${r.createdAtText}<c:if test="${r.edited}"> (đã sửa)</c:if>
        · <span class="badge">${r.status.label}</span>
        <c:if test="${not empty r.title}"><div><strong><c:out value="${r.title}"/></strong></div></c:if>
        <c:if test="${not empty r.content}"><div class="pre"><c:out value="${r.content}"/></div></c:if>
        <c:choose>
            <c:when test="${not empty r.replyContent}">
                <div class="reply">Phản hồi của <c:out value="${r.replyByName}"/> (${r.replyAtText}): <c:out value="${r.replyContent}"/></div>
            </c:when>
            <c:otherwise>
                <form method="post" action="${ctx}/staff/reviews/${r.id}/reply">${csrf}
                    <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
                    <input type="text" name="content" size="60" maxlength="2000" placeholder="Phản hồi (mỗi đánh giá một lần)" required>
                    <button type="submit">Phản hồi</button>
                </form>
            </c:otherwise>
        </c:choose>
        <form method="post" action="${ctx}/staff/reviews/${r.id}/${r.status == 'VISIBLE' ? 'hide' : 'show'}" class="inline">${csrf}
            <input type="hidden" name="back" value="<c:out value='${filterQuery}'/>">
            <button type="submit">${r.status == 'VISIBLE' ? 'Ẩn đánh giá' : 'Hiện lại'}</button>
        </form>
    </div>
</c:forEach>
<c:if test="${empty reviews}"><p>Không có đánh giá nào.</p></c:if>

<c:if test="${totalPages > 1}">
    <nav class="pager">
        <c:forEach begin="1" end="${totalPages}" var="n">
            <c:choose>
                <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                <c:otherwise><a href="?${filterQuery}&page=${n}">${n}</a></c:otherwise>
            </c:choose>
        </c:forEach>
    </nav>
</c:if>
</body>
</html>
