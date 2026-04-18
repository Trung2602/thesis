import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/cache/manager_cache.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

import '../api/gym_server_api.dart';
import '../models/staff_schedule.dart';
import '../services/auth_service.dart';

class ManagerStaffSchedulePage extends StatefulWidget {
  const ManagerStaffSchedulePage({super.key});

  @override
  State<ManagerStaffSchedulePage> createState() =>
      _ManagerStaffSchedulePageState();
}

class _ManagerStaffSchedulePageState extends State<ManagerStaffSchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<StaffSchedule> schedulesForSelectedDay = [];

  bool _loading = false;
  bool isFirstLoad = true;

  final cache = ManagerCache().staffScheduleManagerCache;
  List<dynamic>? listStaffs;
  List<dynamic>? listShifts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_selectedDay == null) {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _loadSchedulesForDay(_selectedDay!);
    }

    if (listStaffs == null || listShifts == null) {
      _ensureDataLoaded();
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

  Future<List<dynamic>> _getStaffs() async {
    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(UserServerApi.getStaffs),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("Lỗi load staff");
    }

    return jsonDecode(res.body);
  }

  Future<List<dynamic>> _getShifts() async {
    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(GymServerApi.getShifts),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception("Lỗi load staff");
    }

    return jsonDecode(res.body);
  }

  Future<void> _ensureDataLoaded() async {
    try {
      if (listStaffs == null) {
        listStaffs = await _getStaffs();
      }

      if (listShifts == null) {
        listShifts = await _getShifts();
      }
    } catch (e) {
      showMsg("Lỗi load dữ liệu: $e", isError: true);
    }
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
      final uri = Uri.parse(GymServerApi.getStaffSchedulesFilter).replace(queryParameters: {'date': dateString});
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
    final result = await _showScheduleForm();

    if (result == null) return;

    final token = await AuthService().getToken();

    final newSchedule = StaffSchedule(
      staffUuid: result["staffUuid"],
      shiftUuid: result["shiftUuid"],
      date: result["date"],
    );

    final res = await http.post(
      Uri.parse(GymServerApi.postStaffSchedule),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newSchedule.toJson()),
    );


    if (res.statusCode == 200) {
      showMsg("Thêm thành công");
      cache.remove(formatDate(_selectedDay!));
      await _loadSchedulesForDay(_selectedDay!);
    } else {
      showMsg("Lỗi thêm", isError: true);
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

  void _showScheduleDetail(StaffSchedule s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chi tiết lịch"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Nhân viên: ${s.staffName}"),
            Text("Ngày: ${s.date?.toLocal().toString().split(' ')[0]}"),
            Text("Ca: ${s.shiftName}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleEditSchedule(s);
            },
            child: const Text("Sửa"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDelete(s.uuid!);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditSchedule(StaffSchedule s) async {
    final result = await _showScheduleForm(initial: s);

    if (result == null) return;

    final token = await AuthService().getToken();

    final updated = StaffSchedule(
      uuid: s.uuid,
      staffUuid: result["staffUuid"],
      shiftUuid: result["shiftUuid"],
      date: result["date"],
    );

    final res = await http.post(
      Uri.parse(GymServerApi.postStaffSchedule),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updated.toJson()),
    );
    print("status: ${res.statusCode}");

    if (res.statusCode == 200) {
      showMsg("Cập nhật thành công");
      cache.remove(formatDate(_selectedDay!));
      await _loadSchedulesForDay(_selectedDay!);
    } else {
      showMsg("Lỗi update", isError: true);
    }
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

  Future<Map<String, dynamic>?> _showScheduleForm({StaffSchedule? initial,}) async {
    await _ensureDataLoaded();
    String? selectedStaffUuid = initial?.staffUuid?.toString();
    String? selectedShiftUuid = initial?.shiftUuid?.toString();
    DateTime selectedDate = initial?.date ?? _selectedDay!;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(initial == null
                  ? "Thêm lịch làm việc"
                  : "Sửa lịch làm việc"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStaffUuid,
                      isExpanded: true,
                      itemHeight: 60,
                      decoration: const InputDecoration(labelText: "Nhân viên"),
                      items: listStaffs!.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem(
                          value: s["uuid"].toString(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s["name"],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                s["mail"],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => selectedStaffUuid = val);
                      },
                    ),

                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text("Ngày: "),
                        TextButton(
                          child: Text(
                            selectedDate
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setStateDialog(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),

                    DropdownButtonFormField<String>(
                      value: selectedShiftUuid,
                      decoration: const InputDecoration(labelText: "Ca làm"),
                      items: listShifts!.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem(
                          value: s["uuid"].toString(),
                          child: Text(s["name"]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() => selectedShiftUuid = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStaffUuid == null ||
                        selectedShiftUuid == null) {
                      showMsg("Vui lòng chọn đầy đủ", isError: true);
                      return;
                    }

                    Navigator.pop(context, {
                      "staffUuid": selectedStaffUuid,
                      "shiftUuid": selectedShiftUuid,
                      "date": selectedDate,
                    });
                  },
                  child: const Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
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
        if (_selectedDay != null && !_selectedDay!.isBefore(DateTime.now()))
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
                onTap: () => _showScheduleDetail(s),
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
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lịch làm việc nhân viên",
          style: TextStyle(
            color: Color(0xFFFFD740),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Color(0xFFFFD740)),
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildActions(),
            const SizedBox(height: 25),

            const Text(
              "Lịch trong ngày",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),
            _buildScheduleList(),
          ],
        ),
      ),
    );
  }
}