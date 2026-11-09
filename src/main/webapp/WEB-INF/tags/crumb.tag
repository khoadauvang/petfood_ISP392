<%@ tag pageEncoding="UTF-8" body-content="empty" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Một mục giữa của <pf:breadcrumb> --%>
<%@ attribute name="href" required="true" %>
<%@ attribute name="label" required="true" %>
<span class="pf-bc-sep" aria-hidden="true">›</span>
<a href="${href}"><c:out value="${label}"/></a>
