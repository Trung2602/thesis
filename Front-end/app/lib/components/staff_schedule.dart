import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import 'package:gym/models/staff_schedule.dart';
import 'package:gym/models/account_provider.dart';
import 'package:gym/models/account.dart';

import '../api/gym_server_api.dart';
import '../cache/app_cache.dart';
import '../services/auth_service.dart';

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
  List<StaffSchedule> schedulesForSelectedDay = [];

  bool _loading = false;
  bool isFirstLoad = true;

  final cache = AppCache().staffScheduleCache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;

    if (_selectedDay == null) {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _loadSchedulesForDay(_selectedDay!);
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

  String formatDate(DateTime day) {
    return "${day.year.toString().padLeft(4, '0')}-"
        "${day.month.toString().padLeft(2, '0')}-"
        "${day.day.toString().padLeft(2, '0')}";
  }

  bool canDelete(DateTime date) {
    final today = DateTime.now();
    final limit = DateTime(today.year, today.month, today.day + 2);
    return !date.isBefore(limit);
  }

  Future<void> deleteStaffSchedule(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteStaffSchedule(uuid)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Xóa thất bại: ${res.statusCode}");
    }
  }

  Future<void> _loadSchedulesForDay(DateTime day) async {
    final dateString = formatDate(day);
    if (cache.containsKey(dateString)) {
      setState(() {
        schedulesForSelectedDay = cache[dateString]!;
        isFirstLoad = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      isFirstLoad = true;
    });
    final token = await AuthService().getToken();
    try {
      final uri = Uri.parse(GymServerApi.getStaffSchedulesFilterByStaff)
          .replace(queryParameters: {'date': dateString});

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;
      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }
      final List data = jsonDecode(response.body);
      final schedules = data.map((e) => StaffSchedule.fromJson(e)).toList();
      cache[dateString] = schedules;
      setState(() {
        schedulesForSelectedDay = schedules;
      });
    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi khi tải lịch: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          isFirstLoad = false;
        });
      }
    }
  }

  Future<void> _handleAddSchedule() async {
    if (_selectedDay == null) return;

    final token = await AuthService().getToken();
    List<dynamic> shifts = [];

    try {
      final res = await http.get(
        Uri.parse(GymServerApi.getShifts),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;

      if (res.statusCode == 200) {
        shifts = jsonDecode(res.body);
      } else {
        showMsg("Lỗi tải ca làm việc: ${res.statusCode}", isError: true);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi: $e", isError: true);
      return;
    }
    final selectedShift = await _showShiftDialog(shifts);
    if (!mounted) return;
    if (selectedShift == null) return;

    final newSchedule = StaffSchedule(
      staffUuid: account!.uuid,
      date: _selectedDay!,
      shiftUuid: selectedShift["uuid"],
    );

    try {
      final res = await http.post(
        Uri.parse(GymServerApi.postStaffSchedule),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newSchedule.toJson()),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        showMsg("Đã thêm lịch staff");
        cache.remove(formatDate(_selectedDay!));
        await _loadSchedulesForDay(_selectedDay!);
      } else if (res.statusCode == 409) {
        showMsg("Lịch bị trùng, không thể tạo", isError: true);
      } else {
        showMsg("Lỗi khi tạo lịch: ${res.statusCode}", isError: true);
      }

    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi: $e", isError: true);
    }
  }

  Future<void> _handleDelete(String uuid) async {
    try {
      await deleteStaffSchedule(uuid);
      if (!mounted) return;

      showMsg("Đã xóa lịch staff");
      cache.remove(formatDate(_selectedDay!));
      await _loadSchedulesForDay(_selectedDay!);
    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi xóa lịch: $e", isError: true);
    }
  }

  Future<Map<String, dynamic>?> _showShiftDialog(List<dynamic> shifts) async {
    if (shifts.isEmpty) {
      showMsg("Chưa có ca làm việc", isError: true);
      return null;
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Chọn ca làm việc"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ListTile(
                title: Text(
                  "${shift['name']} (${shift['checkin']} - ${shift['checkout']})",
                ),
                onTap: () => Navigator.of(dialogContext).pop(shift),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
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
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            leftChevronIcon:
            Icon(Icons.chevron_left, color: Color(0xFFFFD740)),
            rightChevronIcon:
            Icon(Icons.chevron_right, color: Color(0xFFFFD740)),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.redAccent),
            todayDecoration:
            BoxDecoration(color: Color(0xFF2C318F), shape: BoxShape.circle),
            selectedDecoration:
            BoxDecoration(color: Color(0xFFFFAB40), shape: BoxShape.circle),
            defaultTextStyle: TextStyle(color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.white70),
            weekendStyle: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
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
        if (_selectedDay != null &&
            !_selectedDay!.isBefore(DateTime.now().add(const Duration(days: 2))))
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: _handleAddSchedule,
            child: const Text("Add Staff Schedule"),
          )
      ],
    );
  }

  Widget _buildScheduleList() {
    if (isFirstLoad && _loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Column(
      children: [
        if (_loading)
          const LinearProgressIndicator(),

        if (schedulesForSelectedDay.isEmpty)
          Text(
            "Không có ca làm vào ngày ${_selectedDay!.toLocal().toString().split(' ')[0]}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          )
        else
          ...schedulesForSelectedDay.map((s) {
            return Card(
              color: Colors.white.withValues(alpha: 0.15),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFFFFD740)),
                title: Text(
                  s.shiftName ?? "",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Nhân viên: ${s.staffName}\nCa làm: ${s.shiftName}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: canDelete(s.date!)
                    ? IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.redAccent),
                  onPressed: () => _handleDelete(s.uuid!),
                )
                    : null,
              ),
            );
          }),
      ],
    );
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
              shadows: [
                Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(2, 2))
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildCalendar(),
          const SizedBox(height: 30),

          _buildActions(),
          const SizedBox(height: 30),

          const Text(
            "Lịch Làm Việc Trong Ngày:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          _buildScheduleList(),
        ],
      ),
    );
  }
}