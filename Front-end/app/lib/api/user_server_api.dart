import '../config/app_config.dart';

class UserServerApi {
  static final String baseUrl = AppConfig.buildUrl("user");

  // ================= AUTH =================
  static final String login = "$baseUrl/auth/login";
  static final String register = "$baseUrl/auth/register";
  static final String otpURL = "$baseUrl/auth/register/verify-otp";
  // ================= FORGOT PASSWORD =================
  static final String forgotPassword = "$baseUrl/auth/password/forgot";
  static final String forgotPasswordVerifyOtp = "$baseUrl/auth/password/forgot/verify-otp";
  static final String resetPassword = "$baseUrl/auth/password/reset";

  // ================= ACCOUNT =================
  static final String me = "$baseUrl/accounts/me";
  static final String accountUpdate = "$baseUrl/accounts/me";
  static final String verifyPassword = "$baseUrl/accounts/me/password/verify";
  static final String changePassword = "$baseUrl/accounts/me/password";
  static final String loadAccount = "$baseUrl/accounts";
  static String deleteAccount(String uuid) => "$baseUrl/accounts/$uuid";

  // ================= ADMIN =================
  static String getAdminByUuid(String uuid) => "$baseUrl/admins/$uuid";
  static final String postAdmin = "$baseUrl/admins";
  static final String patchAdmin = "$baseUrl/admins";

  // ================= STAFF =================
  static String getStaffByUuid(String uuid) => "$baseUrl/staffs/$uuid";
  static final String postStaff = "$baseUrl/staffs";
  static final String patchStaff ="$baseUrl/staffs";
  static final String getStaffs ="$baseUrl/staffs";
  static final String getWorkingStaff = "$baseUrl/staffs/working";

  // ================= CUSTOMER =================
  static String getCustomerByUuid(String uuid) => "$baseUrl/customers/$uuid";
  static final String postCustomer = "$baseUrl/customers";
  static final String patchCustomer ="$baseUrl/customers";
}