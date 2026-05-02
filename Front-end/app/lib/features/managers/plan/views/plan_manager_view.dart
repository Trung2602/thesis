import 'package:flutter/material.dart';

import '../../../../models/plan.dart';
import '../providers/plan_provider.dart';
import '../widgets/plan_card.dart';
import '../../shared/widgets/manager_info_row.dart';

class ManagerPlanView extends StatefulWidget {
  const ManagerPlanView({super.key});

  @override
  State<ManagerPlanView> createState() => _ManagerPlanViewState();
}

class _ManagerPlanViewState extends State<ManagerPlanView> {
  final _provider = PlanProvider();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _provider.fetchPlans();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_provider.isLoading &&
          _provider.hasMore) {
        _provider.fetchPlans();
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openForm({Plan? plan}) {
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final priceCtrl =
    TextEditingController(text: plan?.price?.toString() ?? '');
    final durationCtrl =
    TextEditingController(text: plan?.durationDays?.toString() ?? '');
    final descCtrl =
    TextEditingController(text: plan?.description ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plan == null ? 'Thêm gói' : 'Sửa gói',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(color: Colors.white24),
                _buildField(nameCtrl, 'Tên gói'),
                const SizedBox(height: 10),
                _buildField(priceCtrl, 'Giá',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildField(durationCtrl, 'Số ngày',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildField(descCtrl, 'Mô tả', maxLines: 2),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      label: const Text('Hủy',
                          style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      onPressed: () async {
                        await _provider.savePlan({
                          'uuid': plan?.uuid,
                          'name': nameCtrl.text.trim(),
                          'price': int.tryParse(priceCtrl.text),
                          'durationDays':
                          int.tryParse(durationCtrl.text),
                          'description': descCtrl.text.trim(),
                        });
                        if (mounted) Navigator.pop(context);
                        _provider.fetchPlans(isRefresh: true);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  void _showDetail(Plan p) {
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
                  const Icon(Icons.workspace_premium, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              ManagerInfoRow(icon: Icons.attach_money, title: 'Giá', value: '${p.price ?? 0} VNĐ'),
              ManagerInfoRow(icon: Icons.date_range, title: 'Thời hạn', value: '${p.durationDays ?? 0} ngày'),
              ManagerInfoRow(icon: Icons.description, title: 'Mô tả', value: p.description ?? ''),
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
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openForm(plan: p);
                    },
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    label: const Text('Sửa',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await _provider.deletePlan(p.uuid!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa')),
                        );
                        _provider.fetchPlans(isRefresh: true);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Xóa',
                        style: TextStyle(color: Colors.red)),
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
        title: const Text('Quản lý gói tập'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD740),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          if (_provider.isLoading && _provider.isFirstLoad)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _provider.fetchPlans(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _provider.plans.length + 1,
                itemBuilder: (context, index) {
                  if (index < _provider.plans.length) {
                    return PlanCard(
                      plan: _provider.plans[index],
                      onTap: () => _showDetail(_provider.plans[index]),
                    );
                  }
                  return _provider.hasMore
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child:
                    Center(child: CircularProgressIndicator()),
                  )
                      : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('Hết dữ liệu',
                          style:
                          TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}