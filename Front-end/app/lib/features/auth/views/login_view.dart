import 'package:flutter/material.dart';
import 'package:gym/features/auth/providers/login_provider.dart';
import 'package:gym/features/auth/widgets/auth_text_field.dart';
import 'package:gym/features/auth/widgets/forgot_password_dialog.dart';
import 'package:gym/features/home/home_shell.dart';
import 'package:gym/features/auth/views/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _provider = LoginProvider();

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final account = await _provider.login(
      context,
      _mailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (account != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      _passwordController.clear();
      setState(() {});
    }
  }

  void _openForgotPassword() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForgotPasswordDialog(provider: _provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/logo_transparent_white.png'),
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'GALACTIC FITNESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black, offset: Offset(3, 3))
                    ],
                  ),
                ),
                const Text(
                  'Trung tâm huấn luyện phi hành gia',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Error message
                if (_provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _provider.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),

                AuthTextField(
                  controller: _mailController,
                  label: 'Mail',
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _provider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAB40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _provider.isLoading
                        ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
                      'Đăng Nhập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: _openForgotPassword,
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterView()),
                  ),
                  child: const Text(
                    'Chưa có tài khoản? Đăng ký ngay',
                    style: TextStyle(
                        color: Color(0xFFFFAB40), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}