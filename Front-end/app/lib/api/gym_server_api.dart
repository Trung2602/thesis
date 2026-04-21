class GymServerApi {
  // static const String baseUrl = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com/api/v1/gym";
  static const String baseUrl = "http://192.168.1.10:8080/api/v1/gym";

  // ================== PLAN ==================
  static const String getPlans = "$baseUrl/plans";
  static String getPlanByUuid(String uuid) => "$baseUrl/plans/$uuid";
  static const String postPlan = "$baseUrl/plans";
  static String deletePlan(String uuid) => "$baseUrl/plans/$uuid";
  static const String getPlansFilter = "$baseUrl/plans/filter";

  // ================== SHIFT ==================
  static const String getShifts = "$baseUrl/shifts";
  static String getShiftByUuid(String uuid) => "$baseUrl/shifts/$uuid";
  static const String postShift = "$baseUrl/shifts";
  static String deleteShift(String uuid) => "$baseUrl/shifts/$uuid";
  static const String getShiftsFilter = "$baseUrl/shifts/filter";

  // ================== CUSTOMER SCHEDULE ==================
  static const String getCustomerSchedules = "$baseUrl/customer-schedules";
  static String getCustomerScheduleByUuid(String uuid) => "$baseUrl/customer-schedules/$uuid";
  static const String postCustomerSchedule = "$baseUrl/customer-schedules";
  static String deleteCustomerSchedule(String uuid) => "$baseUrl/customer-schedules/$uuid";
  static const String getCustomerSchedulesFilter = "$baseUrl/customer-schedules/filter";

  // ================== STAFF SCHEDULE ==================
  static const String getStaffSchedules = "$baseUrl/staff-schedules";
  static const String getStaffSchedulesByStaff = "$baseUrl/staff-schedules/staff";
  static String getStaffScheduleByUuid(String uuid) => "$baseUrl/staff-schedules/$uuid";
  static const String postStaffSchedule = "$baseUrl/staff-schedules";
  static String deleteStaffSchedule(String uuid) => "$baseUrl/staff-schedules/$uuid";
  static const String getStaffSchedulesFilter = "$baseUrl/staff-schedules/filter";
  static const String getStaffSchedulesFilterByStaff = "$baseUrl/staff-schedules/filter/staff";

  // ================== STAFF DAY OFF ==================
  static const String getStaffDayOffs = "$baseUrl/day-offs";
  static String getStaffDayOffByUuid(String uuid) => "$baseUrl/day-offs/$uuid";
  static const String postStaffDayOff = "$baseUrl/day-offs";
  static String deleteStaffDayOff(String uuid) => "$baseUrl/day-offs/$uuid";
  static const String getStaffDayOffsFilter = "$baseUrl/day-offs/filter";

  // ================== PAY CUSTOMER ==================
  static const String getPayCustomers = "$baseUrl/pay-customers";
  static String getPayCustomerByUuid(String uuid) => "$baseUrl/pay-customers/$uuid";
  static const String postPayCustomer = "$baseUrl/pay-customers";
  static String deletePayCustomer(String uuid) => "$baseUrl/pay-customers/$uuid";
  static const String getPayCustomersFilter = "$baseUrl/pay-customers/filter";
  static const String getPayCustomersSort = "$baseUrl/pay-customers/sort";

  // ================== SALARY ==================
  static const String getSalaries = "$baseUrl/salaries";
  static String getSalaryByUuid(String uuid) => "$baseUrl/salaries/$uuid";
  static const String postSalary = "$baseUrl/salaries";
  static String deleteSalary(String uuid) => "$baseUrl/salaries/$uuid";
  static const String getSalariesFilter = "$baseUrl/salaries/filter";
  static const String postSalariesForAllStaff = "$baseUrl/salaries/calculate-month";

  // ================== FACILITY ==================
  static const String getFacilities = "$baseUrl/facilities";
  static String getFacilityByUuid(String uuid) => "$baseUrl/facilities/$uuid";
  static const String postFacility = "$baseUrl/facilities";
  static String deleteFacility(String uuid) => "$baseUrl/facilities/$uuid";
  static const String getFacilitiesFilter = "$baseUrl/facilities/filter";

  // ================== PAYMENT ==================
  static const String createPayment = "$baseUrl/payment/create";
  static const String returnPath = "/api/v1/payment/return";

  // ================== REPORT ==================
  static const String getReport = "$baseUrl/report";
}