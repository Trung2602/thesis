import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Account.dart';
import '../models/AccountProvider.dart';
import '../models/Salary.dart';
import '../api.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  Account? account;
  List<Salary> salaries = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
    if (account != null) {
      fetchSalaries(account!.id);
    }
  }

  Future<void> fetchSalaries(int staffId) async {
    try {
      final response = await http.get(Uri.parse(Api.getSalaries(staffId)));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          salaries = jsonData.map((e) => Salary.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Fetch salaries error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : salaries.isEmpty
          ? const Center(
        child: Text(
          "Chưa có dữ liệu lương",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: salaries.length,
        itemBuilder: (context, index) {
          final salary = salaries[index];
          return Card(
            color: Colors.white.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${salary.date.month}/${salary.date.year}",
                    style: const TextStyle(
                      color: Color(0xFFFFAB40),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số ngày nghỉ:",
                          style: TextStyle(color: Colors.white70)),
                      Text("${salary.dayOff}",
                          style:
                          const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số giờ làm:",
                          style: TextStyle(color: Colors.white70)),
                      Text("${salary.duration} giờ",
                          style:
                          const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng lương:",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                      Text("${salary.price} VND",
                          style: const TextStyle(
                              color: Color(0xFFFFD740),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
