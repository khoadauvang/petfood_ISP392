package com.isp392.petfood.controller;

import com.isp392.petfood.dto.OrderRow;
import com.isp392.petfood.entity.Order;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.GhnShippingService;
import com.isp392.petfood.service.OrderService;
import com.isp392.petfood.service.ReturnService;
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

import java.util.Arrays;
import java.util.EnumSet;
import java.util.Set;
import java.util.stream.Collectors;

// Đơn hàng của khách. /orders/** chỉ cho CUSTOMER; chỉ thấy đơn của chính mình (đơn người khác -> 404).
//   GET  /orders                 lịch sử đơn, mới nhất trước; ?status=PENDING,CONFIRMED lọc theo tab trạng thái
//   GET  /orders/{id}            chi tiết đơn: dòng hàng, lô + HSD đã giao, các mốc trạng thái
//   POST /orders/{id}/cancel     huỷ (PENDING / CONFIRMED) hoặc gửi yêu cầu huỷ (PROCESSING), BR-19
@Controller
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final ReturnService returnService;
    private final GhnShippingService ghnShippingService;

    @GetMapping
    public String list(@AuthenticationPrincipal AccountPrincipal user,
                       @RequestParam(name = "status", required = false) String status,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        Set<OrderStatus> statuses = parseStatuses(status);
        Page<OrderRow> result = orderService.listForCustomer(user.getCustomerId(), statuses, Math.max(page, 1) - 1);
        String statusValue = statuses.stream().map(Enum::name).collect(Collectors.joining(","));
        model.addAttribute("orders", result.getContent());
        model.addAttribute("orderItems", orderService.itemPreviews(result.getContent().stream().map(OrderRow::getId).toList()));
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());
        model.addAttribute("status", statusValue);
        model.addAttribute("filterQuery", QueryStrings.of("status", statusValue));
        return "customer/orders";
    }

    // Tab trạng thái gửi lên dạng "PENDING,CONFIRMED"; giá trị lạ thì bỏ qua, rỗng = mọi trạng thái
    private static Set<OrderStatus> parseStatuses(String status) {
        Set<OrderStatus> statuses = EnumSet.noneOf(OrderStatus.class);
        if (status != null) {
            for (String s : status.split(",")) {
                Arrays.stream(OrderStatus.values()).filter(v -> v.name().equalsIgnoreCase(s.trim())).forEach(statuses::add);
            }
        }
        return statuses;
    }

    @GetMapping("/{id}")
    public String detail(@AuthenticationPrincipal AccountPrincipal user, @PathVariable("id") Long id, Model model) {
        model.addAttribute("order", orderService.getForCustomer(user.getCustomerId(), id));
        // Vận đơn GHN (mã vận đơn, trạng thái, ngày giao dự kiến); null nếu chưa cấu hình GHN hoặc đơn chưa giao
        model.addAttribute("shipment", ghnShippingService.shipment(id).orElse(null));
        model.addAttribute("returns", returnService.listForOrder(user.getCustomerId(), id));
        model.addAttribute("canRequestReturn", returnService.canRequest(user.getCustomerId(), id));
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
