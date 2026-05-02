import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String description;

  const ScheduleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time, color: Colors.white60, size: 16),
              const SizedBox(width: 5),
              Text(time,
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}