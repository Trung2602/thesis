import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gym/models/account_provider.dart';
import 'package:gym/models/available_staff.dart';
import '../providers/customer_schedule_provider.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/customer_schedule_card.dart';

class CustomerScheduleView extends StatefulWidget {
  const CustomerScheduleView({super.key});

  @override
  State<CustomerScheduleView> createState() => _CustomerScheduleViewState();
}

class _CustomerScheduleViewState extends State<CustomerScheduleView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final CustomerScheduleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CustomerScheduleProvider();
    final today = DateTime.now();
    _selectedDay = today;
    _focusedDay = today;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadSchedulesForDay(today);
    });
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  Future<void> _handleAddSchedule() async {
    final checkIn = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (checkIn == null) return;

    if (!mounted) return;
    final checkOut = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: checkIn.hour + 1, minute: checkIn.minute),
    );
    if (checkOut == null) return;

    await _provider.fetchWorkingStaff(_selectedDay!, checkIn, checkOut);
    if (!mounted) return;

    final selectedStaff = await _showStaffDialog();
    if (selectedStaff == null) return;

    final error = await _provider.addSchedule(
        _selectedDay!, checkIn, checkOut, selectedStaff);
    if (!mounted) return;

    if (error == null) {
      _showMsg('Đã thêm lịch');
    } else if (error == 'conflict') {
      _showMsg('Lịch trùng ngày và giờ checkin, không thể tạo',
          isError: true);
    } else {
      _showMsg('Lỗi khi thêm lịch: $error', isError: true);
    }
  }

  Future<AvailableStaff?> _showStaffDialog() {
    return showDialog<AvailableStaff>(
      context: context,
      builder: (context) {
        if (_provider.isLoadingStaff) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_provider.staffList.isEmpty) {
          return AlertDialog(
            title: const Text('Không có nhân viên trống'),
            content: const Text(
                'Không có nhân viên nào làm việc trong khoảng thời gian này.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
        return AlertDialog(
          title: const Text('Chọn nhân viên'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _provider.staffList.length,
              itemBuilder: (context, index) {
                final staff = _provider.staffList[index];
                return ListTile(
                  title: Text(staff.name),
                  onTap: () => Navigator.pop(context, staff),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(String uuid, DateTime day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa lịch này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await _provider.deleteSchedule(uuid, day);
    if (!mounted) return;
    if (error == null) {
      _showMsg('Xóa lịch thành công');
    } else {
      _showMsg('Lỗi khi xóa lịch: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CustomerScheduleProvider>(
        builder: (context, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch Trình Huấn Luyện',
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

              ScheduleCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                calendarFormat: _calendarFormat,
                onDaySelected: (selected, focused) async {
                  final dateStr = provider.formatDate(selected);
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    if (!provider.cache.containsKey(dateStr)) {
                      provider.isLoading = true;
                    }
                  });
                  await provider.loadSchedulesForDay(selected);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                },
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
                      });
                      await provider.loadSchedulesForDay(today);
                    },
                    child: const Text('Today'),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedDay != null &&
                      !_selectedDay!.isBefore(DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day)) &&
                      account?.role != 'STAFF')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent),
                      onPressed: _handleAddSchedule,
                      child: const Text('Add Schedule'),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                'Sự Kiện Trong Ngày Được Chọn:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 5,
                        color: Colors.black54,
                        offset: Offset(1, 1))
                  ],
                ),
              ),
              const SizedBox(height: 15),

              if (_selectedDay == null)
                const Text(
                  'Hãy chọn một ngày trên lịch để xem lịch trình của bạn.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              else if (provider.isFirstLoad || provider.isLoading)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white))
              else if (provider.schedulesForSelectedDay.isEmpty)
                  Text(
                    'Không có sự kiện vào ngày ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                  )
                else
                  Column(
                    children: provider.schedulesForSelectedDay
                        .map((s) => CustomerScheduleCard(
                      schedule: s,
                      onDelete: () =>
                          _handleDelete(s.uuid!, _selectedDay!),
                    ))
                        .toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}