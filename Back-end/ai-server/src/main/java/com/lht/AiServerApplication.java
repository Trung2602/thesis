package com.lht;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@EnableFeignClients(basePackages = "com.lht.client")
@SpringBootApplication
public class AiServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(AiServerApplication.class, args);
	}

}
