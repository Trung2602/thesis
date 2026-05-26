package com.lht.services;

import com.lht.client.InternalUserClient;
import com.lht.dto.BodyLogDTO;
import com.lht.dto.GoalDTO;
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
    private final InternalUserClient userClient;

    public RAGContext research(float[] queryVector, UUID uuid) {
        List<Food> foods = foodService.findTopSimilar(queryVector, 5);
        List<Exercise> exercises = exerciseService.findTopSimilar(queryVector, 5);
        List<ChatHistory> recentChats = chatHistoryService.getRecentChats(uuid, 5);
        List<BodyLogDTO> logs = userClient.getRecentHistory(uuid, 5);
        GoalDTO goal = userClient.getGoalByCustomerUuid(uuid);
        Collections.reverse(recentChats);
        return new RAGContext(foods, exercises, recentChats, logs, goal);
    }
}
