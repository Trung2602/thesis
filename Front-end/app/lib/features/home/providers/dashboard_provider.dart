import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/plan.dart';
import 'package:gym/models/shift.dart';
import 'package:gym/services/auth_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _planCache = AppCache().planCache;
  final _shiftCache = AppCache().shiftCache;

  Future<List<Plan>> getPlans() async {
    const key = 'plans';
    if (_planCache.containsKey(key)) return _planCache[key]!;

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getPlans),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final result = (jsonDecode(res.body) as List)
          .map((e) => Plan.fromJson(e))
          .toList();
      _planCache[key] = result;
      return result;
    }
    throw Exception('Failed to load plans');
  }

  Future<List<Shift>> getShifts() async {
    const key = 'shifts';
    if (_shiftCache.containsKey(key)) return _shiftCache[key]!;

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getShifts),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final result = (jsonDecode(res.body) as List)
          .map((e) => Shift.fromJson(e)).toList();
      _shiftCache[key] = result;
      return result;
    }
    throw Exception('Failed to load shifts');
  }
}