package com.lht.client;

import com.lht.dto.BodyLogDTO;
import com.lht.dto.CustomerDTO;
import com.lht.dto.GoalDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.UUID;

@FeignClient(
        name = "user-service",
        url = "${user.service.url}"
)
public interface InternalUserClient {
    @GetMapping("/internal/customers/{uuid}/bmi")
    CustomerDTO getCustomer(@PathVariable UUID uuid);

    @GetMapping("/internal/customer/{uuid}/body-log")
    List<BodyLogDTO> getRecentHistory(@PathVariable UUID uuid, @RequestParam(defaultValue = "0") int limit);

    @GetMapping("/internal/customer/{uuid}/goal")
    GoalDTO getGoalByCustomerUuid(@PathVariable UUID uuid);
}
