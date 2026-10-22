<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hồ sơ của tôi · PetFood</title>
    <%-- Style tạm để xem được dữ liệu. FE team thay bằng css/ riêng. --%>
    <style>
        body { font-family: Arial, sans-serif; margin: 16px; color: #222; }
        .big-avatar { width: 120px; height: 120px; border-radius: 50%; object-fit: cover; background: #eee;
                      display: flex; align-items: center; justify-content: center; color: #999; }
        dl { display: grid; grid-template-columns: max-content 1fr; gap: 4px 12px; }
        dt { color: #666; }
        .field { margin: 10px 0; }
        .field label { display: block; margin-bottom: 4px; }
        .error { color: #b00020; display: block; }
        .hint { color: #666; font-size: 13px; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/_header.jspf" %>

<h1>Hồ sơ của tôi</h1>

<c:choose>
    <c:when test="${not empty profile.avatarUrl}">
        <img class="big-avatar" src="${ctx}<c:out value='${profile.avatarUrl}'/>" alt="Ảnh đại diện">
    </c:when>
    <c:otherwise><div class="big-avatar">Chưa có ảnh</div></c:otherwise>
</c:choose>

<dl>
    <dt>Email</dt><dd><c:out value="${profile.email}"/></dd>
    <dt>Hạng thành viên</dt><dd>${profile.tierLabel}</dd>
    <dt>Đăng nhập bằng</dt>
    <dd>
        <c:if test="${profile.hasPassword}">Email + mật khẩu</c:if>
        <c:if test="${profile.hasPassword and profile.googleLinked}"> · </c:if>
        <c:if test="${profile.googleLinked}">Google</c:if>
    </dd>
</dl>

<%-- multipart: có ô chọn ảnh. CSRF token đi qua tham số ẩn (form:form tự thêm). --%>
<form:form method="post" action="${ctx}/profile" modelAttribute="profileForm" enctype="multipart/form-data">
    <div class="field">
        <label for="fullName">Họ tên</label>
        <form:input path="fullName" maxlength="100"/>
        <form:errors path="fullName" cssClass="error"/>
    </div>
    <div class="field">
        <label for="phone">Số điện thoại</label>
        <form:input path="phone" maxlength="12" placeholder="0912345678"/>
        <form:errors path="phone" cssClass="error"/>
    </div>
    <div class="field">
        <label for="avatar">Ảnh đại diện mới</label>
        <input type="file" id="avatar" name="avatar" accept="image/jpeg,image/png,image/webp">
        <span class="hint">JPG, PNG hoặc WEBP, tối đa 5MB, tối thiểu 100×100 px.</span>
        <form:errors path="avatar" cssClass="error"/>
        <c:if test="${not empty profile.avatarUrl}">
            <label><form:checkbox path="removeAvatar"/> Xoá ảnh đại diện hiện tại</label>
        </c:if>
    </div>
    <button type="submit">Lưu thay đổi</button>
</form:form>

</body>
</html>
