import 'package:flutter/material.dart';

import '../../../../models/salary.dart';
import '../providers/salary_provider.dart';
import '../widgets/salary_card.dart';
import '../../shared/widgets/manager_info_row.dart';
import '../../shared/widgets/month_year_header.dart';

class ManagerSalaryView extends StatefulWidget {
  const ManagerSalaryView({super.key});

  @override
  State<ManagerSalaryView> createState() => _ManagerSalaryViewState();
}

class _ManagerSalaryViewState extends State<ManagerSalaryView> {
  final _provider = SalaryProvider();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchSalaries();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchSalaries();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDetail(Salary s) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              ManagerInfoRow(icon: Icons.calendar_today, title: 'Ngày', value: s.date.toString()),
              ManagerInfoRow(icon: Icons.access_time, title: 'Giờ làm', value: '${s.duration}'),
              ManagerInfoRow(icon: Icons.event_busy, title: 'Ngày nghỉ', value: '${s.dayOff}'),
              ManagerInfoRow(icon: Icons.attach_money, title: 'Lương', value: '${s.price} VNĐ'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Đóng',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _provider.deleteSalary(s.uuid!);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Xóa',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lương'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: Column(
        children: [
          MonthYearHeader(
            selectedMonth: _provider.selectedMonth,
            yearController: _provider.yearController,
            onPrevMonth: () => _provider.changeMonth(-1),
            onNextMonth: () => _provider.changeMonth(1),
            onSearch: () => _provider.fetchSalaries(isRefresh: true),
          ),
          if (_provider.salaries.isEmpty && _provider.isCurrentMonth())
            ElevatedButton(
              onPressed: _provider.payAllSalary,
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Thanh toán lương tháng'),
            ),
          Expanded(
            child: _provider.isFirstLoad
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: _provider.salaries.length + 1,
              itemBuilder: (context, index) {
                if (index < _provider.salaries.length) {
                  return SalaryCard(
                    salary: _provider.salaries[index],
                    onTap: () =>
                        _showDetail(_provider.salaries[index]),
                  );
                }
                return _provider.hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator()),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Hết dữ liệu',
                        style: TextStyle(
                            color: Colors.white70)),
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