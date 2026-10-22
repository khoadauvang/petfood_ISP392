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
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .table-wrap { overflow-x: auto; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border-bottom: 1px solid #e5e5e5; padding: 8px; text-align: left; }
        th { background: #f6f6f6; }
        .num { text-align: right; white-space: nowrap; }
        .pager a, .pager strong { margin-right: 8px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<h1>Đơn hàng của tôi</h1>

<c:choose>
    <c:when test="${empty orders}">
        <p>Bạn chưa có đơn hàng nào. <a href="${ctx}/products">Mua sắm ngay</a></p>
    </c:when>
    <c:otherwise>
        <div class="table-wrap">
        <table>
            <thead>
            <tr><th>Mã đơn</th><th>Ngày đặt</th><th>Sản phẩm</th><th class="num">Tổng tiền</th><th>Trạng thái</th><th>Thanh toán</th></tr>
            </thead>
            <tbody>
            <c:forEach var="o" items="${orders}">
                <tr>
                    <td><a href="${ctx}/orders/${o.id}">#${o.id}</a></td>
                    <td>${o.createdAtText}</td>
                    <td>${o.totalQuantity} sản phẩm (${o.lineCount} dòng)</td>
                    <td class="num"><fmt:formatNumber value="${o.totalAmount}" type="number"/> ₫</td>
                    <td>${o.status.label}<c:if test="${o.cancelRequested}"> · đang yêu cầu huỷ</c:if></td>
                    <td>${o.paymentStatusLabel}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>
        <c:if test="${totalPages > 1}">
            <nav class="pager">
                <c:if test="${currentPage > 1}"><a href="?page=${currentPage - 1}">‹ Trước</a></c:if>
                <c:forEach begin="1" end="${totalPages}" var="n">
                    <c:choose>
                        <c:when test="${n == currentPage}"><strong>${n}</strong></c:when>
                        <c:otherwise><a href="?page=${n}">${n}</a></c:otherwise>
                    </c:choose>
                </c:forEach>
                <c:if test="${currentPage < totalPages}"><a href="?page=${currentPage + 1}">Sau ›</a></c:if>
            </nav>
        </c:if>
    </c:otherwise>
</c:choose>

</body>
</html>
