import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/gym_server_api.dart';
import '../models/salary.dart';
import '../services/auth_service.dart';

class ManagerSalaryPage extends StatefulWidget {
  const ManagerSalaryPage({super.key});

  @override
  State<ManagerSalaryPage> createState() => _ManagerSalaryPageState();
}

class _ManagerSalaryPageState extends State<ManagerSalaryPage> {
  List<Salary> salaries = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;
  int page = 0;
  final int size = 20;
  int selectedMonth = DateTime.now().month;
  final yearController = TextEditingController(text: DateTime.now().year.toString());
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<Salary>> cache = {};
  String get cacheKey => "$selectedMonth-${yearController.text}";

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

  Future<void> fetchSalaries({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      salaries.clear();
      hasMore = true;
    }

    if (!isRefresh && cache.containsKey(cacheKey)) {
      setState(() {
        salaries = cache[cacheKey]!;
        isFirstLoad = false;
      });
      return;
    }

    setState(() => isLoading = true);

    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse("${GymServerApi.getSalariesFilter}?page=$page&size=$size&month=$selectedMonth&year=${yearController.text}"),
      headers: {
        "Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      final List data = json['content'];

      final newData = data.map((e) => Salary.fromJson(e)).toList();
      setState(() {
        salaries.addAll(newData);
        page++;
        isFirstLoad = false;
        if (newData.length < size) hasMore = false;
        cache[cacheKey] = salaries;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> payAllSalary() async {
    final token = await AuthService().getToken();
    await http.post(
      Uri.parse(GymServerApi.postSalariesForAllStaff),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    fetchSalaries(isRefresh: true);
  }

  Future<void> deleteSalary(String uuid) async {
    final token = await AuthService().getToken();
    await http.delete(
      Uri.parse(GymServerApi.deleteSalary(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );
    fetchSalaries(isRefresh: true);
  }

  void showDetail(Salary s) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1A237E),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.staffName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Colors.white24),

                buildInfoRow(Icons.calendar_today, "Ngày", s.date.toString()),
                buildInfoRow(Icons.access_time, "Giờ làm", "${s.duration}"),
                buildInfoRow(Icons.event_busy, "Ngày nghỉ", "${s.dayOff}"),
                buildInfoRow(Icons.attach_money, "Lương", "${s.price} VNĐ"),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      label: const Text(
                        "Đóng",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        deleteSalary(s.uuid!);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(Salary s) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // LEFT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.staffName,
                    style: const TextStyle(
                      color: Color(0xFFFFAB40),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("Lương: ${s.price ?? 0} VNĐ",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetail(s),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD740),
              ),
              child: const Text("Chi tiết",
                  style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
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

          IconButton(
            onPressed: () {
              setState(() {
                selectedMonth--;
                if (selectedMonth < 1) {
                  selectedMonth = 12;
                }
              });
              fetchSalaries(isRefresh: true);
            },
            icon: const Icon(Icons.arrow_left, color: Colors.white),
          ),

          Text("Tháng $selectedMonth", style: const TextStyle(color: Colors.white)),

          IconButton(
            onPressed: () {
              setState(() {
                selectedMonth++;
                if (selectedMonth > 12) {
                  selectedMonth = 1;
                }
              });
              fetchSalaries(isRefresh: true);
            },
            icon: const Icon(Icons.arrow_right, color: Colors.white),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () => fetchSalaries(isRefresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
            ),
            child: const Text("Xem",
                style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return now.month == selectedMonth &&
        now.year.toString() == yearController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý lương"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: Column(
        children: [
          buildHeader(),

          if (salaries.isEmpty && isCurrentMonth())
            ElevatedButton(
              onPressed: payAllSalary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Thanh toán lương tháng"),
            ),

          Expanded(
            child: isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: salaries.length + 1,
              itemBuilder: (context, index) {
                if (index < salaries.length) {
                  return buildCard(salaries[index]);
                }
                return hasMore ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ) : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text("Hết dữ liệu", style: TextStyle(color: Colors.white70)),
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