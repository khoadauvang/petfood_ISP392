package com.isp392.petfood.controller;

import com.isp392.petfood.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequiredArgsConstructor
public class PageController {

    private final InventoryAlertService inventoryAlertService;

    // /admin: dashboard thống kê riêng của Admin ở AdminDashboardController

    @GetMapping("/staff")
    public String staff(Model model) {
        return dashboard(model, "Trang nhân viên (Staff)");
    }

    // Spring Security chuyển tiếp (forward) tới đây khi bị từ chối quyền (SecurityConfig.accessDeniedPage)
    @RequestMapping("/403")
    public ModelAndView forbidden() {
        return ErrorPages.of(HttpStatus.FORBIDDEN, null);
    }

    // Tổng quan: số cảnh báo tồn thấp / lô sắp hết hạn + lối vào các trang quản lý (FR-38, FR-45)
    private String dashboard(Model model, String title) {
        model.addAttribute("pageTitle", title);
        model.addAttribute("alertSummary", inventoryAlertService.getSummary());
        return "staff/dashboard";
    }
}
