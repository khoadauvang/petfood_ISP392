<%@ tag pageEncoding="UTF-8" body-content="scriptless" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Breadcrumb dùng chung cho các trang phía khách: Trang chủ › (các mục giữa) › trang hiện tại.
     Cách dùng (khai báo <%@ taglib prefix="pf" tagdir="/WEB-INF/tags" %>):
       <pf:breadcrumb current="Chi tiết đơn #PFS-12">
           <pf:crumb href="${ctx}/profile" label="Tài khoản"/>
           <pf:crumb href="${ctx}/orders" label="Đơn hàng của tôi"/>
       </pf:breadcrumb>
     currentId: id cho mục hiện tại khi JS cần đổi chữ (trang hồ sơ). style: chỉnh khoảng cách theo từng trang. --%>
<%@ attribute name="current" required="true" %>
<%@ attribute name="currentId" required="false" %>
<%@ attribute name="style" required="false" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/breadcrumb.css?v=1">
<nav class="pf-breadcrumb" aria-label="Breadcrumb"<c:if test="${not empty style}"> style="${style}"</c:if>>
    <a href="${pageContext.request.contextPath}/"><i class="fi fi-rr-home"></i><span>Trang chủ</span></a>
    <jsp:doBody/>
    <span class="pf-bc-sep" aria-hidden="true">›</span>
    <span class="pf-bc-current" aria-current="page"<c:if test="${not empty currentId}"> id="${currentId}"</c:if>><c:out value="${current}"/></span>
</nav>
