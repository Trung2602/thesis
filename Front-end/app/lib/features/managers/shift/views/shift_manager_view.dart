import 'package:flutter/material.dart';

import '../../../../models/shift.dart';
import '../providers/shift_provider.dart';
import '../widgets/shift_card.dart';
import '../../shared/widgets/manager_info_row.dart';

class ManagerShiftView extends StatefulWidget {
  const ManagerShiftView({super.key});

  @override
  State<ManagerShiftView> createState() => _ManagerShiftViewState();
}

class _ManagerShiftViewState extends State<ManagerShiftView> {
  final _provider = ShiftProvider();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchShifts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchShifts();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openForm({Shift? shift}) {
    final nameCtrl = TextEditingController(text: shift?.name ?? '');
    TimeOfDay? checkin = shift?.checkin;
    TimeOfDay? checkout = shift?.checkout;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          Future<void> pickTime(bool isCheckin) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: isCheckin
                  ? (checkin ?? TimeOfDay.now())
                  : (checkout ?? TimeOfDay.now()),
            );
            if (picked != null) {
              setStateDialog(() {
                if (isCheckin) {
                  checkin = picked;
                } else {
                  checkout = picked;
                }
              });
            }
          }

          String timeText(TimeOfDay? t) => t == null
              ? 'Chọn giờ'
              : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFF1A237E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(
                        shift == null ? 'Thêm ca làm' : 'Sửa ca làm',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white24),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tên ca',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Check-in: ${timeText(checkin)}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                        onPressed: () => pickTime(true),
                        icon: const Icon(Icons.access_time,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Check-out: ${timeText(checkout)}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                        onPressed: () => pickTime(false),
                        icon: const Icon(Icons.access_time,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon:
                        const Icon(Icons.close, color: Colors.white70),
                        label: const Text('Hủy',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: () async {
                          await _provider.saveShift({
                            'uuid': shift?.uuid,
                            'name': nameCtrl.text.trim(),
                            'checkin': checkin == null
                                ? null
                                : '${checkin!.hour.toString().padLeft(2, '0')}:${checkin!.minute.toString().padLeft(2, '0')}',
                            'checkout': checkout == null
                                ? null
                                : '${checkout!.hour.toString().padLeft(2, '0')}:${checkout!.minute.toString().padLeft(2, '0')}',
                          });
                          if (mounted) Navigator.pop(context);
                          _provider.fetchShifts(isRefresh: true);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(Shift s) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              ManagerInfoRow(
                icon: Icons.schedule,
                title: 'Thời gian',
                value:
                '${Shift.formatTime(s.checkin)} - ${Shift.formatTime(s.checkout)}',
              ),
              ManagerInfoRow(icon: Icons.timer, title: 'Số giờ', value: '${s.duration ?? 0} giờ'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Đóng',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openForm(shift: s);
                    },
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    label: const Text('Sửa',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deleteShift(s.uuid!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa')),
                        );
                        _provider.fetchShifts(isRefresh: true);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Xóa',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý ca làm'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shift_manager_fab',
        backgroundColor: const Color(0xFFFFD740),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          if (_provider.isLoading && _provider.isFirstLoad)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _provider.fetchShifts(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _provider.shifts.length + 1,
                itemBuilder: (context, index) {
                  if (index < _provider.shifts.length) {
                    return ShiftCard(
                      shift: _provider.shifts[index],
                      onTap: () => _showDetail(_provider.shifts[index]),
                    );
                  }
                  return _provider.hasMore
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('Hết dữ liệu',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}