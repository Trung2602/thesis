package com.lht.controllers.api;

import com.lht.dto.CustomerDTO;
import com.lht.dto.CustomerRequestDTO;
import com.lht.dto.OtpRequest;
import com.lht.dto.VerifyCustomerDTO;
import com.lht.services.AccountService;
import com.lht.services.CustomerService;
import com.lht.services.MailService;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/customer")
@RequiredArgsConstructor
public class ApiCustomerController {


}
