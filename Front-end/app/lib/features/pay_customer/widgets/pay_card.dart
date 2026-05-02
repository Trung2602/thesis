import 'package:flutter/material.dart';
import 'package:gym/models/pay_customer.dart';

class PayCard extends StatelessWidget {
  final PayCustomer pay;

  const PayCard({super.key, required this.pay});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gói tập: ${pay.planName}',
                style: const TextStyle(color: Colors.white)),
            Text('Giá: ${pay.price} VND',
                style: const TextStyle(color: Colors.white70)),
            Text('Ngày đóng: ${pay.date}',
                style: const TextStyle(color: Colors.white70)),
            Text('Mã GD: ${pay.txnRef ?? '-'}',
                style: const TextStyle(color: Colors.white70)),
            Text('Trạng thái: ${pay.status ?? 'Unknown'}',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}