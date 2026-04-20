class AiServerApi {
  // static const String baseUrl = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com/api/v1/ai";
  // static const String wsBaseUrl = "wss://fitness-alb-1289679733.us-east-1.elb.amazonaws.com";
  static const String baseUrl = "http://192.168.1.7:8082/api/v1/ai";
  static const String wsBaseUrl = "http://192.168.1.7:8082";

  // CHAT
  static const String getChatHistory = "$baseUrl/chat/history";

  // WEBSOCKET
  static const String wsEndpoint = "$wsBaseUrl/ws-chat";
  static const String aiTopic = "/topic/ai";
  static const String aiSend = "/app/api/v1/ai/ai.ask";
}