class Api {
  static const String baseUrlGymServer = "http://192.168.1.4:8080/api/v1";
  static const String baseUrlUserServer = "http://192.168.1.4:8081/api/v1";
  static const String baseUrlAiServer = "http://192.168.1.4:8082/api/v1";

  static const String login = "$baseUrlUserServer/auth/login";
  static const String register = "$baseUrlUserServer/auth/register";
  static const String otpURL = "$baseUrlUserServer/auth/verify/otp";
  static const String me = "$baseUrlUserServer/account/me";
  static const String accountUpdate = "$baseUrlUserServer/account/me";
  static const String verifyPassword = "$baseUrlUserServer/account/me/password/verify";
  static const String changePassword = "$baseUrlUserServer/account/me/password";


  // ================= ADMIN =================
  static const String getAdminsAll = "$baseUrlGymServer/admins";
  static String getAdminByUuid(String uuid) => "$baseUrlGymServer/admins/$uuid";
  static const String postAdmin = "$baseUrlGymServer/admins";
  static String deleteAdmin(String uuid) => "$baseUrlGymServer/admins/$uuid";
  static const String getAdminsFilter = "$baseUrlGymServer/admins/filter";


  // ================= STAFF =================
  static const String getStaffsAll = "$baseUrlGymServer/staffs";
  static String getStaffByUuid(String uuid) => "$baseUrlGymServer/staffs/$uuid";
  static const String postStaff = "$baseUrlGymServer/staffs";
  static String deleteStaff(String uuid) => "$baseUrlGymServer/staffs/$uuid";
  static const String getStaffsFilter = "$baseUrlGymServer/staffs/filter";


  // ================= CUSTOMER =================
  static const String getCustomersAll = "$baseUrlGymServer/customers";
  static String getCustomerByUuid(String uuid) => "$baseUrlGymServer/customers/$uuid";
  static const String postCustomer = "$baseUrlGymServer/customers";
  static String deleteCustomer(String uuid) => "$baseUrlGymServer/customers/$uuid";
  static const String getCustomersFilter = "$baseUrlGymServer/customers/filter";


  // ================= CUSTOMER SCHEDULE =================
  static const String getCustomerSchedulesAll = "$baseUrlGymServer/customer-schedules";
  static String getCustomerScheduleByUuid(String uuid) => "$baseUrlGymServer/customer-schedules/$uuid";
  static const String postCustomerSchedule = "$baseUrlGymServer/customer-schedules";
  static String deleteCustomerSchedule(String uuid) => "$baseUrlGymServer/customer-schedules/$uuid";
  static const String getCustomerSchedulesFilter = "$baseUrlGymServer/customer-schedules/filter";


  // ================= PAY CUSTOMER =================
  static const String getPayCustomersAll = "$baseUrlGymServer/pay-customers";
  static String getPayCustomerByUuid(String uuid) => "$baseUrlGymServer/pay-customers/$uuid";
  static const String postPayCustomer = "$baseUrlGymServer/pay-customers";
  static String deletePayCustomer(String uuid) => "$baseUrlGymServer/pay-customers/$uuid";
  static const String getPayCustomersFilter = "$baseUrlGymServer/pay-customers/filter";


  // ================= STAFF SCHEDULE =================
  static const String getStaffSchedulesAll = "$baseUrlGymServer/staff-schedules";
  static String getStaffScheduleByUuid(String uuid) => "$baseUrlGymServer/staff-schedules/$uuid";
  static const String postStaffSchedule = "$baseUrlGymServer/staff-schedules";
  static String deleteStaffSchedule(String uuid) => "$baseUrlGymServer/staff-schedules/$uuid";
  static const String getStaffSchedulesFilter = "$baseUrlGymServer/staff-schedules/filter";


  // ================= STAFF DAY OFF =================
  static const String getStaffDayOffsAll = "$baseUrlGymServer/staff-day-offs";
  static String getStaffDayOffByUuid(String uuid) => "$baseUrlGymServer/staff-day-offs/$uuid";
  static const String postStaffDayOff = "$baseUrlGymServer/staff-day-offs";
  static String deleteStaffDayOff(String uuid) => "$baseUrlGymServer/staff-day-offs/$uuid";
  static const String getStaffDayOffsFilter = "$baseUrlGymServer/staff-day-offs/filter";


  // ================= PLAN =================
  static const String getPlansAll = "$baseUrlGymServer/plans";
  static String getPlanByUuid(String uuid) => "$baseUrlGymServer/plans/$uuid";
  static const String postPlan = "$baseUrlGymServer/plans";
  static String deletePlan(String uuid) => "$baseUrlGymServer/plans/$uuid";
  static const String getPlansFilter = "$baseUrlGymServer/plans/filter";


  // ================= SHIFT =================
  static const String getShiftsAll = "$baseUrlGymServer/shifts";
  static String getShiftByUuid(String uuid) => "$baseUrlGymServer/shifts/$uuid";
  static const String postShift = "$baseUrlGymServer/shifts";
  static String deleteShift(String uuid) => "$baseUrlGymServer/shifts/$uuid";
  static const String getShiftsFilter = "$baseUrlGymServer/shifts/filter";


  // ================= FACILITY =================
  static const String getFacilitiesAll = "$baseUrlGymServer/facilities";
  static String getFacilityByUuid(String uuid) => "$baseUrlGymServer/facilities/$uuid";
  static const String postFacility = "$baseUrlGymServer/facilities";
  static String deleteFacility(String uuid) => "$baseUrlGymServer/facilities/$uuid";
  static const String getFacilitiesFilter = "$baseUrlGymServer/facilities/filter";


  // ================= SALARY =================
  static const String getSalariesAll = "$baseUrlGymServer/salaries";
  static String getSalaryByUuid(String uuid) => "$baseUrlGymServer/salaries/$uuid";
  static const String postSalary = "$baseUrlGymServer/salaries";
  static String deleteSalary(String uuid) => "$baseUrlGymServer/salaries/$uuid";
  static const String getSalariesFilter = "$baseUrlGymServer/salaries/filter";
}

