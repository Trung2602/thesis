import 'package:flutter/material.dart';

class DayOffCard extends StatelessWidget {
  final DateTime date;
  final bool approved;
  final bool showDelete;
  final VoidCallback onDelete;

  const DayOffCard({
    super.key,
    required this.date,
    required this.approved,
    required this.showDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading:
        const Icon(Icons.event_available, color: Colors.white70),
        title: Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Ngày nghỉ đã đăng ký',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: approved ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                approved ? 'Đã duyệt' : 'Chờ duyệt',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            if (showDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}