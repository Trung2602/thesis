import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/pay_card.dart';
import 'payment_webview.dart';

class PayCustomerView extends StatefulWidget {
  const PayCustomerView({super.key});

  @override
  State<PayCustomerView> createState() => _PayCustomerViewState();
}

class _PayCustomerViewState extends State<PayCustomerView> {
  final _scrollController = ScrollController();
  late final PaymentProvider _provider;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _provider = PaymentProvider();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _provider.loadMore();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    if (account != null && _isFirstLoad) {
      _isFirstLoad = false;
      _provider.fetchPayCustomers(account.uuid);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Future<void> _handlePay() async {
    List<dynamic> plans = [];
    try {
      plans = await _provider.fetchPlans();
    } catch (e) {
      if (!mounted) return;
      _showMsg('Lỗi: $e', isError: true);
      return;
    }

    if (!mounted) return;

    final selectedPlan = await showDialog<dynamic>(
      context: context,
      builder: (ctx) {
        if (plans.isEmpty) {
          return AlertDialog(
            title: const Text('Chưa có gói tập'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'))
            ],
          );
        }
        return AlertDialog(
          title: const Text('Chọn gói tập'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return ListTile(
                  title:
                  Text('${plan['name']} - ${plan['price']} VND'),
                  onTap: () => Navigator.pop(ctx, plan),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedPlan == null || !mounted) return;

    String paymentUrl;
    try {
      paymentUrl =
          await _provider.createPayment(selectedPlan['uuid']) ?? '';
    } catch (e) {
      if (!mounted) return;
      _showMsg('$e', isError: true);
      return;
    }

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PaymentWebView(paymentUrl: paymentUrl)),
    );

    if (!mounted) return;
    final account = Provider.of<AccountProvider>(context, listen: false).account;

    if (result?['status'] == 'SUCCESS') {
      _showMsg('Thanh toán thành công!');
      await _provider.fetchPayCustomers(account!.uuid, forceRefresh: true);
      final updatedAccount = await _provider.refreshAccount();
      if (!mounted) return;
      if (updatedAccount != null) {
        Provider.of<AccountProvider>(context, listen: false)
            .setAccount(updatedAccount);
      }
    } else {
      _showMsg('Thanh toán thất bại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<PaymentProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          appBar: AppBar(
            title: const Text('Gia hạn thành viên',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A237E),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              TextButton.icon(
                onPressed: _handlePay,
                icon: const Icon(Icons.payment, color: Colors.greenAccent),
                label: const Text(
                  'Thanh Toán',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1A237E),
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'Hạn thành viên: ${account?.expiryDate != null ? account!.expiryDate!.toLocal().toString().split(' ')[0] : 'Chưa có'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.payList.isEmpty
                ? const Center(
              child: Text('Chưa có thanh toán nào',
                style: TextStyle(color: Colors.white),
              ),
            ) : ListView.builder(
              controller: _scrollController,
              itemCount: provider.payList.length + 1,
              itemBuilder: (context, index) {
                if (index < provider.payList.length) {
                  return PayCard(pay: provider.payList[index]);
                }
                return provider.isLoadingMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ) : const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}