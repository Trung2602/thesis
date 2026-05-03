import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/cache/app_cache.dart';
import 'package:gym/models/account.dart';
import 'package:gym/models/pay_customer.dart';
import 'package:gym/services/auth_service.dart';

class PaymentProvider extends ChangeNotifier {
  final cache = AppCache().payCustomerCache;

  List<PayCustomer> allData = [];
  List<PayCustomer> payList = [];
  int visibleCount = 5;
  bool isLoading = false;
  bool isLoadingMore = false;

  Future<void> fetchPayCustomers(String userUuid) async {
    if (cache.containsKey(userUuid)) {
      allData = cache[userUuid]!;
      visibleCount = 5;
      payList = allData.take(visibleCount).toList();
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse(GymServerApi.getPayCustomers),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final result = (jsonDecode(res.body) as List)
            .map((e) => PayCustomer.fromJson(e))
            .toList();
        cache[userUuid] = result;
        allData = result;
        visibleCount = 5;
        payList = allData.take(visibleCount).toList();
      }
    } catch (e) {
      debugPrint('Fetch pay error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (visibleCount >= allData.length || isLoadingMore) return;
    isLoadingMore = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      visibleCount += 5;
      payList = allData.take(visibleCount).toList();
      isLoadingMore = false;
      notifyListeners();
    });
  }

  Future<List<dynamic>> fetchPlans() async {
    final res = await http.get(Uri.parse(GymServerApi.getPlans));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Lỗi tải gói: ${res.statusCode}');
  }

  Future<String?> createPayment(String planUuid) async {
    try {
      final token = await AuthService().getToken();
      final res = await http.post(
        Uri.parse(GymServerApi.createPayment),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'planUuid': planUuid}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['paymentUrl'];
      }
      throw Exception('Lỗi tạo thanh toán: ${res.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Account?> refreshAccount() async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse(UserServerApi.me),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return Account.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('Refresh account error: $e');
    }
    return null;
  }
}