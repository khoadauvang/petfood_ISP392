package com.isp392.petfood.controller;

import com.isp392.petfood.service.InventoryAlertService;
import com.isp392.petfood.service.InventoryPolicy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

// GET /staff/alerts: cảnh báo tồn thấp (BR-62) và lô sắp hết hạn (BR-59), cho STAFF và ADMIN
@Controller
@RequiredArgsConstructor
public class StaffAlertController {

    private final InventoryAlertService inventoryAlertService;
    private final InventoryPolicy inventoryPolicy;

    @GetMapping("/staff/alerts")
    public String alerts(Model model) {
        model.addAttribute("lowStockProducts", inventoryAlertService.lowStockProducts());
        model.addAttribute("nearExpiryLots", inventoryAlertService.nearExpiryLots());
        model.addAttribute("shelfLifeDays", inventoryPolicy.getShelfLifeCommitmentDays());
        model.addAttribute("quarantineDays", inventoryPolicy.getQuarantineDays());
        return "staff/alerts";
    }
}
