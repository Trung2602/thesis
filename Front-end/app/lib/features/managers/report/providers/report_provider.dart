import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../api/gym_server_api.dart';
import '../../../../services/auth_service.dart';

class ReportProvider extends ChangeNotifier {
  String type = 'MONTH'; // MONTH | QUARTER | YEAR
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  int quarter = 1;

  List<double> expenseData = [];
  List<double> revenueData = [];
  double totalExpense = 0;
  double totalRevenue = 0;
  double profit = 0;
  bool isLoading = false;

  Future<void> fetchReport() async {
    isLoading = true;
    notifyListeners();

    final token = await AuthService().getToken();
    try {
      final res = await http.get(
        Uri.parse(
          '${GymServerApi.getReport}?type=$type&month=$month&year=$year&quarter=$quarter',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        expenseData = List<double>.from(data['expense'] ?? []);
        revenueData = List<double>.from(data['revenue'] ?? []);
        totalExpense = (data['totalExpense'] ?? 0).toDouble();
        totalRevenue =
            (data['totalRevenue'] ?? 0).toDouble() + 100000000;
        profit = totalRevenue - totalExpense;
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setType(String t) {
    type = t;
    notifyListeners();
    fetchReport();
  }

  void changeMonth(int delta) {
    month += delta;
    if (month < 1) month = 12;
    if (month > 12) month = 1;
    notifyListeners();
    fetchReport();
  }

  void changeYear(int delta) {
    year += delta;
    notifyListeners();
    fetchReport();
  }

  void setQuarter(int q) {
    quarter = q;
    notifyListeners();
    fetchReport();
  }
}