import 'package:gym/models/pay_customer.dart';
import 'package:gym/models/plan.dart';
import 'package:gym/models/shift.dart';

import '../models/customer_schedule.dart';
import '../models/salary.dart';
import '../models/staff_day_off.dart';
import '../models/staff_schedule.dart';

class AppCache {
  static final AppCache _instance = AppCache._internal();
  factory AppCache() => _instance;

  AppCache._internal();

  // ===== CACHE =====
  final Map<String, List<Salary>> salaryCache = {};
  final Map<String, List<StaffSchedule>> staffScheduleCache = {};
  final Map<String, List<CustomerSchedule>> customerScheduleCache = {};
  final Map<String, List<StaffDayOff>> staffDayOffCache = {};
  final Map<String, List<PayCustomer>> payCustomerCache = {};
  final Map<String, List<Shift>> shiftCache = {};
  final Map<String, List<Plan>> planCache = {};

  // ===== CLEAR ALL =====
  void clearAll() {
    salaryCache.clear();
    staffScheduleCache.clear();
    customerScheduleCache.clear();
    staffDayOffCache.clear();
    payCustomerCache.clear();
    shiftCache.clear();
    planCache.clear();
  }

  // ===== CLEAR THEO USER =====
  void clearUser(String userUuid) {
    salaryCache.remove(userUuid);
  }
}