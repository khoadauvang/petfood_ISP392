package com.isp392.petfood.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

// Bật @Scheduled (job tính lại hạng thành viên hằng ngày; sau này: Flash Sale, huỷ đơn quá hạn)
@Configuration
@EnableScheduling
public class SchedulingConfig {
}
