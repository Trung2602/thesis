package com.lht.builder;

import com.lht.dto.CustomerDTO;
import com.lht.dto.RAGContext;

import java.time.LocalDate;
import java.time.Period;
import java.util.stream.Collectors;

public class PromptBuilder {

    public static String build(CustomerDTO user, RAGContext ctx, String question) {

        String foodContext = ctx.getFoods().stream()
                .map(f -> f.getName() + " (" + f.getCalories100g() + " kcal)")
                .collect(Collectors.joining("\n"));

        String exerciseContext = ctx.getExercises().stream()
                .map(e -> e.getName() + ": " + String.join("; ", e.getInstructions()))
                .collect(Collectors.joining("\n"));

        double weight = user.getWeight().doubleValue(); // kg
        double height = user.getHeight().doubleValue(); // cm
        int age = Period.between(user.getBirthday(), LocalDate.now()).getYears();

        double BMR;
        if ("male".equalsIgnoreCase(user.getGender())) {
            BMR = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
        } else if ("female".equalsIgnoreCase(user.getGender())) {
            BMR = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
        } else {
            BMR = 1500;
        }
        double TDEE_coefficient = 1.375;
        // ít vận động: 1.2
        // tập nhẹ: 1.375
        // tập vừa: 1.55
        // tập nặng: 1.725

        double calories = BMR * TDEE_coefficient;
        double bmi = weight / Math.pow(height / 100.0, 2);

        return """
                Bạn là huấn luyện viên gym và chuyên gia dinh dưỡng.
                
                Người dùng hỏi: %s
                BMI: %.2f
                Daily Calories Target: %.2f kcal
                
                AVAILABLE FOODS (name (calories_per_100g kcal)):
                %s
                
                AVAILABLE EXERCISES (name):
                %s
                
                NHIỆM VỤ:
                Tạo kế hoạch tập luyện và ăn uống trong 1 ngày.
                
                QUY TẮC QUAN TRỌNG:
                1. Chỉ sử dụng thực phẩm trong danh sách AVAILABLE FOODS
                2. Chỉ sử dụng bài tập trong AVAILABLE EXERCISES
                3. Không được tạo thực phẩm hoặc bài tập mới
                4. KHÔNG hiển thị UUID trong kết quả
                5. Mỗi bữa chỉ 1 dòng (Breakfast/Lunch/Dinner)
                6. Mỗi bữa ăn có thể nhiều món
                7. Phải ghi số gram cho mỗi món
                
                FORMAT BẮT BUỘC:
               
                Your current BMI (Body Mass Index): %.2f
                Calories needed per day: %.2f
                
                Your diet for tomorrow:
                
                - Breakfast:
                =>> Food name - xxx g
                
                - Lunch:
                =>> Food name - xxx g
                
                - Dinner:
                =>> Food name - xxx g
                
                Your workout plan for tomorrow:
                
                - Exercise: Exercise name
                + Sets: number
                + Reps: number OR Duration: minutes
                Instructions: step1; step2; step3
                -------
                - Exercise: Exercise name
                + Sets: number
                + Reps: number OR Duration: minutes
                Instructions: step1; step2; step3
                
                “Remember, every meal is a step forward, and every workout is a chance to make your body stronger.
                Stick with it today, and tomorrow you’ll see amazing results. You’re doing great – don’t give up!”
                
                Chỉ trả về kế hoạch theo format trên.
                Không giải thích thêm.
                """.formatted(question, bmi, calories, foodContext, exerciseContext, bmi, calories);
    }
}