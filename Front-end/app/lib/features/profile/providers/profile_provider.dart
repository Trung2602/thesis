import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/models/account.dart';

class ProfileProvider extends ChangeNotifier {
  final _picker = ImagePicker();

  File? selectedImage;
  String? errorText;

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return token.isEmpty ? null : token;
  }

  void clearError() {
    errorText = null;
    notifyListeners();
  }

  Future<Account?> saveProfile({
    required String password,
    required String name,
    required String mail,
    required String gender,
    required String role,
    required bool isActive,
    required DateTime? birthday,
  }) async {
    if (password.isEmpty) {
      errorText = 'Vui lòng nhập mật khẩu';
      notifyListeners();
      return null;
    }

    try {
      final token = await _getToken();
      if (token == null) {
        errorText = 'Bạn chưa đăng nhập';
        notifyListeners();
        return null;
      }

      final verifyRes = await http.post(
        Uri.parse(UserServerApi.verifyPassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': password}),
      );

      if (verifyRes.statusCode != 200) {
        errorText = verifyRes.body;
        notifyListeners();
        return null;
      }

      final request = http.MultipartRequest('PATCH', Uri.parse(UserServerApi.accountUpdate));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['mail'] = mail;
      request.fields['gender'] = gender;
      request.fields['role'] = role;
      request.fields['isActive'] = isActive.toString();

      if (birthday != null) {
        request.fields['birthday'] = birthday.toIso8601String().split('T')[0];
      }
      if (selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        errorText = null;
        notifyListeners();
        return Account.fromJson(jsonDecode(res.body));
      } else {
        errorText = res.body;
        notifyListeners();
        return null;
      }
    } catch (e) {
      errorText = 'Lỗi kết nối: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> changePassword({required String oldPass,
    required String newPass, required String confirmPass,
  }) async {
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      errorText = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }
    if (newPass != confirmPass) {
      errorText = 'Xác nhận mật khẩu mới không khớp';
      notifyListeners();
      return false;
    }

    try {
      final token = await _getToken();
      if (token == null) {
        errorText = 'Bạn chưa đăng nhập';
        notifyListeners();
        return false;
      }

      final res = await http.patch(
        Uri.parse(UserServerApi.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'password': oldPass, 'newPassword': newPass}),
      );

      if (res.statusCode == 200) {
        errorText = null;
        notifyListeners();
        return true;
      } else {
        errorText = res.body;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorText = 'Lỗi kết nối: $e';
      notifyListeners();
      return false;
    }
  }
}