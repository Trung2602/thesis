package com.lht.services.impl;

import com.lht.services.GeminiService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GeminiServiceImpl implements GeminiService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private static final int MAX_RETRIES = 5;

    @Override
    public String generate(String prompt) {
        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;
        Map<String, Object> request = Map.of(
                "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt))))
        );

        int attempt = 0;
        while (true) {
            try {
                Map response = restTemplate.postForObject(url, request, Map.class);
                List candidates = (List) response.get("candidates");
                Map first = (Map) candidates.get(0);
                Map content = (Map) first.get("content");
                List parts = (List) content.get("parts");
                Map part = (Map) parts.get(0);
                return (String) part.get("text");
            } catch (HttpServerErrorException e) {
                if (e.getStatusCode().value() == 503 && attempt < MAX_RETRIES) {
                    attempt++;
                    long wait = Math.min((long) Math.pow(2, attempt) * 1000, 30_000L);
                    System.out.println("Gemini generate 503, retry " + attempt + " sau " + wait + "ms");
                    try {
                        Thread.sleep(wait);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new RuntimeException(ie);
                    }
                } else {
                    throw e;
                }
            } catch (Exception e) {
                throw new RuntimeException("Gemini generate failed: " + e.getMessage(), e);
            }
        }
    }
}
