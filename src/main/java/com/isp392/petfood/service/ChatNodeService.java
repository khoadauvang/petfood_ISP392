package com.isp392.petfood.service;

import com.isp392.petfood.dto.ChatConversation;
import com.isp392.petfood.dto.ChatNodeForm;
import com.isp392.petfood.dto.ChatNodeOption;
import com.isp392.petfood.dto.ChatNodeRow;
import com.isp392.petfood.dto.ChatStep;
import com.isp392.petfood.entity.ChatNode;
import com.isp392.petfood.enums.ChatNodeStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.ChatNodeRepository;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.SupportTicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

// Cây kịch bản chatbox (module 9, requirements 7.10):
//   - khách không gõ tự do: chọn chủ đề -> nội dung con -> giải pháp; không cần đăng nhập
//   - nút ẩn (HIDDEN) thì khách không thấy nút đó và cả nhánh con của nó
//   - nút đã có yêu cầu hỗ trợ tham chiếu thì chỉ ẩn, không xoá; đổi cha phải chặn vòng lặp (ghi chú 8 trong script SQL)
@Service
@RequiredArgsConstructor
public class ChatNodeService {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final ChatNodeRepository nodeRepository;
    private final SupportTicketRepository ticketRepository;
    private final EmployeeRepository employeeRepository;

    // ===== Phía khách =====

    // Màn hình chatbox: nodeId trống = danh sách chủ đề gốc
    @Transactional(readOnly = true)
    public ChatConversation conversation(Long nodeId) {
        if (nodeId == null) {
            return new ChatConversation(List.of(), toSteps(nodeRepository.findRoots(ChatNodeStatus.ACTIVE)));
        }
        List<ChatNode> path = visiblePath(nodeId);
        return new ChatConversation(toSteps(path), toSteps(nodeRepository.findChildren(nodeId, ChatNodeStatus.ACTIVE)));
    }

    // Nhãn của nút khách đang đứng khi bấm "Khác"; null nếu không có hoặc khách không tới được nút đó
    @Transactional(readOnly = true)
    public String visibleLabel(Long nodeId) {
        if (nodeId == null) {
            return null;
        }
        try {
            List<ChatNode> path = visiblePath(nodeId);
            return path.get(path.size() - 1).getLabel();
        } catch (NotFoundException e) {
            return null;
        }
    }

    // Đường đi từ chủ đề gốc tới nút; nút hoặc một nút cha đã ẩn thì coi như không tồn tại với khách
    private List<ChatNode> visiblePath(Long nodeId) {
        List<ChatNode> path = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        ChatNode node = nodeRepository.findById(nodeId).orElse(null);
        while (node != null && seen.add(node.getId())) {
            if (node.getStatus() != ChatNodeStatus.ACTIVE) {
                node = null;
                break;
            }
            path.add(node);
            node = node.getParent();
        }
        if (path.isEmpty() || path.get(path.size() - 1).getParent() != null) {
            throw new NotFoundException("Không tìm thấy nội dung hỗ trợ #" + nodeId);
        }
        Collections.reverse(path);
        return path;
    }

    // ===== Phía Staff =====

    // Cả cây theo thứ tự hiển thị (cha rồi tới con, cùng cấp theo sort_order)
    @Transactional(readOnly = true)
    public List<ChatNodeRow> tree() {
        Map<Long, List<ChatNode>> children = childrenMap();
        List<ChatNodeRow> rows = new ArrayList<>();
        for (ChatNode root : children.getOrDefault(null, List.of())) {
            walk(root, 0, false, children, rows);
        }
        return rows;
    }

    private void walk(ChatNode node, int depth, boolean ancestorHidden, Map<Long, List<ChatNode>> children,
                      List<ChatNodeRow> rows) {
        List<ChatNode> kids = children.getOrDefault(node.getId(), List.of());
        rows.add(new ChatNodeRow(node.getId(), depth, node.getLabel(), node.getBotMessage(), node.getActionUrl(),
                node.getSortOrder(), node.getStatus(), kids.size(), ancestorHidden,
                node.getUpdatedBy().getFullName(), node.getUpdatedAt().format(DATE_TIME)));
        boolean hidden = ancestorHidden || node.getStatus() != ChatNodeStatus.ACTIVE;
        for (ChatNode kid : kids) {
            walk(kid, depth + 1, hidden, children, rows);
        }
    }

    // Các nút được chọn làm cha: bỏ chính nút đang sửa và toàn bộ con cháu của nó (tránh vòng lặp)
    @Transactional(readOnly = true)
    public List<ChatNodeOption> parentOptions(Long editingId) {
        List<ChatNodeOption> options = new ArrayList<>();
        Set<Long> excluded = editingId == null ? Set.of() : descendantsAndSelf(editingId, childrenMap());
        for (ChatNodeRow row : tree()) {
            if (!excluded.contains(row.getId())) {
                options.add(new ChatNodeOption(row.getId(), "— ".repeat(row.getDepth()) + row.getLabel()
                        + (row.getStatus() == ChatNodeStatus.ACTIVE ? "" : " (đã ẩn)")));
            }
        }
        return options;
    }

