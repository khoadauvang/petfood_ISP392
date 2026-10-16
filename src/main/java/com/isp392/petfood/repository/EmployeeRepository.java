package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

import com.isp392.petfood.enums.AccountStatus;
import com.isp392.petfood.enums.Role;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByAccountId(Long accountId);
    //Tra Optional thay vi null de nguoi goi buoc phai xu ly truong hop khong tim thay
    //Ở bước Login (nchung là tầng trên) sẽ xử lý

    @Query("select e from Employee e join fetch e.account where e.id = :id")
    Optional<Employee> findWithAccount(@Param("id") Long id);

    // Trang quản lý nhân viên (Admin): lọc vai trò, trạng thái, tìm theo tên / email / SĐT
    @Query(value = """
            select e from Employee e join fetch e.account a
            where (:role is null or a.role = :role)
              and (:status is null or a.status = :status)
              and (:keyword is null or e.fullName like concat('%', :keyword, '%')
                   or a.email like concat('%', :keyword, '%') or e.phone like concat('%', :keyword, '%'))
            """,
            countQuery = """
            select count(e) from Employee e join e.account a
            where (:role is null or a.role = :role)
              and (:status is null or a.status = :status)
              and (:keyword is null or e.fullName like concat('%', :keyword, '%')
                   or a.email like concat('%', :keyword, '%') or e.phone like concat('%', :keyword, '%'))
            """)
    Page<Employee> search(@Param("role") Role role, @Param("status") AccountStatus status,
                          @Param("keyword") String keyword, Pageable pageable);

    // Số Admin còn đăng nhập được: không cho khoá / hạ vai trò Admin cuối cùng
    @Query("""
            select count(a) from Account a
            where a.role = com.isp392.petfood.enums.Role.ADMIN and a.status = com.isp392.petfood.enums.AccountStatus.ACTIVE
            """)
    long countActiveAdmins();
}
