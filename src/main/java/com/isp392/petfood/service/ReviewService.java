package com.isp392.petfood.service;

import com.isp392.petfood.dto.ReviewDto;
import com.isp392.petfood.dto.ReviewForm;
import com.isp392.petfood.dto.ReviewSummary;
import com.isp392.petfood.entity.OrderItem;
import com.isp392.petfood.entity.ProductReview;
import com.isp392.petfood.entity.ReviewReply;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.ReviewStatus;
import com.isp392.petfood.exception.BusinessRuleException;
import com.isp392.petfood.exception.NotFoundException;
import com.isp392.petfood.repository.EmployeeRepository;
import com.isp392.petfood.repository.OrderItemRepository;
import com.isp392.petfood.repository.ProductReviewRepository;
import com.isp392.petfood.repository.ReviewReplyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

// Đánh giá sản phẩm (module 8, requirements 7.9):
//   - khách chỉ đánh giá dòng hàng thuộc đơn COMPLETED của chính mình; mỗi order_item một đánh giá (sửa lại được)
//   - product_id / customer_id lấy từ dòng đơn, không nhận từ form (ghi chú 4 trong script SQL)
//   - staff phản hồi tối đa một lần mỗi đánh giá; đánh giá vi phạm thì ẩn (HIDDEN), không xoá
@Service
@RequiredArgsConstructor
public class ReviewService {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final int PAGE_SIZE = 15;

    private final ProductReviewRepository reviewRepository;
    private final ReviewReplyRepository replyRepository;
    private final OrderItemRepository orderItemRepository;
    private final EmployeeRepository employeeRepository;

    // ===== Phía khách =====

    // Tên sản phẩm của dòng đơn khách được đánh giá (kiểm tra quyền trước khi hiện form)
    @Transactional(readOnly = true)
    public String reviewableProductName(Long customerId, Long orderId, Long orderItemId) {
        return reviewableItem(customerId, orderId, orderItemId).getProduct().getName();
    }

    // Đánh giá đã có của dòng đơn (để sửa), hoặc form trống
    @Transactional(readOnly = true)
    public ReviewForm getForm(Long customerId, Long orderId, Long orderItemId) {
        reviewableItem(customerId, orderId, orderItemId);
        ReviewForm form = new ReviewForm();
        reviewRepository.findByOrderItem_Id(orderItemId).ifPresent(r -> {
            form.setRating(r.getRating());
            form.setTitle(r.getTitle());
            form.setContent(r.getContent());
        });
        return form;
    }

    @Transactional
    public ProductReview save(Long customerId, Long orderId, Long orderItemId, ReviewForm form) {
        OrderItem item = reviewableItem(customerId, orderId, orderItemId);
        ProductReview review = reviewRepository.findByOrderItem_Id(orderItemId).orElse(null);
        if (review == null) {
            review = new ProductReview();
            review.setOrderItem(item);
            review.setProduct(item.getProduct());                    // khớp dòng đơn (ghi chú 4)
            review.setCustomer(item.getOrder().getCustomer());
        } else {
            review.setUpdatedAt(LocalDateTime.now());                // đánh giá đã ẩn thì sửa xong vẫn ẩn
        }
        review.setRating(form.getRating());
        review.setTitle(blankToNull(form.getTitle()));
        review.setContent(blankToNull(form.getContent()));
        try {
            return reviewRepository.saveAndFlush(review);
        } catch (DataIntegrityViolationException e) {
            throw new BusinessRuleException("Dòng hàng này vừa được đánh giá, vui lòng tải lại trang.");
        }
    }

    // Dòng đơn nào đã có đánh giá
    @Transactional(readOnly = true)
    public Set<Long> reviewedOrderItemIds(Collection<Long> orderItemIds) {
        return orderItemIds.isEmpty() ? Set.of() : new HashSet<>(reviewRepository.findReviewedOrderItemIds(orderItemIds));
    }

