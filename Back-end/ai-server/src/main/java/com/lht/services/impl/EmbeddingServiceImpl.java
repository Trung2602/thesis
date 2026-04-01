package com.lht.services.impl;

import com.lht.services.EmbeddingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EmbeddingServiceImpl implements EmbeddingService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public float[] createEmbedding(String text) {
        String modelName = "gemini-embedding-001";
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":embedContent?key=" + apiKey;

        Map<String, Object> request =
                Map.of("model", "models/" + modelName, "content", Map.of("parts", List.of(Map.of("text", text)))
                );

        Map response = restTemplate.postForObject(url, request, Map.class);
        try {
            Map embedding = (Map) response.get("embedding");
            List<Double> values = (List<Double>) embedding.get("values");

            float[] arr = new float[values.size()];
            for (int i = 0; i < values.size(); i++) arr[i] = values.get(i).floatValue();
            return arr;
        } catch (Exception e) {
            throw new RuntimeException("Embedding failed: " + response);
        }
    }
}
