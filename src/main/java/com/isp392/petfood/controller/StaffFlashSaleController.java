package com.isp392.petfood.controller;

import com.isp392.petfood.dto.FlashSaleForm;
import com.isp392.petfood.dto.FlashSaleItemForm;
import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.FlashSaleService;
import com.isp392.petfood.service.InventoryPolicy;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.format.DateTimeFormatter;
import java.util.function.Supplier;

// Flash Sale: STAFF chỉ xem danh sách / chi tiết; mọi thao tác thay đổi chỉ ADMIN (chặn ở SecurityConfig, chốt 22/10).
//   GET  /staff/flash-sales                      danh sách chiến dịch
//   GET  /staff/flash-sales/new                  form tạo       POST cùng URL để lưu (trạng thái DRAFT)
//   GET  /staff/flash-sales/{id}                 chi tiết: các suất, thêm suất từ lô cận hạn, nút chuyển trạng thái
//   GET  /staff/flash-sales/{id}/edit            sửa tên / giờ (chỉ DRAFT)   POST cùng URL
//   POST /staff/flash-sales/{id}/items           thêm suất (giá tự tính theo HSD lô)        POST .../items/{itemId}/delete   xoá suất
//   POST /staff/flash-sales/{id}/activate | pause | resume | end | delete
@Controller
@RequestMapping("/staff/flash-sales")
@RequiredArgsConstructor
public class StaffFlashSaleController {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final FlashSaleService flashSaleService;
    private final InventoryPolicy inventoryPolicy;

    @InitBinder
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("sales", flashSaleService.list());
        return "staff/flash-sales/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("flashSaleForm", new FlashSaleForm());
        model.addAttribute("saleId", null);
        return "staff/flash-sales/form";
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("flashSaleForm") FlashSaleForm form, BindingResult result,
                         @AuthenticationPrincipal AccountPrincipal user, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return "staff/flash-sales/form";
        }
        try {
            FlashSale sale = flashSaleService.create(form, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage", "Đã tạo chiến dịch #" + sale.getId() + ". Hãy thêm suất từ các lô cận hạn.");
            return "redirect:/staff/flash-sales/" + sale.getId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return "staff/flash-sales/form";
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        if (!model.containsAttribute("itemForm")) {
            model.addAttribute("itemForm", new FlashSaleItemForm());
        }
        return showDetail(id, model);
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("flashSaleForm", flashSaleService.getForm(id));
        model.addAttribute("saleId", id);
        return "staff/flash-sales/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id, @Valid @ModelAttribute("flashSaleForm") FlashSaleForm form,
                         BindingResult result, Model model, RedirectAttributes redirect) {
        model.addAttribute("saleId", id);
        if (result.hasErrors()) {
            return "staff/flash-sales/form";
        }
        try {
            flashSaleService.update(id, form);
            redirect.addFlashAttribute("successMessage", "Đã lưu chiến dịch #" + id + ".");
            return "redirect:/staff/flash-sales/" + id;
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return "staff/flash-sales/form";
        }
    }

    @PostMapping("/{id}/items")
    public String addItem(@PathVariable("id") Long id, @Valid @ModelAttribute("itemForm") FlashSaleItemForm form,
                          BindingResult result, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return showDetail(id, model);
        }
        try {
            flashSaleService.addItem(id, form);
            redirect.addFlashAttribute("successMessage", "Đã thêm suất từ lô #" + form.getLotId() + ".");
            return "redirect:/staff/flash-sales/" + id;
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showDetail(id, model);
        }
    }

    @PostMapping("/{id}/items/{itemId}/delete")
    public String removeItem(@PathVariable("id") Long id, @PathVariable("itemId") Long itemId, RedirectAttributes redirect) {
        return act(id, redirect, "Đã xoá suất #" + itemId, () -> {
            flashSaleService.removeItem(id, itemId);
            return null;
        });
    }

    @PostMapping("/{id}/activate")
    public String activate(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Chiến dịch đã bắt đầu, khách thấy ở trang Flash Sale", () -> flashSaleService.activate(id));
    }

    @PostMapping("/{id}/pause")
    public String pause(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã tạm dừng chiến dịch", () -> flashSaleService.pause(id));
    }

    @PostMapping("/{id}/resume")
    public String resume(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Chiến dịch chạy lại", () -> flashSaleService.resume(id));
    }

    @PostMapping("/{id}/end")
    public String end(@PathVariable("id") Long id, RedirectAttributes redirect) {
        return act(id, redirect, "Đã kết thúc chiến dịch", () -> flashSaleService.end(id));
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            flashSaleService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá chiến dịch nháp #" + id + ".");
            return "redirect:/staff/flash-sales";
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/staff/flash-sales/" + id;
        }
    }

    private String showDetail(Long id, Model model) {
        FlashSale sale = flashSaleService.get(id);
        model.addAttribute("sale", sale);
        model.addAttribute("saleStartText", sale.getStartTime().format(DATE_TIME));
        model.addAttribute("saleEndText", sale.getEndTime().format(DATE_TIME));
        model.addAttribute("items", flashSaleService.items(id));
        model.addAttribute("redLots", flashSaleService.redLots(id));
        model.addAttribute("shelfLifeDays", inventoryPolicy.getShelfLifeCommitmentDays());
        model.addAttribute("quarantineDays", inventoryPolicy.getQuarantineDays());
        model.addAttribute("deepDiscountDays", inventoryPolicy.getDeepDiscountDays());
        model.addAttribute("discountPercent", inventoryPolicy.getDiscountPercent());
        model.addAttribute("deepDiscountPercent", inventoryPolicy.getDeepDiscountPercent());
        return "staff/flash-sales/detail";
    }

    private static String act(Long id, RedirectAttributes redirect, String success, Supplier<?> action) {
        try {
            action.get();
            redirect.addFlashAttribute("successMessage", success + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/flash-sales/" + id;
    }
}
