package com.lht.services.impl;

import com.lht.services.EmbeddingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class EmbeddingServiceImpl implements EmbeddingService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private static final int MAX_RETRIES = 5;

    @Override
    public float[] createEmbedding(String text) {
        String modelName = "gemini-embedding-001";
        String url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":embedContent?key=" + apiKey;

        Map<String, Object> request = Map.of(
                "model", "models/" + modelName,
                "content", Map.of("parts", List.of(Map.of("text", text))),
                "outputDimensionality", 768
        );

        int attempt = 0;
        while (true) {
            try {
                Map response = restTemplate.postForObject(url, request, Map.class);
                Map embedding = (Map) response.get("embedding");
                List<Double> values = (List<Double>) embedding.get("values");
                float[] arr = new float[values.size()];
                for (int i = 0; i < values.size(); i++) arr[i] = values.get(i).floatValue();
                return arr;
            } catch (HttpClientErrorException e) {
                if (e.getStatusCode().value() == 429 && attempt < MAX_RETRIES) {
                    attempt++;
                    long waitMs = extractRetryDelay(e.getResponseBodyAsString());
                    try { Thread.sleep(waitMs); }
                    catch (InterruptedException ie) { Thread.currentThread().interrupt(); throw new RuntimeException(ie); }
                } else {
                    throw new RuntimeException("Embedding failed after " + attempt + " retries", e);
                }
            }
        }
    }

    private long extractRetryDelay(String responseBody) {
        try {
            Matcher m = Pattern.compile("retry[^\"]*\"(\\d+)s").matcher(responseBody);
            if (m.find()) return (Long.parseLong(m.group(1)) + 2) * 1000L;
        } catch (Exception ignored) {}
        return 60_000L;
    }
}
