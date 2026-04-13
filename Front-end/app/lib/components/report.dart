import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../api/api.dart';

class ReportDashboardPage extends StatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  State<ReportDashboardPage> createState() => _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  String type = "MONTH"; // MONTH | QUARTER | YEAR
  int month = DateTime.now().month;
  int year = DateTime.now().year;

  List<double> salaryData = [];
  List<double> revenueData = [];

  double totalSalary = 0;
  double totalRevenue = 0;

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

    final res = await http.get(
      Uri.parse(
          "${Api.report}?type=$type&month=$month&year=$year"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      setState(() {
        salaryData = List<double>.from(data['salary']);
        revenueData = List<double>.from(data['revenue']);
        totalSalary = data['totalSalary'];
        totalRevenue = data['totalRevenue'];
      });
    }

    setState(() => isLoading = false);
  }

  // ================= BAR CHART =================
  Widget buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(salaryData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: salaryData[i],
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
    double profit = totalRevenue - totalSalary;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: totalRevenue,
              color: Colors.blue,
              title: "Thu",
            ),
            PieChartSectionData(
              value: totalSalary,
              color: Colors.red,
              title: "Chi",
            ),
            PieChartSectionData(
              value: profit > 0 ? profit : 0,
              color: Colors.green,
              title: "Lãi",
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (type == "MONTH")
              DropdownButton<int>(
                value: month,
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text("Tháng $m"),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() => month = val!);
                },
              ),

            const SizedBox(width: 10),

            SizedBox(
              width: 80,
              child: TextField(
                controller:
                TextEditingController(text: year.toString()),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  year = int.tryParse(val) ?? year;
                },
                decoration: const InputDecoration(hintText: "Năm"),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: fetchReport,
              child: const Text("Xem"),
            )
          ],
        )
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
          backgroundColor:
          type == t ? Colors.orange : Colors.grey,
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

            const Text("So sánh dòng tiền",
                style: TextStyle(color: Colors.white)),

            buildBarChart(),

            const SizedBox(height: 20),

            const Text("Lợi nhuận",
                style: TextStyle(color: Colors.white)),

            buildPieChart(),

            const SizedBox(height: 20),

            Text(
              "Tổng thu: $totalRevenue | Tổng chi: $totalSalary",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}