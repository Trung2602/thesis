import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/register_provider.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/register_form_field.dart';
import '../widgets/register_otp_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  late final RegisterProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = RegisterProvider();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdayController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _birthdayController.text.isNotEmpty &&
          _weightController.text.isNotEmpty &&
          _heightController.text.isNotEmpty &&
          _provider.selectedImage != null;

  Future<void> _handleRegister() async {
    final registered = await _provider.register(
      mail: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      name: _nameController.text.trim(),
      birthday: _birthdayController.text,
      weight: _weightController.text,
      height: _heightController.text,
    );
    if (!mounted) return;
    if (registered) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => RegisterOtpDialog(
          mail: _emailController.text.trim(),
          provider: _provider,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _birthdayController.text =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<RegisterProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          appBar: AppBar(
            title: const Text('Đăng ký'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AvatarPicker(
                  selectedImage: provider.selectedImage,
                  onPick: provider.pickImage,
                ),
                const SizedBox(height: 20),

                RegisterFormField(
                    controller: _nameController, label: 'Họ tên'),
                RegisterFormField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress),
                RegisterFormField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  obscureText: provider.obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      provider.obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: provider.toggleObscurePassword,
                  ),
                ),
                RegisterFormField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  obscureText: provider.obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      provider.obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: provider.toggleObscureConfirm,
                  ),
                ),

                // Date picker
                RegisterFormField(
                  controller: _birthdayController,
                  label: 'Ngày sinh',
                  readOnly: true,
                  onTap: _pickDate,
                  suffixIcon: const Icon(Icons.calendar_today,
                      color: Colors.white70),
                ),

                RegisterFormField(
                  controller: _weightController,
                  label: 'Cân nặng (kg)',
                  keyboardType: TextInputType.number,
                ),
                RegisterFormField(
                  controller: _heightController,
                  label: 'Chiều cao (cm)',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),

                // Gender dropdown
                DropdownButtonFormField<bool>(
                  initialValue: provider.gender,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Nam')),
                    DropdownMenuItem(value: false, child: Text('Nữ')),
                  ],
                  onChanged: (v) => provider.toggleGender(v!),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF0F123A),
                  decoration: const InputDecoration(
                    labelText: 'Giới tính',
                    labelStyle: TextStyle(color: Colors.yellowAccent),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellowAccent)),
                  ),
                ),

                const SizedBox(height: 20),

                if (provider.errorMessage != null)
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid && !provider.isLoading
                        ? _handleRegister
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAB40),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
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