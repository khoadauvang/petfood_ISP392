package com.isp392.petfood.dto;

import com.isp392.petfood.enums.AccountStatus;
import com.isp392.petfood.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Getter;

// Một nhân viên (Staff / Admin) trong trang quản lý tài khoản
@Getter
@AllArgsConstructor
public class EmployeeRow {
    private final Long employeeId;
    private final Long accountId;
    private final String email;
    private final String fullName;
    private final String phone;
    private final Role role;
    private final AccountStatus status;
    private final String createdAtText;
}
