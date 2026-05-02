import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/pay_customer.dart';
import '../../shared/widgets/manager_status_chip.dart';

class PayCustomerCard extends StatelessWidget {
  final PayCustomer payCustomer;
  final VoidCallback onTap;

  const PayCustomerCard(
      {super.key, required this.payCustomer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.orange),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payCustomer.customerName ?? 'Không tên',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    payCustomer.date != null
                        ? DateFormat('dd/MM/yyyy').format(payCustomer.date!)
                        : '-',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,###').format(payCustomer.price ?? 0)} VNĐ',
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ManagerStatusChip(status: payCustomer.status),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD740)),
              child: const Text('Chi tiết',
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}