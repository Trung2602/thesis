import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/staff_day_off.dart';
import '../providers/day_off_provider.dart';
import '../widgets/day_off_card.dart';
import '../../shared/widgets/month_year_header.dart';

class ManagerDayOffView extends StatefulWidget {
  const ManagerDayOffView({super.key});

  @override
  State<ManagerDayOffView> createState() => _ManagerDayOffViewState();
}

class _ManagerDayOffViewState extends State<ManagerDayOffView> {
  final _provider = DayOffProvider();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchData();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDetail(StaffDayOff d) {
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
              const Row(
                children: [
                  Icon(Icons.event_busy, color: Colors.amber),
                  SizedBox(width: 10),
                  Text(
                    'Chi tiết ngày nghỉ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              Text(
                'Nhân viên: ${d.name ?? 'Không có tên'}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Ngày: ${DateFormat('dd/MM/yyyy').format(d.date)}',
                style: const TextStyle(color: Colors.white),
              ),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deleteItem(d.uuid);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa')),
                        );
                        _provider.fetchData(isRefresh: true);
                      }
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
        title: const Text('Quản lý ngày nghỉ'),
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
            onSearch: () => _provider.fetchData(isRefresh: true),
          ),
          if (_provider.isFirstLoad) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _provider.list.length + 1,
              itemBuilder: (context, index) {
                if (index < _provider.list.length) {
                  return DayOffCard(
                    dayOff: _provider.list[index],
                    onTap: () => _showDetail(_provider.list[index]),
                  );
                }
                return _provider.hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Hết dữ liệu',
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