import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../cache/app_cache.dart';
import '../models/account.dart';
import '../models/account_provider.dart';
import '../models/staff_day_off.dart';

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

  bool _loading = false;
  bool isFirstLoad = true;
  final cache = AppCache().staffDayOffCache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
    if (account != null) {
      fetchStaffDayOffsByMonth(_selectedMonth, _selectedYear);
    }
  }

  Future<void> fetchStaffDayOffsByMonth(int month, int year) async {
    final key = "$month-$year";
    if (cache.containsKey(key)) {
      setState(() {
        _registeredDaysOff = cache[key]!;
        isFirstLoad = false;
      });
      return;
    }
    if (isFirstLoad) {
      setState(() => isFirstLoad = true);
    } else {
      setState(() => _loading = true);
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final url = Uri.parse(Api.getStaffDayOffs).replace(
      queryParameters: {
        "month": month.toString(),
        "year": year.toString(),
      },
    );
    try {
      final res = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        final data = StaffDayOff.fromJsonList(body);
        cache[key] = data;
        if (cache.length > 12) {
          cache.remove(cache.keys.first);
        }

        setState(() {
          _registeredDaysOff = data;
          isFirstLoad = false;
        });
      }
    } catch (e) {
      debugPrint("Exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          isFirstLoad = false;
        });
      }
    }
  }

  void showMsg(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _registerDayOff() async {
    if (account == null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (!mounted) return;
    if (picked == null) return;

    bool exists = _registeredDaysOff.any((d) =>
        d.date.year == picked.year &&
        d.date.month == picked.month &&
        d.date.day == picked.day);

    if (exists) {
      showMsg("Ngày ${picked.day}/${picked.month}/${picked.year} đã xin nghỉ rồi.", isError: true);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(Api.postStaffDayOff),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "date": picked.toIso8601String().split("T")[0],
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        showMsg("Đăng ký nghỉ thành công ngày ${picked.day}/${picked.month}/${picked.year}");
        cache.remove("$_selectedMonth-$_selectedYear");
        fetchStaffDayOffsByMonth(_selectedMonth, _selectedYear);
      } else {
        showMsg("Lỗi đăng ký nghỉ (${res.statusCode})", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi: $e", isError: true);
    }
  }

  Future<void> _deleteDayOff(String uuid) async {
    try {
      final res = await http.delete(Uri.parse(Api.deleteStaffDayOff(uuid)));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 204) {
        cache.remove("$_selectedMonth-$_selectedYear");
        setState(() {
          _registeredDaysOff.removeWhere((d) => d.uuid == uuid);
        });
        showMsg("Xoá ngày nghỉ thành công");
      } else if (res.statusCode == 404) {
        showMsg("Ngày nghỉ không tồn tại hoặc đã bị xoá", isError: true);
      } else {
        showMsg("Lỗi khi xoá: ${res.statusCode}", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showMsg("Không thể kết nối server: $e", isError: true);
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
                    initialValue: _selectedMonth,
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
                    initialValue: _selectedYear,
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
                    final key = "$_selectedMonth-$_selectedYear";
                    setState(() {
                      if (!cache.containsKey(key)) {
                        _loading = true;
                      }
                    });
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
              child: isFirstLoad
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : _loading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : _registeredDaysOff.isEmpty
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

                  // Lấy ngày hôm nay
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  // Điều kiện hiện nút xoá: chỉ khi ngày > hôm nay + 1
                  final showDelete = day.isAfter(today.add(const Duration(days: 1)));

                  return Card(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                      leading: const Icon(Icons.event_available, color: Colors.white70),
                      title: Text(
                        '${day.day}/${day.month}/${day.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "Ngày nghỉ đã đăng ký",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),

                      trailing: showDelete ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: "Xoá ngày nghỉ",
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Xác nhận"),
                              content: Text(
                                  "Bạn có chắc muốn xoá ngày ${day.day}/${day.month}/${day.year}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Huỷ"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Xoá",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteDayOff(_registeredDaysOff[index].uuid);
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
