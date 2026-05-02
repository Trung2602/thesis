import 'package:gym/models/facility.dart';
import 'package:gym/models/pay_customer.dart';
import 'package:gym/models/plan.dart';
import 'package:gym/models/shift.dart';

import '../models/Exercise.dart';
import '../models/Food.dart';
import '../models/salary.dart';
import '../models/staff_day_off.dart';
import '../models/staff_schedule.dart';

class ManagerCache {
  static final ManagerCache _instance = ManagerCache._internal();
  factory ManagerCache() => _instance;

  ManagerCache._internal();
  // ===MANAGER CACHE===
  final Map<String, List<Salary>> salaryManagerCache = {};
  final Map<String, List<Facility>> facilityManagerCache = {};
  final Map<String, List<StaffSchedule>> staffScheduleManagerCache = {};
  final Map<String, List<StaffDayOff>> staffDayOffManagerCache = {};
  final Map<String, List<PayCustomer>> payCustomerManagerCache = {};
  final Map<String, List<Shift>> shiftManagerCache = {};
  final Map<String, List<Plan>> planManagerCache = {};
  final Map<String, List<Food>> foodManagerCache = {};
  final Map<String, List<Exercise>> exerciseManagerCache = {};
  // ===== CLEAR ALL =====
  void clearAll() {
    salaryManagerCache.clear();
    facilityManagerCache.clear();
    staffDayOffManagerCache.clear();
    staffScheduleManagerCache.clear();
    payCustomerManagerCache.clear();
    shiftManagerCache.clear();
    payCustomerManagerCache.clear();
    foodManagerCache.clear();
    exerciseManagerCache.clear();
  }
}