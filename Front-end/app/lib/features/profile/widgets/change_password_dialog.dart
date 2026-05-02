import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Widget _passField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_errorText!,
                  style: const TextStyle(color: Colors.red)),
            ),
          _passField(_oldPassController, 'Mật khẩu cũ', Icons.lock_outline),
          _passField(_newPassController, 'Mật khẩu mới', Icons.lock),
          _passField(_confirmPassController, 'Xác nhận mật khẩu mới',
              Icons.lock_reset),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await provider.changePassword(
              oldPass: _oldPassController.text.trim(),
              newPass: _newPassController.text.trim(),
              confirmPass: _confirmPassController.text.trim(),
            );
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Mật khẩu đã được đổi thành công')),
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