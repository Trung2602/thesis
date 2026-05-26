import 'package:flutter/material.dart';
import 'package:gym/models/goal.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAchieve;

  const GoalCard({
    super.key,
    required this.goal,
    this.onEdit,
    this.onDelete,
    this.onAchieve,
  });

  String _goalTypeLabel(String type) {
    switch (type) {
      case 'LOSE_WEIGHT': return 'Giảm cân';
      case 'GAIN_MUSCLE': return 'Tăng cơ';
      case 'MAINTAIN': return 'Duy trì';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineStr = goal.deadline != null
        ? DateFormat('dd/MM/yyyy').format(goal.deadline!)
        : 'Không có deadline';

    return Card(
      color: (goal.isAchieved == true)
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                goal.isAchieved == true
                    ? Icons.emoji_events
                    : Icons.flag,
                color: goal.isAchieved == true
                    ? Colors.greenAccent
                    : const Color(0xFFFFD740),
              ),
              title: Text(
                _goalTypeLabel(goal.goalType),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Deadline: $deadlineStr'
                    '${goal.targetWeight != null ? '\nMục tiêu: ${goal.targetWeight} kg' : ''}'
                    '${goal.targetBodyFat != null ? '  •  ${goal.targetBodyFat}% mỡ' : ''}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: goal.isAchieved == true
                  ? const Chip(
                label: Text('Đã đạt',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.green,
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAchieve != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent),
                      tooltip: 'Đánh dấu đạt',
                      onPressed: onAchieve,
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}