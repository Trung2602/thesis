// body_log_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/user_server_api.dart';
import 'package:gym/models/body_log.dart';
import 'package:gym/models/goal.dart';
import 'package:gym/services/auth_service.dart';

class BodyLogProvider extends ChangeNotifier {
  List<BodyLog> bodyLogs = [];
  Goal? currentGoal;

  bool isLoading = false;
  bool isGoalLoading = false;

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===== BODY LOG =====
  Future<void> loadBodyLogs(String customerUuid) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse(UserServerApi.getBodyLogs(customerUuid)),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        bodyLogs = (jsonDecode(res.body) as List)
            .map((e) => BodyLog.fromJson(e))
            .toList();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createBodyLog(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse(UserServerApi.postBodyLog),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) return null;
      return jsonDecode(res.body)['message'] ?? 'Lỗi không xác định';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> updateBodyLog(String uuid, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(
        Uri.parse(UserServerApi.patchBodyLog(uuid)),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      if (res.statusCode == 200) return null;
      return jsonDecode(res.body)['message'] ?? 'Lỗi không xác định';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> deleteBodyLog(String uuid, String customerUuid) async {
    try {
      final res = await http.delete(
        Uri.parse(UserServerApi.deleteBodyLog(uuid)),
        headers: await _headers(),
      );
      if (res.statusCode == 204) {
        await loadBodyLogs(customerUuid);
        return null;
      }
      return 'Lỗi: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }

  // ===== GOAL =====
  Future<void> loadGoal() async {
    isGoalLoading = true;
    notifyListeners();
    try {
      final res = await http.get(
        Uri.parse(UserServerApi.getCurrentGoal),
        headers: await _headers(),
      );
      print('GOAL STATUS: ${res.statusCode}');
      print('GOAL BODY: ${res.body}');
      if (res.statusCode == 200 && res.body.isNotEmpty && res.body != 'null') {
        currentGoal = Goal.fromJson(jsonDecode(res.body));
      } else {
        currentGoal = null;
      }
    } finally {
      isGoalLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveGoal(Map<String, dynamic> data, {String? uuid}) async {
    try {
      final http.Response res;
      if (uuid != null) {
        // update
        res = await http.put(
          Uri.parse(UserServerApi.putGoal(uuid)),
          headers: await _headers(),
          body: jsonEncode(data),
        );
      } else {
        // create (hoặc upsert nếu đã có)
        res = await http.post(
          Uri.parse(UserServerApi.postGoal),
          headers: await _headers(),
          body: jsonEncode(data),
        );
      }
      if (res.statusCode == 200) {
        await loadGoal();
        return null;
      }
      return 'Lỗi: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> deleteGoal(String uuid) async {
    try {
      final res = await http.delete(
        Uri.parse(UserServerApi.deleteGoal(uuid)),
        headers: await _headers(),
      );
      if (res.statusCode == 204) {
        currentGoal = null;
        notifyListeners();
        return null;
      }
      return 'Lỗi: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String?> markAchieved(String uuid) async {
    try {
      final res = await http.patch(
        Uri.parse(UserServerApi.achieveGoal(uuid)),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        await loadGoal();
        return null;
      }
      return 'Lỗi: ${res.statusCode}';
    } catch (e) {
      return 'error: $e';
    }
  }
}