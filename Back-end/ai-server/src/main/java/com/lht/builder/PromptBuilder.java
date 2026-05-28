package com.lht.builder;

import com.lht.dto.BodyLogDTO;
import com.lht.dto.CustomerDTO;
import com.lht.dto.GoalDTO;
import com.lht.dto.RAGContext;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

public class PromptBuilder {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    public static String build(CustomerDTO user, RAGContext ctx, String question) {

        // ===== FOOD & EXERCISE =====
        String foodList = ctx.getFoods().isEmpty() ? "" :
                ctx.getFoods().stream()
                        .map(f -> "  - " + f.getName() + " (" + f.getCalories100g() + " kcal/100g)")
                        .collect(Collectors.joining("\n"));

        String exerciseList = ctx.getExercises().isEmpty() ? "" :
                ctx.getExercises().stream()
                        .map(e -> "  - " + e.getName() + ": " + String.join("; ", e.getInstructions()))
                        .collect(Collectors.joining("\n"));

        // ===== CHAT HISTORY =====
        String chatHistoryContext = (ctx.getRecentChats() == null || ctx.getRecentChats().isEmpty()) ? "" :
                ctx.getRecentChats().stream()
                        .map(c -> "Người dùng: " + c.getMessage() + "\nTrợ lý: " + c.getAiReply())
                        .collect(Collectors.joining("\n\n"));

        // ===== BODY LOGS =====
        String bodyLogContext = buildBodyLogSection(ctx.getLogs());

        // ===== GOAL =====
        String goalContext = buildGoalSection(ctx.getGoal());

        // ===== BMR / TDEE / BMI =====
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
        // ít vận động: 1.2
        // tập nhẹ: 1.375
        // tập vừa: 1.55
        // tập nặng: 1.725
        double bmi = weight / Math.pow(height / 100.0, 2);

        String historySection = chatHistoryContext.isBlank() ? "" : """
                    === LỊCH SỬ HỘI THOẠI GẦN ĐÂY ===
                    %s
                    
                    """.formatted(chatHistoryContext);

        String foodSection = ctx.getFoods().isEmpty()
                ? """
                    === DANH SÁCH THỰC PHẨM TỪ DATABASE ===
                    [KHÔNG CÓ DỮ LIỆU - TUYỆT ĐỐI KHÔNG được đề xuất bất kỳ thực phẩm nào]
                    """
                : """
                    === DANH SÁCH THỰC PHẨM TỪ DATABASE ===
                    (Đây là danh sách DUY NHẤT được phép dùng. KHÔNG được thêm bất kỳ thực phẩm nào khác.)
                    %s
                    """.formatted(foodList);

        String exerciseSection = ctx.getExercises().isEmpty()
                ? """
                    === DANH SÁCH BÀI TẬP TỪ DATABASE ===
                    [KHÔNG CÓ DỮ LIỆU - TUYỆT ĐỐI KHÔNG được đề xuất bất kỳ bài tập nào]
                    """
                : """
                    === DANH SÁCH BÀI TẬP TỪ DATABASE ===
                    (Đây là danh sách DUY NHẤT được phép dùng. KHÔNG được thêm bất kỳ bài tập nào khác.)
                    %s
                    """.formatted(exerciseList);

        return """
                    Bạn là trợ lý AI chuyên về gym, thể hình và dinh dưỡng - thân thiện như một HLV cá nhân.
                    
                    === THÔNG TIN NGƯỜI DÙNG ===
                    - Cân nặng hiện tại: %.1f kg | Chiều cao: %.1f cm | Tuổi: %d | Giới tính: %s
                    - BMI hiện tại: %.2f
                    - Nhu cầu calo mỗi ngày (TDEE): %.0f kcal
                    
                    %s\
                    %s\
                    %s\
                    %s\
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
                    
                    [QUY TẮC 7] Khi phân tích tiến trình: dùng dữ liệu "LỊCH SỬ CHỈ SỐ CƠ THỂ" và "MỤC TIÊU" để đưa ra
                    nhận xét cụ thể, có số liệu. Nếu không có dữ liệu body log, đừng đề cập đến tiến trình.
                    
                    [QUY TẮC 8] Nếu có mục tiêu (GOAL), hãy điều chỉnh lời khuyên về calo, thực phẩm và bài tập
                    sao cho phù hợp với mục tiêu đó (giảm cân / tăng cơ / duy trì / giảm mỡ).
                    """.formatted(
                weight, height, age, user.getGender(),
                bmi, TDEE,
                goalContext,
                bodyLogContext,
                foodSection,
                exerciseSection,
                historySection,
                question
        );
    }

    private static String buildBodyLogSection(List<BodyLogDTO> logs) {
        if (logs == null || logs.isEmpty()) {
            return "";
        }

        String rows = logs.stream().map(log -> {
            StringBuilder sb = new StringBuilder("  - ");
//            sb.append(log.getLoggedAt() != null ? log.getLoggedAt().format(DATETIME_FMT) : "N/A");
            if (log.getWeight() != null)
                sb.append(" | Cân nặng: ").append(log.getWeight()).append(" kg");
            if (log.getHeight() != null)
                sb.append(" | Chiều cao: ").append(log.getHeight()).append(" cm");
            if (log.getBodyFatPercent() != null)
                sb.append(" | Mỡ cơ thể: ").append(log.getBodyFatPercent()).append("%");
            if (log.getMuscleMass() != null)
                sb.append(" | Cơ bắp: ").append(log.getMuscleMass()).append(" kg");
            if (log.getNote() != null && !log.getNote().isBlank())
                sb.append(" | Ghi chú: ").append(log.getNote());
            return sb.toString();
        }).collect(Collectors.joining("\n"));

        return """
                    === LỊCH SỬ CHỈ SỐ CƠ THỂ (GẦN NHẤT) ===
                    (Dùng để phân tích tiến trình và đưa ra lời khuyên cá nhân hoá)
                    %s
                    
                    """.formatted(rows);
    }

    private static String buildGoalSection(GoalDTO goal) {
        if (goal == null) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("=== MỤC TIÊU CỦA NGƯỜI DÙNG ===\n");

        if (goal.getGoalType() != null)
            sb.append("  - Loại mục tiêu: ").append(translateGoalType(goal.getGoalType())).append("\n");
        if (goal.getTargetWeight() != null)
            sb.append("  - Cân nặng mục tiêu: ").append(goal.getTargetWeight()).append(" kg\n");
        if (goal.getTargetBodyFat() != null)
            sb.append("  - Mỡ cơ thể mục tiêu: ").append(goal.getTargetBodyFat()).append("%\n");
        if (goal.getDeadline() != null)
            sb.append("  - Thời hạn: ").append(goal.getDeadline().format(DATE_FMT)).append("\n");
        if (goal.getIsAchieved() != null)
            sb.append("  - Trạng thái: ").append(goal.getIsAchieved() ? "Đã đạt được ✓" : "Đang thực hiện").append("\n");

        sb.append("\n");
        return sb.toString();
    }

    private static String translateGoalType(String goalType) {
        return switch (goalType.toLowerCase()) {
            case "weight_loss"    -> "Giảm cân";
            case "muscle_gain"    -> "Tăng cơ";
            case "maintenance"    -> "Duy trì cân nặng";
            case "fat_loss"       -> "Giảm mỡ";
            case "body_recomp"    -> "Thay đổi thành phần cơ thể";
            case "endurance"      -> "Tăng sức bền";
            default               -> goalType;
        };
    }
}