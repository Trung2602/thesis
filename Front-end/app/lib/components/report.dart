import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';

class ReportDashboardPage extends StatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  State<ReportDashboardPage> createState() => _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  String type = "MONTH"; // MONTH | QUARTER | YEAR

  int month = DateTime.now().month;
  int year = DateTime.now().year;
  int quarter = 1;

  List<double> expenseData = [];
  List<double> revenueData = [];

  double totalExpense = 0;
  double totalRevenue = 0;
  double profit = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  // ================= FETCH =================
  Future<void> fetchReport() async {
    setState(() => isLoading = true);

    final token = await AuthService().getToken();

    try {
      final res = await http.get(
        Uri.parse(
          "${GymServerApi.getReport}?type=$type&month=$month&year=$year&quarter=$quarter",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        debugPrint("STATUS: ${res.statusCode}");
        debugPrint("BODY: ${res.body}");
        setState(() {
          expenseData = List<double>.from(data['expense'] ?? []);
          revenueData = List<double>.from(data['revenue'] ?? []);
          totalExpense = (data['totalExpense'] ?? 0).toDouble();
          totalRevenue = (data['totalRevenue'] ?? 0).toDouble();
          profit = totalRevenue - totalExpense;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= BAR CHART =================
  Widget buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(expenseData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: expenseData[i],
                  color: Colors.red,
                  width: 8,
                ),
                BarChartRodData(
                  toY: revenueData[i],
                  color: Colors.blue,
                  width: 8,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ================= PIE CHART =================
  Widget buildPieChart() {
    double total = totalRevenue + totalExpense;

    double revenuePercent = total == 0 ? 0 : (totalRevenue / total) * 100;
    double expensePercent = total == 0 ? 0 : (totalExpense / total) * 100;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: revenuePercent,
              color: Colors.blue,
              title: "${revenuePercent.toStringAsFixed(1)}%",
            ),
            PieChartSectionData(
              value: expensePercent,
              color: Colors.red,
              title: "${expensePercent.toStringAsFixed(1)}%",
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER =================
  Widget buildFilter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTypeButton("MONTH", "Tháng"),
            buildTypeButton("QUARTER", "Quý"),
            buildTypeButton("YEAR", "Năm"),
          ],
        ),
        const SizedBox(height: 10),

        // ===== MONTH =====
        if (type == "MONTH")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    month = month > 1 ? month - 1 : 12;
                  });
                  fetchReport();
                },
                icon: const Icon(Icons.arrow_left, color: Colors.white),
              ),
              Text(
                "Tháng $month/$year",
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    month = month < 12 ? month + 1 : 1;
                  });
                  fetchReport();
                },
                icon: const Icon(Icons.arrow_right, color: Colors.white),
              ),
            ],
          ),

        // ===== QUARTER =====
        if (type == "QUARTER")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              int q = i + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => quarter = q);
                    fetchReport();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quarter == q ? Colors.orange : Colors.grey,
                  ),
                  child: Text("Q$q"),
                ),
              );
            }),
          ),

        // ===== YEAR =====
        if (type == "YEAR")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() => year--);
                  fetchReport();
                },
                icon: const Icon(Icons.arrow_left, color: Colors.white),
              ),
              Text("$year", style: const TextStyle(color: Colors.white)),
              IconButton(
                onPressed: () {
                  setState(() => year++);
                  fetchReport();
                },
                icon: const Icon(Icons.arrow_right, color: Colors.white),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildTypeButton(String t, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() => type = t);
          fetchReport();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: type == t ? Colors.orange : Colors.grey,
        ),
        child: Text(label),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo cáo thống kê"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  buildFilter(),

                  const SizedBox(height: 20),

                  Text(
                    "Doanh thu: $totalRevenue",
                    style: const TextStyle(color: Colors.blue),
                  ),

                  Text(
                    "Chi tiêu: $totalExpense",
                    style: const TextStyle(color: Colors.red),
                  ),

                  Text(
                    "Lợi nhuận: $profit",
                    style: TextStyle(
                      color: profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Tỷ lệ thu / chi",
                    style: TextStyle(color: Colors.white),
                  ),

                  buildPieChart(),

                  const SizedBox(height: 20),

                  const Text(
                    "Biểu đồ dòng tiền",
                    style: TextStyle(color: Colors.white),
                  ),

                  buildBarChart(),
                ],
              ),
            ),
    );
  }
}
