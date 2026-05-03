class AppConfig {
  static const bool isProduction = false;
  static const String prodHost  = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com/api/v1/user";
  static const String localHost = "http://192.168.1.5";

  static const String aiPort = "8082";
  static const String gymPort = "8080";
  static const String userPort = "8081";

  static String buildUrl(String service) {
    if (isProduction) {
      return prodHost + "/api/v1/" + service;
    } else {
      String port;
      if (service == "ai") port = aiPort;
      else if (service == "gym") port = gymPort;
      else port = userPort;

      return localHost + ":" + port + "/api/v1/" + service;
    }
  }
}