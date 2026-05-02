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
                5. Mỗi bữa chỉ 1 dòng (Buổi sáng/Buổi trưa/Buổi tối)
                6. Mỗi bữa ăn có thể nhiều món
                7. Phải ghi số gram cho mỗi món
                8. Trả lời theo ngôn ngữ tiếng người dùng hỏi.
                9. Nội dung phải giữ nguyên ý nghĩa nhưng viết lại tự nhiên bằng tiếng Việt.
                
                FORMAT BẮT BUỘC:
               
                Chỉ số BMI (Chỉ số khối cơ thể) hiện tại của bạn: %.2f
                Lượng calo cần thiết mỗi ngày: %.2f
                
                ===Chế độ dinh dưỡng của bạn cho một ngày:
                
                - Buổi sáng:
                =>> Món ăn - xxx g - Lượng calo : xxx
                
                - Buổi trưa:
                =>> Món ăn - xxx g - Lượng calo : xxx
                
                - Buổi tối:
                =>> Món ăn - xxx g - Lượng calo : xxx
                
                Kế hoạch tập luyện của bạn cho một ngày:
               
                - Bài tập: Tên
                + Sets: xxx 
                + Reps: xxx lần Hoặc Thời lượng: xxx (phút hoặc giây)
                Hướng dẫn: Bước 1: ...; Bước 2: ...; Bước 3: ...
                -------
                - Bài tập: Tên
                + Sets: xxx
                + Reps: xxx lần Hoặc Thời lượng: xxx (phút hoặc giây)
                Hướng dẫn: Bước 1: ...; Bước 2: ...; Bước 3: ...
                
                “Hãy nhớ rằng, mỗi bữa ăn là một bước tiến, và mỗi buổi tập luyện là một cơ hội để giúp cơ thể bạn khỏe mạnh hơn.
                Hãy kiên trì hôm nay, và ngày mai bạn sẽ thấy kết quả tuyệt vời. Bạn đang làm rất tốt – đừng bỏ cuộc!”
                
                Chỉ trả về kế hoạch theo format trên.
                Không giải thích thêm.
                """.formatted(question, bmi, calories, foodContext, exerciseContext, bmi, calories);
    }
}