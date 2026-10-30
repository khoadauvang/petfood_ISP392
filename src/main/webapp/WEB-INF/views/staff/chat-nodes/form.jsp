<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Model: chatNodeForm (parentId, label, botMessage, actionUrl, sortOrder, status), nodeId (null = thêm mới),
     parentOptions (ChatNodeOption: id, label đã thụt lề; đã bỏ chính nút này và con cháu), nodeStatuses --%>
<c:choose>
    <c:when test="${empty nodeId}">
        <c:set var="pageHeading" value="Thêm nút kịch bản"/>
        <c:url var="formAction" value="/staff/chat-nodes/new"/>
    </c:when>
    <c:otherwise>
        <c:set var="pageHeading" value="Sửa nút kịch bản #${nodeId}"/>
        <c:url var="formAction" value="/staff/chat-nodes/${nodeId}/edit"/>
    </c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${pageHeading} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>CHĂM SÓC KHÁCH HÀNG</span> <span class="sep">&gt;</span> <a href="${ctx}/staff/chat-nodes" style="color:inherit; text-decoration:none;">KỊCH BẢN PHẢN HỒI CHAT</a> <span class="sep">&gt;</span> <span class="current">${pageHeading}</span>
            </div>
            <h1>${pageHeading}</h1>
        </div>
    </div>

<form:form method="post" action="${formAction}" modelAttribute="chatNodeForm">
    <div class="grid-form">
        <label for="parentId">Nút cha</label>
        <div>
            <form:select path="parentId">
                <form:option value="" label="(Không có — chủ đề gốc)"/>
                <form:options items="${parentOptions}" itemValue="id" itemLabel="label"/>
            </form:select>
            <form:errors path="parentId" cssClass="err"/>
        </div>

        <label for="label">Nhãn (câu khách chọn)</label>
        <div>
            <form:input path="label" maxlength="150" size="60" required="required"/>
            <span class="hint">Ví dụ: "Theo dõi đơn hàng", "Đơn của tôi giao chậm"</span>
            <form:errors path="label" cssClass="err"/>
        </div>

        <label for="botMessage">Câu trả lời của chatbox</label>
        <div>
            <form:textarea path="botMessage" rows="5" cols="70" maxlength="4000" required="required"/>
            <form:errors path="botMessage" cssClass="err"/>
        </div>

        <label for="actionUrl">Link gợi ý (tuỳ chọn)</label>
        <div>
            <form:input path="actionUrl" maxlength="255" size="60" placeholder="/orders"/>
            <span class="hint">Trang trong shop bắt đầu bằng / (ví dụ /orders, /flash-sale), hoặc link http(s)://</span>
            <form:errors path="actionUrl" cssClass="err"/>
        </div>

        <label for="sortOrder">Thứ tự</label>
        <div>
            <form:input path="sortOrder" type="number" min="0" max="9999"/>
            <span class="hint">Số nhỏ hiện trước trong cùng cấp</span>
            <form:errors path="sortOrder" cssClass="err"/>
        </div>

        <label for="status">Trạng thái</label>
        <div>
            <form:select path="status">
                <form:options items="${nodeStatuses}" itemLabel="label"/>
            </form:select>
            <form:errors path="status" cssClass="err"/>
        </div>
    </div>
    <p>
        <button type="submit">Lưu</button>
        <a href="${ctx}/staff/chat-nodes">Huỷ</a>
    </p>
</form:form>
</main>
</body>
</html>
