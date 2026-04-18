package com.lht.controllers.api;

import com.lht.client.InternalUserClient;
import com.lht.configs.PaymentConfig;
import com.lht.dto.InternalUserResponse;
import com.lht.pojo.PayCustomer;
import com.lht.pojo.Plan;
import com.lht.pojo.StatusType;
import com.lht.services.PayCustomerService;
import com.lht.services.PaymentService;
import com.lht.services.PlanService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/gym")
@RequiredArgsConstructor
public class ApiPaymentController {

//    @Autowired
//    private PayCustomerService payCustomerService;
//
//    @Autowired
//    private PlanService planService;
//
//    @Autowired
//    private InternalUserClient internalUserClient;
//
//    private final PaymentConfig vnpConfig;
//
//    public ApiPaymentController(PaymentConfig vnpConfig) {
//        this.vnpConfig = vnpConfig;
//    }
//
//    @PostMapping("/payment/create")
//    public ResponseEntity<?> createPayment(@RequestBody Map<String, String> body,
//            HttpServletRequest request) throws UnsupportedEncodingException {
//
//        UUID planUuid = UUID.fromString(body.get("planUuid"));
//        String mail = SecurityContextHolder.getContext().getAuthentication().getName();
//        InternalUserResponse userResponse = null;
//        if (mail != null && !mail.isEmpty()) {
//            userResponse = internalUserClient.getInternalByMail(mail);
//        }
//
//        Plan plan = planService.getByUuid(planUuid);
//
//        PayCustomer pc = new PayCustomer();
//        pc.setDate(LocalDate.now());
//        pc.setPlanUuid(plan.getUuid());
//        pc.setCustomerUuid(userResponse.uuid());
//        pc.setStatus(StatusType.FAILED);
//        PayCustomer pay = this.payCustomerService.createPayCustomer(pc);
//
//        String vnp_Version = "2.1.0";
//        String vnp_Command = "pay";
//        String vnp_TxnRef = String.valueOf(System.currentTimeMillis());
//        String vnp_IpAddr = request.getRemoteAddr();
//        String orderType = "170000"; // Thương mại điện tử
//
//        Map<String, String> vnp_Params = new HashMap<>();
//        vnp_Params.put("vnp_Version", vnp_Version);
//        vnp_Params.put("vnp_Command", vnp_Command);
//        vnp_Params.put("vnp_TmnCode", vnpConfig.getVnp_TmnCode());
//        vnp_Params.put("vnp_Amount", String.valueOf(plan.getPrice() * 100));
//        vnp_Params.put("vnp_CurrCode", "VND");
//        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
//        vnp_Params.put("vnp_OrderInfo", String.valueOf(pay.getUuid()));
//        vnp_Params.put("vnp_OrderType", orderType);
//        vnp_Params.put("vnp_Locale", "vn");
//        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);
//        vnp_Params.put("vnp_CreateDate", new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()));
//        Calendar cal = Calendar.getInstance();
//        cal.add(Calendar.MINUTE, 15);
//        vnp_Params.put("vnp_ExpireDate", new SimpleDateFormat("yyyyMMddHHmmss").format(cal.getTime()));
//
//        vnp_Params.put("vnp_ReturnUrl", vnpConfig.getVnp_ReturnUrl());
//
//        System.out.println("URL return " + vnpConfig.getVnp_ReturnUrl());
//        // Sort params
//        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
//        Collections.sort(fieldNames);
//        StringBuilder hashData = new StringBuilder();
//        StringBuilder query = new StringBuilder();
//        for (String fieldName : fieldNames) {
//            String fieldValue = vnp_Params.get(fieldName);
//            if (fieldValue != null && !fieldValue.isEmpty()) {
//                hashData.append(fieldName).append('=')
//                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString())).append('&');
//                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString())).append('=')
//                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString())).append('&');
//            }
//        }
//        hashData.deleteCharAt(hashData.length() - 1);
//        query.deleteCharAt(query.length() - 1);
//
//        String vnp_SecureHash = hmacSHA512(vnpConfig.getVnp_HashSecret(), hashData.toString());
//        query.append("&vnp_SecureHash=").append(vnp_SecureHash);
//        String paymentUrl = vnpConfig.getVnp_Url() + "?" + query.toString();
//
//        Map<String, String> result = new HashMap<>();
//        result.put("paymentUrl", paymentUrl);
//
//        return ResponseEntity.ok(result);
//    }
//
//    private String hmacSHA512(String key, String data) {
//        try {
//            Mac hmac512 = Mac.getInstance("HmacSHA512");
//            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
//            hmac512.init(secretKey);
//            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
//            StringBuilder sb = new StringBuilder();
//            for (byte b : result) {
//                sb.append(String.format("%02x", b));
//            }
//            return sb.toString();
//        } catch (Exception e) {
//            return "";
//        }
//    }
//
//    @GetMapping("/payment/return")
//    public ResponseEntity<?> handleReturn(@RequestParam Map<String, String> params, HttpServletResponse response) throws Exception {
//        // In tất cả param ra console
//        System.out.println("===== VNPAY RETURN PARAMS =====");
//        params.forEach((key, value) -> {
//            System.out.println(key + " = " + value);
//        });
//        System.out.println("================================");
//
//        String vnp_SecureHash = params.get("vnp_SecureHash");
//
//        // Tính chữ ký lại
//        Map<String, String> sortedParams = new TreeMap<>(params);
//        sortedParams.remove("vnp_SecureHash");
//
//        StringBuilder signData = new StringBuilder();
//        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
//            if (entry.getKey().startsWith("vnp_")) {
//                signData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8.toString()))
//                        .append("=")
//                        .append(URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8.toString()))
//                        .append("&");
//            }
//        }
//        signData.deleteCharAt(signData.length() - 1);
//        String calculatedHash = hmacSHA512(vnpConfig.getVnp_HashSecret(), signData.toString());
//
//        if (calculatedHash.equals(vnp_SecureHash)) {
//            StatusType status = StatusType.FAILED;
//            if ("00".equals(params.get("vnp_ResponseCode"))) {
//                status = StatusType.SUCCESS;
//            }
//            UUID pcUuid = UUID.fromString(params.get("vnp_OrderInfo"));
//            PayCustomer pay = this.payCustomerService.getByUuid(pcUuid);
//            String txnRef = params.get("vnp_TxnRef");
//            String bankCode = params.get("vnp_BankCode");
//            this.payCustomerService.updatePaymentStatus(pay, txnRef, status, bankCode);
//
//            if (pay.getStatus() == StatusType.SUCCESS) {
//                internalUserClient.updateExpiryAfterPayment(pay.getCustomerUuid(), pay.getPlanUuid());
//            }
//            // --- Redirect về frontend ---
//            Map<String, Object> result = new HashMap<>();
//            result.put("status", status);
//
//            return ResponseEntity.ok(result);
//        } else {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid signature");
//        }
//    }

    private final PaymentService paymentService;

    @PostMapping("/payment/create")
    public ResponseEntity<?> createPayment(@RequestBody Map<String, String> body,
                                           HttpServletRequest request) throws Exception {

        UUID planUuid = UUID.fromString(body.get("planUuid"));
        String mail = SecurityContextHolder.getContext().getAuthentication().getName();

        String paymentUrl = paymentService.createPaymentUrl(planUuid, mail, request.getRemoteAddr());

        return ResponseEntity.ok(Map.of("paymentUrl", paymentUrl));
    }

    @GetMapping("/payment/return")
    public ResponseEntity<?> handleReturn(@RequestParam Map<String, String> params) throws Exception {

        StatusType status = paymentService.handleReturn(params);

        return ResponseEntity.ok(Map.of("status", status));
    }
}
