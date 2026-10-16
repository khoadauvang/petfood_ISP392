package com.isp392.petfood.repository;

import com.isp392.petfood.entity.FlashSale;
import com.isp392.petfood.enums.FlashSaleStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

public interface FlashSaleRepository extends JpaRepository<FlashSale, Long> {

    // Trang quản lý: mới nhất trước, kèm người tạo
    @Query("select s from FlashSale s join fetch s.createdBy order by s.startTime desc, s.id desc")
    List<FlashSale> findAllForList();

    // Scheduler: chiến dịch ở các trạng thái cần xét
    List<FlashSale> findByStatusIn(Collection<FlashSaleStatus> statuses);

    // Chiến dịch đã tới giờ kết thúc mà chưa ENDED
    @Query("select s from FlashSale s where s.status <> com.isp392.petfood.enums.FlashSaleStatus.ENDED and s.endTime <= :now")
    List<FlashSale> findOverdue(@Param("now") LocalDateTime now);
}
