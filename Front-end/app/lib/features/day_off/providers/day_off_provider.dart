import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/staff_day_off.dart';

class DayOffProvider extends ChangeNotifier {
  final cache = AppCache().staffDayOffCache;

  List<StaffDayOff> registeredDaysOff = [];
  bool isLoading = false;
  bool isFirstLoad = true;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> fetchByMonth(int month, int year) async {
    final key = '$month-$year';
    if (cache.containsKey(key)) {
      registeredDaysOff = cache[key]!;
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
      final token = await _getToken();
      final url = Uri.parse(GymServerApi.getStaffDayOffs).replace(
        queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
        },
      );
      final res =
      await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (res.statusCode == 200) {
        final data =
        StaffDayOff.fromJsonList(jsonDecode(res.body) as List<dynamic>);
        cache[key] = data;
        if (cache.length > 12) cache.remove(cache.keys.first);
        registeredDaysOff = data;
      }
    } catch (e) {
      debugPrint('fetchByMonth error: $e');
    } finally {
      isLoading = false;
      isFirstLoad = false;
      notifyListeners();
    }
  }

  // Trả về null nếu thành công, String lỗi nếu thất bại
  Future<String?> registerDayOff(
      DateTime picked, int selectedMonth, int selectedYear) async {
    final exists = registeredDaysOff.any((d) =>
    d.date.year == picked.year &&
        d.date.month == picked.month &&
        d.date.day == picked.day);

    if (exists) {
      return 'duplicate';
    }

    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse(GymServerApi.postStaffDayOff),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': picked.toIso8601String().split('T')[0],
        }),
      );

      if (res.statusCode == 200) {
        cache.remove('$selectedMonth-$selectedYear');
        await fetchByMonth(selectedMonth, selectedYear);
        return null;
      }
      return 'server: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> deleteDayOff(
      String uuid, int selectedMonth, int selectedYear) async {
    try {
      final res = await http
          .delete(Uri.parse(GymServerApi.deleteStaffDayOff(uuid)));

      if (res.statusCode == 200 || res.statusCode == 204) {
        cache.remove('$selectedMonth-$selectedYear');
        registeredDaysOff.removeWhere((d) => d.uuid == uuid);
        notifyListeners();
        return null;
      } else if (res.statusCode == 404) {
        return 'not_found';
      }
      return 'server: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }
}