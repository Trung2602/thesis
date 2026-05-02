import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/ai_server_api.dart';
import '../../../../models/Food.dart';
import '../../../../services/auth_service.dart';
import '../../../../cache/manager_cache.dart';

class FoodProvider extends ChangeNotifier {
  List<Food> foods = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int currentPage = 0;
  int totalPages = 1;
  final int pageSize = 10;

  final _cache = ManagerCache().foodManagerCache;

  Future<void> fetchFoods({bool isRefresh = false, int page = 0}) async {
    if (isLoading) return;

    final cacheKey = 'page_$page';

    if (!isRefresh && _cache.containsKey(cacheKey)) {
      foods = _cache[cacheKey]!;
      currentPage = page;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (foods.isEmpty) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final uri = Uri.parse(AiServerApi.getFoods).replace(
      queryParameters: {'page': '$page', 'size': '$pageSize'},
    );
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newFoods =
      (data['content'] as List).map((e) => Food.fromJson(e)).toList();
      _cache[cacheKey] = newFoods;
      foods = newFoods;
      totalPages = data['totalPages'];
      currentPage = page;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deleteFood(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(AiServerApi.deleteFood(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      _cache.clear();
      return true;
    }
    return false;
  }

  Future<void> saveFood(Map<String, dynamic> body, bool isNew) async {
    final token = await AuthService().getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (isNew) {
      await http.post(Uri.parse(AiServerApi.postFood),
          headers: headers, body: jsonEncode(body));
    } else {
      await http.patch(Uri.parse(AiServerApi.patchFood),
          headers: headers, body: jsonEncode(body));
    }
    _cache.clear();
  }
}