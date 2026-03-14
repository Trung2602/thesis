import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/AccountProvider.dart';
import '../models/PayCustomer.dart';
import '../models/Account.dart';
import '../api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_webview.dart';

class PayCustomerScreen extends StatefulWidget {
  const PayCustomerScreen({super.key});

  @override
  State<PayCustomerScreen> createState() => _PayCustomerScreenState();
}

class _PayCustomerScreenState extends State<PayCustomerScreen> {
  List<PayCustomerModel> payList = [];
  bool loading = true;

  Account? account;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
    fetchPayCustomers();
  }

  Future<void> fetchPayCustomers() async {
    setState(() {
      loading = true;
    });

    try {
      final url = Api.getPayCustomersAll(account!.id);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        payList = data.map((e) => PayCustomerModel.fromJson(e)).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _showPlanDialogAndPay() async {
    List<dynamic> plans = [];

    // 1. Lấy danh sách gói từ API
    try {
      final res = await http.get(Uri.parse(Api.getPlans));
      if (res.statusCode == 200) {
        plans = jsonDecode(res.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi tải gói: ${res.statusCode}")));
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      return;
    }

    // 2. Mở dialog chọn gói
    final selectedPlan = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        if (plans.isEmpty) {
          return AlertDialog(
            title: const Text("Chưa có gói tập"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              )
            ],
          );
        }

        return AlertDialog(
          title: const Text("Chọn gói tập"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return ListTile(
                  title: Text("${plan['name']} - ${plan['price']} VND"),
                  onTap: () => Navigator.of(context).pop(plan),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedPlan == null) return;

    try {
      // Gọi API /payment/create
      final uri = Uri.parse(
          "${Api.createPayment}?planId=${selectedPlan['id']}&username=${account!.username}");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final paymentUrl = data['paymentUrl'];

        //Mở WebView trong app
        final resultUrl = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebView(paymentUrl: paymentUrl),
          ),
        );

        if (resultUrl != null && resultUrl['status'] == 'SUCCESS') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thanh toán thành công!")),
          );
          await fetchPayCustomers();
          final accRes = await http.get(Uri.parse(Api.getCustomerById(account!.id)));
          if (accRes.statusCode == 200) {
            final updatedCustomer = Account.fromJson(jsonDecode(accRes.body));
            Provider.of<AccountProvider>(context, listen: false).setAccount(updatedCustomer);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thanh toán thất bại")),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tạo thanh toán: ${res.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      appBar: AppBar(
        title: Text(
          "Hạn thành viên: ${account?.expiryDate != null ? account!.expiryDate!.toLocal().toString().split(' ')[0] : 'Chưa có'}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : payList.isEmpty
            ? const Center(
          child: Text(
            'Chưa có thanh toán nào',
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          itemCount: payList.length,
          itemBuilder: (context, index) {
            final pay = payList[index];
            return Card(
              color: Colors.white.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Gói tập: ${pay.planName}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text("Giá: ${pay.price} VND",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("Ngày đóng: ${pay.date}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("Mã GD: ${pay.txnRef ?? '-'}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("Trạng thái: ${pay.status ?? 'Unknown'}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    if (pay.bankCode != null)
                      Text("Ngân hàng: ${pay.bankCode}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPlanDialogAndPay,
        label: const Text("Thanh Toán"),
        icon: const Icon(Icons.payment),
        backgroundColor: Colors.greenAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
