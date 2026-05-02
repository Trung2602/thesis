import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/salary.dart';
import '../../../../services/auth_service.dart';

class SalaryProvider extends ChangeNotifier {
  List<Salary> salaries = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;
  int page = 0;
  final int size = 20;

  int selectedMonth = DateTime.now().month;
  final yearController =
  TextEditingController(text: DateTime.now().year.toString());

  final Map<String, List<Salary>> _cache = {};

  String get _cacheKey => '$selectedMonth-${yearController.text}';

  Future<void> fetchSalaries({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      salaries.clear();
      hasMore = true;
    }

    if (!isRefresh && _cache.containsKey(_cacheKey)) {
      salaries = _cache[_cacheKey]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(
          '${GymServerApi.getSalariesFilter}?page=$page&size=$size&month=$selectedMonth&year=${yearController.text}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      final List data = json['content'];
      final newData = data.map((e) => Salary.fromJson(e)).toList();
      salaries.addAll(newData);
      page++;
      isFirstLoad = false;
      if (newData.length < size) hasMore = false;
      _cache[_cacheKey] = salaries;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> payAllSalary() async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse(GymServerApi.postSalariesForAllStaff),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchSalaries(isRefresh: true);
  }

  Future<void> deleteSalary(String uuid) async {
    final token = await AuthService().getToken();
    await http.delete(
      Uri.parse(GymServerApi.deleteSalary(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchSalaries(isRefresh: true);
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return now.month == selectedMonth &&
        now.year.toString() == yearController.text;
  }

  void changeMonth(int delta) {
    selectedMonth += delta;
    if (selectedMonth < 1) selectedMonth = 12;
    if (selectedMonth > 12) selectedMonth = 1;
    notifyListeners();
    fetchSalaries(isRefresh: true);
  }

  @override
  void dispose() {
    yearController.dispose();
    super.dispose();
  }
}