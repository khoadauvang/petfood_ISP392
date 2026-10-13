package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByAccountId(Long accountId);
    //Tra Optional thay vi null de nguoi goi buoc phai xu ly truong hop khong tim thay
    //Ở bước Login (nchung là tầng trên) sẽ xử lý
}
