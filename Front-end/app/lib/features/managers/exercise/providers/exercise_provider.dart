import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../models/Exercise.dart';
import '../../../../api/ai_server_api.dart';
import '../../../../services/auth_service.dart';
import '../../../../cache/manager_cache.dart';

class ExerciseProvider extends ChangeNotifier {
  List<Exercise> exercises = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int currentPage = 0;
  int totalPages = 1;
  final int pageSize = 10;

  final _cache = ManagerCache().exerciseManagerCache;

  Future<void> fetchExercises({bool isRefresh = false, int page = 0}) async {
    if (isLoading) return;

    final cacheKey = 'page_$page';

    if (!isRefresh && _cache.containsKey(cacheKey)) {
      exercises = _cache[cacheKey]!;
      currentPage = page;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (exercises.isEmpty) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final uri = Uri.parse(AiServerApi.getExercises).replace(
      queryParameters: {'page': '$page', 'size': '$pageSize'},
    );
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final newExercises =
      (data['content'] as List).map((e) => Exercise.fromJson(e)).toList();
      _cache[cacheKey] = newExercises;
      exercises = newExercises;
      totalPages = data['totalPages'];
      currentPage = page;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deleteExercise(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(AiServerApi.deleteExercise(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      _cache.clear();
      return true;
    }
    return false;
  }

  Future<void> saveExercise(Map<String, dynamic> body, bool isNew) async {
    final token = await AuthService().getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (isNew) {
      await http.post(
        Uri.parse(AiServerApi.postExercise),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      await http.patch(
        Uri.parse(AiServerApi.patchExercise),
        headers: headers,
        body: jsonEncode(body),
      );
    }
    _cache.clear();
  }
}