import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../models/staff_schedule.dart';
import '../providers/staff_schedule_provider.dart';
import '../widgets/schedule_list_item.dart';

class ManagerStaffScheduleView extends StatefulWidget {
  const ManagerStaffScheduleView({super.key});

  @override
  State<ManagerStaffScheduleView> createState() =>
      _ManagerStaffScheduleViewState();
}

class _ManagerStaffScheduleViewState
    extends State<ManagerStaffScheduleView> {
  final _provider = StaffScheduleProvider();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedDay == null) {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _loadDay(_selectedDay!);
    }
    _provider.ensureDataLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _showMsg(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Future<void> _loadDay(DateTime day) async {
    try {
      await _provider.loadSchedulesForDay(day);
      if (mounted) setState(() {});
    } catch (e) {
      _showMsg('Lỗi khi tải lịch: $e', isError: true);
    }
  }

  Future<Map<String, dynamic>?> _showScheduleForm(
      {StaffSchedule? initial}) async {
    await _provider.ensureDataLoaded();

    String? selectedStaffUuid = initial?.staffUuid?.toString();
    String? selectedShiftUuid = initial?.shiftUuid?.toString();
    DateTime selectedDate = initial?.date ?? _selectedDay!;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
              initial == null ? 'Thêm lịch làm việc' : 'Sửa lịch làm việc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStaffUuid,
                  isExpanded: true,
                  itemHeight: 60,
                  decoration:
                  const InputDecoration(labelText: 'Nhân viên'),
                  items: _provider.listStaffs!.map<DropdownMenuItem<String>>((s) {
                    return DropdownMenuItem(
                      value: s['uuid'].toString(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s['name'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(s['mail'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setStateDialog(() => selectedStaffUuid = val),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Ngày: '),
                    TextButton(
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
                      child: Text(selectedDate
                          .toLocal()
                          .toString()
                          .split(' ')[0]),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: selectedShiftUuid,
                  decoration: const InputDecoration(labelText: 'Ca làm'),
                  items: _provider.listShifts!
                      .map<DropdownMenuItem<String>>((s) {
                    return DropdownMenuItem(
                      value: s['uuid'].toString(),
                      child: Text(s['name']),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedShiftUuid = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStaffUuid == null || selectedShiftUuid == null) {
                  _showMsg('Vui lòng chọn đầy đủ', isError: true);
                  return;
                }

                final selectedStaff = _provider.listStaffs!.firstWhere((s) => s['uuid'].toString() == selectedStaffUuid);

                final facilityUuid = selectedStaff['facilityUuid']?.toString();

                Navigator.pop(context, {
                  'staffUuid': selectedStaffUuid,
                  'shiftUuid': selectedShiftUuid,
                  'date': selectedDate,
                  'facilityUuid': facilityUuid,
                });
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAdd() async {
    final result = await _showScheduleForm();
    if (result == null) return;
    final ok = await _provider.addSchedule(result, _selectedDay!);
    if (mounted) {
      _showMsg(ok ? 'Thêm thành công' : 'Lỗi thêm', isError: !ok);
      setState(() {});
    }
  }

  Future<void> _handleEdit(StaffSchedule s) async {
    final result = await _showScheduleForm(initial: s);
    if (result == null) return;
    final ok = await _provider.editSchedule(s, result, _selectedDay!);
    if (mounted) {
      _showMsg(ok ? 'Cập nhật thành công' : 'Lỗi update', isError: !ok);
      setState(() {});
    }
  }

  Future<void> _handleDelete(String uuid) async {
    try {
      await _provider.deleteSchedule(uuid, _selectedDay!);
      if (mounted) {
        _showMsg('Đã xóa lịch staff');
        setState(() {});
      }
    } catch (e) {
      if (mounted) _showMsg('Lỗi xóa lịch: $e', isError: true);
    }
  }

  void _showDetail(StaffSchedule s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết lịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhân viên: ${s.staffName}'),
            Text('Ngày: ${s.date?.toLocal().toString().split(' ')[0]}'),
            Text('Ca: ${s.shiftName}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Trạng thái: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: s.approved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.approved ? 'Đã duyệt' : 'Chờ duyệt',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleApprove(s);
            },
            child: Text(
              s.approved ? 'Hủy duyệt' : 'Duyệt',
              style: TextStyle(color: s.approved ? Colors.orange : Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleEdit(s);
            },
            child: const Text('Sửa'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDelete(s.uuid!);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(StaffSchedule s) async {
    final ok = await _provider.approveSchedule(s.uuid!, _selectedDay!);
    if (mounted) {
      _showMsg(ok ? 'Cập nhật trạng thái thành công' : 'Lỗi duyệt lịch', isError: !ok);
      setState(() {});
    }
  }

  Widget _buildCalendar() {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            _loadDay(selectedDay);
          },
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
            todayDecoration: BoxDecoration(
                color: Color(0xFF2C318F), shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(
                color: Color(0xFFFFAB40), shape: BoxShape.circle),
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
            _loadDay(today);
          },
          child: const Text('Today'),
        ),
        const SizedBox(width: 10),
        if (_selectedDay != null &&
            !_selectedDay!.isBefore(DateTime.now()))
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent),
            onPressed: _handleAdd,
            child: const Text('Add Staff Schedule'),
          ),
      ],
    );
  }

  Widget _buildScheduleList() {
    if (_provider.isFirstLoad && _provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    return Column(
      children: [
        if (_provider.isLoading) const LinearProgressIndicator(),
        if (_provider.schedulesForSelectedDay.isEmpty)
          Text(
            'Không có ca làm vào ngày ${_selectedDay!.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          )
        else
          ..._provider.schedulesForSelectedDay.map((s) => ScheduleListItem(
            schedule: s,
            onTap: () => _showDetail(s),
          )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch làm việc nhân viên',
          style: TextStyle(
              color: Color(0xFFFFD740), fontWeight: FontWeight.bold),
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
              'Lịch trong ngày',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildScheduleList(),
          ],
        ),
      ),
    );
  }
}