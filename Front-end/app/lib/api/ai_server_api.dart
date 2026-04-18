class AiServerApi {
  static const String baseUrl = "http://192.168.1.2:8082/api/v1/ai";
  static const String wsBaseUrl = "http://192.168.1.2:8082";

  // CHAT
  static const String getChatHistory = "$baseUrl/chat/history";

  // WEBSOCKET
  static const String wsEndpoint = "$wsBaseUrl/ws-chat/websocket/";
  static const String aiTopic = "/topic/ai";
  static const String aiSend = "/app/api/v1/ai.ask";
}