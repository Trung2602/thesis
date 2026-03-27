import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_provider.dart';
import '../models/pay_customer.dart';
import '../models/account.dart';
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
  List<PayCustomer> payList = [];
  bool loading = true;

  Account? account;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
    fetchPayCustomers();
  }

  Future<void> fetchPayCustomers() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final url = Api.getPayCustomersAll(account!.uuid);
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          payList = data.map((e) => PayCustomer.fromJson(e)).toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void showMsg(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _showPlanDialogAndPay() async {
    List<dynamic> plans = [];

    //Lấy danh sách gói từ API
    try {
      final res = await http.get(Uri.parse(Api.getPlans));
      if (!mounted) return;
      if (res.statusCode == 200) {
        plans = jsonDecode(res.body);
      } else {
        showMsg("Lỗi tải gói: ${res.statusCode}", isError: true);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      showMsg("Lỗi: $e", isError: true);
      return;
    }

    //Mở dialog chọn gói
    final selectedPlan = await showDialog<dynamic>(
      context: context,
      builder: (dialogContext) {
        if (plans.isEmpty) {
          return AlertDialog(
            title: const Text("Chưa có gói tập"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
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
                  onTap: () => Navigator.of(dialogContext).pop(plan),
                );
              },
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    if (selectedPlan == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      final res = await http.post(
        Uri.parse(Api.createPayment),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "planUuid": selectedPlan['uuid'],
        }),
      );


      if (!mounted) return;
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
        if (!mounted) return;
        if (resultUrl?['status'] == 'SUCCESS') {
          showMsg("Thanh toán thành công!");
          await fetchPayCustomers();
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token") ?? "";
          final accRes = await http.get(
            Uri.parse(Api.me),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );
          if (!mounted) return;
          if (accRes.statusCode == 200) {
            final updatedCustomer = Account.fromJson(jsonDecode(accRes.body));
            Provider.of<AccountProvider>(context, listen: false).setAccount(updatedCustomer);
          }
        } else {
          showMsg("Thanh toán thất bại", isError: true);
        }

      } else {
        showMsg("Lỗi tạo thanh toán: ${res.statusCode}", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
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
              color: Colors.white.withValues(alpha: 0.08),
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
