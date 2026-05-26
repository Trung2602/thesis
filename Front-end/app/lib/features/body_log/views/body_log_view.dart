import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import 'package:gym/models/body_log.dart';
import 'package:gym/models/goal.dart';
import '../../../models/account.dart';
import '../providers/body_log_provider.dart';
import '../widgets/body_log_card.dart';
import '../widgets/goal_card.dart';

class BodyLogView extends StatefulWidget {
  const BodyLogView({super.key});

  @override
  State<BodyLogView> createState() => _BodyLogViewState();
}

class _BodyLogViewState extends State<BodyLogView> {
  late final BodyLogProvider _provider;
  bool _didInit = false;
  Account? account;

  @override
  void initState() {
    super.initState();
    _provider = BodyLogProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account ??= Provider.of<AccountProvider>(context, listen: false).account;
    if (account != null && !_didInit) {
      _didInit = true;
      _provider.loadBodyLogs(account!.uuid);
      _provider.loadGoal();
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  Future<void> _showBodyLogForm({BodyLog? existing}) async {
    final weightCtrl = TextEditingController(text: existing?.weight.toString() ?? '');
    final heightCtrl = TextEditingController(text: existing?.height.toString() ?? '');
    final fatCtrl    = TextEditingController(text: existing?.bodyFatPercent?.toString() ?? '');
    final muscleCtrl = TextEditingController(text: existing?.muscleMass?.toString() ?? '');
    final noteCtrl   = TextEditingController(text: existing?.note ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          existing == null ? 'Thêm chỉ số' : 'Sửa chỉ số',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(weightCtrl, 'Cân nặng (kg)'),
              _field(heightCtrl, 'Chiều cao (cm)'),
              _field(fatCtrl,    '% mỡ cơ thể (tuỳ chọn)'),
              _field(muscleCtrl, 'Khối lượng cơ kg (tuỳ chọn)'),
              _field(noteCtrl,   'Ghi chú (tuỳ chọn)', isNumber: false),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final data = {
      'customerUuid': account!.uuid,
      if (weightCtrl.text.isNotEmpty) 'weight': double.tryParse(weightCtrl.text),
      if (heightCtrl.text.isNotEmpty) 'height': double.tryParse(heightCtrl.text),
      if (fatCtrl.text.isNotEmpty)    'bodyFatPercent': double.tryParse(fatCtrl.text),
      if (muscleCtrl.text.isNotEmpty) 'muscleMass': double.tryParse(muscleCtrl.text),
      if (noteCtrl.text.isNotEmpty)   'note': noteCtrl.text,
    };

    final error = existing == null
        ? await _provider.createBodyLog(data)
        : await _provider.updateBodyLog(existing.uuid!, data);

    if (!mounted) return;
    if (error == null) {
      await _provider.loadBodyLogs(account!.uuid);
      _showMsg(existing == null ? 'Đã thêm chỉ số' : 'Đã cập nhật');
    } else {
      _showMsg(error, isError: true);
    }
  }

  Future<void> _showGoalForm() async {
    final existing = _provider.currentGoal;
    String selectedType = existing?.goalType ?? 'LOSE_WEIGHT';
    final weightCtrl = TextEditingController(text: existing?.targetWeight?.toString() ?? '');
    final fatCtrl    = TextEditingController(text: existing?.targetBodyFat?.toString() ?? '');
    DateTime? deadline = existing?.deadline;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            existing == null ? 'Đặt mục tiêu' : 'Sửa mục tiêu',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco('Loại mục tiêu'),
                  items: const [
                    DropdownMenuItem(value: 'LOSE_WEIGHT', child: Text('Giảm cân')),
                    DropdownMenuItem(value: 'GAIN_MUSCLE', child: Text('Tăng cơ')),
                    DropdownMenuItem(value: 'MAINTAIN',    child: Text('Duy trì')),
                  ],
                  onChanged: (v) => setS(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                _field(weightCtrl, 'Cân nặng mục tiêu (kg)'),
                _field(fatCtrl,    '% mỡ mục tiêu'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setS(() => deadline = picked);
                      },
                      child: Text(
                        deadline != null
                            ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                            : 'Chọn deadline',
                        style: const TextStyle(color: Color(0xFFFFAB40)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final data = {
      'goalType': selectedType,
      if (weightCtrl.text.isNotEmpty) 'targetWeight': double.tryParse(weightCtrl.text),
      if (fatCtrl.text.isNotEmpty)    'targetBodyFat': double.tryParse(fatCtrl.text),
      if (deadline != null)
        'deadline':
        '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}',
    };

    final error = await _provider.saveGoal(data, uuid: existing?.uuid);
    if (!mounted) return;
    if (error == null) {
      _showMsg(existing == null ? 'Đã đặt mục tiêu' : 'Đã cập nhật mục tiêu');
    } else {
      _showMsg(error, isError: true);
    }
  }

  Future<void> _handleDeleteBodyLog(String uuid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc muốn xóa bản ghi này?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await _provider.deleteBodyLog(uuid, account!.uuid);
    if (!mounted) return;
    _showMsg(error == null ? 'Đã xóa' : error!, isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final role = account?.role ?? '';
    final isCustomer = role == 'CUSTOMER';

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<BodyLogProvider>(
        builder: (ctx, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          appBar: AppBar(
            title: const Text('Chỉ Số Cơ Thể'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: const Color(0xFFFFD740),
          ),
          body: provider.isLoading && provider.bodyLogs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              if (provider.isLoading) const LinearProgressIndicator(),
              if (isCustomer) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: provider.isGoalLoading
                      ? const LinearProgressIndicator()
                      : provider.currentGoal == null
                      ? _NoGoalBanner(onTap: _showGoalForm)
                      : GoalCard(
                    goal: provider.currentGoal!,
                    onEdit: () => _showGoalForm(),
                    onDelete: () async {
                      final err = await provider.deleteGoal(
                          provider.currentGoal!.uuid!);
                      if (!mounted) return;
                      _showMsg(
                          err == null ? 'Đã xóa mục tiêu' : err,
                          isError: err != null);
                    },
                    onAchieve: provider.currentGoal!.isAchieved == true
                        ? null
                        : () async {
                      final err = await provider.markAchieved(
                          provider.currentGoal!.uuid!);
                      if (!mounted) return;
                      _showMsg(
                          err == null ? 'Chúc mừng! Đã đạt mục tiêu 🎉' : err,
                          isError: err != null);
                    },
                  ),
                ),
                const SizedBox(height: 4),
              ],

              Expanded(
                child: provider.bodyLogs.isEmpty
                    ? const Center(
                  child: Text(
                    'Chưa có dữ liệu chỉ số cơ thể',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    await _provider.loadBodyLogs(account!.uuid);
                    await _provider.loadGoal();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: provider.bodyLogs.length,
                    itemBuilder: (ctx, i) {
                      final log = provider.bodyLogs[i];
                      return BodyLogCard(
                        log: log,
                        onEdit: null,
                        onDelete: null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool isNumber = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDeco(label),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24)),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFAB40))),
  );
}

class _NoGoalBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _NoGoalBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          children: [
            Icon(Icons.flag_outlined, color: Colors.white38, size: 18),
            SizedBox(width: 8),
            Text('Chưa có mục tiêu — nhấn để đặt mục tiêu',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}