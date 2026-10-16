package com.isp392.petfood.repository;

import com.isp392.petfood.entity.SupportReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SupportReplyRepository extends JpaRepository<SupportReply, Long> {

    // Lịch sử email của một yêu cầu, cũ trước
    @Query("""
            select r from SupportReply r join fetch r.repliedBy
            where r.ticket.id = :ticketId order by r.createdAt, r.id
            """)
    List<SupportReply> findByTicket(@Param("ticketId") Long ticketId);
}