    @Transactional(readOnly = true)
    public ChatNodeForm getForm(Long id) {
        ChatNode node = find(id);
        ChatNodeForm form = new ChatNodeForm();
        form.setParentId(node.getParent() == null ? null : node.getParent().getId());
        form.setLabel(node.getLabel());
        form.setBotMessage(node.getBotMessage());
        form.setActionUrl(node.getActionUrl());
        form.setSortOrder(node.getSortOrder());
        form.setStatus(node.getStatus());
        return form;
    }

    @Transactional
    public ChatNode create(ChatNodeForm form, Long employeeId) {
        ChatNode node = new ChatNode();
        apply(node, form, employeeId);
        return nodeRepository.save(node);
    }

    @Transactional
    public ChatNode update(Long id, ChatNodeForm form, Long employeeId) {
        ChatNode node = find(id);
        apply(node, form, employeeId);
        return node;
    }

    @Transactional
    public ChatNode setStatus(Long id, ChatNodeStatus status, Long employeeId) {
        ChatNode node = find(id);
        node.setStatus(status);
        node.setUpdatedBy(employeeRepository.getReferenceById(employeeId));
        return node;
    }

    // Chỉ xoá nút chưa có nút con và chưa có yêu cầu hỗ trợ nào tham chiếu; còn lại thì ẩn
    @Transactional
    public void delete(Long id) {
        ChatNode node = find(id);
        if (nodeRepository.existsByParent_Id(id)) {
            throw new BusinessRuleException("Nút \"" + node.getLabel() + "\" còn nút con. Hãy xoá hoặc chuyển các nút con trước, hoặc ẩn nút này.");
        }
        if (ticketRepository.existsByFromNode_Id(id)) {
            throw new BusinessRuleException("Nút \"" + node.getLabel() + "\" đã có yêu cầu hỗ trợ tham chiếu nên chỉ ẩn được, không xoá.");
        }
        nodeRepository.delete(node);
    }

    // ===== Phụ trợ =====

    private void apply(ChatNode node, ChatNodeForm form, Long employeeId) {
        node.setParent(resolveParent(node.getId(), form.getParentId()));
        node.setLabel(form.getLabel().trim());
        node.setBotMessage(form.getBotMessage().trim());
        node.setActionUrl(form.getActionUrl() == null || form.getActionUrl().isBlank() ? null : form.getActionUrl().trim());
        node.setSortOrder(form.getSortOrder());
        node.setStatus(form.getStatus());
        node.setUpdatedBy(employeeRepository.getReferenceById(employeeId));
    }

    // Cha không được là chính nút này hoặc một nút con cháu của nó (CHECK trong DB chỉ chặn tự trỏ)
    private ChatNode resolveParent(Long nodeId, Long parentId) {
        if (parentId == null) {
            return null;
        }
        ChatNode parent = nodeRepository.findById(parentId)
                .orElseThrow(() -> new BusinessRuleException("parentId", "Nút cha không tồn tại"));
        if (nodeId != null) {
            Set<Long> seen = new HashSet<>();
            for (ChatNode n = parent; n != null && seen.add(n.getId()); n = n.getParent()) {
                if (n.getId().equals(nodeId)) {
                    throw new BusinessRuleException("parentId",
                            "Không chọn được nút này hoặc một nút con của nó làm nút cha (tạo vòng lặp)");
                }
            }
        }
        return parent;
    }

    private Map<Long, List<ChatNode>> childrenMap() {
        Map<Long, List<ChatNode>> children = new LinkedHashMap<>();
        for (ChatNode n : nodeRepository.findAllForTree()) {
            children.computeIfAbsent(n.getParent() == null ? null : n.getParent().getId(), k -> new ArrayList<>()).add(n);
        }
        return children;
    }

    private static Set<Long> descendantsAndSelf(Long id, Map<Long, List<ChatNode>> children) {
        Set<Long> result = new HashSet<>();
        List<Long> stack = new ArrayList<>(List.of(id));
        while (!stack.isEmpty()) {
            Long current = stack.remove(stack.size() - 1);
            if (result.add(current)) {
                children.getOrDefault(current, List.of()).forEach(c -> stack.add(c.getId()));
            }
        }
        return result;
    }

    private ChatNode find(Long id) {
        return nodeRepository.findById(id).orElseThrow(() -> new NotFoundException("Không tìm thấy nút kịch bản #" + id));
    }

    private static List<ChatStep> toSteps(List<ChatNode> nodes) {
        return nodes.stream().map(n -> new ChatStep(n.getId(), n.getLabel(), n.getBotMessage(), n.getActionUrl())).toList();
    }
}
