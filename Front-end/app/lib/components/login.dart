import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
import '../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  void _login() async {
    final mail = _mailController.text.trim();
    final password = _passwordController.text.trim();

    if (mail.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Mail hoặc mật khẩu không được để trống");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await _authService.login(context, mail, password);

      if (!mounted) return;

      if (account != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        _passwordController.clear();
        setState(() => _errorMessage = "Sai địa chỉ mail hoặc mật khẩu");
      }
    } catch (e) {
      setState(() => _errorMessage = "Có lỗi xảy ra: $e");
    }

    setState(() => _isLoading = false);
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
            padding: const EdgeInsets.all(32.0),
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
                  "GALACTIC FITNESS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(3, 3))
                    ],
                  ),
                ),
                const Text(
                  "Trung tâm huấn luyện phi hành gia",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                // Hiển thị thông báo lỗi nếu có
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                // Trường nhập mail
                TextField(
                  controller: _mailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    labelText: 'Mail',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color.fromRGBO(255, 255, 255, 0.1), // Sử dụng Color.fromRGBO để thay thế withOpacity
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Trường nhập mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    labelText: 'Mật khẩu',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color.fromRGBO(255, 255, 255, 0.1), // Sử dụng Color.fromRGBO
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login, // Vô hiệu hóa nút khi đang tải
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAB40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  onPressed: () {
                    // Xử lý quên mật khẩu
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  child: const Text(
                    'Chưa có tài khoản? Đăng ký ngay',
                    style: TextStyle(
                      color: Color(0xFFFFAB40),
                      fontWeight: FontWeight.bold,
                    ),
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