import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/report_provider.dart';
import '../widgets/report_filter.dart';

class ReportDashboardView extends StatefulWidget {
  const ReportDashboardView({super.key});

  @override
  State<ReportDashboardView> createState() => _ReportDashboardViewState();
}

class _ReportDashboardViewState extends State<ReportDashboardView> {
  final _provider = ReportProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchReport();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(_provider.expenseData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                    toY: _provider.expenseData[i],
                    color: Colors.red,
                    width: 8),
                BarChartRodData(
                    toY: _provider.revenueData[i],
                    color: Colors.blue,
                    width: 8),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _provider.totalRevenue + _provider.totalExpense;
    final revenuePercent =
    total == 0 ? 0.0 : (_provider.totalRevenue / total) * 100;
    final expensePercent =
    total == 0 ? 0.0 : (_provider.totalExpense / total) * 100;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: revenuePercent,
              color: Colors.blue,
              title: '${revenuePercent.toStringAsFixed(1)}%',
            ),
            PieChartSectionData(
              value: expensePercent,
              color: Colors.red,
              title: '${expensePercent.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: _provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ── Filter ──
            ReportFilter(provider: _provider),
            const SizedBox(height: 20),

            // ── Summary ──
            Text(
              'Doanh thu: ${_provider.totalRevenue}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'Chi tiêu: ${_provider.totalExpense}',
              style: const TextStyle(color: Colors.red),
            ),
            Text(
              'Lợi nhuận: ${_provider.profit}',
              style: TextStyle(
                color: _provider.profit >= 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // ── Pie chart ──
            const Text('Tỷ lệ thu / chi',
                style: TextStyle(color: Colors.white)),
            _buildPieChart(),
            const SizedBox(height: 20),

            // ── Bar chart ──
            const Text('Biểu đồ dòng tiền',
                style: TextStyle(color: Colors.white)),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }
}