import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/profile_provider.dart';

class SaveProfileDialog extends StatefulWidget {
  final String name;
  final String mail;
  final String gender;
  final String role;
  final bool isActive;
  final DateTime? birthday;

  const SaveProfileDialog({
    super.key,
    required this.name,
    required this.mail,
    required this.gender,
    required this.role,
    required this.isActive,
    required this.birthday,
  });

  @override
  State<SaveProfileDialog> createState() => _SaveProfileDialogState();
}

class _SaveProfileDialogState extends State<SaveProfileDialog> {
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return AlertDialog(
      title: const Text('Xác nhận mật khẩu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_errorText!,
                  style: const TextStyle(color: Colors.red)),
            ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nhập mật khẩu',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedAccount = await provider.saveProfile(
              password: _passwordController.text.trim(),
              name: widget.name,
              mail: widget.mail,
              gender: widget.gender,
              role: widget.role,
              isActive: widget.isActive,
              birthday: widget.birthday,
            );

            if (!context.mounted) return;

            if (updatedAccount != null) {
              context
                  .read<AccountProvider>()
                  .setAccount(updatedAccount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thông tin đã được lưu')),
              );
            } else {
              setState(() => _errorText = provider.errorText);
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}