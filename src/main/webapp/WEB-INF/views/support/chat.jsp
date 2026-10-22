<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: chat (ChatConversation)
       chat.path          các bước khách đã chọn (ChatStep: id, label, botMessage, actionUrl), trống ở màn hình đầu
       chat.options       lựa chọn tiếp theo; trống khi bước cuối là giải pháp
       chat.currentNodeId id bước cuối (null ở màn hình đầu), gửi kèm khi bấm "Khác" --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hỗ trợ · PetFood</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .chat { max-width: 640px; display: flex; flex-direction: column; gap: 8px; }
        .bubble { padding: 8px 12px; border-radius: 12px; max-width: 80%; white-space: pre-line; }
        .bot { background: #f1f3f5; align-self: flex-start; }
        .user { background: #2f7d32; color: #fff; align-self: flex-end; }
        .action { margin-top: 6px; white-space: normal; }
        .options { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
        .options a { border: 1px solid #2f7d32; color: #2f7d32; border-radius: 16px; padding: 6px 12px; text-decoration: none; }
        .options a.other { border-style: dashed; color: #555; border-color: #888; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/_header.jspf" %>
<h1>Hỗ trợ khách hàng</h1>

<div class="chat">
    <div class="bubble bot">Xin chào! PetFood có thể giúp gì cho bạn? Hãy chọn một chủ đề bên dưới.</div>
    <c:forEach var="step" items="${chat.path}">
        <div class="bubble user"><c:out value="${step.label}"/></div>
        <div class="bubble bot"><c:out value="${step.botMessage}"/><%@ include file="/WEB-INF/views/support/_action-link.jspf" %></div>
    </c:forEach>
    <c:if test="${not empty chat.path and empty chat.options}">
        <div class="bubble bot">Nội dung trên đã giải quyết được vấn đề của bạn chưa? Nếu chưa, hãy bấm "Khác" để gửi yêu cầu cho nhân viên.</div>
    </c:if>
</div>

<div class="options">
    <c:forEach var="o" items="${chat.options}">
        <a href="${ctx}/support?node=${o.id}"><c:out value="${o.label}"/></a>
    </c:forEach>
    <c:url var="otherUrl" value="/support/ticket"><c:if test="${chat.currentNodeId != null}"><c:param name="node" value="${chat.currentNodeId}"/></c:if></c:url>
    <a class="other" href="${otherUrl}">Khác (gửi yêu cầu cho nhân viên)</a>
    <c:if test="${not empty chat.path}">
        <c:if test="${chat.path.size() > 1}">
            <a class="other" href="${ctx}/support?node=${chat.path[chat.path.size() - 2].id}">‹ Quay lại</a>
        </c:if>
        <a class="other" href="${ctx}/support">Bắt đầu lại</a>
    </c:if>
</div>
<c:if test="${empty chat.path and empty chat.options}"><p>Chưa có chủ đề hỗ trợ nào, bạn hãy bấm "Khác" để gửi câu hỏi.</p></c:if>
</body>
</html>
