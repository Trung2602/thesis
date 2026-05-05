package com.lht.services;

import com.lht.dto.RAGContext;
import com.lht.pojo.ChatHistory;
import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final FoodService foodService;
    private final ExerciseService exerciseService;
    private final ChatHistoryService chatHistoryService;

    public RAGContext research(float[] queryVector, UUID uuid) {
        List<Food> foods = foodService.findTopSimilar(queryVector, 5);
        List<Exercise> exercises = exerciseService.findTopSimilar(queryVector, 5);
        List<ChatHistory> recentChats = chatHistoryService.getRecentChats(uuid, 5);
        Collections.reverse(recentChats);
        return new RAGContext(foods, exercises, recentChats);
    }
}
