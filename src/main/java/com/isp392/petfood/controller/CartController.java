package com.isp392.petfood.controller;

import com.isp392.petfood.entity.CartItem;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

// Giỏ hàng. /cart/** chỉ cho CUSTOMER (SecurityConfig, BR-07). Giỏ luôn là giỏ của người đang đăng nhập,
// dòng giỏ của khách khác trả về 404.
//   GET  /cart                          xem giỏ: giá hiện tại, tạm tính, dòng hết hàng / vượt tồn
//   POST /cart/add                      productId, quantity            -> dòng giá thường
//                                       flashSaleItemId, quantity      -> dòng Flash Sale (tách riêng, BR-65)
//   POST /cart/items/{id}/quantity      đổi số lượng
//   POST /cart/items/{id}/delete        xoá dòng
@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public String view(@AuthenticationPrincipal AccountPrincipal user, Model model) {
        model.addAttribute("cart", cartService.getCart(user.getCustomerId()));
        return "customer/cart";
    }

    @PostMapping("/add")
    public String add(@AuthenticationPrincipal AccountPrincipal user,
                      @RequestParam(name = "productId", required = false) Long productId,
                      @RequestParam(name = "flashSaleItemId", required = false) Long flashSaleItemId,
                      @RequestParam(name = "quantity", defaultValue = "1") int quantity,
                      @RequestParam(name = "returnUrl", required = false) String returnUrl,
                      RedirectAttributes redirect) {
        // Trang gửi kèm returnUrl (trang chủ, danh sách sản phẩm) thì quay lại đúng trang đó;
        // không có thì: thêm từ trang chi tiết quay lại trang đó, thêm suất Flash Sale thì về giỏ
        String back = isLocalPath(returnUrl) ? "redirect:" + returnUrl
                : flashSaleItemId == null && productId != null ? "redirect:/products/" + productId : "redirect:/cart";
        try {
            CartItem item;
            if (flashSaleItemId != null) {
                item = cartService.addFlashSale(user.getCustomerId(), flashSaleItemId, quantity);
            } else if (productId != null) {
                item = cartService.addRegular(user.getCustomerId(), productId, quantity);
            } else {
                throw new BusinessRuleException("Chưa chọn sản phẩm");
            }
            redirect.addFlashAttribute("successMessage", "Đã thêm " + quantity + " × " + item.getProduct().getName()
                    + " vào giỏ (giỏ có " + item.getQuantity() + ").");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", "Chưa thêm được vào giỏ: " + e.getMessage());
        }
        return back;
    }

    // Chỉ nhận đường dẫn trong app ("/products?..."), chặn chuyển hướng ra trang ngoài ("//evil.com", "http://...")
    private static boolean isLocalPath(String url) {
        return url != null && url.startsWith("/") && !url.startsWith("//") && !url.contains("\\")
                && url.chars().noneMatch(Character::isISOControl);
    }

    @PostMapping("/items/{id}/quantity")
    public String updateQuantity(@AuthenticationPrincipal AccountPrincipal user,
                                 @PathVariable("id") Long id,
                                 @RequestParam(name = "quantity") int quantity,
                                 RedirectAttributes redirect) {
        try {
            CartItem item = cartService.updateQuantity(user.getCustomerId(), id, quantity);
            redirect.addFlashAttribute("successMessage",
                    "Đã đổi số lượng " + item.getProduct().getName() + " thành " + quantity + ".");
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", "Chưa đổi được số lượng: " + e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/items/{id}/delete")
    public String remove(@AuthenticationPrincipal AccountPrincipal user,
                         @PathVariable("id") Long id,
                         RedirectAttributes redirect) {
        CartItem item = cartService.remove(user.getCustomerId(), id);
        redirect.addFlashAttribute("successMessage", "Đã xoá " + item.getProduct().getName() + " khỏi giỏ.");
        return "redirect:/cart";
    }
}
