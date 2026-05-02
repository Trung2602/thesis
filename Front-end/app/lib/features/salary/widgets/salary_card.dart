import 'package:flutter/material.dart';
import 'package:gym/models/salary.dart';

class SalaryCard extends StatelessWidget {
  final Salary salary;

  const SalaryCard({super.key, required this.salary});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salary.date != null
                  ? '${salary.date!.month}/${salary.date!.year}'
                  : 'Không có ngày',
              style: const TextStyle(
                  color: Color(0xFFFFAB40),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _row('Số ngày nghỉ:', '${salary.dayOff}'),
            const SizedBox(height: 4),
            _row('Số giờ làm:', '${salary.duration} giờ'),
            const Divider(color: Colors.white30, height: 16),
            _row('Tổng lương:', '${salary.price} VND',
                highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white70,
                fontWeight:
                highlight ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: highlight
                    ? const Color(0xFFFFD740)
                    : Colors.white,
                fontWeight:
                highlight ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}