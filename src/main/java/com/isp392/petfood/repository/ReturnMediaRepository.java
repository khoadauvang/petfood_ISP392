package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ReturnMedia;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReturnMediaRepository extends JpaRepository<ReturnMedia, Long> {

    List<ReturnMedia> findByReturnRequest_IdOrderByIdAsc(Long returnId);
}
