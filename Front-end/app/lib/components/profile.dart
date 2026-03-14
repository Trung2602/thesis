import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Account.dart';
import '../models/AccountProvider.dart';
import '../api.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  late TextEditingController nameController;
  late TextEditingController mailController;
  late TextEditingController avatarController;
  late TextEditingController passwordController;
  late TextEditingController usernameController;

  DateTime? birthday;
  bool gender = true;
  String role = "Customer";
  bool isActive = true;

  File? _selectedImage;
  final picker = ImagePicker();

  bool _isInit = true; // để init dữ liệu lần đầu

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    mailController = TextEditingController();
    avatarController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final account = Provider.of<AccountProvider>(context).account;
      if (account != null) {
        usernameController.text = account.username;
        nameController.text = account.name;
        mailController.text = account.mail;
        avatarController.text = account.avatar;
        passwordController.text = '';
        birthday = account.birthday;
        gender = account.gender;
        role = account.role;
        isActive = account.isActive;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mailController.dispose();
    avatarController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _showSaveDialog(BuildContext context) {
    final account = Provider.of<AccountProvider>(context, listen: false).account;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Xác nhận mật khẩu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nhập mật khẩu",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text("Lưu"),
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  setState(() => errorText = "Vui lòng nhập mật khẩu");
                  return;
                }

                try {
                  // Lấy token từ SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString("token") ?? "";

                  if (token.isEmpty) {
                    setState(() => errorText = "Bạn chưa đăng nhập");
                    return;
                  }

                  // Verify password
                  final verifyRes = await http.post(
                    Uri.parse(Api.verifyPassword),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",},
                    body: jsonEncode({
                      "password": password,
                    }),
                  );

                  if (verifyRes.statusCode != 200) {
                    setState(() => errorText = verifyRes.body);
                    return;
                  }

                  // Update account
                  final uri = Uri.parse(Api.accountUpdate);
                  final request = http.MultipartRequest('POST', uri);

                  request.headers['Authorization'] = "Bearer $token";
                  request.fields['name'] = nameController.text;
                  request.fields['mail'] = mailController.text;
                  request.fields['gender'] = gender.toString();
                  request.fields['role'] = role;
                  request.fields['isActive'] = isActive.toString();
                  if (birthday != null) request.fields['birthday'] = birthday!.toIso8601String();
                  if (passwordController.text.isNotEmpty) request.fields['password'] = passwordController.text;

                  if (_selectedImage != null) {
                    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
                  }

                  final streamedRes = await request.send();
                  final res = await http.Response.fromStream(streamedRes);

                  if (res.statusCode == 200) {
                    final updatedAcc = Account.fromJson(jsonDecode(res.body));
                    Provider.of<AccountProvider>(context, listen: false).setAccount(updatedAcc);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thông tin đã được lưu")),
                    );
                  } else {
                    setState(() => errorText = res.body);
                  }
                } catch (e) {
                  setState(() => errorText = "Lỗi kết nối: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, Account account) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Đổi mật khẩu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                ),
              TextField(controller: oldPassController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu cũ", prefixIcon: Icon(Icons.lock_outline))),
              TextField(controller: newPassController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu mới", prefixIcon: Icon(Icons.lock))),
              TextField(controller: confirmPassController, obscureText: true, decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới", prefixIcon: Icon(Icons.lock_reset))),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text("Lưu"),
              onPressed: () async {
                final oldPass = oldPassController.text.trim();
                final newPass = newPassController.text.trim();
                final confirmPass = confirmPassController.text.trim();

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  setState(() => errorText = "Vui lòng nhập đầy đủ thông tin");
                  return;
                }

                if (newPass != confirmPass) {
                  setState(() => errorText = "Xác nhận mật khẩu mới không khớp");
                  return;
                }

                try {
                  // Lấy token từ SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString("token") ?? "";

                  if (token.isEmpty) {
                    setState(() => errorText = "Bạn chưa đăng nhập");
                    return;
                  }

                  final changeRes = await http.post(
                    Uri.parse(Api.changePassword),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",},
                    body: jsonEncode({
                      "password": oldPass,
                      "newPassword": newPass,
                    }),
                  );

                  if (changeRes.statusCode == 200) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu đã được đổi thành công")),
                    );
                  } else {
                    setState(() => errorText = changeRes.body);
                  }
                } catch (e) {
                  setState(() => errorText = "Lỗi kết nối: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;

    if (account == null) return const Center(child: Text("Chưa có tài khoản"));

    return Scaffold(
      body: Container(
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/background.jpg'),
        //     fit: BoxFit.cover,
        //     opacity: 0.7,
        //   ),
        // ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (account.avatar.isNotEmpty ? NetworkImage(account.avatar) : null) as ImageProvider?,
                    child: (_selectedImage == null && account.avatar.isEmpty)
                        ? const Icon(Icons.person, size: 80, color: Colors.white70)
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
              // Form
              Card(
                color: Colors.white.withOpacity(0.85),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: usernameController, readOnly: true, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.account_circle))),
                      const SizedBox(height: 10),
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên", prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 10),
                      TextField(controller: mailController, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail))),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text("Ngày sinh: ${birthday != null ? birthday.toString().split(' ')[0] : 'Chưa chọn'}"),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: birthday ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => birthday = picked);
                        },
                      ),
                      SwitchListTile(value: gender, onChanged: (val) => setState(() => gender = val), title: Text("Giới tính: ${gender ? "Nam" : "Nữ"}")),
                      TextField(readOnly: true, controller: TextEditingController(text: role), decoration: const InputDecoration(labelText: "Vai trò", prefixIcon: Icon(Icons.security))),
                      SwitchListTile(value: isActive, onChanged: null, title: const Text("Kích hoạt tài khoản")), //onChanged: (val) => setState(() => isActive = val)
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showChangePasswordDialog(context, account),
                            icon: const Icon(Icons.lock, color: Colors.white),
                            label: const Text("Đổi Mật Khẩu"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showSaveDialog(context),
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Lưu Thay Đổi"),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C318F), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
