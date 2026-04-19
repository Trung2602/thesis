class AiServerApi {
  static const String baseUrl = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com/api/v1/ai";
  static const String wsBaseUrl = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com";

  // CHAT
  static const String getChatHistory = "$baseUrl/chat/history";

  // WEBSOCKET
  static const String wsEndpoint = "$wsBaseUrl/ws-chat/websocket/";
  static const String aiTopic = "/topic/ai";
  static const String aiSend = "/app/api/v1/ai.ask";
}