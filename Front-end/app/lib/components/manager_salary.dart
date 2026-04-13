import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/salary.dart';
import '../services/auth_service.dart';
import '../api/api.dart';

class ManagerSalaryPage extends StatefulWidget {
  const ManagerSalaryPage({super.key});

  @override
  State<ManagerSalaryPage> createState() => _ManagerSalaryPageState();
}

class _ManagerSalaryPageState extends State<ManagerSalaryPage> {
  List<Salary> salaries = [];

  bool isLoading = false;
  bool hasMore = true;

  int page = 0;
  final int size = 20;

  int selectedMonth = DateTime.now().month;
  final yearController =
  TextEditingController(text: DateTime.now().year.toString());

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSalaries();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchSalaries();
      }
    });
  }

  // ================= FETCH =================
  Future<void> fetchSalaries({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (isRefresh) {
      page = 0;
      salaries.clear();
      hasMore = true;
    }

    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(
          "${Api.getSalaries}?page=$page&size=$size&month=$selectedMonth&year=${yearController.text}"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      final newData = data.map((e) => Salary.fromJson(e)).toList();

      setState(() {
        salaries.addAll(newData);
        page++;
        if (newData.length < size) hasMore = false;
      });
    }

    setState(() => isLoading = false);
  }

  // ================= CARD =================
  Widget buildSalaryCard(Salary s) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.staffName,
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            Text("Ngày: ${s.date?.toString().split(' ')[0] ?? ''}",
                style: const TextStyle(color: Colors.white70)),

            Text("Số giờ: ${s.duration ?? 0}",
                style: const TextStyle(color: Colors.white70)),

            Text("Ngày nghỉ: ${s.dayOff ?? 0}",
                style: const TextStyle(color: Colors.white70)),

            Text("Lương: ${s.price ?? 0} VNĐ",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ================= FILTER =================
  Widget buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Month dropdown
          DropdownButton<int>(
            value: selectedMonth,
            dropdownColor: const Color(0xFF1A237E),
            items: List.generate(12, (i) => i + 1)
                .map((m) => DropdownMenuItem(
              value: m,
              child: Text("Tháng $m",
                  style: const TextStyle(color: Colors.white)),
            ))
                .toList(),
            onChanged: (val) {
              setState(() => selectedMonth = val!);
            },
          ),

          const SizedBox(width: 10),

          // Year input
          SizedBox(
            width: 80,
            child: TextField(
              controller: yearController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Năm",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: () {
              fetchSalaries(isRefresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
            ),
            child: const Text("Kiểm tra", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý lương"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: Column(
        children: [
          buildFilter(),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: salaries.length + 1,
              itemBuilder: (context, index) {
                if (index < salaries.length) {
                  return buildSalaryCard(salaries[index]);
                }

                // loading cuối list
                return hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text("Hết dữ liệu",
                        style: TextStyle(color: Colors.white70)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}