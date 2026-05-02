import 'package:flutter/material.dart';
import '../providers/login_provider.dart';
import 'auth_text_field.dart';
import 'reset_password_dialog.dart';

class OtpDialog extends StatefulWidget {
  final String email;
  final LoginProvider provider;

  const OtpDialog({super.key, required this.email, required this.provider});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final _otpController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F4E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Nhập mã OTP',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mã xác nhận đã được gửi đến\n${widget.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _otpController,
            label: 'Mã OTP',
            prefixIcon: Icons.pin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            hintText: '------',
            style: const TextStyle(
                color: Colors.white, letterSpacing: 8, fontSize: 20),
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
            final otpText = _otpController.text.trim();
            if (otpText.isEmpty || otpText.length < 6) {
              setState(() => _errorText = 'Vui lòng nhập đủ 6 chữ số');
              return;
            }
            final success = await widget.provider.verifyOtp(
                widget.email, int.parse(otpText));
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ResetPasswordDialog(
                    email: widget.email, provider: widget.provider),
              );
            } else {
              setState(() => _errorText = 'Mã OTP không đúng hoặc đã hết hạn');
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