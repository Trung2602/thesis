package com.lht.services;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;

import java.util.List;

public interface RagService {

    String askFitnessAI(
            double weight,
            double height,
            String question
    );

}
