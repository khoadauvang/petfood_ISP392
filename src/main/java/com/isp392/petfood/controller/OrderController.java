package com.isp392.petfood.controller;

import com.isp392.petfood.dto.OrderRow;
import com.isp392.petfood.entity.Order;
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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Đơn hàng của khách. /orders/** chỉ cho CUSTOMER; chỉ thấy đơn của chính mình (đơn người khác -> 404).
//   GET  /orders                 lịch sử đơn, mới nhất trước
//   GET  /orders/{id}            chi tiết đơn: dòng hàng, lô + HSD đã giao, các mốc trạng thái
//   POST /orders/{id}/cancel     huỷ (PENDING / CONFIRMED) hoặc gửi yêu cầu huỷ (PROCESSING), BR-19
@Controller
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public String list(@AuthenticationPrincipal AccountPrincipal user,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        Page<OrderRow> result = orderService.listForCustomer(user.getCustomerId(), Math.max(page, 1) - 1);
        model.addAttribute("orders", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        return "customer/orders";
    }

    @GetMapping("/{id}")
    public String detail(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("id") Long id, Model model) {
        model.addAttribute("order", orderService.getForCustomer(user.getCustomerId(), id));
        return "customer/order-detail";
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@AuthenticationPrincipal AccountPrincipal user,
                         @PathVariable("id") Long id,
                         @RequestParam(name = "cancelReason", required = false) String reason,
                         RedirectAttributes redirect) {
        try {
            Order order = orderService.cancelByCustomer(user.getCustomerId(), id, reason);
            redirect.addFlashAttribute("successMessage", order.getStatus() == OrderStatus.CANCELLED
                    ? "Đã huỷ đơn #" + id + "."
                    : "Đã gửi yêu cầu huỷ đơn #" + id + ", cửa hàng sẽ xác nhận sớm.");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/orders/" + id;
    }
}
