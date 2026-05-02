import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/plan.dart';
import '../../../../services/auth_service.dart';

class PlanProvider extends ChangeNotifier {
  List<Plan> plans = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;
  int page = 0;
  final int size = 10;
  final Map<int, List<Plan>> _cache = {};

  Future<void> fetchPlans({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      plans.clear();
      hasMore = true;
      _cache.clear();
    }

    if (_cache.containsKey(page)) {
      plans.addAll(_cache[page]!);
      page++;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (page == 0) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final uri = Uri.parse(GymServerApi.getPlansFilter).replace(
      queryParameters: {'page': '$page', 'size': '$size'},
    );
    final res =
    await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Plan.fromJson(e)).toList();
      _cache[page] = newData;
      plans.addAll(newData);
      page++;
      if (newData.length < size) hasMore = false;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deletePlan(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deletePlan(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<void> savePlan(Map<String, dynamic> body) async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse(GymServerApi.postPlan),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}