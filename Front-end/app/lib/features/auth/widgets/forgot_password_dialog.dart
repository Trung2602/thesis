import 'package:flutter/material.dart';
import '../providers/login_provider.dart';
import 'auth_text_field.dart';
import 'otp_dialog.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final LoginProvider provider;

  const ForgotPasswordDialog({super.key, required this.provider});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F4E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Quên mật khẩu',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nhập email để nhận mã xác nhận',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            errorText: _errorText,
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
            final email = _emailController.text.trim();
            if (email.isEmpty) {
              setState(() => _errorText = 'Vui lòng nhập email');
              return;
            }
            setState(() => _errorText = null);
            final success = await widget.provider.forgotPassword(email);
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => OtpDialog(email: email, provider: widget.provider),
              );
            } else {
              setState(() => _errorText = 'Không tìm thấy tài khoản với email này');
            }
          },
          child: const Text(
            'Xác nhận',
            style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}