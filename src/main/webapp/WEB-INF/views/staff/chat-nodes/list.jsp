<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="csrf"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"></c:set>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Kịch bản phản hồi Chatbot · PetFood</title>
    <%@ include file="/WEB-INF/views/staff/_head.jspf" %>
    <style>
        /* Tối ưu giao diện bảng kịch bản chatbox */
        .chat-tree-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #ffffff;
        }

        .chat-tree-table th {
            background: #fafaf9;
            color: #57534e;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 14px 16px;
            border-bottom: 2px solid #e7e5e4;
        }

        .chat-tree-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #f0eeeb;
            vertical-align: middle;
            transition: background 0.15s ease;
        }

        .chat-tree-table tr:hover td {
            background: #fffcf8;
        }

        .chat-tree-table tr.node-row-root td {
            background: #fffdf9;
            border-top: 1px solid #fed7aa;
            border-bottom: 2px solid #fed7aa;
        }

        .chat-tree-table tr.node-muted td {
            opacity: 0.62;
        }

        /* Thụt lề và biểu tượng cấu trúc cây */
        .tree-node-wrap {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }

        .tree-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            font-size: 16px;
            flex-shrink: 0;
            margin-top: 1px;
        }

        .tree-icon.root {
            background: #ffedd5;
            color: #ea580c;
            border: 1px solid #ffd8b8;
        }

        .tree-icon.solution {
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }

        .tree-icon.sub {
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
        }

        .node-content-wrap {
            flex: 1;
            min-width: 0;
        }

        .node-title-line {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 4px;
        }

        .node-title {
            font-size: 14px;
            font-weight: 700;
            color: #1f2937;
        }

        .node-title.root {
            font-size: 15px;
            color: #c2410c;
        }

        .node-msg-box {
            display: flex;
            align-items: flex-start;
            gap: 7px;
            margin-top: 6px;
            font-size: 12.5px;
            line-height: 1.45;
            color: #4b5563;
            background: #f8fafc;
            border-radius: 8px;
            padding: 8px 12px;
            border-left: 3px solid #cbd5e1;
            word-break: break-word;
        }

        .node-msg-box i {
            color: #94a3b8;
            font-size: 15px;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .node-link-box {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-top: 6px;
            font-size: 12px;
            color: #0369a1;
            background: #f0f9ff;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid #bae6fd;
        }

        .node-link-box a {
            color: #0284c7;
            text-decoration: underline;
            font-weight: 600;
        }

        /* Cột Thứ tự đẹp, rõ ràng */
        .order-badge-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            min-width: 42px;
            height: 30px;
            padding: 0 10px;
            border-radius: 999px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            color: #334155;
            font-weight: 800;
            font-size: 13px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
        }

        .order-badge-pill i {
            font-size: 12px;
            color: #94a3b8;
        }

        /* Cột Cập nhật */
        .updater-cell {
            font-size: 12px;
            line-height: 1.4;
        }

        .updater-name {
            font-weight: 700;
            color: #334155;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .updater-time {
            color: #94a3b8;
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 3px;
        }

        /* Nhóm nút thao tác chuẩn hoá (Flexbox, không bị tràn/rớt dòng) */
        .action-btn-group {
            display: inline-flex;
            align-items: center;
            justify-content: flex-end;
            gap: 6px;
            flex-wrap: nowrap;
        }

        .act-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            height: 32px;
            padding: 0 12px;
            font-size: 12.5px;
            font-weight: 700;
            line-height: 1;
            border-radius: 8px;
            border: 1px solid var(--line, #e2e8f0);
            background: #ffffff;
            color: #475569;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.18s ease;
            white-space: nowrap;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
            box-sizing: border-box;
        }

        .act-btn i {
            font-size: 14px;
            line-height: 1;
        }

        /* Nút + Nút con */
        .act-btn.btn-add-child {
            border-color: #ffd8b8;
            background: #fffaf5;
            color: #ea580c;
        }
        .act-btn.btn-add-child:hover {
            background: #ffedd5;
            border-color: #ea580c;
            color: #c2410c;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(234, 88, 12, 0.15);
        }

        /* Nút Sửa */
        .act-btn.btn-edit {
            border-color: #cbd5e1;
            background: #ffffff;
            color: #334155;
        }
        .act-btn.btn-edit:hover {
            background: #f1f5f9;
            border-color: #94a3b8;
            color: #0f172a;
            transform: translateY(-1px);
        }

        /* Nút Ẩn */
        .act-btn.btn-toggle-hide {
            border-color: #fed7aa;
            background: #fffbeb;
            color: #d97706;
        }
        .act-btn.btn-toggle-hide:hover {
            background: #fef3c7;
            border-color: #f59e0b;
            color: #b45309;
            transform: translateY(-1px);
        }

        /* Nút Hiện */
        .act-btn.btn-toggle-show {
            border-color: #bbf7d0;
            background: #f0fdf4;
            color: #16a34a;
        }
        .act-btn.btn-toggle-show:hover {
            background: #dcfce7;
            border-color: #22c55e;
            color: #15803d;
            transform: translateY(-1px);
        }

        /* Nút Xoá */
        .act-btn.btn-delete {
            border-color: #fecaca;
            background: #fff5f5;
            color: #dc2626;
        }
        .act-btn.btn-delete:hover {
            background: #fee2e2;
            border-color: #ef4444;
            color: #991b1b;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(239, 68, 68, 0.15);
        }

        .inline-form {
            display: inline;
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/staff/_nav.jspf" %>

<main class="reveal">
    <div class="page-head">
        <div>
            <div class="screen-bc">
                <span>CHĂM SÓC KHÁCH HÀNG</span> <span class="sep">&gt;</span> <span class="current">KỊCH BẢN PHẢN HỒI CHAT</span>
            </div>
            <h1>KỊCH BẢN PHẢN HỒI CHAT <span class="pill-badge orange">CÂY ĐIỀU HƯỚNG</span></h1>
            <p class="page-sub">Thiết lập kịch bản cây hội thoại hỗ trợ khách hàng tự động, liên kết giải pháp và tra cứu nhanh.</p>
        </div>

        <div>
            <a href="${ctx}/staff/chat-nodes/new" class="btn-flashsale" title="Tạo một chủ đề lớn cấp cao nhất">
                <i class="ti ti-plus"></i>Thêm chủ đề gốc
            </a>
        </div>
    </div>

    <%-- 4 Thẻ KPI thống kê số lượng nút kịch bản --%>
    <c:set var="totalCount" value="${nodes != null ? nodes.size() : 0}"/>
    <c:set var="rootCount" value="0"/>
    <c:set var="solutionCount" value="0"/>
    <c:set var="activeCount" value="0"/>
    <c:forEach var="n" items="${nodes}">
        <c:if test="${n.depth == 0}"><c:set var="rootCount" value="${rootCount + 1}"/></c:if>
        <c:if test="${n.childCount == 0}"><c:set var="solutionCount" value="${solutionCount + 1}"/></c:if>
        <c:if test="${n.status == 'ACTIVE'}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    </c:forEach>

    <section class="grid g-4" style="margin-bottom: 20px;">
        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Tổng số nút</span>
                <span class="kpi-ico orange"><i class="ti ti-binary-tree"></i></span>
            </div>
            <div class="kpi-value">${totalCount}</div>
            <div class="kpi-meta"><span class="badge orange">Toàn bộ kịch bản</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Chủ đề gốc</span>
                <span class="kpi-ico blue"><i class="ti ti-folders"></i></span>
            </div>
            <div class="kpi-value" style="color:#2563eb">${rootCount}</div>
            <div class="kpi-meta"><span class="badge" style="background:#eff6ff; color:#1d4ed8">Mục cấp 1</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Giải pháp tự động</span>
                <span class="kpi-ico green"><i class="ti ti-bulb"></i></span>
            </div>
            <div class="kpi-value" style="color:#10b981">${solutionCount}</div>
            <div class="kpi-meta"><span class="badge ok">Câu trả lời cuối</span></div>
        </div>

        <div class="panel kpi">
            <div class="kpi-top">
                <span class="kpi-label">Đang hiển thị</span>
                <span class="kpi-ico purple"><i class="ti ti-eye"></i></span>
            </div>
            <div class="kpi-value" style="color:#7c3aed">${activeCount}</div>
            <div class="kpi-meta"><span class="badge purple">Đang phục vụ khách</span></div>
        </div>
    </section>

    <%-- Hướng dẫn nhanh quy tắc điều hướng kịch bản --%>
    <div style="display: flex; align-items: center; gap: 12px; background: #fffaf0; border: 1px solid #fed7aa; border-radius: 12px; padding: 12px 18px; margin-bottom: 20px; font-size: 13px; color: #9a3412;">
        <i class="ti ti-info-circle" style="font-size: 20px; color: #ea580c; flex-shrink: 0;"></i>
        <span>
            <b>Quy tắc hoạt động:</b> Khách chọn <b>Chủ đề gốc</b> → <b>Nội dung con</b> → <b>Giải pháp</b>. Nút không có nhánh con được xem là giải pháp trả lời trực tiếp. Khi ẩn nút cha, toàn bộ nhánh con sẽ tự động ẩn trên trang khách. Nút đã có yêu cầu hỗ trợ tham chiếu chỉ có thể ẩn, không thể xoá.
        </span>
    </div>

    <%-- Bảng danh sách cây kịch bản --%>
    <div class="panel" style="padding:0; overflow:hidden">
        <div class="split-head">
            <div>
                <h3 style="margin:0"><i class="ti ti-messages" style="color:var(--color-primary)"></i>CẤU TRÚC CÂY KỊCH BẢN PHẢN HỒI</h3>
                <small style="color:var(--text-muted)">Phân cấp hiển thị theo chủ đề và nội dung giải đáp</small>
            </div>
            <div style="font-size:13px; color:var(--text-muted)">
                Tổng cộng: <b style="color:var(--color-primary)">${totalCount}</b> nút kịch bản
            </div>
        </div>

        <c:choose>
            <c:when test="${empty nodes}">
                <div style="text-align:center; padding:48px 20px; color:var(--text-muted)">
                    <div style="width:54px; height:54px; border-radius:50%; background:#fff7ed; color:#ea580c; display:grid; place-items:center; font-size:24px; margin:0 auto 16px">
                        <i class="ti ti-messages"></i>
                    </div>
                    <h3 style="margin:0 0 8px 0; color:var(--text-main)">Chưa có nút kịch bản nào</h3>
                    <p style="font-size:13px; margin:0 0 16px 0">Hãy thêm chủ đề gốc đầu tiên để xây dựng kịch bản chatbox tự động cho khách.</p>
                    <a href="${ctx}/staff/chat-nodes/new" class="btn-flashsale">
                        <i class="ti ti-plus"></i>Thêm chủ đề gốc ngay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto">
                    <table class="chat-tree-table">
                        <thead>
                        <tr>
                            <th style="min-width:320px">NỘI DUNG NÚT KỊCH BẢN</th>
                            <th style="width:90px; text-align:center" title="Thứ tự hiển thị ưu tiên">THỨ TỰ</th>
                            <th style="width:130px; text-align:center">TRẠNG THÁI</th>
                            <th style="width:170px">CẬP NHẬT</th>
                            <th style="width:250px; text-align:right">THAO TÁC</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="n" items="${nodes}">
                            <tr class="${n.depth == 0 ? 'node-row-root' : ''} ${n.status == 'HIDDEN' or n.hiddenByAncestor ? 'node-muted' : ''}">
                                <%-- Cột 1: Cây kịch bản (Thụt lề theo depth + icon) --%>
                                <td style="padding-left: ${16 + n.depth * 32}px">
                                    <div class="tree-node-wrap">
                                        <c:choose>
                                            <c:when test="${n.depth == 0}">
                                                <div class="tree-icon root" title="Chủ đề gốc">
                                                    <i class="ti ti-folder"></i>
                                                </div>
                                            </c:when>
                                            <c:when test="${n.childCount == 0}">
                                                <div class="tree-icon solution" title="Giải pháp trực tiếp">
                                                    <i class="ti ti-bulb"></i>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="tree-icon sub" title="Nhánh câu hỏi con">
                                                    <i class="ti ti-corner-down-right"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <div class="node-content-wrap">
                                            <div class="node-title-line">
                                                <span class="node-title ${n.depth == 0 ? 'root' : ''}">
                                                    <c:out value="${n.label}"/>
                                                </span>

                                                <c:if test="${n.depth == 0}">
                                                    <span class="pill-badge orange" style="font-size:10.5px">Chủ đề gốc</span>
                                                    <span class="pill-badge gray" style="font-size:10.5px">${n.childCount} nhánh con</span>
                                                </c:if>

                                                <c:if test="${n.depth > 0 and n.childCount == 0}">
                                                    <span class="pill-badge green" style="font-size:10.5px">
                                                        <i class="ti ti-bulb"></i>Giải pháp
                                                    </span>
                                                </c:if>
                                            </div>

                                            <c:if test="${not empty n.botMessage}">
                                                <div class="node-msg-box">
                                                    <i class="ti ti-message-dots"></i>
                                                    <span><c:out value="${n.botMessage}"/></span>
                                                </div>
                                            </c:if>

                                            <c:if test="${not empty n.actionUrl}">
                                                <div class="node-link-box">
                                                    <i class="ti ti-link"></i>
                                                    <span>Liên kết: <a href="${ctx}${n.actionUrl}" target="_blank"><c:out value="${n.actionUrl}"/></a></span>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </td>

                                <%-- Cột 2: Thứ tự (Badge bo tròn, căn giữa rõ ràng) --%>
                                <td style="text-align:center">
                                    <div class="order-badge-pill" title="Thứ tự ưu tiên: #${n.sortOrder}">
                                        <i class="ti ti-arrows-sort"></i>
                                        <span>${n.sortOrder}</span>
                                    </div>
                                </td>

                                <%-- Cột 3: Trạng thái --%>
                                <td style="text-align:center">
                                    <c:choose>
                                        <c:when test="${n.status == 'ACTIVE'}">
                                            <span class="pill-badge green"><i class="ti ti-eye"></i>Đang hiện</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pill-badge gray"><i class="ti ti-eye-off"></i>Đã ẩn</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${n.hiddenByAncestor}">
                                        <div style="margin-top:4px">
                                            <span class="pill-badge red" style="font-size:10px; padding:2px 7px" title="Nút cha đang ẩn nên khách không thấy nhánh này">
                                                <i class="ti ti-alert-triangle"></i>Cha đang ẩn
                                            </span>
                                        </div>
                                    </c:if>
                                </td>

                                <%-- Cột 4: Người cập nhật & Thời gian --%>
                                <td>
                                    <div class="updater-cell">
                                        <div class="updater-name">
                                            <i class="ti ti-user-circle" style="color:#f97316; font-size:14px"></i>
                                            <c:out value="${n.updatedByName}"/>
                                        </div>
                                        <div class="updater-time">
                                            <i class="ti ti-clock"></i>
                                            <span>${n.updatedAtText}</span>
                                        </div>
                                    </div>
                                </td>

                                <%-- Cột 5: Thao tác (Nhóm nút đều đẹp, rõ ràng từng chức năng) --%>
                                <td style="text-align:right">
                                    <div class="action-btn-group">
                                        <%-- Nút Thêm nút con --%>
                                        <a href="${ctx}/staff/chat-nodes/new?parent=${n.id}" class="act-btn btn-add-child" title="Thêm nút con vào mục này">
                                            <i class="ti ti-plus"></i><span>Nút con</span>
                                        </a>

                                        <%-- Nút Sửa --%>
                                        <a href="${ctx}/staff/chat-nodes/${n.id}/edit" class="act-btn btn-edit" title="Chỉnh sửa nội dung nút">
                                            <i class="ti ti-pencil"></i><span>Sửa</span>
                                        </a>

                                        <%-- Nút Ẩn / Hiện --%>
                                        <form method="post" action="${ctx}/staff/chat-nodes/${n.id}/${n.status == 'ACTIVE' ? 'hide' : 'show'}" class="inline-form">
                                            ${csrf}
                                            <button type="submit" class="act-btn ${n.status == 'ACTIVE' ? 'btn-toggle-hide' : 'btn-toggle-show'}"
                                                    title="${n.status == 'ACTIVE' ? 'Ẩn nút này khỏi chatbox của khách' : 'Hiện lại nút này'}">
                                                <i class="ti ${n.status == 'ACTIVE' ? 'ti-eye-off' : 'ti-eye'}"></i>
                                                <span>${n.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'}</span>
                                            </button>
                                        </form>

                                        <%-- Nút Xoá (chỉ khi không có con) --%>
                                        <c:if test="${n.childCount == 0}">
                                            <form method="post" action="${ctx}/staff/chat-nodes/${n.id}/delete" class="inline-form"
                                                  onsubmit="return confirm('Bạn có chắc chắn muốn xoá nút này không?');">
                                                ${csrf}
                                                <button type="submit" class="act-btn btn-delete" title="Xoá nút này">
                                                    <i class="ti ti-trash"></i><span>Xoá</span>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

</body>
</html>
