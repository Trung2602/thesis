import 'package:flutter/material.dart';
import 'package:gym/models/staff_schedule.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Color(0xFFFFD740)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                schedule.shiftName ?? '',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: schedule.approved ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                schedule.approved ? 'Đã duyệt' : 'Chờ duyệt',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Ca làm: ${schedule.shiftName}',
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