package com.isp392.petfood.controller;

import com.isp392.petfood.dto.LotForm;
import com.isp392.petfood.dto.LotRow;
import com.isp392.petfood.dto.ProductLotGroupDto;
import com.isp392.petfood.enums.LotView;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.service.InventoryPolicy;
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

import java.util.List;

// Quản lý lô. /staff/** cho phép STAFF và ADMIN (SecurityConfig).
//   GET  /staff/lots                     xem tồn theo lô: lọc theo tình trạng, sản phẩm, từ khoá; sắp xếp FEFO
//   GET  /staff/lots/new?productId=..    form nhập lô       POST /staff/lots/new để lưu
//   GET  /staff/lots/{id}/edit           sửa lô nhập nhầm   POST cùng URL để lưu
//   POST /staff/lots/{id}/delete         xoá lô nhập nhầm
@Controller
@RequestMapping("/staff/lots")
@RequiredArgsConstructor
public class StaffLotController {

    private final LotService lotService;
    private final ProductAdminService productAdminService;
    private final InventoryPolicy inventoryPolicy;

    @InitBinder
    public void trimStrings(WebDataBinder binder) {
        binder.registerCustomEditor(String.class, new StringTrimmerEditor(true));
    }

    @GetMapping
    public String list(@RequestParam(name = "view", defaultValue = "ALL") LotView view,
                       @RequestParam(name = "productId", required = false) Long productId,
                       @RequestParam(name = "keyword", required = false) String keyword,
                       @RequestParam(name = "page", defaultValue = "1") int page,
                       Model model) {
        Page<LotRow> result = lotService.search(view, productId, keyword, Math.max(page, 1) - 1);
        List<ProductLotGroupDto> productGroups = lotService.getProductLotGroups(view, productId, keyword);

        model.addAttribute("productGroups", productGroups);
        model.addAttribute("lots", result.getContent());
        model.addAttribute("currentPage", result.getNumber() + 1);
        model.addAttribute("totalPages", result.getTotalPages());
        model.addAttribute("totalItems", result.getTotalElements());

        model.addAttribute("filterView", view);
        model.addAttribute("filterProductId", productId);
        model.addAttribute("filterKeyword", keyword);
        model.addAttribute("filterQuery", QueryStrings.of(
                "view", view, "productId", productId, "keyword", keyword));

        model.addAttribute("lotViews", LotView.values());
        model.addAttribute("products", productAdminService.listOptions());
        model.addAttribute("shelfLifeDays", inventoryPolicy.getShelfLifeCommitmentDays());
        model.addAttribute("quarantineDays", inventoryPolicy.getQuarantineDays());
        model.addAttribute("lotStats", lotService.getLotStats());
        return "staff/lots/list";
    }

    @GetMapping("/new")
    public String createForm(@RequestParam(name = "productId", required = false) Long productId, Model model) {
        LotForm form = new LotForm();
        form.setProductId(productId);          // đi từ trang sản phẩm / cảnh báo thì chọn sẵn sản phẩm
        model.addAttribute("lotForm", form);
        return showForm(model, null);
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("lotForm") LotForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(model, null);
        }
        try {
            LotRow lot = lotService.create(form);
            redirect.addFlashAttribute("successMessage", "Đã nhập lô #" + lot.getId() + ": " + lot.getReceivedQty()
                    + " sản phẩm " + lot.getSku() + ", HSD " + lot.getExpiryDateText()
                    + " (còn " + lot.getDaysLeft() + " ngày)");
            addExpiryWarning(lot, redirect);
            return "redirect:/staff/products/" + lot.getProductId();    // về trang sản phẩm để xem tồn theo lô
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(model, null);
        }
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable("id") Long id, Model model, RedirectAttributes redirect) {
        LotRow lot = lotService.getRow(id);
        if (!lot.isUntouched()) {
            redirect.addFlashAttribute("errorMessage", "Lô #" + id + " đã xuất hàng nên không sửa được.");
            return "redirect:/staff/products/" + lot.getProductId();
        }
        model.addAttribute("lotForm", lotService.getForm(id));
        return showForm(model, id);
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id,
                         @Valid @ModelAttribute("lotForm") LotForm form,
                         BindingResult result,
                         Model model,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return showForm(model, id);
        }
        try {
            LotRow lot = lotService.update(id, form);
            redirect.addFlashAttribute("successMessage", "Đã sửa lô #" + id + ": " + lot.getReceivedQty()
                    + " sản phẩm, HSD " + lot.getExpiryDateText());
            addExpiryWarning(lot, redirect);
            return "redirect:/staff/products/" + lot.getProductId();
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            return showForm(model, id);
        }
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id, RedirectAttributes redirect) {
        LotRow lot = lotService.getRow(id);
        try {
            lotService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá lô #" + id + " của " + lot.getSku());
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/staff/products/" + lot.getProductId();
    }

    // Lô vừa nhập/sửa mà đã dưới mốc hạn dùng thì nhắc ngay (BR-51)
    private void addExpiryWarning(LotRow lot, RedirectAttributes redirect) {
        switch (lot.getLevel()) {
            case RED -> redirect.addFlashAttribute("warningMessage", "Lô còn dưới "
                    + inventoryPolicy.getShelfLifeCommitmentDays()
                    + " ngày (cảnh báo đỏ): không tính vào tồn bán thường, chỉ bán qua Flash Sale.");
            case BLOCKED, EXPIRED -> redirect.addFlashAttribute("warningMessage", "Lô còn dưới "
                    + inventoryPolicy.getQuarantineDays()
                    + " ngày: không được bán dưới mọi hình thức, cần cách ly.");
            default -> {
                // còn hạn dài: không cần nhắc
            }
        }
    }

    // lotId == null: form nhập lô (chọn sản phẩm); có giá trị: form sửa (sản phẩm cố định)
    private String showForm(Model model, Long lotId) {
        model.addAttribute("lotId", lotId);
        if (lotId == null) {
            model.addAttribute("products", productAdminService.listOptions());
        } else {
            model.addAttribute("lot", lotService.getRow(lotId));
        }
        model.addAttribute("shelfLifeDays", inventoryPolicy.getShelfLifeCommitmentDays());
        model.addAttribute("quarantineDays", inventoryPolicy.getQuarantineDays());
        return "staff/lots/form";
    }
}
