<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Yêu cầu #${ticket.ticketCode} · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
</head>
<body class="admin-app">
    <%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

    <main class="admin-main">
        <div class="breadcrumb-bar" style="margin-bottom: 0.75rem; font-size: 0.8rem; color: #64748b;">
            <a href="${ctx}/staff/support" style="color: #64748b; text-decoration: none;">‹ Quay lại Hàng đợi yêu cầu hỗ trợ</a>
        </div>

        <!-- Master-Detail Single Ticket Detail View -->
        <div class="card" style="background: #fff; border-radius: 10px; border: 1px solid #eaeaea; box-shadow: 0 1px 3px rgba(0,0,0,0.03); max-width: 1000px; margin: 0 auto; overflow: hidden;">
            
            <!-- Ticket Thread Header -->
            <div style="padding: 1.1rem 1.5rem; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 0.75rem; background: #fffcf8;">
                <div>
                    <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.3rem;">
                        <h1 style="margin: 0; font-size: 1.35rem; font-weight: 800; color: #0f172a;">YÊU CẦU #${ticket.ticketCode}</h1>
                        <span class="badge ${ticket.status}" style="font-weight: 700; font-size: 0.78rem; padding: 0.25rem 0.65rem;">${ticket.status.label}</span>
                    </div>
                    <div style="font-size: 0.8rem; color: #64748b; display: flex; align-items: center; gap: 8px;">
                        <i class="ti ti-clock"></i>
                        <span>Gửi lúc: <strong>${ticket.createdAtText}</strong></span>
                        <span>•</span>
                        <span>Người tiếp nhận: <strong><c:out value="${empty ticket.handledByName ? 'Chưa tiếp nhận' : ticket.handledByName}"/></strong></span>
                        <c:if test="${not empty ticket.closedAtText}">
                            <span>•</span>
                            <span>Đóng lúc: ${ticket.closedAtText}</span>
                        </c:if>
                    </div>
                </div>

                <!-- Action buttons -->
                <div style="display: flex; gap: 0.5rem; align-items: center;">
                    <c:if test="${ticket.canClaim}">
                        <form method="post" action="${ctx}/staff/support/${ticket.id}/claim" style="display: inline;">${csrf}
                            <button type="submit" class="btn btn-sm btn-primary" style="background: #f59e0b; border: none; color: #fff; font-weight: 700;">
                                <i class="ti ti-user-plus"></i> Nhận xử lý
                            </button>
                        </form>
                    </c:if>
                    <c:if test="${ticket.canClose}">
                        <form method="post" action="${ctx}/staff/support/${ticket.id}/close" style="display: inline;">${csrf}
                            <button type="submit" class="btn btn-sm btn-secondary" style="background: #fff; border: 1px solid #cbd5e1; color: #475569;">
                                <i class="ti ti-check"></i> Đóng yêu cầu
                            </button>
                        </form>
                    </c:if>
                    <c:if test="${ticket.canMarkSpam}">
                        <form method="post" action="${ctx}/staff/support/${ticket.id}/spam" style="display: inline;" onsubmit="return confirm('Đánh dấu yêu cầu này là spam?');">${csrf}
                            <button type="submit" class="btn btn-sm" style="background: #fff; border: 1px solid #fecaca; color: #dc2626;">
                                <i class="ti ti-flag"></i> Báo spam
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>

            <!-- Customer Meta Box -->
            <div style="background: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 1rem 1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.75rem;">
                    <div style="display: flex; align-items: center; gap: 0.85rem;">
                        <div style="width: 44px; height: 44px; border-radius: 50%; background: #fed7aa; color: #c2410c; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 1.05rem;">
                            KH
                        </div>
                        <div>
                            <div style="display: flex; align-items: center; gap: 6px;">
                                <strong style="color: #0f172a; font-size: 1rem;"><c:out value="${ticket.contactName}"/></strong>
                                <span class="badge" style="background: #e0f2fe; color: #0369a1; font-size: 0.72rem; font-weight: 600;">
                                    ${ticket.customerAccount ? 'Tài khoản khách hàng' : 'Khách vãng lai'}
                                </span>
                            </div>
                            <div style="font-size: 0.82rem; color: #64748b;">
                                <c:out value="${ticket.contactEmail}"/>
                            </div>
                        </div>
                    </div>

                    <div style="font-size: 0.82rem; color: #64748b;">
                        <div>Chủ đề chatbox: <strong><c:out value="${empty ticket.fromNodeLabel ? '(Khác)' : ticket.fromNodeLabel}"/></strong></div>
                    </div>
                </div>
            </div>

            <!-- Thread Conversation -->
            <div style="padding: 1.5rem; background: #fafafa; display: flex; flex-direction: column; gap: 1.25rem;">
                
                <!-- Initial Customer Message -->
                <div style="display: flex; gap: 0.75rem; align-items: flex-start; max-width: 85%;">
                    <div style="width: 34px; height: 34px; border-radius: 50%; background: #fed7aa; color: #c2410c; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">
                        KH
                    </div>
                    <div>
                        <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 0.25rem;">
                            <strong style="color: #1e293b;"><c:out value="${ticket.contactName}"/></strong> • ${ticket.createdAtText}
                        </div>
                        <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 12px 12px 12px 2px; padding: 0.85rem 1.1rem; font-size: 0.88rem; color: #1e293b; line-height: 1.5; white-space: pre-wrap; box-shadow: 0 1px 2px rgba(0,0,0,0.03);"><c:out value="${ticket.content}"/></div>
                    </div>
                </div>

                <!-- Existing Staff Replies -->
                <c:forEach var="r" items="${ticket.replies}">
                    <div style="display: flex; gap: 0.75rem; align-items: flex-start; max-width: 85%; align-self: flex-end; flex-direction: row-reverse;">
                        <div style="width: 34px; height: 34px; border-radius: 50%; background: #fdba74; color: #7c2d12; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.8rem; flex-shrink: 0;">
                            NV
                        </div>
                        <div style="text-align: right;">
                            <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 0.25rem;">
                                ${r.createdAtText} • <strong style="color: #ea580c;"><c:out value="${r.repliedByName}"/></strong>
                                <span class="badge ${r.sendStatus}" style="font-size: 0.68rem; margin-left: 4px;">${r.sendStatus.label}</span>
                            </div>
                            <div style="background: #fff7ed; border: 1px solid #ffedd5; border-radius: 12px 12px 2px 12px; padding: 0.85rem 1.1rem; font-size: 0.88rem; color: #431407; line-height: 1.5; text-align: left; white-space: pre-wrap; box-shadow: 0 1px 2px rgba(0,0,0,0.03);"><c:out value="${r.content}"/></div>
                            <c:if test="${r.sendStatus == 'FAILED' and ticket.canReply}">
                                <form method="post" action="${ctx}/staff/support/${ticket.id}/replies/${r.id}/resend" style="margin-top: 4px;">${csrf}
                                    <button type="submit" class="btn btn-xs btn-danger">Gửi lại email này</button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty ticket.replies}">
                    <div style="text-align: center; color: #94a3b8; font-size: 0.82rem; padding: 1rem 0;">
                        Chưa có phản hồi nào cho yêu cầu này.
                    </div>
                </c:if>

            </div>

            <!-- Email Reply Composer Form -->
            <c:if test="${ticket.canReply}">
                <div style="padding: 1.25rem 1.5rem; background: #fff; border-top: 1px solid #e2e8f0;">
                    <form method="post" action="${ctx}/staff/support/${ticket.id}/reply">${csrf}
                        <div style="font-size: 0.78rem; color: #64748b; margin-bottom: 0.5rem;">
                            Gửi email tới: <strong><c:out value="${ticket.contactEmail}"/></strong>, tiêu đề <em>"[PetFood] Trả lời yêu cầu hỗ trợ #${ticket.ticketCode}"</em>
                        </div>
                        <div style="margin-bottom: 0.75rem;">
                            <textarea name="content" rows="4" maxlength="4000" required placeholder="Nhập nội dung phản hồi gửi qua email cho khách hàng..." style="width: 100%; padding: 0.75rem 0.9rem; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.88rem; line-height: 1.45;"><c:out value="${replyDraft}"/></textarea>
                        </div>
                        <div style="display: flex; justify-content: flex-end; gap: 0.5rem;">
                            <button type="submit" class="btn btn-primary" style="background: #f59e0b; border: 1px solid #d97706; color: #fff; font-weight: 700; padding: 0.5rem 1.2rem;">
                                <i class="ti ti-send"></i> Gửi email phản hồi
                            </button>
                        </div>
                    </form>
                </div>
            </c:if>

        </div>
    </main>
</body>
</html>
