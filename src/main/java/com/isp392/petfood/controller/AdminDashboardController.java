package com.isp392.petfood.controller;

import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.service.AdminDashboardService;
import com.isp392.petfood.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

// Dashboard thống kê, chỉ ADMIN (module 10, phần thêm).
//   GET /admin?from=yyyy-MM-dd&to=yyyy-MM-dd             mặc định cả tháng hiện tại (đầu tháng tới cuối tháng)
//   GET /admin/api/stats?from=yyyy-MM-dd&to=yyyy-MM-dd   cùng số liệu dạng JSON để dashboard tự cập nhật (polling)
@Controller
@RequiredArgsConstructor
public class AdminDashboardController {

    private static final DateTimeFormatter UPDATED_AT = DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy");

    private final AdminDashboardService dashboardService;
    private final InventoryAlertService inventoryAlertService;

    @GetMapping("/admin")
    public String dashboard(@RequestParam(name = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                            @RequestParam(name = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                            Model model) {
        LocalDate end = endOrDefault(to);
        LocalDate start = startOrDefault(from, end);
        model.addAttribute("filterFrom", start);
        model.addAttribute("filterTo", end);
        model.addAttribute("alertSummary", inventoryAlertService.getSummary());
        model.addAttribute("lowStockProducts", inventoryAlertService.lowStockProducts());
        model.addAttribute("nearExpiryLots", inventoryAlertService.nearExpiryLots());
        try {
            model.addAttribute("stats", dashboardService.build(start, end));
        } catch (BusinessRuleException e) {
            model.addAttribute("errorMessage", e.getMessage());
        }
        return "admin/dashboard";
    }

    @GetMapping("/admin/api/stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> realtimeStats(
            @RequestParam(name = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(name = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        LocalDate end = endOrDefault(to);
        LocalDate start = startOrDefault(from, end);
        try {
            return ResponseEntity.ok(Map.of(
                    "stats", dashboardService.build(start, end),
                    "alertSummary", inventoryAlertService.getSummary(),
                    "updatedAt", LocalDateTime.now().format(UPDATED_AT)));
        } catch (BusinessRuleException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    private static LocalDate endOrDefault(LocalDate to) {
        LocalDate today = LocalDate.now();
        return to == null ? today.withDayOfMonth(today.lengthOfMonth()) : to;
    }

    private static LocalDate startOrDefault(LocalDate from, LocalDate end) {
        return from == null ? end.withDayOfMonth(1) : from;
    }
}
