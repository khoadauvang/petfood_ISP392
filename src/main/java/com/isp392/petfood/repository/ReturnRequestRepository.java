package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReturnRequest;
import com.isp392.petfood.enums.ReturnReason;
import com.isp392.petfood.enums.ReturnStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Long> {

    List<ReturnRequest> findByOrder_IdOrderByCreatedAtDesc(Long orderId);

    // Trang quản lý trả hàng của Staff: lọc trạng thái, lý do, ngày gửi [from, to) (null = bỏ qua),
    // từ khoá theo mã yêu cầu / mã đơn (numericId) hoặc tên / SĐT / email khách
    @Query(value = """
            select r from ReturnRequest r join fetch r.order o join fetch o.customer c join fetch c.account a
            where (:status is null or r.status = :status)
              and (:reason is null or r.reason = :reason)
              and (:from is null or r.createdAt >= :from)
              and (:to is null or r.createdAt < :to)
              and (:keyword is null
                   or (:numericId is not null and (r.id = :numericId or o.id = :numericId))
                   or c.fullName like concat('%', :keyword, '%')
                   or c.phone like concat('%', :keyword, '%')
                   or a.email like concat('%', :keyword, '%'))
            """,
            countQuery = """
            select count(r) from ReturnRequest r join r.order o join o.customer c join c.account a
            where (:status is null or r.status = :status)
              and (:reason is null or r.reason = :reason)
              and (:from is null or r.createdAt >= :from)
              and (:to is null or r.createdAt < :to)
              and (:keyword is null
                   or (:numericId is not null and (r.id = :numericId or o.id = :numericId))
                   or c.fullName like concat('%', :keyword, '%')
                   or c.phone like concat('%', :keyword, '%')
                   or a.email like concat('%', :keyword, '%'))
            """)
    Page<ReturnRequest> search(@Param("status") ReturnStatus status,
                               @Param("reason") ReturnReason reason,
                               @Param("from") LocalDateTime from,
                               @Param("to") LocalDateTime to,
                               @Param("numericId") Long numericId,
                               @Param("keyword") String keyword,
                               Pageable pageable);

    // Khoá khi đổi trạng thái: 2 nhân viên thao tác cùng lúc không ghi đè nhau
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from ReturnRequest r where r.id = :id")
    Optional<ReturnRequest> findByIdForUpdate(@Param("id") Long id);

    long countByStatus(ReturnStatus status);
}
