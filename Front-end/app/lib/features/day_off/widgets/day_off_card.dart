import 'package:flutter/material.dart';

class DayOffCard extends StatelessWidget {
  final DateTime date;
  final bool showDelete;
  final VoidCallback onDelete;

  const DayOffCard({
    super.key,
    required this.date,
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
        trailing: showDelete
            ? IconButton(
          icon: const Icon(Icons.delete_outline,
              color: Colors.redAccent),
          tooltip: 'Xoá ngày nghỉ',
          onPressed: onDelete,
        )
            : null,
      ),
    );
  }
}