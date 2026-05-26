import 'package:flutter/material.dart';
import '../../../../models/staff_schedule.dart';

class ScheduleListItem extends StatelessWidget {
  final StaffSchedule schedule;
  final VoidCallback onTap;

  const ScheduleListItem({super.key, required this.schedule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        isThreeLine: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: const Icon(
          Icons.schedule,
          color: Color(0xFFFFD740),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                schedule.shiftName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: schedule.approved
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                schedule.approved
                    ? 'Đã duyệt'
                    : 'Chờ duyệt',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Nhân viên: ${schedule.staffName}\nCa làm: ${schedule.shiftName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}