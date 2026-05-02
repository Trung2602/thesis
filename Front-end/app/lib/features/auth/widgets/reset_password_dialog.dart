import 'package:flutter/material.dart';
import '../providers/login_provider.dart';

class ResetPasswordDialog extends StatefulWidget {
  final String email;
  final LoginProvider provider;

  const ResetPasswordDialog(
      {super.key, required this.email, required this.provider});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorText;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.white54,
        ),
        onPressed: onToggle,
      ),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F4E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Đặt mật khẩu mới',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'Mật khẩu mới',
              prefixIcon: Icons.lock,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'Nhập lại mật khẩu mới',
              prefixIcon: Icons.lock_outline,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ).copyWith(
              errorText: _errorText,
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFAB40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final newPass = _newPasswordController.text;
            final confirmPass = _confirmPasswordController.text;
            if (newPass.isEmpty) {
              setState(() => _errorText = 'Vui lòng nhập mật khẩu mới');
              return;
            }
            if (newPass.length < 6) {
              setState(() => _errorText = 'Mật khẩu tối thiểu 6 ký tự');
              return;
            }
            if (newPass != confirmPass) {
              _confirmPasswordController.clear();
              setState(() => _errorText = 'Mật khẩu không khớp');
              return;
            }
            final success =
            await widget.provider.resetPassword(widget.email, newPass);
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đổi mật khẩu thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              setState(
                      () => _errorText = 'Đặt lại mật khẩu thất bại, vui lòng thử lại');
            }
          },
          child: const Text(
            'Xác nhận',
            style: TextStyle(
                color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}