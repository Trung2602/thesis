class UserServerApi {
  // static const String baseUrl = "http://fitness-alb-1289679733.us-east-1.elb.amazonaws.com/api/v1/user";
  static const String baseUrl = "http://192.168.1.7:8081/api/v1/user";

  // ================= AUTH =================
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String otpURL = "$baseUrl/auth/verify/otp";

  // ================= ACCOUNT =================
  static const String me = "$baseUrl/accounts/me";
  static const String accountUpdate = "$baseUrl/accounts/me";
  static const String verifyPassword = "$baseUrl/accounts/me/password/verify";
  static const String changePassword = "$baseUrl/accounts/me/password";
  static const String loadAccount = "$baseUrl/accounts";
  static String deleteAccount(String uuid) => "$baseUrl/accounts/$uuid";

  // ================= ADMIN =================
  static String getAdminByUuid(String uuid) => "$baseUrl/admins/$uuid";
  static const String postAdmin = "$baseUrl/admins";
  static const String patchAdmin = "$baseUrl/admins";

  // ================= STAFF =================
  static String getStaffByUuid(String uuid) => "$baseUrl/staffs/$uuid";
  static const String postStaff = "$baseUrl/staffs";
  static const String patchStaff ="$baseUrl/staffs";
  static const String getStaffs ="$baseUrl/staffs";
  static const String getWorkingStaff = "$baseUrl/staffs/working";

  // ================= CUSTOMER =================
  static String getCustomerByUuid(String uuid) => "$baseUrl/customers/$uuid";
  static const String postCustomer = "$baseUrl/customers";
  static const String patchCustomer ="$baseUrl/customers";
}