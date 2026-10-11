package com.isp392.petfood.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class TestController {

    @GetMapping("/test")
    public String test(Model model){
        model.addAttribute("message", "JSP chay roi");
        model.addAttribute("items", List.of("Hạt cho chó", "Pate cho mèo", "Snack"));
        return "test";
    }
}
