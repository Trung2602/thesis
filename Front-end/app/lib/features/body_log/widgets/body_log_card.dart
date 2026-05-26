import 'package:flutter/material.dart';
import 'package:gym/models/body_log.dart';
import 'package:intl/intl.dart';

class BodyLogCard extends StatelessWidget {
  final BodyLog log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BodyLogCard({
    super.key,
    required this.log,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bmi = log.weight / ((log.height / 100) * (log.height / 100));
    final dateStr = log.loggedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(log.loggedAt!)
        : 'Không rõ';

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
              leading: const Icon(Icons.monitor_weight, color: Color(0xFFFFD740)),
              title: Text(
                '${log.weight} kg  •  ${log.height} cm',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'BMI: ${bmi.toStringAsFixed(1)}  •  $dateStr',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
            if (log.bodyFatPercent != null || log.muscleMass != null) ...[
              const Divider(color: Colors.white24),
              Row(
                children: [
                  if (log.bodyFatPercent != null)
                    _chip(Icons.water_drop, '${log.bodyFatPercent}% mỡ'),
                  if (log.muscleMass != null)
                    _chip(Icons.fitness_center, '${log.muscleMass} kg cơ'),
                ],
              ),
            ],
            if (log.note != null && log.note!.isNotEmpty) ...[
              const Divider(color: Colors.white24),
              Row(
                children: [
                  const Icon(Icons.notes, color: Color(0xFFFFAB40), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(log.note!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFFFFAB40), size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}