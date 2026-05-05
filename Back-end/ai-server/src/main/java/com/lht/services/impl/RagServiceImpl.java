package com.lht.services.impl;

import com.lht.builder.PromptBuilder;
import com.lht.client.InternalUserClient;
import com.lht.dto.RAGContext;
import com.lht.services.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RagServiceImpl implements RagService {

    private final EmbeddingService embeddingService;
    private final SearchService searchService;
    private final GeminiService geminiService;
    private final InternalUserClient userClient;

    @Override
    public String askFitnessAI(UUID uuid, String question) {
        float[] vector = embeddingService.createEmbedding(question);
        RAGContext ctx = searchService.research(vector, uuid);
        String prompt = PromptBuilder.build(userClient.getCustomer(uuid), ctx, question);
        return geminiService.generate(prompt);
    }
}
