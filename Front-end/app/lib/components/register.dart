import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym/components/home.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/Account.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  bool? _gender = true; // true = Nam, false = Nữ
  String? _errorMessage;
  bool _isLoading = false;

  File? _selectedImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late BuildContext rootContext;

  @override
  void initState() {
    super.initState();
    rootContext = context;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Future<void> _submitRegister() async {
  //   if (_selectedImage == null) {
  //     setState(() {
  //       _errorMessage = "Vui lòng chọn ảnh đại diện!";
  //     });
  //     return;
  //   }
  //
  //   if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
  //     setState(() {
  //       _errorMessage = "Mật khẩu xác nhận không khớp!";
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });
  //
  //   final account = Account(
  //     id: 0,
  //     username: _usernameController.text.trim(),
  //     password: _passwordController.text.trim(),
  //     name: _nameController.text.trim(),
  //     mail: _emailController.text.trim(),
  //     birthday: _birthdayController.text.trim().isNotEmpty
  //         ? DateTime.tryParse(_birthdayController.text.trim())
  //         : null,
  //     gender: _gender ?? true,
  //     role: "Customer",
  //     isActive: true,
  //     avatar: "", // server sẽ nhận file multipart
  //   );
  //
  //   try {
  //     // ép nullable File! vì đã chắc chắn có ảnh
  //     final result = await _authService.registerAndLogin(context, account, _selectedImage!);
  //
  //     if (!mounted) return;
  //
  //     if (result != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Đăng ký thành công!")),
  //       );
  //       // Điều hướng sang màn hình Home hoặc màn hình chính
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()),);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = e.toString();
  //     });
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  Future<void> _submitRegister() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = "Vui lòng chọn ảnh đại diện!";
      });
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = "Mật khẩu xác nhận không khớp!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final account = Account(
      id: 0,
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      mail: _emailController.text.trim(),
      birthday: _birthdayController.text.trim().isNotEmpty
          ? DateTime.tryParse(_birthdayController.text.trim())
          : null,
      gender: _gender ?? true,
      role: "Customer",
      isActive: true,
      avatar: "",
    );

    try {
      // Gọi API đăng ký
      final registered = await _authService.registerWithImage(account, _selectedImage!);

      if (!mounted) return;

      if (registered) {
        // Nếu đăng ký thành công, mở dialog nhập OTP
        _showOtpDialog(context, account);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOtpDialog(BuildContext rootContext, Account account) {
    final otpController = TextEditingController();

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Xác thực OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: "Nhập 6 số OTP",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // dùng ctx để đóng dialog
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final otp = int.tryParse(otpController.text.trim());
                if (otp == null) return;

                Navigator.pop(ctx); // đóng dialog bằng ctx

                // Gọi verifyOtpAndLogin
                final acc = await _authService.verifyOtpAndLogin(
                  rootContext,
                  account.mail ?? '',
                  account.password ?? '',
                  otp,
                );

                if (!rootContext.mounted) return;

                if (acc != null) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(content: Text("Đăng ký & xác thực thành công!")),
                  );
                  Navigator.pushReplacement(
                    rootContext,
                    MaterialPageRoute(builder: (_) => const Home()),
                  );
                } else {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(content: Text("OTP không hợp lệ hoặc đã hết hạn!")),
                  );
                }
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }


  //======================================

  bool get _isFormValid {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _birthdayController.text.isNotEmpty &&
        _selectedImage != null; // bắt buộc chọn ảnh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF0F123A),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar + chọn ảnh
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text("Chọn từ thư viện"),
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
                    icon: const Icon(Icons.image),
                    label: const Text("Chọn ảnh"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Tên đăng nhập",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  labelStyle: const TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  labelStyle: const TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Họ tên",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _birthdayController,
                readOnly: true, // không cho nhập tay
                decoration: const InputDecoration(
                  labelText: "Ngày sinh",
                  labelStyle: TextStyle(color: Colors.white70),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onTap: () async {
                  DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18)); // mặc định 18 tuổi
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: const Color(0xFF1A237E), // màu chọn ngày
                            onPrimary: Colors.white, // màu chữ ngày được chọn
                            onSurface: Colors.black, // màu chữ ngày bình thường
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1A237E), // màu nút Hủy/OK
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    _birthdayController.text = "${pickedDate.year.toString().padLeft(4,'0')}-"
                        "${pickedDate.month.toString().padLeft(2,'0')}-"
                        "${pickedDate.day.toString().padLeft(2,'0')}";
                  }
                },
                onChanged: (value) => setState(() {}),
              ),

              Row(
                children: [
                  const Icon(Icons.wc, color: Colors.white70),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: _gender,
                      dropdownColor: const Color(0xFF1A237E),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text("Nam", style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text("Nữ", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _gender = value);
                      },
                      decoration: const InputDecoration(
                        labelText: "Giới tính",
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading || !_isFormValid ? null : _submitRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Đăng ký",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
