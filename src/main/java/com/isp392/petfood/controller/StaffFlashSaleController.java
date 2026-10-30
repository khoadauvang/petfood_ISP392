package com.isp392.petfood.controller;

import com.isp392.petfood.dto.ActiveFlashSaleProductRow;
import com.isp392.petfood.dto.FlashSaleForm;
import com.isp392.petfood.dto.FlashSaleItemForm;
import com.isp392.petfood.dto.FlashSaleRow;
import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.enums.FlashSaleStatus;
import com.isp392.petfood.enums.SaleType;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.function.Supplier;

// Quản lý Chương trình khuyến mãi & Flash Sale (Screen 5)
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

    // Trang chủ CHƯƠNG TRÌNH: Gồm BẢNG 1 (Sản phẩm đang Flash Sale) và BẢNG 2 (Chương trình giảm giá)
    @GetMapping
    public String list(Model model) {
        List<ActiveFlashSaleProductRow> activeProducts = flashSaleService.listActiveFlashSaleProducts();
        List<FlashSaleRow> campaigns = flashSaleService.list();

        model.addAttribute("activeProducts", activeProducts);
        model.addAttribute("campaigns", campaigns);
        model.addAttribute("totalActiveProducts", activeProducts.size());
        model.addAttribute("totalCampaigns", campaigns.size());

        String activeCampaignName = activeProducts.stream()
                .filter(ActiveFlashSaleProductRow::isActive)
                .findFirst()
                .map(p -> p.getSaleCode() + " (" + p.getSaleName() + ")")
                .orElseGet(() -> campaigns.stream()
                        .filter(c -> c.getStatus() == FlashSaleStatus.ACTIVE)
                        .findFirst()
                        .map(c -> c.getCode() + " (" + c.getName() + ")")
                        .orElse("Chưa có chiến dịch đang mở bán"));
        model.addAttribute("activeCampaignName", activeCampaignName);

        return "staff/flash-sales/list";
    }

    // Kích hoạt Flash Sale NGAY LẬP TỨC cho 1 lô cận date (21 - 89 ngày)
    // 30-89 ngày: giảm 40%; 21-29 ngày: giảm 70%; <21 ngày: tiêu hủy
    @PostMapping("/quick-create")
    public String quickCreate(@RequestParam("lotId") Long lotId,
                             @AuthenticationPrincipal AccountPrincipal user,
                             RedirectAttributes redirect) {
        try {
            FlashSale sale = flashSaleService.quickCreateFlashSaleForLot(lotId, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage",
                    "Đã kích hoạt Flash Sale ngay lập tức cho lô hàng #" + lotId + "! Mức giảm "
                            + sale.getDiscountPercent() + "% (" + sale.getName() + ").");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            redirect.addFlashAttribute("errorMessage", "Không thể kích hoạt Flash Sale: " + e.getMessage());
        }
        return "redirect:/staff/flash-sales";
    }

    // Form tạo Chương trình khuyến mãi (áp dụng cho các lô bình thường > 90 ngày, giảm chung 1 mức %)
    @GetMapping("/new")
    public String createForm(Model model) {
        FlashSaleForm form = new FlashSaleForm();
        form.setStartTime(com.isp392.petfood.service.VnpayClient.nowVn().withSecond(0).withNano(0));
        form.setEndTime(com.isp392.petfood.service.VnpayClient.nowVn().withMinute(0).withSecond(0).withNano(0).plusDays(7));
        form.setDiscountPercent(20);

        model.addAttribute("flashSaleForm", form);
        model.addAttribute("saleId", null);
        model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(null));
        return "staff/flash-sales/form";
    }

    @PostMapping("/new")
    public String create(@Valid @ModelAttribute("flashSaleForm") FlashSaleForm form, BindingResult result,
                         @AuthenticationPrincipal AccountPrincipal user, Model model, RedirectAttributes redirect) {
        if (result.hasErrors()) {
            model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(null));
            return "staff/flash-sales/form";
        }
        try {
            FlashSale sale = flashSaleService.createPromotion(form, user.getEmployeeId());
            redirect.addFlashAttribute("successMessage",
                    "Đã tạo chương trình khuyến mãi \"" + sale.getName() + "\" áp dụng mức giảm "
                            + sale.getDiscountPercent() + "% cho các lô hàng thành công!");
            return "redirect:/staff/flash-sales";
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(null));
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
        model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(id));
        return "staff/flash-sales/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable("id") Long id, @Valid @ModelAttribute("flashSaleForm") FlashSaleForm form,
                         BindingResult result,
                         @RequestParam(value = "activate", required = false) Boolean activate,
                         Model model, RedirectAttributes redirect) {
        model.addAttribute("saleId", id);
        if (result.hasErrors()) {
            model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(id));
            return "staff/flash-sales/form";
        }
        try {
            flashSaleService.update(id, form);
            if (Boolean.TRUE.equals(activate)) {
                flashSaleService.activate(id);
                redirect.addFlashAttribute("successMessage", "Đã lưu và bắt đầu mở bán chiến dịch #" + id + " thành công!");
            } else {
                redirect.addFlashAttribute("successMessage", "Đã lưu thông tin chương trình #" + id + ".");
            }
            return "redirect:/staff/flash-sales/" + id;
        } catch (BusinessRuleException e) {
            FormErrors.apply(e, result, model);
            model.addAttribute("normalLots", flashSaleService.normalLotsForPromotion(id));
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
    public String removeItem(@PathVariable("id") Long id, @PathVariable("itemId") Long itemId,
                             @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                             RedirectAttributes redirect) {
        return act(id, redirect, redirectUrl, "Đã gỡ sản phẩm #" + itemId, () -> {
            flashSaleService.removeItem(id, itemId);
            return null;
        });
    }

    @PostMapping("/{id}/activate")
    public String activate(@PathVariable("id") Long id,
                           @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                           RedirectAttributes redirect) {
        return act(id, redirect, redirectUrl, "Chương trình đã bắt đầu chạy mở bán", () -> flashSaleService.activate(id));
    }

    @PostMapping("/{id}/pause")
    public String pause(@PathVariable("id") Long id,
                        @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                        RedirectAttributes redirect) {
        return act(id, redirect, redirectUrl, "Đã tạm dừng chương trình", () -> flashSaleService.pause(id));
    }

    @PostMapping("/{id}/resume")
    public String resume(@PathVariable("id") Long id,
                         @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                         RedirectAttributes redirect) {
        return act(id, redirect, redirectUrl, "Chương trình tiếp tục chạy", () -> flashSaleService.resume(id));
    }

    @PostMapping("/{id}/end")
    public String end(@PathVariable("id") Long id,
                      @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                      RedirectAttributes redirect) {
        return act(id, redirect, redirectUrl, "Đã dừng / kết thúc chương trình", () -> flashSaleService.end(id));
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long id,
                         @RequestParam(value = "redirectUrl", required = false) String redirectUrl,
                         RedirectAttributes redirect) {
        try {
            flashSaleService.delete(id);
            redirect.addFlashAttribute("successMessage", "Đã xoá chiến dịch nháp #" + id + ".");
            if (redirectUrl != null && !redirectUrl.isBlank()) {
                return "redirect:" + redirectUrl;
            }
            return "redirect:/staff/flash-sales";
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/staff/flash-sales/" + id;
        }
    }

    private String showDetail(Long id, Model model) {
        FlashSale sale = flashSaleService.get(id);
        model.addAttribute("sale", sale);
        model.addAttribute("isPromotion", sale.getSaleType() == SaleType.PROMOTION);
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

    private static String act(Long id, RedirectAttributes redirect, String redirectUrl, String success, Supplier<?> action) {
        try {
            action.get();
            redirect.addFlashAttribute("successMessage", success + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        if (redirectUrl != null && !redirectUrl.isBlank()) {
            return "redirect:" + redirectUrl;
        }
        return "redirect:/staff/flash-sales/" + id;
    }
}
