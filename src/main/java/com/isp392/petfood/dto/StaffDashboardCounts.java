package com.isp392.petfood.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// Số đếm trên dashboard Staff (/staff và /staff/api/stats)
@Getter
@AllArgsConstructor
public class StaffDashboardCounts {
    private final long pendingOrders;       // PENDING chờ xác nhận
    private final long processingOrders;    // CONFIRMED + PROCESSING
    private final long returnRequests;      // yêu cầu trả hàng REQUESTED chờ duyệt
    private final long cancelledOrders;     // CANCELLED + RETURNED
    private final long completedOrders;     // COMPLETED
}
