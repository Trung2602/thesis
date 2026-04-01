package com.lht.services.impl;

import com.lht.client.InternalUserClient;
import com.lht.configs.PaymentConfig;
import com.lht.component.SecurityUtils;
import com.lht.pojo.PayCustomer;
import com.lht.pojo.Plan;
import com.lht.pojo.StatusType;
import com.lht.services.PayCustomerService;
import com.lht.services.PaymentService;
import com.lht.services.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;

@Service
@Transactional
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PayCustomerService payCustomerService;
    private final PlanService planService;
    private final InternalUserClient internalUserClient;
    private final PaymentConfig vnpConfig;

    @Override
    public String createPaymentUrl(UUID planUuid, String mail, String ip) throws Exception {

        UUID uuid = SecurityUtils.getCurrentUserUuid();
        Plan plan = planService.getByUuid(planUuid);

        // ===== Create PayCustomer =====
        PayCustomer pc = new PayCustomer();
        pc.setDate(LocalDate.now());
        pc.setPlanUuid(plan.getUuid());
        pc.setCustomerUuid(uuid);
        pc.setStatus(StatusType.FAILED);

        PayCustomer pay = payCustomerService.createPayCustomer(pc);

        // ===== Build VNPAY params =====
        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", vnpConfig.getVnp_TmnCode());
        vnp_Params.put("vnp_Amount", String.valueOf(plan.getPrice() * 100));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", String.valueOf(System.currentTimeMillis()));
        vnp_Params.put("vnp_OrderInfo", String.valueOf(pay.getUuid()));
        vnp_Params.put("vnp_OrderType", "170000");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_IpAddr", ip);

        String createDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        vnp_Params.put("vnp_CreateDate", createDate);

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 15);
        vnp_Params.put("vnp_ExpireDate", new SimpleDateFormat("yyyyMMddHHmmss").format(cal.getTime()));
        vnp_Params.put("vnp_ReturnUrl", vnpConfig.getVnp_ReturnUrl());

        // ===== Build query + hash =====
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();

        for (String fieldName : fieldNames) {
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII)).append('&');
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII)).append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII)).append('&');
            }
        }

        hashData.deleteCharAt(hashData.length() - 1);
        query.deleteCharAt(query.length() - 1);

        String secureHash = hmacSHA512(vnpConfig.getVnp_HashSecret(), hashData.toString());
        query.append("&vnp_SecureHash=").append(secureHash);

        return vnpConfig.getVnp_Url() + "?" + query;
    }

    @Override
    public StatusType handleReturn(Map<String, String> params) throws Exception {

        String vnp_SecureHash = params.get("vnp_SecureHash");
        Map<String, String> sortedParams = new TreeMap<>(params);
        sortedParams.remove("vnp_SecureHash");
        StringBuilder signData = new StringBuilder();
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            if (entry.getKey().startsWith("vnp_")) {
                signData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8)).append("=")
                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8)).append("&");
            }
        }
        signData.deleteCharAt(signData.length() - 1);
        String calculatedHash = hmacSHA512(vnpConfig.getVnp_HashSecret(), signData.toString());
        if (!calculatedHash.equals(vnp_SecureHash)) {
            throw new RuntimeException("Invalid signature");
        }
        StatusType status = "00".equals(params.get("vnp_ResponseCode")) ? StatusType.SUCCESS : StatusType.FAILED;

        UUID pcUuid = UUID.fromString(params.get("vnp_OrderInfo"));
        PayCustomer pay = payCustomerService.getByUuid(pcUuid);

        payCustomerService.updatePaymentStatus(
                pay,
                params.get("vnp_TxnRef"),
                status,
                params.get("vnp_BankCode")
        );

        if (status == StatusType.SUCCESS) {
            internalUserClient.updateExpiryAfterPayment(pay.getCustomerUuid(), pay.getPlanUuid());
        }

        return status;
    }

    private String hmacSHA512(String key, String data) {
        try {
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : result) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hash error");
        }
    }
}
