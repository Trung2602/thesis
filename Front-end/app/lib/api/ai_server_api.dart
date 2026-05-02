import '../config/app_config.dart';

class AiServerApi {
  static final String baseUrl = AppConfig.buildUrl("ai");
  static final String wsBaseUrl = AppConfig.isProduction
      ? AppConfig.prodHost : AppConfig.localHost + ":" + AppConfig.aiPort;

  // ===== EXERCISE =====
  static final String getExercises = "$baseUrl/exercises";
  static final String postExercise = "$baseUrl/exercises";
  static final String patchExercise = "$baseUrl/exercises";
  static String deleteExercise(String uuid) => "$baseUrl/exercises/$uuid";
  static String getExerciseById(String uuid) => "$baseUrl/exercises/$uuid";

// ===== FOOD =====
  static final String getFoods = "$baseUrl/foods";
  static final String postFood = "$baseUrl/foods";
  static final String patchFood = "$baseUrl/foods";
  static String deleteFood(String uuid) => "$baseUrl/foods/$uuid";
  static String getFoodById(String uuid) => "$baseUrl/foods/$uuid";

  // CHAT
  static final String getChatHistory = "$baseUrl/chat/history";

  // WEBSOCKET
  static final String wsEndpoint = "$wsBaseUrl/ws-chat";
  static String aiTopic = "/topic/ai";
  static String aiSend = "/app/api/v1/ai/ai.ask";
}