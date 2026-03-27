class Api {
  static const String baseUrl = "http://192.168.1.10:8080/api/v1";
  //static const String baseUrl = "https://4a9723599745.ngrok-free.app/api";

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String otpURL = "$baseUrl/auth/verify/otp";
  static const String me = "$baseUrl/account/me";
  static const String accountUpdate = "$baseUrl/account/me"; // PATCH
  static const String verifyPassword = "$baseUrl/account/me/password/verify";
  static const String changePassword = "$baseUrl/account/me/password";
  // ================== FACILITY ==================
  static const String getFacilities = "$baseUrl/facilities";
  static String getFacilityByUuid(String uuid) => "$baseUrl/facilities/$uuid";
  static const String getFacilitiesFilter = "$baseUrl/facilities/filter";
  // ================== PLAN ==================
  static const String getPlans = "$baseUrl/plans";
  static const String getPlansFilter = "$baseUrl/plans/filter";
  static String getPlanByUuid(String uuid) => "$baseUrl/plans/$uuid";
  // ================== SHIFT ==================
  static const String getShifts = "$baseUrl/shifts";
  static const String getShiftsFilter = "$baseUrl/shifts/filter";
  static String getShiftByUuid(String uuid) => "$baseUrl/shifts/$uuid";

  // ==================///// CUSTOMER \\\\\==================
  // ================== CUSTOMER SCHEDULE ==================
  static const String getCustomerSchedulesAll = "$baseUrl/customer-schedules";
  static const String getCustomerSchedulesFilter = "$baseUrl/customer-schedules/filter";
  static String getCustomerScheduleByUuid(String uuid) => "$baseUrl/customer-schedules/$uuid";
  static const String postCustomerSchedule = "$baseUrl/customer-schedules";
  static String deleteCustomerSchedule(String uuid) => "$baseUrl/customer-schedules/$uuid";
  //================== PAY CUSTOMER ==================
  static String getPayCustomerByUuid(String uuid) => "$baseUrl/pay-customers/$uuid";
  static const String getPayCustomersFilter = "$baseUrl/pay-customers/filter";
  static String getPayCustomersAll(String uuid) => "$baseUrl/pay-customers/customer/$uuid";

  // ==================///// STAFF \\\\\==================
  // ================== STAFF =================
  static String getWorkingStaff({required String date, required String checkin, required String checkout,}) => "$baseUrl/staffs?date=$date&checkin=$checkin&checkout=$checkout";
  // ================== STAFF SCHEDULE ==================
  static String getStaffSchedules(String staffUuid) => "$baseUrl/staff-schedules/staff/$staffUuid";
  static const String getStaffSchedulesFilter = "$baseUrl/staff-schedules/filter";
  static String getStaffScheduleByUuid(String uuid) => "$baseUrl/staff-schedules/$uuid";
  static const String postStaffSchedule = "$baseUrl/staff-schedules";
  static String deleteStaffSchedule(String uuid) => "$baseUrl/staff-schedules/$uuid";
  // ================== STAFF DAY OFF ==================
  static const String getStaffDayOffs = "$baseUrl/day-offs";
  static String getStaffDayOffById(String uuid) => "$baseUrl/day-offs/$uuid";
  static const String postStaffDayOff = "$baseUrl/day-offs";
  static String deleteStaffDayOff(String uuid) => "$baseUrl/day-offs/$uuid";
  // ================== SALARY ==================
  static String getSalaries(String staffUuid) => "$baseUrl/salaries/staff/$staffUuid";
  static const String getSalariesFilter = "$baseUrl/salaries/filter";
  static String getSalaryById(String uuid) => "$baseUrl/salaries/$uuid";

  // Payment
  static const String createPayment = "$baseUrl/payment/create";
}

//dart pub global activate flutterfire_cli
//flutterfire configure --project=gym-chat-371b5

