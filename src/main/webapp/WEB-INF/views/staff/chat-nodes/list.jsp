<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: nodes (ChatNodeRow theo thứ tự cây: id, depth, label, botMessage, actionUrl, sortOrder, status,
     childCount, hiddenByAncestor, updatedByName, updatedAtText) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Kịch bản chatbox · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>.muted { opacity: .55; } .bot-msg { color: #555; font-size: 13px; }</style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<h1>KỊCH BẢN CHATBOX</h1>
<p class="hint">Khách chọn chủ đề → nội dung con → giải pháp. Nút không có con là giải pháp. Nút ẩn thì khách không thấy cả nhánh con.
    Nút đã có yêu cầu hỗ trợ tham chiếu chỉ ẩn được, không xoá.</p>
<p><a href="${ctx}/staff/chat-nodes/new">+ Thêm chủ đề gốc</a> · <a href="${ctx}/support" target="_blank">Xem chatbox như khách ›</a></p>

<table>
    <thead><tr><th>Nút</th><th class="num">Thứ tự</th><th>Trạng thái</th><th>Cập nhật</th><th></th></tr></thead>
    <tbody>
    <c:forEach var="n" items="${nodes}">
        <tr class="${n.status == 'HIDDEN' or n.hiddenByAncestor ? 'muted' : ''}">
            <td style="padding-left: ${8 + n.depth * 28}px">
                <strong><c:out value="${n.label}"/></strong>
                <c:if test="${n.childCount == 0}"><span class="badge">Giải pháp</span></c:if>
                <div class="bot-msg pre"><c:out value="${n.botMessage}"/></div>
                <c:if test="${not empty n.actionUrl}"><div class="bot-msg">Link: <c:out value="${n.actionUrl}"/></div></c:if>
            </td>
            <td class="num">${n.sortOrder}</td>
            <td><span class="badge ${n.status}">${n.status.label}</span>
                <c:if test="${n.hiddenByAncestor}"><div class="hint">Nút cha đã ẩn</div></c:if></td>
            <td class="hint"><c:out value="${n.updatedByName}"/><br>${n.updatedAtText}</td>
            <td>
                <a href="${ctx}/staff/chat-nodes/new?parent=${n.id}">+ Nút con</a>
                · <a href="${ctx}/staff/chat-nodes/${n.id}/edit">Sửa</a>
                <form method="post" action="${ctx}/staff/chat-nodes/${n.id}/${n.status == 'ACTIVE' ? 'hide' : 'show'}" class="inline">${csrf}
                    <button type="submit">${n.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}</button>
                </form>
                <c:if test="${n.childCount == 0}">
                    <form method="post" action="${ctx}/staff/chat-nodes/${n.id}/delete" class="inline"
                          onsubmit="return confirm('Xoá nút này?');">${csrf}
                        <button type="submit">Xoá</button>
                    </form>
                </c:if>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty nodes}"><tr><td colspan="5">Chưa có nút nào. Hãy thêm chủ đề gốc.</td></tr></c:if>
    </tbody>
</table>
</body>
</html>
