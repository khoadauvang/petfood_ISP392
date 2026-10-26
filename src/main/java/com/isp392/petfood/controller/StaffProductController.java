package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ProductAdminRow;
import com.isp392.petfood.dto.ProductForm;
import com.isp392.petfood.dto.ProductGroupDto;
import com.isp392.petfood.entity.Product;
import com.isp392.petfood.enums.AgeGroup;
import com.isp392.petfood.enums.ProductStatus;
import com.isp392.petfood.enums.Species;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.service.CategoryService;
import com.isp392.petfood.service.LotService;
import com.isp392.petfood.service.ProductAdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.propertyeditors.StringTrimmerEditor;
import org.springframework.data.domain.Page;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Quản lý sản phẩm. /staff/** cho phép STAFF và ADMIN (SecurityConfig).
//   GET  /staff/products                     danh sách + tìm kiếm, lọc, phân trang
//   GET  /staff/products/new                 form thêm (multipart, 5 ảnh)   POST cùng URL để lưu
//   GET  /staff/products/new?variantOf={id}  form thêm biến thể: điền sẵn từ sản phẩm gốc, ảnh trống lấy ảnh gốc
//   GET  /staff/products/{id}                chi tiết: 5 ảnh + tồn theo lô
//   GET  /staff/products/{id}/edit           form sửa (thay ảnh nào chọn ảnh đó)   POST cùng URL để lưu
//   POST /staff/products/{id}/toggle-status  ẩn/hiện: ACTIVE <-> DISCONTINUED
//   POST /staff/products/{id}/delete         xoá (chỉ sản phẩm chưa có lô / đơn hàng)
@Controller
@RequestMapping("/staff/products")
@RequiredArgsConstructor
public class StaffProductController {

    private final ProductAdminService productAdminService;
    private final CategoryService categoryService;
    private final LotService lotService;

    // Cắt khoảng trắng 2 đầu mọi ô chữ; ô bỏ trống thành null (mã vạch trống -> NULL, không vướng UNIQUE)
    @InitBinder
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(@RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "categoryId", required = false) Long categoryId,
                       @RequestParam(name = "species", required = false) Species species,
                       @RequestParam(name = "status", required = false) ProductStatus status,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        // Trên URL page tính từ 1, Spring Data tính từ 0
        Page<ProductAdminRow> result = productAdminService.search(keyword, categoryId, species, status,
                Math.max(page, 1) - 1);

        List<ProductGroupDto> productGroups = productAdminService.getProductGroups(keyword, categoryId, species, status);

        // Đếm chính xác số lượng cho 3 KPI Cards
        long totalActive = 0;
        long totalDiscontinued = 0;
        for (ProductGroupDto g : productGroups) {
            totalActive += g.getActiveCount();
            totalDiscontinued += g.getDiscontinuedCount();
        }
        Map<String, Long> productCounts = new HashMap<>();
        productCounts.put("total", result.getTotalElements());
        productCounts.put("active", totalActive);
        productCounts.put("discontinued", totalDiscontinued);
        model.addAttribute("productCounts", productCounts);

        model.addAttribute("productGroups", productGroups);
        model.addAttribute("products", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());

        // Giữ lại bộ lọc trên form và trong link phân trang
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterCategoryId", categoryId);
        model.addAttribute("filterSpecies", species);
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterQuery", QueryStrings.of(
                "keyword", keyword, "categoryId", categoryId, "species", species, "status", status));

        model.addAttribute("categories", categoryService.listAll());
        model.addAttribute("speciesList", Species.values());
        model.addAttribute("productStatuses", ProductStatus.values());
        return "staff/products/list";
    }

    @GetMapping("/new")
    public String createForm(@RequestParam(name = "variantOf", required = false) Long variantOf, Model model) {
        ProductForm form = variantOf == null ? new ProductForm() : productAdminService.buildVariantForm(variantOf);
        model.addAttribute("productForm", form);
        return showCreateForm(model, form);
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("productForm") ProductForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return showCreateForm(model, form);
        }
        try {
            Product saved = productAdminService.create(form);
            String added = form.getVariantOf() != null
                    ? "Đã thêm biến thể " + saved.getFullSku()
                    : "Đã thêm sản phẩm " + saved.getFullSku();
            redirect.addFlashAttribute("successMessage", added + " kèm 5 ảnh"
                    + (form.hasFirstLot() ? " và lô đầu tiên (" + form.getFirstLotQty() + " sản phẩm)" : ""));
            return "redirect:/staff/products/" + saved.getId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showCreateForm(model, form);
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable("id") Long id, Model model) {
        model.addAttribute("product", productAdminService.getDetail(id));
        model.addAttribute("lots", lotService.lotsOfProduct(id));
        return "staff/products/detail";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model) {
        model.addAttribute("productForm", productAdminService.getForm(id));
        return showForm(model, id);
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id,
                         @Valid @ModelAttribute("productForm") ProductForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            FormErrors.summary(model);
            return showForm(model, id);
        }
        try {
            Product saved = productAdminService.update(id, form);
            redirect.addFlashAttribute("successMessage", "Đã lưu sản phẩm " + saved.getFullSku());
            return "redirect:/staff/products/" + id;
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(model, id);
        }
    }

    // from=list: bấm ở trang danh sách thì quay lại danh sách, còn lại quay về trang chi tiết
    @PostMapping("/{id}/toggle-status")
    public String toggleStatus(@PathVariable("id") Long id,
                               @RequestParam(name = "from", required = false) String from,
                               RedirectAttributes redirect) {
        Product product = productAdminService.toggleStatus(id);
        redirect.addFlashAttribute("successMessage", product.getStatus() == ProductStatus.ACTIVE
                ? "Đã mở bán lại " + product.getFullSku()
                : "Đã ẩn " + product.getFullSku() + " (ngừng kinh doanh): không còn hiện ở trang khách");
        return "list".equals(from) ? "redirect:/staff/products" : "redirect:/staff/products/" + id;
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            String sku = productAdminService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá sản phẩm " + sku + " và 5 ảnh của nó");
            return "redirect:/staff/products";
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/staff/products/" + id;
        }
    }

    // productId == null: form thêm mới; có giá trị: form sửa (kèm ảnh hiện tại để xem trước)
    // Form thêm; nếu đang thêm biến thể thì kèm sản phẩm gốc (parentProduct) để JSP hiện ảnh sẽ kế thừa
    private String showCreateForm(Model model, ProductForm form) {
        if (form.getVariantOf() != null) {
            model.addAttribute("parentProduct", productAdminService.getDetail(form.getVariantOf()));
        }
        return showForm(model, null);
    }

    private String showForm(Model model, Long productId) {
        model.addAttribute("productId", productId);
        if (productId != null) {
            model.addAttribute("product", productAdminService.getDetail(productId));
        }
        model.addAttribute("categories", categoryService.listAll());
        model.addAttribute("speciesList", Species.values());
        model.addAttribute("ageGroups", AgeGroup.values());
        model.addAttribute("productStatuses", ProductStatus.values());
        return "staff/products/form";
    }
}
