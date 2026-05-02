import 'package:flutter/material.dart';
import 'package:gym/models/customer_schedule.dart';

class CustomerScheduleCard extends StatelessWidget {
  final CustomerSchedule schedule;
  final VoidCallback onDelete;

  const CustomerScheduleCard({
    super.key,
    required this.schedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading:
        const Icon(Icons.fitness_center, color: Color(0xFFFFD740)),
        title: Text(
          schedule.facilityName ?? 'Không có tên cơ sở',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Huấn luyện viên: ${schedule.staffName ?? 'Chưa có'}\n'
              'Khách hàng: ${schedule.customerName ?? 'Chưa có'}\n'
              '${schedule.checkin?.format(context)} - ${schedule.checkout?.format(context)}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}