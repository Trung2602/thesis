import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../api/user_server_api.dart';
import '../../../../cache/manager_cache.dart';
import '../../../../models/account.dart';
import '../../../../models/account_lite.dart';
import '../../../../models/facility.dart';
import '../../../../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  List<AccountLite> users = [];
  bool isLoading = true;

  Future<void> fetchUsers({required String role}) async {
    isLoading = true;
    notifyListeners();

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse('${UserServerApi.loadAccount}?role=$role'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      users = data.map((e) => AccountLite.fromJson(e)).toList();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<List<Facility>> fetchFacilities() async {
    final cached = ManagerCache().facilityManagerCache['all'];
    if (cached != null && cached.isNotEmpty) return cached;

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getFacilities),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final facilities = data.map((e) => Facility.fromJson(e)).toList();
      ManagerCache().facilityManagerCache['all'] = facilities;
      return facilities;
    }
    return [];
  }

  Future<Account> fetchDetail(String uuid, String role) async {
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(_getDetailApi(role, uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return Account.fromJson(jsonDecode(res.body));
    throw Exception('Load detail failed');
  }

  Future<void> deleteUser(String uuid) async {
    final token = await AuthService().getToken();
    await http.delete(
      Uri.parse(UserServerApi.deleteAccount(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> saveUser({
    required String? uuid,
    required String role,
    required Map<String, dynamic> bodyMap,
  }) async {
    final token = await AuthService().getToken();
    final url = uuid == null ? _getCreateApi(role) : _getUpdateApi(role);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    if (uuid == null) {
      await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(bodyMap));
    } else {
      await http.patch(Uri.parse(url),
          headers: headers, body: jsonEncode(bodyMap));
    }
  }

  String _getDetailApi(String role, String uuid) {
    switch (role) {
      case 'ADMIN':
        return UserServerApi.getAdminByUuid(uuid);
      case 'STAFF':
        return UserServerApi.getStaffByUuid(uuid);
      case 'CUSTOMER':
        return UserServerApi.getCustomerByUuid(uuid);
      default:
        throw Exception('Invalid role');
    }
  }

  String _getCreateApi(String role) {
    switch (role) {
      case 'ADMIN':
        return UserServerApi.postAdmin;
      case 'STAFF':
        return UserServerApi.postStaff;
      case 'CUSTOMER':
        return UserServerApi.postCustomer;
      default:
        throw Exception('Invalid role');
    }
  }

  String _getUpdateApi(String role) {
    switch (role) {
      case 'ADMIN':
        return UserServerApi.patchAdmin;
      case 'STAFF':
        return UserServerApi.patchStaff;
      case 'CUSTOMER':
        return UserServerApi.patchCustomer;
      default:
        throw Exception('Invalid role');
    }
  }

  String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
}