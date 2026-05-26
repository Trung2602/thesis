import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../api/user_server_api.dart';
import '../../../../cache/manager_cache.dart';
import '../../../../models/staff_schedule.dart';
import '../../../../services/auth_service.dart';

class StaffScheduleProvider extends ChangeNotifier {
  List<StaffSchedule> schedulesForSelectedDay = [];
  bool isLoading = false;
  bool isFirstLoad = true;

  List<dynamic>? listStaffs;
  List<dynamic>? listShifts;

  final _cache = ManagerCache().staffScheduleManagerCache;

  String formatDate(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
          '${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';

  bool canDelete(DateTime date) {
    final today = DateTime.now();
    final limit = DateTime(today.year, today.month, today.day + 2);
    return !date.isBefore(limit);
  }

  Future<List<dynamic>> _getStaffs() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(UserServerApi.getStaffs),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Lỗi load staff');
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> _getShifts() async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getShifts),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Lỗi load shifts');
    return jsonDecode(res.body);
  }

  Future<void> ensureDataLoaded() async {
    if (listStaffs == null) listStaffs = await _getStaffs();
    if (listShifts == null) listShifts = await _getShifts();
  }

  Future<void> loadSchedulesForDay(DateTime day) async {
    final dateString = formatDate(day);

    if (_cache.containsKey(dateString)) {
      schedulesForSelectedDay = _cache[dateString]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final uri = Uri.parse(GymServerApi.getStaffSchedulesFilter)
        .replace(queryParameters: {'date': dateString});
    final response =
    await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    final List data = jsonDecode(response.body);
    final schedules = data.map((e) => StaffSchedule.fromJson(e)).toList();
    _cache[dateString] = schedules;
    schedulesForSelectedDay = schedules;

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> addSchedule(Map<String, dynamic> result, DateTime selectedDay) async {
    final token = await AuthService().getToken();
    final newSchedule = StaffSchedule(
      staffUuid: result['staffUuid'],
      facilityUuid: result['facilityUuid'],
      shiftUuid: result['shiftUuid'],
      date: result['date'],
    );

    final res = await http.post(
      Uri.parse(GymServerApi.postStaffSchedule),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newSchedule.toJson()),
    );
    print(res.statusCode);
    print(res.body);
    if (res.statusCode == 200) {
      _cache.remove(formatDate(selectedDay));
      await loadSchedulesForDay(selectedDay);
      return true;
    }
    return false;
  }

  Future<bool> approveSchedule(String uuid, DateTime selectedDay) async {
    final token = await AuthService().getToken();
    final res = await http.patch(
      Uri.parse(GymServerApi.approveStaffSchedule(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      _cache.remove(formatDate(selectedDay));
      await loadSchedulesForDay(selectedDay);
      return true;
    }
    return false;
  }

  Future<bool> editSchedule(StaffSchedule original, Map<String, dynamic> result, DateTime selectedDay) async {
    final token = await AuthService().getToken();
    final updated = StaffSchedule(
      uuid: original.uuid,
      staffUuid: result['staffUuid'],
      shiftUuid: result['shiftUuid'],
      date: result['date'],
      facilityUuid: original.facilityUuid,
    );

    final res = await http.post(
      Uri.parse(GymServerApi.postStaffSchedule),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updated.toJson()),
    );
    if (res.statusCode == 200) {
      _cache.remove(formatDate(selectedDay));
      await loadSchedulesForDay(selectedDay);
      return true;
    }
    return false;
  }

  Future<void> deleteSchedule(String uuid, DateTime selectedDay) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteStaffSchedule(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Xóa thất bại: ${res.statusCode}');
    }
    _cache.remove(formatDate(selectedDay));
    await loadSchedulesForDay(selectedDay);
  }

  void invalidateDay(DateTime day) {
    _cache.remove(formatDate(day));
  }
}