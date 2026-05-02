import '../config/app_config.dart';

class GymServerApi {
  static final String baseUrl = AppConfig.buildUrl("gym");

  // ================== PLAN ==================
  static final String getPlans = "$baseUrl/plans";
  static String getPlanByUuid(String uuid) => "$baseUrl/plans/$uuid";
  static final String postPlan = "$baseUrl/plans";
  static String deletePlan(String uuid) => "$baseUrl/plans/$uuid";
  static final String getPlansFilter = "$baseUrl/plans/filter";

  // ================== SHIFT ==================
  static final String getShifts = "$baseUrl/shifts";
  static String getShiftByUuid(String uuid) => "$baseUrl/shifts/$uuid";
  static final String postShift = "$baseUrl/shifts";
  static String deleteShift(String uuid) => "$baseUrl/shifts/$uuid";
  static final String getShiftsFilter = "$baseUrl/shifts/filter";

  // ================== CUSTOMER SCHEDULE ==================
  static final String getCustomerSchedules = "$baseUrl/customer-schedules";
  static String getCustomerScheduleByUuid(String uuid) => "$baseUrl/customer-schedules/$uuid";
  static final String postCustomerSchedule = "$baseUrl/customer-schedules";
  static String deleteCustomerSchedule(String uuid) => "$baseUrl/customer-schedules/$uuid";
  static final String getCustomerSchedulesFilter = "$baseUrl/customer-schedules/filter";

  // ================== STAFF SCHEDULE ==================
  static final String getStaffSchedules = "$baseUrl/staff-schedules";
  static final String getStaffSchedulesByStaff = "$baseUrl/staff-schedules/staff";
  static String getStaffScheduleByUuid(String uuid) => "$baseUrl/staff-schedules/$uuid";
  static final String postStaffSchedule = "$baseUrl/staff-schedules";
  static String deleteStaffSchedule(String uuid) => "$baseUrl/staff-schedules/$uuid";
  static final String getStaffSchedulesFilter = "$baseUrl/staff-schedules/filter";
  static final String getStaffSchedulesFilterByStaff = "$baseUrl/staff-schedules/filter/staff";

  // ================== STAFF DAY OFF ==================
  static final String getStaffDayOffs = "$baseUrl/day-offs";
  static String getStaffDayOffByUuid(String uuid) => "$baseUrl/day-offs/$uuid";
  static final String postStaffDayOff = "$baseUrl/day-offs";
  static String deleteStaffDayOff(String uuid) => "$baseUrl/day-offs/$uuid";
  static final String getStaffDayOffsFilter = "$baseUrl/day-offs/filter";

  // ================== PAY CUSTOMER ==================
  static final String getPayCustomers = "$baseUrl/pay-customers";
  static String getPayCustomerByUuid(String uuid) => "$baseUrl/pay-customers/$uuid";
  static final String postPayCustomer = "$baseUrl/pay-customers";
  static String deletePayCustomer(String uuid) => "$baseUrl/pay-customers/$uuid";
  static final String getPayCustomersFilter = "$baseUrl/pay-customers/filter";
  static final String getPayCustomersSort = "$baseUrl/pay-customers/sort";

  // ================== SALARY ==================
  static final String getSalaries = "$baseUrl/salaries";
  static String getSalaryByUuid(String uuid) => "$baseUrl/salaries/$uuid";
  static final String postSalary = "$baseUrl/salaries";
  static String deleteSalary(String uuid) => "$baseUrl/salaries/$uuid";
  static final String getSalariesFilter = "$baseUrl/salaries/filter";
  static final String postSalariesForAllStaff = "$baseUrl/salaries/calculate-month";

  // ================== FACILITY ==================
  static final String getFacilities = "$baseUrl/facilities";
  static String getFacilityByUuid(String uuid) => "$baseUrl/facilities/$uuid";
  static final String postFacility = "$baseUrl/facilities";
  static String deleteFacility(String uuid) => "$baseUrl/facilities/$uuid";
  static final String getFacilitiesFilter = "$baseUrl/facilities/filter";

  // ================== PAYMENT ==================
  static final String createPayment = "$baseUrl/payment/create";
  static final String returnPath = "/api/v1/payment/return";

  // ================== REPORT ==================
  static final String getReport = "$baseUrl/report";
}