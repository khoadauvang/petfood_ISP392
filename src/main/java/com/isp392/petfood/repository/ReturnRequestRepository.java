package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReturnRequest;
import com.isp392.petfood.enums.ReturnStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReturnRequestRepository extends JpaRepository<ReturnRequest, Long> {

    List<ReturnRequest> findByOrder_IdOrderByCreatedAtDesc(Long orderId);

    // Trang quản lý trả hàng của Staff: lọc trạng thái (null = tất cả)
    @Query(value = """
            select r from ReturnRequest r join fetch r.order o join fetch o.customer c join fetch c.account
            where (:status is null or r.status = :status)
            """,
            countQuery = "select count(r) from ReturnRequest r where (:status is null or r.status = :status)")
    Page<ReturnRequest> search(@Param("status") ReturnStatus status, Pageable pageable);

    // Khoá khi đổi trạng thái: 2 nhân viên thao tác cùng lúc không ghi đè nhau
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from ReturnRequest r where r.id = :id")
    Optional<ReturnRequest> findByIdForUpdate(@Param("id") Long id);

    long countByStatus(ReturnStatus status);
}
