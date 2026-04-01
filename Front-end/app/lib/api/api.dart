class Api {
  static const String baseUrlGymServer = "http://192.168.1.4:8080/api/v1";
  static const String baseUrlUserServer = "http://192.168.1.4:8081/api/v1";
  static const String baseUrlAiServer = "http://192.168.1.4:8082/api/v1";
  //static const String baseUrl = "https://4a9723599745.ngrok-free.app/api";

  static const String login = "$baseUrlUserServer/auth/login";
  static const String register = "$baseUrlUserServer/auth/register";
  static const String otpURL = "$baseUrlUserServer/auth/verify/otp";
  static const String me = "$baseUrlUserServer/account/me";
  static const String accountUpdate = "$baseUrlUserServer/account/me"; // PATCH
  static const String verifyPassword = "$baseUrlUserServer/account/me/password/verify";
  static const String changePassword = "$baseUrlUserServer/account/me/password";
  // ================== FACILITY ==================
  static const String getFacilities = "$baseUrlGymServer/facilities";
  static String getFacilityByUuid(String uuid) => "$baseUrlGymServer/facilities/$uuid";
  static const String getFacilitiesFilter = "$baseUrlGymServer/facilities/filter";
  // ================== PLAN ==================
  static const String getPlans = "$baseUrlGymServer/plans";
  static const String getPlansFilter = "$baseUrlGymServer/plans/filter";
  static String getPlanByUuid(String uuid) => "$baseUrlGymServer/plans/$uuid";
  // ================== SHIFT ==================
  static const String getShifts = "$baseUrlGymServer/shifts";
  static const String getShiftsFilter = "$baseUrlGymServer/shifts/filter";
  static String getShiftByUuid(String uuid) => "$baseUrlGymServer/shifts/$uuid";

  // ==================///// CUSTOMER \\\\\==================
  // ================== CUSTOMER SCHEDULE ==================
  static const String getCustomerSchedulesAll = "$baseUrlGymServer/customer-schedules";
  static const String getCustomerSchedulesFilter = "$baseUrlGymServer/customer-schedules/filter";
  static String getCustomerScheduleByUuid(String uuid) => "$baseUrlGymServer/customer-schedules/$uuid";
  static const String postCustomerSchedule = "$baseUrlGymServer/customer-schedules";
  static String deleteCustomerSchedule(String uuid) => "$baseUrlGymServer/customer-schedules/$uuid";
  //================== PAY CUSTOMER ==================
  static String getPayCustomerByUuid(String uuid) => "$baseUrlGymServer/pay-customers/$uuid";
  static const String getPayCustomersFilter = "$baseUrlGymServer/pay-customers/filter";
  static const String getPayCustomersAll = "$baseUrlGymServer/pay-customers";

  // ==================///// STAFF \\\\\==================
  // ================== STAFF =================
  static String getWorkingStaff = "$baseUrlUserServer/staffs";
  // ================== STAFF SCHEDULE ==================
  static const String getStaffSchedules = "$baseUrlGymServer/staff-schedules";
  static const String getStaffSchedulesFilter = "$baseUrlGymServer/staff-schedules/filter";
  static String getStaffScheduleByUuid(String uuid) => "$baseUrlGymServer/staff-schedules/$uuid";
  static const String postStaffSchedule = "$baseUrlGymServer/staff-schedules";
  static String deleteStaffSchedule(String uuid) => "$baseUrlGymServer/staff-schedules/$uuid";
  // ================== STAFF DAY OFF ==================
  static const String getStaffDayOffs = "$baseUrlGymServer/day-offs";
  static String getStaffDayOffById(String uuid) => "$baseUrlGymServer/day-offs/$uuid";
  static const String postStaffDayOff = "$baseUrlGymServer/day-offs";
  static String deleteStaffDayOff(String uuid) => "$baseUrlGymServer/day-offs/$uuid";
  // ================== SALARY ==================
  static const String getSalaries = "$baseUrlGymServer/salaries";
  static const String getSalariesFilter = "$baseUrlGymServer/salaries/filter";
  static String getSalaryById(String uuid) => "$baseUrlGymServer/salaries/$uuid";

  // Payment
  static const String createPayment = "$baseUrlGymServer/payment/create";

  // AI
  static const String askAI = "$baseUrlAiServer/ai/fitness";
  static const String getChatHistory = "$baseUrlAiServer/chat/history";
}

//dart pub global activate flutterfire_cli
//flutterfire configure --project=gym-chat-371b5

