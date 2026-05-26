import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/staff_day_off.dart';
import '../../../../services/auth_service.dart';

class DayOffProvider extends ChangeNotifier {
  List<StaffDayOff> list = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;

  int page = 0;
  final int size = 20;

  int selectedMonth = DateTime.now().month;
  final yearController =
  TextEditingController(text: DateTime.now().year.toString());

  final Map<String, List<StaffDayOff>> _cache = {};

  String get _cacheKey => '$selectedMonth-${yearController.text}';

  Future<void> fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      list.clear();
      hasMore = true;
    }

    if (!isRefresh && _cache.containsKey(_cacheKey)) {
      list = _cache[_cacheKey]!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (page == 0) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final url =
        '${GymServerApi.getStaffDayOffsFilter}?page=$page&size=$size&month=$selectedMonth&year=${yearController.text}';

    final res = await http.get(Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List data = decoded is Map ? decoded['content'] : decoded;
      final newData = StaffDayOff.fromJsonList(data);
      list.addAll(newData);
      _cache[_cacheKey] = list;
      page++;
      if (newData.length < size) hasMore = false;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deleteItem(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteStaffDayOff(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  void changeMonth(int delta) {
    selectedMonth += delta;
    if (selectedMonth < 1) selectedMonth = 12;
    if (selectedMonth > 12) selectedMonth = 1;
    notifyListeners();
    fetchData(isRefresh: true);
  }

  @override
  void dispose() {
    yearController.dispose();
    super.dispose();
  }

  Future<bool> approveItem(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.patch(
      Uri.parse(GymServerApi.patchStaffDayOffApprove(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }
}