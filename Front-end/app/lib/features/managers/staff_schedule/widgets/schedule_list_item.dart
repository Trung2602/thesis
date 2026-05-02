import 'package:flutter/material.dart';
import '../../../../models/staff_schedule.dart';

class ScheduleListItem extends StatelessWidget {
  final StaffSchedule schedule;
  final VoidCallback onTap;

  const ScheduleListItem(
      {super.key, required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.schedule, color: Color(0xFFFFD740)),
        title: Text(
          schedule.shiftName ?? '',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Nhân viên: ${schedule.staffName}\nCa làm: ${schedule.shiftName}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}