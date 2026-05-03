import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../models/pay_customer.dart';
import '../../../../services/auth_service.dart';

class PayCustomerProvider extends ChangeNotifier {
  List<PayCustomer> list = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;

  int page = 0;
  final int size = 10;
  String sortField = 'date';
  String sortDir = 'desc';

  Future<void> fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      list.clear();
      hasMore = true;
    }

    isLoading = true;
    isFirstLoad = list.isEmpty;
    notifyListeners();

    final token = await AuthService().getToken();
    final url = '${GymServerApi.getPayCustomersSort}?sortField=$sortField&sortDir=$sortDir&page=$page&size=$size';

    try {
      final res = await http.get(Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'});

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List content = json['content'];
        final newData =
        content.map((e) => PayCustomer.fromJson(e)).toList();
        list.addAll(newData);
        page++;
        hasMore = page < json['totalPages'];
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoading = false;
      isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deletePayCustomer(uuid)),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      list.removeWhere((e) => e.uuid == uuid);
      notifyListeners();
      return true;
    }
    return false;
  }
}