    // Trang chi tiết sản phẩm: đánh giá đang hiện + điểm trung bình
    @Transactional(readOnly = true)
    public ReviewSummary productReviews(Long productId) {
        List<ReviewDto> reviews = toDtos(reviewRepository.findVisibleByProduct(productId));
        String average = reviews.isEmpty() ? null : String.format("%.1f",
                reviews.stream().mapToInt(ReviewDto::getRating).average().orElse(0)).replace('.', ',');
        return new ReviewSummary(reviews, average);
    }

    // ===== Phía Staff =====

    @Transactional(readOnly = true)
    public Page<ReviewDto> search(ReviewStatus status, boolean unreplied, String keyword, int pageNumber) {
        Page<ProductReview> page = reviewRepository.search(status, unreplied,
                keyword == null || keyword.isBlank() ? null : keyword.trim(),
                PageRequest.of(pageNumber, PAGE_SIZE, Sort.by(Sort.Direction.DESC, "createdAt", "id")));
        Map<Long, ReviewReply> replies = repliesOf(page.getContent());
        return page.map(r -> toDto(r, replies.get(r.getId())));
    }

    @Transactional
    public ReviewReply reply(Long reviewId, Long employeeId, String content) {
        if (content == null || content.isBlank()) {
            throw new BusinessRuleException("Vui lòng nhập nội dung phản hồi");
        }
        ProductReview review = find(reviewId);
        if (replyRepository.existsByReview_Id(reviewId)) {
            throw new BusinessRuleException("Đánh giá #" + reviewId + " đã được phản hồi (mỗi đánh giá một lần).");
        }
        try {
            return replyRepository.saveAndFlush(new ReviewReply(review, employeeRepository.getReferenceById(employeeId),
                    content.trim()));
        } catch (DataIntegrityViolationException e) {
            throw new BusinessRuleException("Đánh giá #" + reviewId + " vừa được nhân viên khác phản hồi.");
        }
    }

    @Transactional
    public ProductReview setStatus(Long reviewId, ReviewStatus status) {
        ProductReview review = find(reviewId);
        review.setStatus(status);
        return review;
    }

    // ===== Phụ trợ =====

    // Dòng đơn thuộc đơn COMPLETED của đúng khách này
    private OrderItem reviewableItem(Long customerId, Long orderId, Long orderItemId) {
        OrderItem item = orderItemRepository.findById(orderItemId)
                .filter(i -> i.getOrder().getId().equals(orderId)
                        && i.getOrder().getCustomer().getId().equals(customerId))
                .orElseThrow(() -> new NotFoundException("Không tìm thấy sản phẩm #" + orderItemId + " trong đơn của bạn"));
        if (item.getOrder().getStatus() != OrderStatus.COMPLETED) {
            throw new BusinessRuleException("Chỉ đánh giá được sản phẩm của đơn đã giao thành công.");
        }
        item.getProduct().getName();
        return item;
    }

    private ProductReview find(Long id) {
        return reviewRepository.findById(id).orElseThrow(() -> new NotFoundException("Không tìm thấy đánh giá #" + id));
    }

    private List<ReviewDto> toDtos(List<ProductReview> reviews) {
        Map<Long, ReviewReply> replies = repliesOf(reviews);
        return reviews.stream().map(r -> toDto(r, replies.get(r.getId()))).toList();
    }

    private Map<Long, ReviewReply> repliesOf(List<ProductReview> reviews) {
        if (reviews.isEmpty()) {
            return Map.of();
        }
        return replyRepository.findByReviewIds(reviews.stream().map(ProductReview::getId).toList()).stream()
                .collect(Collectors.toMap(rr -> rr.getReview().getId(), Function.identity()));
    }

    private static ReviewDto toDto(ProductReview r, ReviewReply reply) {
        return new ReviewDto(r.getId(), r.getProduct().getId(), r.getProduct().getName(), r.getCustomer().getFullName(),
                r.getRating(), r.getTitle(), r.getContent(), r.getStatus(), r.getCreatedAt().format(DATE_TIME),
                r.getUpdatedAt() != null,
                reply == null ? null : reply.getContent(),
                reply == null ? null : reply.getRepliedBy().getFullName(),
                reply == null ? null : reply.getCreatedAt().format(DATE_TIME));
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
