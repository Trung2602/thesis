import 'package:flutter/material.dart';
import 'package:gym/models/customer_schedule.dart';

class CustomerScheduleCard extends StatelessWidget {
  final CustomerSchedule schedule;
  final VoidCallback? onDelete;
  final VoidCallback? onEditNote;
  final VoidCallback? onMeasure;

  const CustomerScheduleCard({
    super.key,
    required this.schedule,
    this.onDelete,
    this.onEditNote,
    this.onMeasure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fitness_center, color: Color(0xFFFFD740)),
              title: Text(
                schedule.facilityName ?? 'Không có tên cơ sở',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Huấn luyện viên: ${schedule.staffName ?? 'Chưa có'}\n'
                    'Khách hàng: ${schedule.customerName ?? 'Chưa có'}\n'
                    '${schedule.checkin?.format(context)} - ${schedule.checkout?.format(context)}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: onDelete != null
                  ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
                  : null,
            ),

            if (onMeasure != null) ...[
              const Divider(color: Colors.white24),
              TextButton.icon(
                onPressed: onMeasure,
                icon: const Icon(Icons.monitor_weight, color: Color(0xFFFFAB40), size: 16),
                label: const Text('Đo chỉ số',
                    style: TextStyle(color: Color(0xFFFFAB40), fontSize: 13)),
              ),
            ],

            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
              const Divider(color: Colors.white24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, color: Color(0xFFFFAB40), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      schedule.note!,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  if (onEditNote != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54, size: 18),
                      onPressed: onEditNote,
                    ),
                ],
              ),
            ] else if (onEditNote != null) ...[
              const Divider(color: Colors.white24),
              TextButton.icon(
                onPressed: onEditNote,
                icon: const Icon(Icons.add, color: Colors.white54, size: 16),
                label: const Text('Thêm ghi chú',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}