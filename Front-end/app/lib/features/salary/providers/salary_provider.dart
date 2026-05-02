import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/salary.dart';
import 'package:gym/services/auth_service.dart';

class SalaryProvider extends ChangeNotifier {
  final cache = AppCache().salaryCache;

  List<Salary> salaries = [];
  bool isLoading = false;
  bool isFirstLoad = true;

  Future<void> fetchSalaries(String staffUuid) async {
    if (cache.containsKey(staffUuid)) {
      salaries = cache[staffUuid]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }
    isLoading = true;
    isFirstLoad = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse(GymServerApi.getSalaries),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = (jsonDecode(res.body) as List)
            .map((e) => Salary.fromJson(e))
            .toList();
        cache[staffUuid] = data;
        salaries = data;
      } else {
        throw Exception('Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch salaries error: $e');
    } finally {
      isLoading = false;
      isFirstLoad = false;
      notifyListeners();
    }
  }
}