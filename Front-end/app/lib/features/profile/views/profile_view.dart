import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_section.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/save_profile_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _birthday;
  String _gender = 'MALE';
  String _role = 'CUSTOMER';
  String? _staffType;
  String? _facilityUuid;
  double? _baseSalary;
  bool _isActive = true;
  bool _isInit = true;

  late final ProfileProvider _provider;

  String get _roleDisplayText {
    switch (_role) {
      case 'CUSTOMER':
        return 'Khách Hàng';
      case 'ADMIN':
        return 'Admin';
      case 'STAFF':
        return _staffTypeDisplayText(_staffType);
      default:
        return _role;
    }
  }

  String _staffTypeDisplayText(String? type) {
    switch (type?.toUpperCase()) {
      case 'FULLTIME':
        return 'Nhân viên chính thức';
      case 'PARTTIME':
        return 'Nhân viên bán thời gian';
      case 'INTERN':
        return 'Thực tập sinh';
      default:
        return type ?? 'Nhân viên';
    }
  }

  @override
  void initState() {
    super.initState();
    _provider = ProfileProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final account = Provider.of<AccountProvider>(context).account;
      if (account != null) {
        _nameController.text = account.name;
        _mailController.text = account.mail;
        _birthday = account.birthday;
        _gender = account.gender;
        _role = account.role;
        _staffType = account.type;
        _facilityUuid = account.facilityUuid;
        _baseSalary = account.baseSalary;
        _isActive = account.isActive;
        _weightController.text = account.weight?.toString() ?? '';
        _heightController.text = account.height?.toString() ?? '';
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _openSaveDialog() {
    final account = Provider.of<AccountProvider>(context, listen: false).account;
    if (account == null) return;

    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: _provider,
        child: SaveProfileDialog(
          uuid:  account.uuid,
          name: _nameController.text,
          mail: _mailController.text,
          gender: _gender,
          role: _role,
          isActive: _isActive,
          birthday: _birthday,
          // CUSTOMER
          weight: _role == 'CUSTOMER' ? double.tryParse(_weightController.text) : null,
          height: _role == 'CUSTOMER' ? double.tryParse(_heightController.text) : null,
          // STAFF
          staffType: _staffType,
          facilityUuid: _facilityUuid,
        ),
      ),
    );
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: _provider,
        child: const ChangePasswordDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;
    if (account == null) {
      return const Center(child: Text('Chưa có tài khoản'));
    }

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<ProfileProvider>(
                builder: (_, provider, __) => AvatarSection(
                  selectedImage: provider.selectedImage,
                  avatarUrl: account.avatar,
                  onPick: provider.pickImage,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _mailController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(
                          'Ngày sinh: ${_birthday != null ? _birthday.toString().split(' ')[0] : 'Chưa chọn'}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _birthday ?? DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _birthday = picked);
                        },
                      ),
                      SwitchListTile(
                        value: _gender == 'MALE',
                        onChanged: (val) =>
                            setState(() => _gender = val ? 'MALE' : 'FEMALE'),
                        title: Text('Giới tính: ${_gender == 'MALE' ? 'Nam' : 'Nữ'}'),
                      ),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: _roleDisplayText),
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.security),
                        ),
                      ),

                      // ── CUSTOMER ──────────────────────────────────
                      if (_role == 'CUSTOMER') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _weightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Cân nặng (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _heightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Chiều cao (cm)',
                            prefixIcon: Icon(Icons.height),
                          ),
                        ),
                      ],

                      // ── STAFF ─────────────────────────────────────
                      if (_role == 'STAFF') ...[
                        const SizedBox(height: 10),
                        // Lương cơ bản — readonly
                        TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _baseSalary != null
                                ? _baseSalary!.toStringAsFixed(0)
                                : '—',
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Lương cơ bản (VNĐ)',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Cơ sở — dropdown, load từ provider
                        Consumer<ProfileProvider>(
                          builder: (_, provider, __) {
                            return DropdownButtonFormField<String>(
                              value: _facilityUuid,
                              decoration: const InputDecoration(
                                labelText: 'Cơ sở làm việc',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              items: provider.facilities
                                  .where((f) => f.uuid != null)
                                  .map((f) => DropdownMenuItem(
                                value: f.uuid!,
                                child: Text(f.name ?? ''),
                              ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _facilityUuid = val),
                            );
                          },
                        ),
                      ],

                      SwitchListTile(
                        value: _isActive,
                        onChanged: null,
                        title: const Text('Kích hoạt tài khoản'),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _openChangePasswordDialog,
                            icon: const Icon(Icons.lock, color: Colors.white),
                            label: const Text('Đổi Mật Khẩu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _openSaveDialog,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text('Lưu Thay Đổi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C318F),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}