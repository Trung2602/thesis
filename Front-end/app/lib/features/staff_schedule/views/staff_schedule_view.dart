import 'package:flutter/material.dart';
import 'package:gym/features/customer_schedule/widgets/schedule_calendar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/staff_schedule_provider.dart';
import '../widgets/staff_schedule_card.dart';

class StaffScheduleView extends StatefulWidget {
  const StaffScheduleView({super.key});

  @override
  State<StaffScheduleView> createState() => _StaffScheduleViewState();
}

class _StaffScheduleViewState extends State<StaffScheduleView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final StaffScheduleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = StaffScheduleProvider();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _provider.loadSchedulesForDay(_selectedDay!);
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Future<void> _handleAddSchedule() async {
    if (_selectedDay == null) return;
    final account = Provider.of<AccountProvider>(context, listen: false).account;
    if (account?.facilityUuid == null) {
      _showMsg('Không tìm thấy cơ sở của bạn', isError: true);
      return;
    }
    List<dynamic> shifts = [];
    try {
      shifts = await _provider.fetchShifts();
    } catch (e) {
      if (!mounted) return;
      _showMsg('Lỗi tải ca làm việc: $e', isError: true);
      return;
    }

    if (!mounted) return;
    if (shifts.isEmpty) {
      _showMsg('Chưa có ca làm việc', isError: true);
      return;
    }

    final selectedShift = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn ca làm việc'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              final shift = shifts[index];
              return ListTile(
                title: Text(
                    '${shift['name']} (${shift['checkin']} - ${shift['checkout']})'),
                onTap: () => Navigator.pop(ctx, shift),
              );
            },
          ),
        ),
      ),
    );

    if (selectedShift == null) return;
    if (!mounted) return;

    final error = await _provider.addSchedule(
        account!.uuid,
        account.facilityUuid!,
        _selectedDay!,
        selectedShift['uuid'],
    );
    if (!mounted) return;
    if (error == null) {
      _showMsg('Đã thêm lịch staff');
    } else if (error == 'conflict') {
      _showMsg('Lịch bị trùng, không thể tạo', isError: true);
    } else {
      _showMsg('Lỗi khi tạo lịch: $error', isError: true);
    }
  }

  Future<void> _handleDelete(String uuid) async {
    final error = await _provider.deleteSchedule(uuid, _selectedDay!);
    if (!mounted) return;
    if (error == null) {
      _showMsg('Đã xóa lịch staff');
    } else {
      _showMsg('Lỗi xóa lịch: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<StaffScheduleProvider>(
        builder: (context, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch Làm Việc Nhân Viên',
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
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                  provider.loadSchedulesForDay(selected);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focused) => _focusedDay = focused,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final today = DateTime.now();
                      setState(() {
                        _selectedDay = today;
                        _focusedDay = today;
                      });
                      provider.loadSchedulesForDay(today);
                    },
                    child: const Text('Today'),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedDay != null &&
                      !_selectedDay!.isBefore(
                          DateTime.now().add(const Duration(days: 2))))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent),
                      onPressed: _handleAddSchedule,
                      child: const Text('Add Staff Schedule'),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                'Lịch Làm Việc Trong Ngày:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              if (provider.isFirstLoad && provider.isLoading)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white))
              else ...[
                if (provider.isLoading) const LinearProgressIndicator(),
                if (provider.schedulesForSelectedDay.isEmpty)
                  Text(
                    'Không có ca làm vào ngày ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  )
                else
                  ...provider.schedulesForSelectedDay.map((s) =>
                      StaffScheduleCard(
                        schedule: s,
                        canDelete: provider.canDelete(s.date!),
                        onDelete: () => _handleDelete(s.uuid!),
                      )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}