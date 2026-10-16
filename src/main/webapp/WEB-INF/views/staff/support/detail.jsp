<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: ticket (SupportTicketDetailDto: ..., replies, canClaim, canReply, canClose, canMarkSpam), replyDraft (flash, khi gửi lỗi) --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${ticket.ticketCode} · Food Pet Shop</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>.reply { border-left: 3px solid #ddd; padding: 6px 10px; margin: 8px 0; max-width: 900px; }
        .reply.FAILED { border-color: #b00020; } .reply.SENT { border-color: #0a5c26; }</style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>
<p><a href="${ctx}/staff/support">‹ Danh sách yêu cầu</a></p>
<h1>Yêu cầu ${ticket.ticketCode} <span class="badge ${ticket.status}">${ticket.status.label}</span></h1>

<div class="grid-form">
    <label>Người gửi</label>
    <div><c:out value="${ticket.contactName}"/> &lt;<c:out value="${ticket.contactEmail}"/>&gt;
        <span class="hint">${ticket.customerAccount ? '(tài khoản khách hàng)' : '(khách vãng lai)'}</span></div>
    <label>Chủ đề chatbox</label>
    <div><c:choose>
        <c:when test="${empty ticket.fromNodeLabel}">(bấm "Khác" ở danh sách chủ đề)</c:when>
        <c:otherwise><c:out value="${ticket.fromNodeLabel}"/></c:otherwise>
    </c:choose></div>
    <label>Gửi lúc</label>
    <div>${ticket.createdAtText}</div>
    <label>Người xử lý</label>
    <div><c:out value="${empty ticket.handledByName ? 'Chưa có' : ticket.handledByName}"/></div>
    <c:if test="${not empty ticket.closedAtText}"><label>Đóng lúc</label><div>${ticket.closedAtText}</div></c:if>
    <label>Nội dung</label>
    <div class="pre"><c:out value="${ticket.content}"/></div>
</div>

<p>
    <c:if test="${ticket.canClaim}">
        <form method="post" action="${ctx}/staff/support/${ticket.id}/claim" class="inline">${csrf}<button type="submit">Nhận xử lý</button></form>
    </c:if>
    <c:if test="${ticket.canClose}">
        <form method="post" action="${ctx}/staff/support/${ticket.id}/close" class="inline">${csrf}<button type="submit">Đóng yêu cầu</button></form>
    </c:if>
    <c:if test="${ticket.canMarkSpam}">
        <form method="post" action="${ctx}/staff/support/${ticket.id}/spam" class="inline"
              onsubmit="return confirm('Đánh dấu yêu cầu này là spam?');">${csrf}<button type="submit">Đánh dấu spam</button></form>
    </c:if>
</p>

<h2>Email đã trả lời</h2>
<c:forEach var="r" items="${ticket.replies}">
    <div class="reply ${r.sendStatus}">
        <strong><c:out value="${r.repliedByName}"/></strong> · ${r.createdAtText}
        · <span class="badge">${r.sendStatus.label}</span><c:if test="${not empty r.sentAtText}"> lúc ${r.sentAtText}</c:if>
        <div class="pre"><c:out value="${r.content}"/></div>
        <c:if test="${r.sendStatus == 'FAILED' and ticket.canReply}">
            <form method="post" action="${ctx}/staff/support/${ticket.id}/replies/${r.id}/resend" class="inline">${csrf}
                <button type="submit">Gửi lại</button>
            </form>
        </c:if>
    </div>
</c:forEach>
<c:if test="${empty ticket.replies}"><p class="hint">Chưa có email nào.</p></c:if>

<c:if test="${ticket.canReply}">
    <h2>Trả lời qua email</h2>
    <form method="post" action="${ctx}/staff/support/${ticket.id}/reply">${csrf}
        <p class="hint">Gửi tới <c:out value="${ticket.contactEmail}"/>, tiêu đề "[Food Pet Shop] Trả lời yêu cầu hỗ trợ ${ticket.ticketCode}".
            Email kèm lại nội dung khách đã hỏi.</p>
        <textarea name="content" rows="6" cols="90" maxlength="4000" required><c:out value="${replyDraft}"/></textarea><br>
        <button type="submit">Gửi email</button>
    </form>
</c:if>
</body>
</html>
