import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/salary_provider.dart';
import '../widgets/salary_card.dart';

class SalaryView extends StatefulWidget {
  const SalaryView({super.key});

  @override
  State<SalaryView> createState() => _SalaryViewState();
}

class _SalaryViewState extends State<SalaryView> {
  late final SalaryProvider _provider;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _provider = SalaryProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    if (account != null && !_didInit) {
      _didInit = true;
      _provider.fetchSalaries(account.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<SalaryProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          body: provider.isFirstLoad && provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              if (provider.isLoading)
                const LinearProgressIndicator(),
              Expanded(
                child: provider.salaries.isEmpty
                    ? const Center(
                  child: Text(
                    'Chưa có dữ liệu lương',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.salaries.length,
                  itemBuilder: (context, index) =>
                      SalaryCard(salary: provider.salaries[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}