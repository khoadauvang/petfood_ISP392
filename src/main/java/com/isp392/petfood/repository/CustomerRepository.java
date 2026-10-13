package com.isp392.petfood.repository;

import com.isp392.petfood.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Optional<Customer> findByAccountId(Long accountId);
}
