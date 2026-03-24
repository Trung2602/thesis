package com.lht.services.impl;

import com.lht.pojo.Exercise;
import com.lht.pojo.Food;
import com.lht.services.GeminiService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GeminiServiceImpl implements GeminiService {

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public String generateFitnessPlan(double bmi, double calories, List<Food> foods, List<Exercise> exercises, String question) {
        String foodContext = foods.stream().map(f -> f.getUuid() + "|" + f.getName() + "|" + f.getCalories100g())
                .collect(Collectors.joining("\n"));
        String exerciseContext = exercises.stream().map(e -> e.getUuid() + "|" + e.getName() + "|" + String.join("; ", e.getInstructions()))
                .collect(Collectors.joining("\n"));

        String prompt = """
Bạn là huấn luyện viên gym và chuyên gia dinh dưỡng.

Người dùng hỏi:
%s

THÔNG TIN NGƯỜI DÙNG
BMI: %.2f
Daily Calories Target: %.2f kcal

AVAILABLE FOODS (uuid|name|calories_per_100g):
%s

AVAILABLE EXERCISES (uuid|name):
%s

NHIỆM VỤ:
Tạo kế hoạch tập luyện và ăn uống trong 7 ngày.

QUY TẮC QUAN TRỌNG:
1. Chỉ sử dụng thực phẩm trong danh sách AVAILABLE FOODS
2. Chỉ sử dụng bài tập trong AVAILABLE EXERCISES
3. Không được tạo thực phẩm hoặc bài tập mới
4. KHÔNG hiển thị UUID trong kết quả
5. Mỗi bữa chỉ 1 dòng (Breakfast/Lunch/Dinner)
6. Mỗi bữa ăn có thể nhiều món
7. Phải ghi số gram cho mỗi món

FORMAT BẮT BUỘC:

BMI: %.2f
Calories needed per day: %.2f

Chế độ ăn của bạn trong 1 tuần tới:

Day 1
Breakfast: Food name - xxx g
Lunch: Food name - xxx g
Dinner: Food name - xxx g

Day 2
Breakfast: Food name - xxx g
Lunch: Food name - xxx g
Dinner: Food name - xxx g

Kế hoạc tập luyện trong 1 tuần tới của bạn:

Day 1
Exercise: Exercise name
Instructions: step1; step2; step3
Sets: number
Reps: number OR Duration: minutes

Day 2
Exercise: Exercise name
Instructions: step1; step2; step3
Sets: number
Reps: number OR Duration: minutes

Chỉ trả về kế hoạch theo format trên.
Không giải thích thêm.
""".formatted(question, bmi, calories, foodContext, exerciseContext, bmi, calories);

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;
        Map<String, Object> request = Map.of("contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))));
        Map response = restTemplate.postForObject(url, request, Map.class);
        try {
            List candidates = (List) response.get("candidates");
            Map first = (Map) candidates.get(0);
            Map content = (Map) first.get("content");
            List parts = (List) content.get("parts");
            Map part = (Map) parts.get(0);

            return (String) part.get("text");
        } catch (Exception e) {
            return response.toString();
        }
    }
}
