import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/staff_schedule.dart';
import 'package:gym/services/auth_service.dart';

class StaffScheduleProvider extends ChangeNotifier {
  final cache = AppCache().staffScheduleCache;

  List<StaffSchedule> schedulesForSelectedDay = [];
  bool isLoading = false;
  bool isFirstLoad = true;

  String formatDate(DateTime day) {
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  bool canDelete(DateTime date) {
    final today = DateTime.now();
    final limit = DateTime(today.year, today.month, today.day + 2);
    return !date.isBefore(limit);
  }

  Future<void> loadSchedulesForDay(DateTime day) async {
    final dateStr = formatDate(day);
    if (cache.containsKey(dateStr)) {
      schedulesForSelectedDay = cache[dateStr]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }
    isLoading = true;
    isFirstLoad = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final uri = Uri.parse(GymServerApi.getStaffSchedulesFilterByStaff)
          .replace(queryParameters: {'date': dateStr});
      final res = await http.get(uri,
          headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode != 200) {
        throw Exception('Server error: ${res.statusCode}');
      }
      final schedules = (jsonDecode(res.body) as List)
          .map((e) => StaffSchedule.fromJson(e))
          .toList();
      cache[dateStr] = schedules;
      schedulesForSelectedDay = schedules;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchShifts() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getShifts),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi tải ca làm việc: ${res.statusCode}');
  }

  Future<String?> addSchedule(
      String staffUuid, DateTime date, String shiftUuid) async {
    try {
      final token = await AuthService().getToken();
      final newSchedule = StaffSchedule(
        staffUuid: staffUuid,
        date: date,
        shiftUuid: shiftUuid,
      );
      final res = await http.post(
        Uri.parse(GymServerApi.postStaffSchedule),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newSchedule.toJson()),
      );
      if (res.statusCode == 200) {
        cache.remove(formatDate(date));
        await loadSchedulesForDay(date);
        return null;
      } else if (res.statusCode == 409) {
        return 'conflict';
      }
      return 'error: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> deleteSchedule(String uuid, DateTime day) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.delete(
        Uri.parse(GymServerApi.deleteStaffSchedule(uuid)),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        cache.remove(formatDate(day));
        await loadSchedulesForDay(day);
        return null;
      }
      return 'error: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }
}