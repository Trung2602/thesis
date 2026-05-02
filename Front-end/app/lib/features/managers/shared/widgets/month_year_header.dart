import 'package:flutter/material.dart';

class MonthYearHeader extends StatelessWidget {
  final int selectedMonth;
  final TextEditingController yearController;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSearch;

  const MonthYearHeader({
    super.key,
    required this.selectedMonth,
    required this.yearController,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: yearController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Năm',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: onPrevMonth,
            icon: const Icon(Icons.arrow_left, color: Colors.white),
          ),
          Text(
            'Tháng $selectedMonth',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.arrow_right, color: Colors.white),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
            ),
            child: const Text('Xem', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}