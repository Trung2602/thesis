import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/available_staff.dart';
import 'package:gym/models/customer_schedule.dart';
import 'package:gym/services/auth_service.dart';

import '../../../models/facility.dart';

class CustomerScheduleProvider extends ChangeNotifier {
  final cache = AppCache().customerScheduleCache;
  final facilityCache = AppCache().facilityCache;
  List<Facility> get facilities => AppCache().facilityCache['all'] ?? [];
  List<CustomerSchedule> schedulesForSelectedDay = [];
  List<AvailableStaff> staffList = [];

  bool isLoadingStaff = false;
  bool isLoading = false;
  bool isFirstLoad = true;

  String formatDate(DateTime day) {
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadFacilities() async {
    if (AppCache().facilityCache.containsKey('all')) return;
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse(GymServerApi.getFacilities),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        AppCache().facilityCache['all'] = data.map((e) => Facility.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> loadSchedulesForDay(DateTime day) async {
    final dateStr = formatDate(day);
    if (cache.containsKey(dateStr)) {
      schedulesForSelectedDay = cache[dateStr]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }
    if (isFirstLoad) {
      isFirstLoad = true;
    } else {
      isLoading = true;
    }
    notifyListeners();

    try {
      final schedules = await _fetchSchedules(dateStr);
      cache[dateStr] = schedules;
      if (cache.length > 20) cache.remove(cache.keys.first);
      schedulesForSelectedDay = schedules;
      isFirstLoad = false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<List<CustomerSchedule>> _fetchSchedules(String date) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse(
        '${GymServerApi.getCustomerSchedulesFilter}?date=$date');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => CustomerSchedule.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load schedules: ${res.statusCode}');
  }

  Future<void> fetchWorkingStaff(String facilityUuid, DateTime date, TimeOfDay checkIn, TimeOfDay checkOut) async {
    isLoadingStaff = true;
    notifyListeners();
    try {
      final token = await AuthService().getToken();
      final checkInStr =
          '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}:00';
      final checkOutStr =
          '${checkOut.hour.toString().padLeft(2, '0')}:${checkOut.minute.toString().padLeft(2, '0')}:00';
      final uri = Uri.parse(UserServerApi.getWorkingStaff(facilityUuid))
          .replace(queryParameters: {
        'date': formatDate(date),
        'checkin': checkInStr,
        'checkout': checkOutStr,
      });
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        staffList = (jsonDecode(res.body) as List)
            .map((e) => AvailableStaff.fromJson(e))
            .toList();
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoadingStaff = false;
      notifyListeners();
    }
  }

  Future<String?> addSchedule(DateTime date, TimeOfDay checkIn,
      TimeOfDay checkOut, AvailableStaff staff) async {
    try {
      final token = await AuthService().getToken();
      final newSchedule = CustomerSchedule(
        date: date,
        checkin: checkIn,
        checkout: checkOut,
        staffUuid: staff.uuid,
        facilityUuid: staff.facilityUuid,
      );
      print('SCHEDULE JSON: ${jsonEncode(staff.toJson())}');
      final res = await http.post(
        Uri.parse(GymServerApi.postCustomerSchedule),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newSchedule.toJson()),
      );
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");
      if (res.statusCode == 200) {
        cache.remove(formatDate(date));
        await loadSchedulesForDay(date);
        return null;
      } else if (res.statusCode == 409) {
        return 'conflict';
      } else {
        throw Exception('Failed: ${res.body}');
      }
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> deleteSchedule(String uuid, DateTime day) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse(GymServerApi.deleteCustomerSchedule(uuid)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 204) {
        cache.remove(formatDate(day));
        await loadSchedulesForDay(day);
        return null; // success
      }
      return 'error: ${res.body}';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> updateNote(String uuid, String note, DateTime day) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.patch(
        Uri.parse(GymServerApi.patchCustomerScheduleNote(uuid)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'note': note}),
      );
      if (res.statusCode == 200) {
        cache.remove(formatDate(day));
        await loadSchedulesForDay(day);
        return null;
      }
      return 'error: ${res.body}';
    } catch (e) {
      return 'error: $e';
    }
  }
}