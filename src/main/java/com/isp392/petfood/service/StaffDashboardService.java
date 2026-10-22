package com.isp392.petfood.service;

import com.isp392.petfood.dto.OrderRow;
import com.isp392.petfood.dto.ReturnRow;
import com.isp392.petfood.dto.StaffDashboardCounts;
import com.isp392.petfood.enums.OrderStatus;
import com.isp392.petfood.enums.ReturnStatus;
import com.isp392.petfood.repository.OrderRepository;
import com.isp392.petfood.repository.ReturnRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// Dashboard vận hành cho Staff/Admin (/staff): số đơn theo nhóm trạng thái, hàng đợi đơn cần chú ý,
// yêu cầu trả hàng gần đây. Cảnh báo kho lấy riêng ở InventoryAlertService.
@Service
@RequiredArgsConstructor
public class StaffDashboardService {

    private final OrderRepository orderRepository;
    private final ReturnRequestRepository returnRequestRepository;
    private final OrderService orderService;
    private final ReturnService returnService;

    @Transactional(readOnly = true)
    public StaffDashboardCounts counts() {
        return new StaffDashboardCounts(
                orderRepository.countByStatus(OrderStatus.PENDING),
                orderRepository.countByStatus(OrderStatus.CONFIRMED) + orderRepository.countByStatus(OrderStatus.PROCESSING),
                returnRequestRepository.countByStatus(ReturnStatus.REQUESTED),
                orderRepository.countByStatus(OrderStatus.CANCELLED) + orderRepository.countByStatus(OrderStatus.RETURNED),
                orderRepository.countByStatus(OrderStatus.COMPLETED));
    }

    // Đơn PENDING cần duyệt; không có thì lấy đơn PROCESSING khách đang yêu cầu huỷ (trang đầu)
    @Transactional(readOnly = true)
    public List<OrderRow> attentionOrders() {
        List<OrderRow> orders = orderService.search(OrderStatus.PENDING, false, null, 0).getContent();
        return orders.isEmpty() ? orderService.search(OrderStatus.PROCESSING, true, null, 0).getContent() : orders;
    }

    // Yêu cầu REQUESTED chờ duyệt; không có thì lấy các yêu cầu gần nhất (trang đầu)
    @Transactional(readOnly = true)
    public List<ReturnRow> recentReturns() {
        List<ReturnRow> returns = returnService.search(ReturnStatus.REQUESTED, 0).getContent();
        return returns.isEmpty() ? returnService.search(null, 0).getContent() : returns;
    }
}
