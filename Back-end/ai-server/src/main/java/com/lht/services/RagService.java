package com.lht.services;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;

import java.util.List;
import java.util.UUID;

public interface RagService {
    String askFitnessAI(UUID userUuid, String question);
}
