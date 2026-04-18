import 'dart:convert';
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/models/account.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gym/models/customer_schedule.dart';
import 'package:gym/models/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../cache/app_cache.dart';
import '../models/available_staff.dart';
import '../services/auth_service.dart';

class CustomerScheduleScreen extends StatefulWidget {
  const CustomerScheduleScreen({super.key});

  @override
  State<CustomerScheduleScreen> createState() => _CustomerScheduleScreenState();
}

class _CustomerScheduleScreenState extends State<CustomerScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Account? account;
  List<CustomerSchedule> schedulesForSelectedDay = [];
  List<AvailableStaff> staffList = [];
  bool isLoadingStaff = true;
  bool _loading = false;
  bool isFirstLoad = true;

  final cache = AppCache().customerScheduleCache;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = today;
    _focusedDay = today;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSchedulesForDay(today);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
  }

  Future<void> loadSchedulesForDay(DateTime day) async {
    final dateStr = _formatDate(day);
    if (cache.containsKey(dateStr)) {
      setState(() {
        schedulesForSelectedDay = cache[dateStr]!;
        isFirstLoad = false;
      });
      return;
    }
    if (isFirstLoad) {
      setState(() => isFirstLoad = true);
    } else {
      setState(() => _loading = true);
    }
    try {
      final schedules = await _getCustomerSchedulesFilter(dateStr);
      if (!mounted) return;
      cache[dateStr] = schedules;
      if (cache.length > 20) {
        cache.remove(cache.keys.first);
      }
      setState(() {
        schedulesForSelectedDay = schedules;
        isFirstLoad = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showMsg("Lỗi khi tải lịch: $e");
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          isFirstLoad = false;
        });
      }
    }
  }

  Future<void> fetchWorkingStaffForTime(DateTime date, TimeOfDay checkIn, TimeOfDay checkOut) async {
    setState(() => isLoadingStaff = true);
    try {
      final staffs = await _fetchWorkingStaff(date, checkIn, checkOut);
      if (!mounted) return;
      setState(() => staffList = staffs);
    } catch (e) {
      _showMsg("Lỗi tải danh sách nhân viên: $e");
    } finally {
      if (mounted) setState(() => isLoadingStaff = false);
    }
  }

  Future<void> addCustomerSchedule(DateTime date, TimeOfDay checkIn, TimeOfDay checkOut, AvailableStaff staff,) async {
    try {
      final token = await AuthService().getToken();

      final newSchedule = CustomerSchedule(
        date: date,
        checkin: checkIn,
        checkout: checkOut,
        staffUuid: staff.uuid,
        facilityUuid: staff.facilityUuid,
      );

      print("New Schedule =${newSchedule.toJson()}, ");

      final uri = Uri.parse(GymServerApi.postCustomerSchedule);

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(newSchedule.toJson()),
      );

      if (res.statusCode == 200) {
        final posted = CustomerSchedule.fromJson(jsonDecode(res.body));
        _showMsg("Đã thêm lịch: ${posted.date}");
        cache.remove(_formatDate(date));
        await loadSchedulesForDay(date);
      } else if (res.statusCode == 409) {
        // Trùng lịch
        _showMsg("Lịch trùng ngày và giờ checkin, không thể tạo", isError: true);
      } else {
        throw Exception("Failed to post schedule: ${res.body}");
      }
    } catch (e) {
      _showMsg("Lỗi khi thêm lịch: $e", isError: true);
    }
  }

  String _formatDate(DateTime day) {
    return "${day.year.toString().padLeft(4,'0')}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}";
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<List<AvailableStaff>> _fetchWorkingStaff(DateTime date, TimeOfDay checkIn, TimeOfDay checkOut) async {
    final token = await AuthService().getToken();
    String checkInStr = "${checkIn.hour.toString().padLeft(2,'0')}:${checkIn.minute.toString().padLeft(2,'0')}:00";
    String checkOutStr = "${checkOut.hour.toString().padLeft(2,'0')}:${checkOut.minute.toString().padLeft(2,'0')}:00";
    String dateStr = _formatDate(date);

    final uri = Uri.parse(UserServerApi.getWorkingStaff).replace(queryParameters: {
      "date": dateStr,
      "checkin": checkInStr,
      "checkout": checkOutStr,
    });

    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AvailableStaff.fromJson(e)).toList();
    } else {
      throw Exception("Server error: ${res.statusCode}");
    }
  }

  Future<List<CustomerSchedule>> _getCustomerSchedulesFilter(String date) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse("${GymServerApi.getCustomerSchedulesFilter}?date=$date");
    final res = await http.get(uri, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => CustomerSchedule.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schedules: ${res.statusCode}");
    }
  }

  Future<void> _deleteSchedule(String uuid) async {
    try {
      final token = await AuthService().getToken();
      final uri = Uri.parse(GymServerApi.deleteCustomerSchedule(uuid));

      final res = await http.delete(uri, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (res.statusCode == 204) {
        _showMsg("Xóa lịch thành công");
      } else {
        _showMsg("Lỗi khi xóa lịch: ${res.body}", isError: true);
      }
    } catch (e) {
      _showMsg("Lỗi khi xóa lịch: $e", isError: true);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final dateStr = _formatDate(selectedDay);
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      if (!cache.containsKey(dateStr)) {
        _loading = true;
      }
    });
    await loadSchedulesForDay(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Lịch Trình Huấn Luyện",
                style: TextStyle(
                  color: Color(0xFFFFAB40),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            color: Colors.white.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFFFD740)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFFFD740)),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF2C318F),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFFFAB40),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  holidayTextStyle: TextStyle(color: Colors.greenAccent),
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
              ElevatedButton(
                onPressed: () async {
                  final today = DateTime.now();
                  setState(() {
                    _selectedDay = today;
                    _focusedDay = today;
                    if (!cache.containsKey(_formatDate(today))) {
                      _loading = true;
                    }
                  });
                  await loadSchedulesForDay(today);
                },
                child: const Text("Today"),
              ),
              const SizedBox(width: 10),
              _selectedDay == null ||
                  _selectedDay!.isBefore(DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day)) ||
                  account?.role == "STAFF"
                  ? const SizedBox.shrink()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent),
                onPressed: () async {
                  final TimeOfDay? selectedCheckin =
                  await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (selectedCheckin == null) return;

                  final TimeOfDay? selectedCheckout =
                  await showTimePicker(context: context,
                    initialTime: TimeOfDay(
                        hour: selectedCheckin.hour + 1,
                        minute: selectedCheckin.minute),
                  );
                  if (selectedCheckout == null) return;
                  await fetchWorkingStaffForTime(_selectedDay!, selectedCheckin, selectedCheckout);
                  AvailableStaff? selectedStaff = await _showStaffSelectionDialog();
                  if (selectedStaff == null) return;
                  await addCustomerSchedule(_selectedDay!, selectedCheckin, selectedCheckout, selectedStaff);
                },
                child: const Text("Add Schedule"),
              ),
            ],
          ),

          const SizedBox(width: 30),
          const SizedBox(height: 20),
          const Text(
            "Sự Kiện Trong Ngày Được Chọn:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(1, 1))
              ],
            ),
          ),
          const SizedBox(height: 15),

          _selectedDay == null ? const Text(
            "Hãy chọn một ngày trên lịch để xem lịch trình của bạn.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          )
              : _buildEventListForSelectedDay(_selectedDay!),
        ],
      ),
    );
  }

  Future<AvailableStaff?> _showStaffSelectionDialog() async {
    return showDialog<AvailableStaff>(
      context: context,
      builder: (context) {
        if (isLoadingStaff) {
          return const Center(child: CircularProgressIndicator());
        }
        if (staffList.isEmpty) {
          return AlertDialog(
            title: const Text("Không có nhân viên trống"),
            content: const Text(
                "Không có nhân viên nào làm việc trong khoảng thời gian này."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        }
        return AlertDialog(
          title: const Text("Chọn nhân viên"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  title: Text(staff.name),
                  onTap: () => Navigator.of(context).pop(staff),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventListForSelectedDay(DateTime day) {
    if (isFirstLoad) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (schedulesForSelectedDay.isEmpty) {
      return Text(
        "Không có sự kiện vào ngày ${day.toLocal().toString().split(' ')[0]}",
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    return Column(
      children: schedulesForSelectedDay.map((schedule) {
        return Card(
          color: Colors.white.withValues(alpha: 0.15),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: Color(0xFFFFD740)),
            title: Text(
              schedule.facilityName ?? 'Không có tên cơ sở',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Huấn luyện viên: ${schedule.staffName ?? 'Chưa có'}\nKhách hàng: ${schedule.customerName ?? 'Chưa có'}\n${schedule.checkin?.format(context)} - ${schedule.checkout?.format(context)}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Xác nhận xóa"),
                    content: const Text("Bạn có chắc muốn xóa lịch này không?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
                    ],
                  ),
                );

                if (confirmed != true) return;

                await _deleteSchedule(schedule.uuid!);
                cache.remove(_formatDate(day));
                await loadSchedulesForDay(day);
              },
            ),

          ),
        );
      }).toList(),
    );
  }
}