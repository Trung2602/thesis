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

  DateTime? _birthday;
  String _gender = 'MALE';
  String _role = 'CUSTOMER';
  bool _isActive = true;
  bool _isInit = true;

  late final ProfileProvider _provider;

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
        _isActive = account.isActive;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  void _openSaveDialog() {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: _provider,
        child: SaveProfileDialog(
          name: _nameController.text,
          mail: _mailController.text,
          gender: _gender,
          role: _role,
          isActive: _isActive,
          birthday: _birthday,
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                          if (picked != null) {
                            setState(() => _birthday = picked);
                          }
                        },
                      ),
                      SwitchListTile(
                        value: _gender == 'MALE',
                        onChanged: (val) => setState(
                                () => _gender = val ? 'MALE' : 'FEMALE'),
                        title: Text(
                            'Giới tính: ${_gender == 'MALE' ? 'Nam' : 'Nữ'}'),
                      ),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: _role),
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.security),
                        ),
                      ),
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