import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/pay_customer.dart';
import '../providers/pay_customer_provider.dart';
import '../widgets/pay_customer_card.dart';
import '../../shared/widgets/manager_info_row.dart';
import '../../shared/widgets/manager_status_chip.dart';

class ManagerPayCustomerView extends StatefulWidget {
  const ManagerPayCustomerView({super.key});

  @override
  State<ManagerPayCustomerView> createState() => _ManagerPayCustomerViewState();
}

class _ManagerPayCustomerViewState extends State<ManagerPayCustomerView> {
  final _provider = PayCustomerProvider();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchData();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showDetail(PayCustomer p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.customerName ?? 'Không tên',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              ManagerInfoRow(icon: Icons.card_membership, title: 'Gói', value: p.planName ?? '-'),
              ManagerInfoRow(
                icon: Icons.calendar_today,
                title: 'Ngày',
                value: p.date != null
                    ? DateFormat('dd/MM/yyyy').format(p.date!)
                    : '-',
              ),
              ManagerInfoRow(icon: Icons.attach_money, title: 'Giá', value: '${p.price ?? 0} VNĐ'),
              ManagerStatusRow(status: p.status),
              if (p.bankCode != null)
                ManagerInfoRow(icon: Icons.account_balance, title: 'Ngân hàng', value: p.bankCode!),
              if (p.txnRef != null)
                ManagerInfoRow(icon: Icons.confirmation_number, title: 'Mã GD', value: p.txnRef!),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text('Đóng',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _provider.deleteItem(p.uuid!);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thanh toán'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _provider.fetchData(isRefresh: true),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: _provider.isFirstLoad && _provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_provider.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _provider.list.isEmpty
                ? const Center(
              child: Text('Không có dữ liệu',
                  style: TextStyle(color: Colors.white70)),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: _provider.list.length + 1,
              itemBuilder: (context, index) {
                if (index < _provider.list.length) {
                  return PayCustomerCard(
                    payCustomer: _provider.list[index],
                    onTap: () =>
                        _showDetail(_provider.list[index]),
                  );
                }
                return _provider.hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator()),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Hết dữ liệu',
                        style: TextStyle(color: Colors.white70)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}