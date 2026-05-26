package com.lht.dto;

import com.lht.pojo.ChatHistory;
import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import lombok.*;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
public class RAGContext {
    private List<Food> foods;
    private List<Exercise> exercises;
    private List<ChatHistory> recentChats;
    private List<BodyLogDTO> logs;
    private GoalDTO goal;
}