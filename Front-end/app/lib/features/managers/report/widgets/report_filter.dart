import 'package:flutter/material.dart';
import '../providers/report_provider.dart';

class ReportFilter extends StatelessWidget {
  final ReportProvider provider;

  const ReportFilter({super.key, required this.provider});

  Widget _typeButton(String t, String label, VoidCallback onTap) {
    final isSelected = provider.type == t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.orange : Colors.grey,
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _typeButton('MONTH', 'Tháng', () => provider.setType('MONTH')),
            _typeButton('QUARTER', 'Quý', () => provider.setType('QUARTER')),
            _typeButton('YEAR', 'Năm', () => provider.setType('YEAR')),
          ],
        ),
        const SizedBox(height: 10),
        if (provider.type == 'MONTH')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => provider.changeMonth(-1),
                icon: const Icon(Icons.arrow_left, color: Colors.white),
              ),
              Text(
                'Tháng ${provider.month}/${provider.year}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () => provider.changeMonth(1),
                icon:
                const Icon(Icons.arrow_right, color: Colors.white),
              ),
            ],
          ),
        if (provider.type == 'QUARTER')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final q = i + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () => provider.setQuarter(q),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    provider.quarter == q ? Colors.orange : Colors.grey,
                  ),
                  child: Text('Q$q'),
                ),
              );
            }),
          ),
        if (provider.type == 'YEAR')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => provider.changeYear(-1),
                icon: const Icon(Icons.arrow_left, color: Colors.white),
              ),
              Text(
                '${provider.year}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () => provider.changeYear(1),
                icon:
                const Icon(Icons.arrow_right, color: Colors.white),
              ),
            ],
          ),
      ],
    );
  }
}