package com.isp392.petfood.controller;

import com.isp392.petfood.entity.CartItem;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.security.AccountPrincipal;
import com.isp392.petfood.security.LocalPaths;
import com.isp392.petfood.service.CartService;
import com.isp392.petfood.service.ShippingFeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

// Giỏ hàng. /cart/** chỉ cho CUSTOMER (SecurityConfig, BR-07). Giỏ luôn là giỏ của người đang đăng nhập,
// dòng giỏ của khách khác trả về 404.
//   GET  /cart                          xem giỏ: giá hiện tại, tạm tính, dòng hết hàng / vượt tồn
//   POST /cart/add                      productId, quantity            -> dòng giá thường
//                                       flashSaleItemId, quantity      -> dòng Flash Sale (tách riêng, BR-65)
//                                       gọi bằng fetch (X-Requested-With) -> JSON {ok, message, cartItemCount}
//                                       buyNow=true ("Mua ngay") -> thêm xong sang thẳng /checkout chỉ với dòng vừa thêm
//   POST /cart/items/{id}/quantity      đổi số lượng
//   POST /cart/items/{id}/delete        xoá dòng
@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;
    private final ShippingFeeService shippingFeeService;

    @GetMapping
    public String view(@AuthenticationPrincipal AccountPrincipal user, Model model) {
        model.addAttribute("cart", cartService.getCart(user.getCustomerId()));
        model.addAttribute("freeShipMinSubtotal", shippingFeeService.getFreeMinSubtotal());
        return "customer/cart";
    }

    @PostMapping("/add")
    public String add(@AuthenticationPrincipal AccountPrincipal user,
                      @RequestParam(name = "productId", required = false) Long productId,
                      @RequestParam(name = "flashSaleItemId", required = false) Long flashSaleItemId,
                      @RequestParam(name = "quantity", defaultValue = "1") int quantity,
                      @RequestParam(name = "returnUrl", required = false) String returnUrl,
                      @RequestParam(name = "buyNow", defaultValue = "false") boolean buyNow,
                      RedirectAttributes redirect) {
        // Trang gửi kèm returnUrl (trang chủ, danh sách sản phẩm) thì quay lại đúng trang đó;
        // không có thì: thêm từ trang chi tiết quay lại trang đó, thêm suất Flash Sale thì về giỏ
        String back = LocalPaths.isLocalPath(returnUrl) ? "redirect:" + returnUrl
                : flashSaleItemId == null && productId != null ? "redirect:/products/" + productId : "redirect:/cart";
        try {
            CartItem item = addItem(user, productId, flashSaleItemId, quantity);
            if (buyNow) {
                // chỉ đặt dòng này, các dòng khác ở lại giỏ (đặt hàng theo dòng được chọn, mục 7.4)
                return "redirect:/checkout?itemIds=" + item.getId();
            }
            redirect.addFlashAttribute("successMessage", addedMessage(item, quantity));
        } catch (BusinessRuleException e) {
            redirect.addFlashAttribute("errorMessage", "Chưa thêm được vào giỏ: " + e.getMessage());
        }
        return back;
    }

    // Cùng /cart/add nhưng gọi bằng fetch (header X-Requested-With) từ trang danh sách sản phẩm:
    // trả JSON thay vì redirect để trang tự báo kết quả và cập nhật số trên icon giỏ, không mất thông báo lỗi
    @PostMapping(value = "/add", headers = "X-Requested-With=XMLHttpRequest")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addAjax(@AuthenticationPrincipal AccountPrincipal user,
                                                       @RequestParam(name = "productId", required = false) Long productId,
                                                       @RequestParam(name = "flashSaleItemId", required = false) Long flashSaleItemId,
                                                       @RequestParam(name = "quantity", defaultValue = "1") int quantity) {
        try {
            CartItem item = addItem(user, productId, flashSaleItemId, quantity);
            return ResponseEntity.ok(Map.of("ok", true, "message", addedMessage(item, quantity),
                    "cartItemCount", cartService.countItems(user.getCustomerId())));
        } catch (BusinessRuleException e) {
            return ResponseEntity.unprocessableEntity()
                    .body(Map.of("ok", false, "message", "Chưa thêm được vào giỏ: " + e.getMessage()));
        }
    }

    private CartItem addItem(AccountPrincipal user, Long productId, Long flashSaleItemId, int quantity) {
        if (flashSaleItemId != null) {
            return cartService.addFlashSale(user.getCustomerId(), flashSaleItemId, quantity);
        }
        if (productId != null) {
            return cartService.addRegular(user.getCustomerId(), productId, quantity);
        }
        throw new BusinessRuleException("Chưa chọn sản phẩm");
    }

    private static String addedMessage(CartItem item, int quantity) {
        return "Đã thêm " + quantity + " × " + item.getProduct().getName() + " vào giỏ (giỏ có " + item.getQuantity() + ").";
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

    @PostMapping(value = "/items/{id}/quantity", headers = "X-Requested-With=XMLHttpRequest")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateQuantityAjax(@AuthenticationPrincipal AccountPrincipal user,
                                                                  @PathVariable("id") Long id,
                                                                  @RequestParam(name = "quantity") int quantity) {
        try {
            CartItem item = cartService.updateQuantity(user.getCustomerId(), id, quantity);
            return ResponseEntity.ok(Map.of(
                    "ok", true,
                    "quantity", item.getQuantity(),
                    "cartItemCount", cartService.countItems(user.getCustomerId()),
                    "message", "Đã lưu"
            ));
        } catch (BusinessRuleException e) {
            return ResponseEntity.unprocessableEntity()
                    .body(Map.of("ok", false, "message", e.getMessage()));
        }
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
