package com.isp392.petfood.dto;

import com.isp392.petfood.enums.InspectionResult;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

// Staff thẩm định từng dòng hàng trả (BR-38): tái nhập / tiêu huỷ, ghi chú, có hoàn tiền dòng đó không (BR-34, BR-37)
@Getter
@Setter
public class InspectForm {

    private List<Line> lines = new ArrayList<>();

    @Getter
    @Setter
    public static class Line {
        private Long returnItemId;
        private InspectionResult result;
        private String note;
        private boolean refund = true;
    }
}
