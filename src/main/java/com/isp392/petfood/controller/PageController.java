package com.isp392.petfood.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PageController {

    @GetMapping("/admin")
    public String admin(Model model) {
        return show(model, "Trang quản trị (Admin)");
    }

    @GetMapping("/staff")
    public String staff(Model model) {
        return show(model, "Trang nhân viên (Staff)");
    }

    @RequestMapping("/403")
    public String forbidden(Model model) {
        return show(model, "403 - Bạn không có quyền vào trang này");
    }

    //show()
    private String show(Model model, String title) {
        model.addAttribute("pageTitle", title);
        return "placeholder";
    }
}
