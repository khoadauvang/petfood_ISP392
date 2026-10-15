package com.isp392.petfood.controller;

import com.isp392.petfood.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
public class PageController {

    private final InventoryAlertService inventoryAlertService;

    // Admin có toàn quyền của Staff nên dùng chung trang tổng quan; phần báo cáo riêng của Admin thêm sau
    @GetMapping("/admin")
    public String admin(Model model) {
        return dashboard(model, "Trang quản trị (Admin)");
    }

    @GetMapping("/staff")
    public String staff(Model model) {
        return dashboard(model, "Trang nhân viên (Staff)");
    }

    @RequestMapping("/403")
    public String forbidden(Model model) {
        return show(model, "403 - Bạn không có quyền vào trang này");
    }

    // Tổng quan: số cảnh báo tồn thấp / lô sắp hết hạn + lối vào các trang quản lý (FR-38, FR-45)
    private String dashboard(Model model, String title) {
        model.addAttribute("pageTitle", title);
        model.addAttribute("alertSummary", inventoryAlertService.getSummary());
        return "staff/dashboard";
    }

    //show()
    private String show(Model model, String title) {
        model.addAttribute("pageTitle", title);
        return "placeholder";
    }
}
