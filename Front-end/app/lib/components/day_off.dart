import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../api.dart';
import '../models/Account.dart';
import '../models/AccountProvider.dart';
import '../models/StaffDayOff.dart';

class DayOff extends StatefulWidget {
  const DayOff({super.key});

  @override
  State<DayOff> createState() => _DayOffState();
}

class _DayOffState extends State<DayOff> {
  List<StaffDayOff> _registeredDaysOff = [];
  Account? account;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
    if (account != null) {
      fetchStaffDayOffsByMonth(_selectedMonth, _selectedYear);
    }
  }

  Future<void> fetchStaffDayOffsByMonth(int month, int year) async {
    int staffId = Provider.of<AccountProvider>(context, listen: false).account!.id;
    final url = Uri.parse(
        "${Api.getStaffDayOffsFilter}?staffId=$staffId&month=$month&year=$year");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        setState(() {
          _registeredDaysOff = StaffDayOff.fromJsonList(body);
        });
      } else {
        debugPrint("Lỗi load day off: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetchStaffDayOffsByMonth: $e");
    }
  }

  Future<void> _registerDayOff() async {
    if (account == null) return;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // không cho chọn ngày quá khứ
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (picked == null) return;

    // Kiểm tra xem đã có trong danh sách chưa
    bool exists = _registeredDaysOff.any((d) =>
    d.date.year == picked.year &&
        d.date.month == picked.month &&
        d.date.day == picked.day);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ngày ${picked.day}/${picked.month}/${picked.year} đã xin nghỉ rồi.")),
      );
      return;
    }

    try {
      final url = Uri.parse(Api.postStaffDayOff);
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "staffName": account!.name,
          "date": picked.toIso8601String().split("T")[0], // yyyy-MM-dd
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký nghỉ thành công ngày ${picked.day}/${picked.month}/${picked.year}")),
        );
        // Load lại danh sách
        fetchStaffDayOffsByMonth(_selectedMonth, _selectedYear);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng ký nghỉ (${res.statusCode})")),
        );
      }
    } catch (e) {
      debugPrint("Exception postStaffDayOff: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra khi đăng ký nghỉ.")),
      );
    }
  }

  Future<void> _deleteDayOff(int id) async {
    final url = Uri.parse(Api.deleteStaffDayOff(id));
    try {
      final res = await http.delete(url);

      if (res.statusCode == 200 || res.statusCode == 204) {
        // Xoá thành công => cập nhật lại danh sách trong state
        setState(() {
          _registeredDaysOff.removeWhere((dayOff) => dayOff.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xoá ngày nghỉ thành công")),
        );
      } else if (res.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ngày nghỉ không tồn tại hoặc đã bị xoá")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi xoá: ${res.statusCode} - ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể kết nối server: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ================== Bộ lọc tháng năm ==================
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1A237E),
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: "Tháng",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text("Tháng $m",
                          style: const TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedMonth = val!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1A237E),
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: "Năm",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                    items: List.generate(10, (i) => DateTime.now().year - 5 + i)
                        .map((y) => DropdownMenuItem(
                      value: y,
                      child: Text("$y",
                          style: const TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedYear = val!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    fetchStaffDayOffsByMonth(_selectedMonth, _selectedYear);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD740),
                      foregroundColor: Colors.black),
                  child: const Text("Xem"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nút xin nghỉ
            ElevatedButton(
              onPressed: _registerDayOff,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD740),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Xin Nghỉ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
              child: _registeredDaysOff.isEmpty
                  ? const Center(
                child: Text(
                  'Không có ngày nghỉ nào trong tháng này.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                itemCount: _registeredDaysOff.length,
                itemBuilder: (context, index) {
                  final day = _registeredDaysOff[index].date;

                  // Lấy ngày hôm nay (không kèm giờ phút giây)
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  // Điều kiện hiện nút xoá: chỉ khi ngày > hôm nay + 1
                  final showDelete =
                  day.isAfter(today.add(const Duration(days: 1)));

                  return Card(
                    color: Colors.white.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.beach_access,
                          color: Colors.white70),
                      title: Text(
                        '${day.day}/${day.month}/${day.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: showDelete
                          ? IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Xác nhận"),
                              content: Text(
                                  "Bạn có chắc muốn xoá ngày nghỉ ${day.day}/${day.month}/${day.year}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Huỷ"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Xoá",
                                      style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteDayOff(_registeredDaysOff[index].id);
                          }
                        },
                      )
                          : null,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
