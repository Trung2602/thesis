import 'package:flutter/material.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache/app_cache.dart';
import '../models/account_provider.dart';
import '../models/pay_customer.dart';
import '../models/account.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'payment_webview.dart';

class PayCustomerScreen extends StatefulWidget {
  const PayCustomerScreen({super.key});

  @override
  State<PayCustomerScreen> createState() => _PayCustomerScreenState();
}

class _PayCustomerScreenState extends State<PayCustomerScreen> {
  List<PayCustomer> payList = [];
  List<PayCustomer> _allData = [];
  int _visibleCount = 5;

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool loading = true;
  bool _loading = false;
  bool isFirstLoad = true;

  final cache = AppCache().payCustomerCache;

  Account? account;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore) {
        _loadMore();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;

    if (account != null && isFirstLoad) {
      isFirstLoad = false;
      fetchPayCustomers(account!.uuid);
    }
  }

  Future<void> fetchPayCustomers(String userUuid) async {
    if (cache.containsKey(userUuid)) {
      final cachedData = cache[userUuid]!;
      setState(() {
        _allData = cachedData;
        _visibleCount = 5;
        payList = _allData.take(_visibleCount).toList();
      });

      return;
    }
    setState(() => _loading = true);

    try {
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse(GymServerApi.getPayCustomers),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final result = data.map((e) => PayCustomer.fromJson(e)).toList();
        cache[userUuid] = result;
        setState(() {
          _allData = result;
          _visibleCount = 5;
          payList = _allData.take(_visibleCount).toList();
        });
      }
    } catch (e) {
      debugPrint("Fetch pay error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loadMore() {
    if (_visibleCount >= _allData.length) return;

    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _visibleCount += 5;
        payList = _allData.take(_visibleCount).toList();
        _isLoadingMore = false;
      });
    });
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
    try {
      final res = await http.get(Uri.parse(GymServerApi.getPlans));
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
        Uri.parse(GymServerApi.createPayment),
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

        //Mở WebView
        final resultUrl = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebView(paymentUrl: paymentUrl),
          ),
        );
        if (!mounted) return;
        if (resultUrl?['status'] == 'SUCCESS') {
          showMsg("Thanh toán thành công!");
          cache.remove(account!.uuid);
          await fetchPayCustomers(account!.uuid);
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token") ?? "";
          final accRes = await http.get(
            Uri.parse(UserServerApi.me),
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : payList.isEmpty
            ? const Center(
          child: Text(
            'Chưa có thanh toán nào',
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: payList.length + 1,
          itemBuilder: (context, index) {
            if (index < payList.length) {
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
                          style: const TextStyle(color: Colors.white)),
                      Text("Giá: ${pay.price} VND",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Ngày đóng: ${pay.date}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Mã GD: ${pay.txnRef ?? '-'}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Trạng thái: ${pay.status ?? 'Unknown'}",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            }
            return _isLoadingMore
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox.shrink();
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
