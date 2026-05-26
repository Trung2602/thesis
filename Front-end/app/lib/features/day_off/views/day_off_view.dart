import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/day_off_provider.dart';
import '../widgets/day_off_card.dart';

class DayOffView extends StatefulWidget {
  const DayOffView({super.key});

  @override
  State<DayOffView> createState() => _DayOffViewState();
}

class _DayOffViewState extends State<DayOffView> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  late final DayOffProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DayOffProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    if (account != null) {
      _provider.fetchByMonth(_selectedMonth, _selectedYear);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Future<void> _handleRegister() async {
    final account = Provider.of<AccountProvider>(context, listen: false).account;
    if (account?.facilityUuid == null) {
      _showMsg('Không tìm thấy cơ sở của bạn', isError: true);
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (!mounted || picked == null) return;

    final error = await _provider.registerDayOff(
        picked, account!.facilityUuid!, _selectedMonth, _selectedYear);
    if (!mounted) return;

    if (error == null) {
      _showMsg('Đăng ký nghỉ thành công ngày ${picked.day}/${picked.month}/${picked.year}');
    } else if (error == 'duplicate') {
      _showMsg('Ngày ${picked.day}/${picked.month}/${picked.year} đã xin nghỉ rồi.', isError: true);
    } else {
      _showMsg('Lỗi đăng ký nghỉ ($error)', isError: true);
    }
  }

  Future<void> _handleDelete(String uuid, DateTime date) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
            'Bạn có chắc muốn xoá ngày ${date.day}/${date.month}/${date.year}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xoá',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true) return;

    final error =
    await _provider.deleteDayOff(uuid, _selectedMonth, _selectedYear);
    if (!mounted) return;

    if (error == null) {
      _showMsg('Xoá ngày nghỉ thành công');
    } else if (error == 'not_found') {
      _showMsg('Ngày nghỉ không tồn tại hoặc đã bị xoá', isError: true);
    } else {
      _showMsg('Lỗi khi xoá: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<DayOffProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filter tháng/năm
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        dropdownColor: const Color(0xFF1A237E),
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Tháng',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white70)),
                        ),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text('Tháng $m',
                              style: const TextStyle(
                                  color: Colors.white)),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMonth = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        dropdownColor: const Color(0xFF1A237E),
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Năm',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white70)),
                        ),
                        items: List.generate(
                            10, (i) => DateTime.now().year - 5 + i)
                            .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y',
                              style: const TextStyle(
                                  color: Colors.white)),
                        ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedYear = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => provider.fetchByMonth(
                          _selectedMonth, _selectedYear),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD740),
                          foregroundColor: Colors.black),
                      child: const Text('Xem'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD740),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Xin Nghỉ',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Danh sách ngày nghỉ đã đăng ký:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: provider.isFirstLoad || provider.isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white))
                      : provider.registeredDaysOff.isEmpty
                      ? const Center(
                    child: Text(
                      'Không có ngày nghỉ nào trong tháng này.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ) : ListView.builder(
                    itemCount: provider.registeredDaysOff.length,
                    itemBuilder: (context, index) {
                      final item = provider.registeredDaysOff[index];
                      if (item.date == null || item.uuid == null) return const SizedBox.shrink();

                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final showDelete = item.date!.isAfter(today.add(const Duration(days: 1)));

                      return DayOffCard(
                        date: item.date!,
                        approved: item.approved,
                        showDelete: showDelete,
                        onDelete: () => _handleDelete(item.uuid!, item.date!),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}