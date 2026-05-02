import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/shift.dart';
import '../../../../services/auth_service.dart';

class ShiftProvider extends ChangeNotifier {
  List<Shift> shifts = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;
  int page = 0;
  final int size = 10;
  final Map<int, List<Shift>> _cache = {};

  Future<void> fetchShifts({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      shifts.clear();
      hasMore = true;
      _cache.clear();
    }

    if (_cache.containsKey(page)) {
      shifts.addAll(_cache[page]!);
      page++;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (page == 0) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final uri = Uri.parse(GymServerApi.getShiftsFilter).replace(
      queryParameters: {'page': '$page', 'size': '$size'},
    );
    final res =
    await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Shift.fromJson(e)).toList();
      _cache[page] = newData;
      shifts.addAll(newData);
      page++;
      if (newData.length < size) hasMore = false;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deleteShift(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteShift(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<void> saveShift(Map<String, dynamic> body) async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse(GymServerApi.postShift),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}