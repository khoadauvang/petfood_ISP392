package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReviewReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface ReviewReplyRepository extends JpaRepository<ReviewReply, Long> {

    // Mỗi đánh giá tối đa một phản hồi (UQ_ReviewReply_review_id)
    boolean existsByReview_Id(Long reviewId);

    @Query("select rr from ReviewReply rr join fetch rr.repliedBy where rr.review.id in :reviewIds")
    List<ReviewReply> findByReviewIds(@Param("reviewIds") Collection<Long> reviewIds);
}
