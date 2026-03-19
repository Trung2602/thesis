package com.lht.services.impl;

import com.lht.services.EmbeddingService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class EmbeddingServiceImpl implements EmbeddingService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public String createEmbedding(String text) {
        String modelName = "gemini-embedding-001";
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":embedContent?key=" + apiKey;
        Map<String, Object> request =
                Map.of("model", "models/" + modelName, "content", Map.of("parts", List.of(Map.of("text", text)))
        );
        Map response = restTemplate.postForObject(url, request, Map.class);
        try {
            Map embedding = (Map) response.get("embedding");
            List<Double> values = (List<Double>) embedding.get("values");

            return values.toString();
        } catch (Exception e) {
            return response.toString();
        }
    }
}