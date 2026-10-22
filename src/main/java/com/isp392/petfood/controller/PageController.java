package com.isp392.petfood.controller;

import com.isp392.petfood.dto.StaffDashboardCounts;
import com.isp392.petfood.service.InventoryAlertService;
import com.isp392.petfood.service.StaffDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class PageController {

    private static final DateTimeFormatter UPDATED_AT = DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy");

    private final InventoryAlertService inventoryAlertService;
    private final StaffDashboardService staffDashboardService;

    // Trang thông tin FE đã đặt link ở header / footer nhưng chưa làm giao diện: tạm hiện placeholder.jsp của FE.
    // Công khai cho Guest (SecurityConfig) để bấm link không bị đẩy về trang đăng nhập.
    private static final Map<String, String> POLICY_TITLES = Map.of(
            "return", "Chính sách đổi trả trong 3 ngày",
            "expiry", "Cam kết hạn dùng tối thiểu 90 ngày",
            "shipping", "Chính sách giao hàng",
            "guide", "Hướng dẫn mua hàng và thanh toán");

    // /admin: dashboard thống kê riêng của Admin ở AdminDashboardController

    @GetMapping("/staff")
    public String staff(Model model) {
        return dashboard(model, "Trang nhân viên (Staff)");
    }

    @GetMapping("/policies")
    public String policies(Model model) {
        return placeholder(model, "Chính sách cửa hàng");
    }

    @GetMapping("/policies/{section}")
    public String policy(@PathVariable("section") String section, Model model) {
        String title = POLICY_TITLES.get(section);
        if (title == null) {
            return "redirect:/policies";
        }
        return placeholder(model, title);
    }

    @GetMapping("/terms")
    public String terms(Model model) {
        return placeholder(model, "Điều khoản dịch vụ");
    }

    @GetMapping("/privacy")
    public String privacy(Model model) {
        return placeholder(model, "Chính sách bảo mật");
    }

    @GetMapping("/partnership")
    public String partnership(Model model) {
        return placeholder(model, "Hợp tác cùng PetFood");
    }

    // Spring Security chuyển tiếp (forward) tới đây khi bị từ chối quyền (SecurityConfig.accessDeniedPage)
    @RequestMapping("/403")
    public ModelAndView forbidden() {
        return ErrorPages.of(HttpStatus.FORBIDDEN, null);
    }

    private static String placeholder(Model model, String title) {
        model.addAttribute("pageTitle", title);
        return "placeholder";
    }

    // API cho dashboard Staff tự cập nhật số liệu (polling): cùng các khoá với model của trang /staff
    @GetMapping("/staff/api/stats")
    @ResponseBody
    public Map<String, Object> staffRealtimeStats() {
        Map<String, Object> stats = dashboardStats();
        stats.put("updatedAt", LocalDateTime.now().format(UPDATED_AT));
        return stats;
    }

    // Tổng quan: số cảnh báo tồn thấp / lô sắp hết hạn, số đơn theo trạng thái, hàng đợi cần xử lý
    // + lối vào các trang quản lý (FR-38, FR-45)
    private String dashboard(Model model, String title) {
        model.addAttribute("pageTitle", title);
        model.addAllAttributes(dashboardStats());
        model.addAttribute("attentionOrders", staffDashboardService.attentionOrders());
        model.addAttribute("recentReturns", staffDashboardService.recentReturns());
        return "staff/dashboard";
    }

    // Tên khoá là hợp đồng với FE (staff/dashboard.jsp và JS gọi /staff/api/stats)
    private Map<String, Object> dashboardStats() {
        StaffDashboardCounts counts = staffDashboardService.counts();
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("pendingOrders", counts.getPendingOrders());
        stats.put("processingOrders", counts.getProcessingOrders());
        stats.put("returnRequests", counts.getReturnRequests());
        stats.put("cancelledOrders", counts.getCancelledOrders());
        stats.put("completedOrders", counts.getCompletedOrders());
        stats.put("alertSummary", inventoryAlertService.getSummary());
        return stats;
    }
}
