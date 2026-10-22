package com.isp392.petfood.controller;

import com.isp392.petfood.dto.OrderRow;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.function.Supplier;

// Xử lý đơn cho STAFF và ADMIN (/staff/**). Mỗi nút chuyển đúng một bước (BR-17):
//   POST /staff/orders/{id}/confirm          PENDING -> CONFIRMED (ghi confirmed_by)
//   POST /staff/orders/{id}/pack             CONFIRMED -> PROCESSING (ghi packed_by)
//   POST /staff/orders/{id}/ship             PROCESSING -> SHIPPED
//   POST /staff/orders/{id}/complete         SHIPPED -> COMPLETED (COD -> PAID)
//   POST /staff/orders/{id}/returned         SHIPPED -> RETURNED (khách không nhận hàng)
//   POST /staff/orders/{id}/cancel           huỷ đơn chưa giao, bắt buộc lý do
//   POST /staff/orders/{id}/cancel-request/approve | reject   duyệt yêu cầu huỷ của khách
//   POST /staff/orders/{id}/refunded         đơn VNPay đã trả tiền bị huỷ: ghi nhận đã hoàn tiền
@Controller
@RequiredArgsConstructor
public class StaffOrderController {

    private final OrderService orderService;

    @GetMapping("/staff/orders")
    public String list(@RequestParam(name = "status", required = false) OrderStatus status,
                       @RequestParam(name = "cancelRequested", defaultValue = "false") boolean cancelRequested,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        Page<OrderRow> result = orderService.search(status, cancelRequested, keyword, Math.max(page, 1) - 1);
        model.addAttribute("orders", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("statuses", OrderStatus.values());
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterCancelRequested", cancelRequested);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of("status", status,
                "cancelRequested", cancelRequested ? "true" : null, "keyword", keyword));
        model.addAttribute("cancelRequestCount", orderService.countCancelRequests());
        // Số đếm cho các ô thống kê đầu trang (không phụ thuộc bộ lọc)
        model.addAttribute("totalAllOrders", orderService.countAll());
        model.addAttribute("pendingOrdersCount", orderService.countByStatus(OrderStatus.PENDING));
        model.addAttribute("processingOrdersCount", orderService.countByStatus(OrderStatus.CONFIRMED)
                + orderService.countByStatus(OrderStatus.PROCESSING));
        model.addAttribute("completedOrdersCount", orderService.countByStatus(OrderStatus.COMPLETED));
        return "staff/orders/list";
    }

    @GetMapping("/staff/orders/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        model.addAttribute("order", orderService.getForStaff(id));
        return "staff/orders/detail";
    }

    @PostMapping("/staff/orders/{id}/confirm")
    public String confirm(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                          RedirectAttributes redirect) {
        return act(id, redirect, "Đã xác nhận đơn #" + id, () -> orderService.confirm(id, user.getEmployeeId()));
    }

    @PostMapping("/staff/orders/{id}/pack")
    public String pack(@PathVariable("id") Long id, @AuthenticationPrincipal AccountPrincipal user,
                       RedirectAttributes redirect) {
        return act(id, redirect, "Đơn #" + id + " đã chuyển sang đóng gói", () -> orderService.pack(id, user.getEmployeeId()));
    }

    @PostMapping("/staff/orders/{id}/ship")
    public String ship(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đơn #" + id + " đang được giao", () -> orderService.ship(id));
    }

    @PostMapping("/staff/orders/{id}/complete")
    public String complete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đơn #" + id + " đã giao thành công", () -> orderService.complete(id));
    }

    @PostMapping("/staff/orders/{id}/returned")
    public String returned(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đơn #" + id + " ghi nhận khách không nhận hàng", () -> orderService.markReturned(id));
    }

    @PostMapping("/staff/orders/{id}/cancel")
    public String cancel(@PathVariable("id") Long id,
                         @RequestParam(name = "cancelReason", required = false) String reason,
                         RedirectAttributes redirect) {
        return act(id, redirect, "Đã huỷ đơn #" + id + " và trả hàng về kho", () -> orderService.cancelByStaff(id, reason));
    }

    // Đơn VNPay đã trả tiền nhưng bị huỷ: staff đã chuyển khoản hoàn cho khách (thủ công, mục 9.12)
    @PostMapping("/staff/orders/{id}/refunded")
    public String refunded(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã ghi nhận hoàn tiền đơn #" + id, () -> orderService.markRefunded(id));
    }

    @PostMapping("/staff/orders/{id}/cancel-request/approve")
    public String approveCancel(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã duyệt huỷ đơn #" + id + " và trả hàng về kho", () -> orderService.approveCancelRequest(id));
    }

    @PostMapping("/staff/orders/{id}/cancel-request/reject")
    public String rejectCancel(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã từ chối yêu cầu huỷ đơn #" + id, () -> orderService.rejectCancelRequest(id));
    }

    private static String act(Long id, RedirectAttributes redirect, String success, Supplier<?> action) {
        try {
            action.get();
            redirect.addFlashAttribute("successMessage", success + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/orders/" + id;
    }
}
