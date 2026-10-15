package com.isp392.petfood.controller;

import com.isp392.petfood.dto.CategoryForm;
import com.isp392.petfood.entity.Category;
import com.isp392.petfood.enums.CategoryStatus;
import com.isp392.petfood.enums.PetType;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.service.CategoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
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

// Quản lý danh mục. /staff/** cho phép STAFF và ADMIN (SecurityConfig).
//   GET  /staff/categories                    danh sách
//   GET  /staff/categories/new                form thêm      POST cùng URL để lưu
//   GET  /staff/categories/{id}/edit          form sửa       POST cùng URL để lưu
//   POST /staff/categories/{id}/toggle-status ẩn <-> hiện
//   POST /staff/categories/{id}/delete        xoá (chỉ khi chưa có sản phẩm)
@Controller
@RequestMapping("/staff/categories")
@RequiredArgsConstructor
public class StaffCategoryController {

    private final CategoryService categoryService;

    // Cắt khoảng trắng 2 đầu mọi ô chữ; ô chỉ có khoảng trắng thành null
    @InitBinder
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("categories", categoryService.listAll());
        return "staff/categories/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("categoryForm", new CategoryForm());
        return showForm(model, null);
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("categoryForm") CategoryForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(model, null);
        }
        try {
            Category saved = categoryService.create(form);
            redirect.addFlashAttribute("successMessage", "Đã thêm danh mục \"" + saved.getName() + "\"");
            return "redirect:/staff/categories";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(model, null);
        }
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("categoryForm", categoryService.getForm(id));
        return showForm(model, id);
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id,
                         @Valid @ModelAttribute("categoryForm") CategoryForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(model, id);
        }
        try {
            Category saved = categoryService.update(id, form);
            redirect.addFlashAttribute("successMessage", "Đã lưu danh mục \"" + saved.getName() + "\"");
            return "redirect:/staff/categories";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(model, id);
        }
    }

    @PostMapping("/{id}/toggle-status")
    public String toggleStatus(@PathVariable("id") Long id, RedirectAttributes redirect) {
        Category category = categoryService.toggleStatus(id);
        redirect.addFlashAttribute("successMessage", category.getStatus() == CategoryStatus.HIDDEN
                ? "Đã ẩn danh mục \"" + category.getName() + "\": sản phẩm trong danh mục không còn hiện ở trang khách"
                : "Đã hiện lại danh mục \"" + category.getName() + "\"");
        return "redirect:/staff/categories";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            String name = categoryService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá danh mục \"" + name + "\"");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/categories";
    }

    // categoryId == null: form thêm mới; có giá trị: form sửa
    private String showForm(Model model, Long categoryId) {
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("petTypes", PetType.values());
        model.addAttribute("categoryStatuses", CategoryStatus.values());
        return "staff/categories/form";
    }
}
