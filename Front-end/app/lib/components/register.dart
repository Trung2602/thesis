import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/customer_request.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _gender = true; // true = male
  bool _isLoading = false;
  String? _errorMessage;

  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late BuildContext rootContext;

  @override
  void initState() {
    super.initState();
    rootContext = context;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitRegister() async {

    if (_selectedImage == null) {
      setState(() => _errorMessage = "Vui lòng chọn ảnh đại diện");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Mật khẩu không khớp");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = CustomerRequest(
        mail: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        birthday: DateTime.parse(_birthdayController.text),
        gender: _gender ? "MALE" : "FEMALE",
        weight: double.tryParse(_weightController.text) ?? 0,
        height: double.tryParse(_heightController.text) ?? 0,
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      );

      final registered = await _authService.registerCustomer(request, _selectedImage);

      if (!mounted) return;

      if (registered) {
        _showOtpDialog(request.mail);
      }

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }

    setState(() => _isLoading = false);
  }

  void _showOtpDialog(String mail) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nhập OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(hintText: "OTP"),
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Huỷ"),
            ),

            ElevatedButton(
              onPressed: () async {
                final otp = int.tryParse(otpController.text.trim());
                if (otp == null) return;
                Navigator.pop(context);
                final success = await _authService.verifyOtp(mail, otp);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đăng ký thành công, hãy đăng nhập")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP không hợp lệ")),
                  );
                }
              },
              child: const Text("Xác nhận"),
            )
          ],
        );
      },
    );
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _birthdayController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _selectedImage != null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),

      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: const Color(0xFF1A237E),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Chọn ảnh"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Chụp ảnh"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text("Chọn ảnh"),
                )
              ],
            ),

            const SizedBox(height: 20),

            _input(_nameController, "Họ tên"),
            _input(_emailController, "Email"),
            _passwordField(_passwordController,
                "Mật khẩu",
                    () => setState(() => _obscurePassword = !_obscurePassword),
                _obscurePassword
            ),
            _passwordField(_confirmPasswordController,
                "Xác nhận mật khẩu",
                    () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                _obscureConfirmPassword
            ),
            _datePicker(),
            _input(_weightController, "Cân nặng (kg)", type: TextInputType.number),
            _input(_heightController, "Chiều cao (cm)", type: TextInputType.number),

            const SizedBox(height: 10),

            DropdownButtonFormField<bool>(
              initialValue : _gender,
              items: const [
                DropdownMenuItem(value: true, child: Text("Nam")),
                DropdownMenuItem(value: false, child: Text("Nữ")),
              ],
              onChanged: (v) => setState(() => _gender = v!),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Giới tính",
                labelStyle: TextStyle(color: Colors.yellowAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellowAccent),
                ),
              ),
              dropdownColor: const Color(0xFF0F123A),
            ),

            const SizedBox(height: 20),

            if (_errorMessage != null)Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isFormValid && !_isLoading ? _submitRegister : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Đăng ký"),
            )

          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.yellowAccent),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.yellowAccent),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String label, VoidCallback toggle, bool obscure,) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.yellowAccent),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.yellowAccent),
          ),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  Widget _datePicker() {
    return TextField(
      controller: _birthdayController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: "Ngày sinh",
        labelStyle: TextStyle(color: Colors.yellowAccent),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.yellowAccent),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          _birthdayController.text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }
      },
    );
  }
}
