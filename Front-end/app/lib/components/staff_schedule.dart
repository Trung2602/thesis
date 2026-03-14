// staff_schedule.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/models/Shift.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import 'package:gym/api.dart';
import 'package:gym/models/StaffSchedule.dart';
import 'package:gym/models/AccountProvider.dart';
import 'package:gym/models/Account.dart';

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Account? account;

  bool isLoading = false;
  List<StaffSchedule> schedulesForSelectedDay = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;

    // Load lịch hôm nay khi mở
    if (_selectedDay == null) {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _loadSchedulesForDay(_selectedDay!);
    }
  }

  Future<void> _loadSchedulesForDay(DateTime day) async {
    setState(() {
      isLoading = true;
    });

    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-"
        "${day.month.toString().padLeft(2, '0')}-"
        "${day.day.toString().padLeft(2, '0')}";

    try {
      final schedules = await getStaffSchedulesFilter(dateStr);
      setState(() {
        schedulesForSelectedDay = schedules;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải lịch: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<StaffSchedule>> getStaffSchedulesFilter(String date) async {
    final res = await http.get(Uri.parse("${Api.getStaffSchedulesFilter}?date=$date"));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => StaffSchedule.fromJson(e)).toList();
    }
    throw Exception("Lỗi load staff schedules");
  }

  Future<Map<String, dynamic>?> showShiftDialog(
      BuildContext context, List<dynamic> shifts) async {
    if (shifts.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Chưa có ca làm việc"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
      return null;
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chọn ca làm việc"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ListTile(
                title: Text("${shift['name']} (${shift['startTime']} - ${shift['endTime']})"),
                onTap: () => Navigator.of(context).pop(shift),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<StaffSchedule> postStaffSchedule(StaffSchedule schedule) async {
    final res = await http.post(
      Uri.parse(Api.postStaffSchedule),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(schedule.toJson()),
    );
    if (res.statusCode == 200) {
      return StaffSchedule.fromJson(jsonDecode(res.body));
    }
    throw Exception("Lỗi tạo staff schedule: ${res.body}");
  }

  Future<void> deleteStaffSchedule(int? id) async {
    if (id == null) throw Exception("ID null");

    final urlStr = Api.deleteStaffSchedule(id);
    final res = await http.delete(Uri.parse(urlStr));

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Xóa staff schedule thất bại: ${res.statusCode}");
    }
  }



  bool canDelete(DateTime date) {
    final today = DateTime.now();
    final twoDaysLater = DateTime(today.year, today.month, today.day + 2);
    return !date.isBefore(twoDaysLater);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lịch Làm Việc Nhân Viên",
            style: TextStyle(
              color: Color(0xFFFFAB40),
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))],
            ),
          ),
          const SizedBox(height: 20),

          // Calendar
          Card(
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadSchedulesForDay(selectedDay);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFFFD740)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFFFD740)),
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  todayDecoration: BoxDecoration(color: Color(0xFF2C318F), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFFFFAB40), shape: BoxShape.circle),
                  defaultTextStyle: TextStyle(color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              // Today button
              ElevatedButton(
                onPressed: () {
                  final today = DateTime.now();
                  setState(() {
                    _selectedDay = today;
                    _focusedDay = today;
                  });
                  _loadSchedulesForDay(today);
                },
                child: const Text("Today"),
              ),
              const SizedBox(width: 10),

              // Add Schedule button
              _selectedDay == null ||
                  _selectedDay!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2))
                  ? const SizedBox.shrink()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                onPressed: () async {
                  // 1. Lấy shifts từ API
                  List<dynamic> shifts = [];
                  try {
                    final res = await http.get(Uri.parse(Api.getShifts));
                    if (res.statusCode == 200) {
                      shifts = jsonDecode(res.body);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi tải ca làm việc: ${res.statusCode}")));
                      return;
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                    return;
                  }

                  // 2. Chọn shift
                  final selectedShift = await showShiftDialog(context, shifts);
                  if (selectedShift == null) return;

                  // 3. Tạo StaffSchedule mới
                  final newSchedule = StaffSchedule(
                    staffName: account!.name,
                    date: _selectedDay!,
                    shiftName: selectedShift["name"]
                  );

                  try {
                    final posted = await postStaffSchedule(newSchedule);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã thêm lịch staff: ${posted.date}")));
                    _loadSchedulesForDay(_selectedDay!);
                  } catch (e) {
                    if (e.toString().contains("409")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lịch bị trùng, không thể tạo")));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Lỗi khi thêm lịch staff: $e")));
                    }
                  }
                },
                child: const Text("Add Staff Schedule"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Lịch Làm Việc Trong Ngày:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 5, color: Colors.black54, offset: Offset(1, 1))],
            ),
          ),
          const SizedBox(height: 15),
          _selectedDay == null
              ? const Text("Hãy chọn một ngày để xem lịch làm việc",
              style: TextStyle(color: Colors.white70, fontSize: 16))
              : _buildEventListForSelectedDay(_selectedDay!),
        ],
      ),
    );
  }

  Widget _buildEventListForSelectedDay(DateTime day) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (schedulesForSelectedDay.isEmpty) {
      return Text(
        "Không có ca làm vào ngày ${day.toLocal().toString().split(' ')[0]}",
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    return Column(
      children: schedulesForSelectedDay.map((s) {
        return Card(
          color: Colors.white.withOpacity(0.15),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.schedule, color: Color(0xFFFFD740)),
            title: Text(
              s.shiftName ?? "",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Nhân viên: ${s.staffName}\nGiờ: ${s.checkIn?.format(context)} - ${s.checkOut?.format(context)}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: canDelete(s.date!)
                ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                try {
                  await deleteStaffSchedule(s.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã xóa lịch staff")));
                  _loadSchedulesForDay(_selectedDay!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi xóa lịch: $e")));
                }
              },
            )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
