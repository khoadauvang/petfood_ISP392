package com.isp392.petfood.repository;

import com.isp392.petfood.entity.ChatNode;
import com.isp392.petfood.enums.ChatNodeStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatNodeRepository extends JpaRepository<ChatNode, Long> {

    // Cả cây cho trang quản lý (dựng cây trong bộ nhớ, kịch bản chỉ vài chục nút)
    @Query("select n from ChatNode n left join fetch n.updatedBy order by n.sortOrder, n.id")
    List<ChatNode> findAllForTree();

    // Chủ đề gốc đang hiện (màn hình đầu của chatbox)
    @Query("select n from ChatNode n where n.parent is null and n.status = :status order by n.sortOrder, n.id")
    List<ChatNode> findRoots(@Param("status") ChatNodeStatus status);

    // Nút con đang hiện của một nút
    @Query("select n from ChatNode n where n.parent.id = :parentId and n.status = :status order by n.sortOrder, n.id")
    List<ChatNode> findChildren(@Param("parentId") Long parentId, @Param("status") ChatNodeStatus status);

    boolean existsByParent_Id(Long parentId);
}
