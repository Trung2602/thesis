import 'package:flutter/material.dart';
import 'package:gym/models/staff_schedule.dart';

class StaffScheduleCard extends StatelessWidget {
  final StaffSchedule schedule;
  final bool canDelete;
  final VoidCallback? onDelete;

  const StaffScheduleCard({
    super.key,
    required this.schedule,
    required this.canDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
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
        trailing: canDelete
            ? IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        )
            : null,
      ),
    );
  }
}