package com.lht.builder;

import com.lht.dto.CustomerDTO;
import com.lht.dto.RAGContext;

import java.time.LocalDate;
import java.time.Period;
import java.util.stream.Collectors;

public class PromptBuilder {

//    public static String build(CustomerDTO user, RAGContext ctx, String question) {
//
//        String foodContext = ctx.getFoods().stream()
//                .map(f -> f.getName() + " (" + f.getCalories100g() + " kcal)")
//                .collect(Collectors.joining("\n"));
//
//        String exerciseContext = ctx.getExercises().stream()
//                .map(e -> e.getName() + ": " + String.join("; ", e.getInstructions()))
//                .collect(Collectors.joining("\n"));
//
//        String chatHistoryContext = "";
//        if (ctx.getRecentChats() != null && !ctx.getRecentChats().isEmpty()) {
//            chatHistoryContext = ctx.getRecentChats().stream()
//                    .map(c -> "Người dùng: " + c.getMessage() + "\nTrợ lý: " + c.getAiReply())
//                    .collect(Collectors.joining("\n"));
//        }
//
//        double weight = user.getWeight().doubleValue(); // kg
//        double height = user.getHeight().doubleValue(); // cm
//        int age = Period.between(user.getBirthday(), LocalDate.now()).getYears();
//
//        double BMR;
//        if ("male".equalsIgnoreCase(user.getGender())) {
//            BMR = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
//        } else if ("female".equalsIgnoreCase(user.getGender())) {
//            BMR = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
//        } else {
//            BMR = 1500;
//        }
//        double TDEE_coefficient = 1.375;
//        // ít vận động: 1.2
//        // tập nhẹ: 1.375
//        // tập vừa: 1.55
//        // tập nặng: 1.725
//
//        double calories = BMR * TDEE_coefficient;
//        double bmi = weight / Math.pow(height / 100.0, 2);
//
//        String historySection = chatHistoryContext.isBlank() ? "" : """
//                LỊCH SỬ HỘI THOẠI GẦN ĐÂY (dùng để hiểu ngữ cảnh, KHÔNG lặp lại):
//                %s
//
//                """.formatted(chatHistoryContext);
//
//        return """
//                Bạn là huấn luyện viên gym và chuyên gia dinh dưỡng.
//
//                Người dùng hỏi: %s
//                BMI: %.2f
//                Daily Calories Target: %.2f kcal
//
//                AVAILABLE FOODS (name (calories_per_100g kcal)):
//                %s
//
//                AVAILABLE EXERCISES (name):
//                %s
//
//                NHIỆM VỤ:
//                Tạo kế hoạch tập luyện và ăn uống trong 1 ngày.
//
//                QUY TẮC QUAN TRỌNG:
//                1. Chỉ sử dụng thực phẩm trong danh sách AVAILABLE FOODS
//                2. Chỉ sử dụng bài tập trong AVAILABLE EXERCISES
//                3. Không được tạo thực phẩm hoặc bài tập mới
//                4. KHÔNG hiển thị UUID trong kết quả
//                5. Mỗi bữa chỉ 1 dòng (Buổi sáng/Buổi trưa/Buổi tối)
//                6. Mỗi bữa ăn có thể nhiều món
//                7. Phải ghi số gram cho mỗi món
//                8. Trả lời theo ngôn ngữ tiếng người dùng hỏi.
//                9. Nội dung phải giữ nguyên ý nghĩa nhưng viết lại tự nhiên bằng tiếng Việt.
//
//                FORMAT BẮT BUỘC:
//
//                Chỉ số BMI (Chỉ số khối cơ thể) hiện tại của bạn: %.2f
//                Lượng calo cần thiết mỗi ngày: %.2f
//
//                ===Chế độ dinh dưỡng của bạn cho một ngày:
//
//                - Buổi sáng:
//                =>> Món ăn - xxx g - Lượng calo : xxx
//
//                - Buổi trưa:
//                =>> Món ăn - xxx g - Lượng calo : xxx
//
//                - Buổi tối:
//                =>> Món ăn - xxx g - Lượng calo : xxx
//
//                Kế hoạch tập luyện của bạn cho một ngày:
//
//                - Bài tập: Tên
//                + Sets: xxx
//                + Reps: xxx lần Hoặc Thời lượng: xxx (phút hoặc giây)
//                ==> Hướng dẫn:
//                Bước 1: ...
//                Bước 2: ...
//                Bước 3: ...
//                -------
//                - Bài tập: Tên
//                + Sets: xxx
//                + Reps: xxx lần Hoặc Thời lượng: xxx (phút hoặc giây)
//                ==> Hướng dẫn:
//                Bước 1: ...
//                Bước 2: ...
//                Bước 3: ...
//
//                “Hãy nhớ rằng, mỗi bữa ăn là một bước tiến, và mỗi buổi tập luyện là một cơ hội để giúp cơ thể bạn khỏe mạnh hơn.
//                Hãy kiên trì hôm nay, và ngày mai bạn sẽ thấy kết quả tuyệt vời. Bạn đang làm rất tốt – đừng bỏ cuộc!”
//
//                Chỉ trả về kế hoạch theo format trên.
//                Không giải thích thêm.
//                """.formatted(question, bmi, calories, foodContext, exerciseContext, bmi, calories);
//    }
    public static String build(CustomerDTO user, RAGContext ctx, String question) {

        // --- Build RAG context ---
        String foodList = ctx.getFoods().isEmpty() ? "" :
                ctx.getFoods().stream()
                        .map(f -> "  - " + f.getName() + " (" + f.getCalories100g() + " kcal/100g)")
                        .collect(Collectors.joining("\n"));

        String exerciseList = ctx.getExercises().isEmpty() ? "" :
                ctx.getExercises().stream()
                        .map(e -> "  - " + e.getName() + ": " + String.join("; ", e.getInstructions()))
                        .collect(Collectors.joining("\n"));

        String chatHistoryContext = (ctx.getRecentChats() == null || ctx.getRecentChats().isEmpty()) ? "" :
                ctx.getRecentChats().stream()
                        .map(c -> "Người dùng: " + c.getMessage() + "\nTrợ lý: " + c.getAiReply())
                        .collect(Collectors.joining("\n\n"));

        // --- Tính chỉ số sức khỏe ---
        double weight = user.getWeight().doubleValue();
        double height = user.getHeight().doubleValue();
        int age = Period.between(user.getBirthday(), LocalDate.now()).getYears();

        double BMR;
        if ("male".equalsIgnoreCase(user.getGender())) {
            BMR = 88.36 + (13.4 * weight) + (4.8 * height) - (5.7 * age);
        } else if ("female".equalsIgnoreCase(user.getGender())) {
            BMR = 447.6 + (9.2 * weight) + (3.1 * height) - (4.3 * age);
        } else {
            BMR = 1500;
        }

        double TDEE = BMR * 1.375;
        double bmi = weight / Math.pow(height / 100.0, 2);

        String historySection = chatHistoryContext.isBlank() ? "" : """
                    === LỊCH SỬ HỘI THOẠI GẦN ĐÂY ===
                    %s
                    
                    """.formatted(chatHistoryContext);

        // --- Xác định có dữ liệu không để cảnh báo AI ---
        String foodSection;
        if (ctx.getFoods().isEmpty()) {
            foodSection = """
                        === DANH SÁCH THỰC PHẨM TỪ DATABASE ===
                        [KHÔNG CÓ DỮ LIỆU - TUYỆT ĐỐI KHÔNG được đề xuất bất kỳ thực phẩm nào]
                        """;
        } else {
            foodSection = """
                        === DANH SÁCH THỰC PHẨM TỪ DATABASE ===
                        (Đây là danh sách DUY NHẤT được phép dùng. KHÔNG được thêm bất kỳ thực phẩm nào khác.)
                        %s
                        """.formatted(foodList);
        }

        String exerciseSection;
        if (ctx.getExercises().isEmpty()) {
            exerciseSection = """
                        === DANH SÁCH BÀI TẬP TỪ DATABASE ===
                        [KHÔNG CÓ DỮ LIỆU - TUYỆT ĐỐI KHÔNG được đề xuất bất kỳ bài tập nào]
                        """;
        } else {
            exerciseSection = """
                        === DANH SÁCH BÀI TẬP TỪ DATABASE ===
                        (Đây là danh sách DUY NHẤT được phép dùng. KHÔNG được thêm bất kỳ bài tập nào khác.)
                        %s
                        """.formatted(exerciseList);
        }

        return """
                    Bạn là trợ lý AI chuyên về gym, thể hình và dinh dưỡng - thân thiện như một HLV cá nhân.
                    
                    === THÔNG TIN NGƯỜI DÙNG ===
                    - Cân nặng: %.1f kg | Chiều cao: %.1f cm | Tuổi: %d | Giới tính: %s
                    - BMI hiện tại: %.2f
                    - Nhu cầu calo mỗi ngày: %.0f kcal
                    
                    %s
                    %s
                    %s\
                    === CÂU HỎI ===
                    %s
                    
                    === QUY TẮC BẮT BUỘC (VI PHẠM LÀ SAI) ===
                    [QUY TẮC 1 - TUYỆT ĐỐI] Khi đề xuất thực phẩm: CHỈ được dùng đúng tên trong "DANH SÁCH THỰC PHẨM TỪ DATABASE".
                    Không được thêm, bịa, suy luận, hoặc dùng thực phẩm tương tự không có trong danh sách.
                    Nếu danh sách trống thì nói "Hiện không có dữ liệu thực phẩm phù hợp trong hệ thống."
                    
                    [QUY TẮC 2 - TUYỆT ĐỐI] Khi đề xuất bài tập: CHỈ được dùng đúng tên trong "DANH SÁCH BÀI TẬP TỪ DATABASE".
                    Không được thêm, bịa, suy luận, hoặc dùng bài tập tương tự không có trong danh sách.
                    Nếu danh sách trống thì nói "Hiện không có dữ liệu bài tập phù hợp trong hệ thống."
                    
                    [QUY TẮC 3] Với câu hỏi thông thường (chào hỏi, hỏi kiến thức gym/dinh dưỡng, hỏi về chỉ số cá nhân):
                    Trả lời tự nhiên, thân thiện — KHÔNG cần tạo kế hoạch, KHÔNG cần dùng danh sách trên.
                    
                    [QUY TẮC 4] Dùng lịch sử hội thoại để trả lời nhất quán, KHÔNG lặp lại nội dung cũ.
                    
                    [QUY TẮC 5] Trả lời bằng ngôn ngữ người dùng đang dùng. Giọng điệu tích cực, khuyến khích.
                    
                    [QUY TẮC 6] KHÔNG hiển thị UUID trong bất kỳ trường hợp nào.
                    """.formatted(
                weight, height, age, user.getGender(),
                bmi, TDEE,
                foodSection,
                exerciseSection,
                historySection,
                question
        );
    }
}