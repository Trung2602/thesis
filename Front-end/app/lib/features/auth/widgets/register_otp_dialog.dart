import 'package:flutter/material.dart';
import '../providers/register_provider.dart';

class RegisterOtpDialog extends StatefulWidget {
  final String mail;
  final RegisterProvider provider;

  const RegisterOtpDialog({
    super.key,
    required this.mail,
    required this.provider,
  });

  @override
  State<RegisterOtpDialog> createState() => _RegisterOtpDialogState();
}

class _RegisterOtpDialogState extends State<RegisterOtpDialog> {
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
        'Nhập OTP',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mã xác nhận đã được gửi đến\n${widget.mail}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, letterSpacing: 8, fontSize: 20),
            decoration: InputDecoration(
              hintText: '------',
              hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 8),
              counterStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorText: _errorText,
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFAB40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final otp = int.tryParse(_otpController.text.trim());
            if (otp == null || _otpController.text.trim().length < 6) {
              setState(() => _errorText = 'Vui lòng nhập đủ 6 chữ số');
              return;
            }
            final success = await widget.provider.verifyOtp(widget.mail, otp);
            if (!context.mounted) return;
            if (success) {
              Navigator.pop(context); // đóng OTP dialog
              Navigator.pop(context); // quay về màn login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng ký thành công, hãy đăng nhập'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              setState(() => _errorText = 'OTP không hợp lệ hoặc đã hết hạn');
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