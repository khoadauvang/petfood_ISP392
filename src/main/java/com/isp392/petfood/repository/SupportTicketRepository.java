package com.isp392.petfood.repository;

import com.isp392.petfood.entity.SupportTicket;
import com.isp392.petfood.enums.SupportStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface SupportTicketRepository extends JpaRepository<SupportTicket, Long> {

    // Nút đã có yêu cầu tham chiếu thì chỉ ẩn, không xoá
    boolean existsByFromNode_Id(Long nodeId);

    @Query("""
            select t from SupportTicket t left join fetch t.fromNode left join fetch t.handledBy
            where t.id = :id
            """)
    Optional<SupportTicket> findDetail(@Param("id") Long id);

    // Trang quản lý: lọc trạng thái, tìm theo mã yêu cầu / email / tên người gửi
    @Query(value = """
            select t from SupportTicket t left join fetch t.handledBy
            where (:status is null or t.status = :status)
              and (:keyword is null or t.ticketCode like concat('%', :keyword, '%')
                   or t.contactEmail like concat('%', :keyword, '%')
                   or t.contactName like concat('%', :keyword, '%'))
            """,
            countQuery = """
            select count(t) from SupportTicket t
            where (:status is null or t.status = :status)
              and (:keyword is null or t.ticketCode like concat('%', :keyword, '%')
                   or t.contactEmail like concat('%', :keyword, '%')
                   or t.contactName like concat('%', :keyword, '%'))
            """)
    Page<SupportTicket> search(@Param("status") SupportStatus status, @Param("keyword") String keyword,
                               Pageable pageable);

    long countByStatus(SupportStatus status);
}
