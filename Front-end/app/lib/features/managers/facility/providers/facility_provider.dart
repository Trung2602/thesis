import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/facility.dart';
import '../../../../services/auth_service.dart';

class FacilityProvider extends ChangeNotifier {
  List<Facility> facilities = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  List<Facility>? _cache;

  Future<void> fetchFacilities({bool isRefresh = false}) async {
    if (isLoading) return;

    if (_cache != null && !isRefresh) {
      facilities = _cache!;
      isFirstLoad = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    if (facilities.isEmpty) isFirstLoad = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getFacilities),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Facility.fromJson(e)).toList();
      _cache = newData;
      facilities = newData;
    }

    isLoading = false;
    isFirstLoad = false;
    notifyListeners();
  }

  Future<bool> deleteFacility(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteFacility(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      _cache = null;
      return true;
    }
    return false;
  }

  Future<void> saveFacility(Map<String, dynamic> body) async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse(GymServerApi.postFacility),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    _cache = null;
  }
}