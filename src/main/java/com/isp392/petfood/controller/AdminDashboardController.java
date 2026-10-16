package com.isp392.petfood.controller;

import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.service.AdminDashboardService;
import com.isp392.petfood.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

// Dashboard thống kê, chỉ ADMIN (module 10, phần thêm).
//   GET /admin?from=yyyy-MM-dd&to=yyyy-MM-dd   mặc định từ đầu tháng tới hôm nay
@Controller
@RequiredArgsConstructor
public class AdminDashboardController {

    private final AdminDashboardService dashboardService;
    private final InventoryAlertService inventoryAlertService;

    @GetMapping("/admin")
    public String dashboard(@RequestParam(name = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                            @RequestParam(name = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                            Model model) {
        LocalDate today = LocalDate.now();
        LocalDate end = to == null ? today : to;
        LocalDate start = from == null ? end.withDayOfMonth(1) : from;
        model.addAttribute("filterFrom", start);
        model.addAttribute("filterTo", end);
        model.addAttribute("alertSummary", inventoryAlertService.getSummary());
        try {
            model.addAttribute("stats", dashboardService.build(start, end));
        } catch (BusinessRuleException e) {
            model.addAttribute("errorMessage", e.getMessage());
        }
        return "admin/dashboard";
    }
}
