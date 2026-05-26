import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/models/account.dart';
import 'package:gym/models/facility.dart';
import 'package:gym/api/gym_server_api.dart';

import '../../../services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final _picker = ImagePicker();

  File? selectedImage;
  String? errorText;
  List<Facility> facilities = [];

  ProfileProvider() {
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final token = await AuthService().getToken();
      final res = await http.get(
        Uri.parse(GymServerApi.getFacilities),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        facilities = data.map((e) => Facility.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  void clearError() {
    errorText = null;
    notifyListeners();
  }

  Future<Account?> saveProfile({
    required String uuid,
    required String password,
    required String name,
    required String mail,
    required String gender,
    required String role,
    required bool isActive,
    required DateTime? birthday,
    // CUSTOMER
    double? weight,
    double? height,
    // STAFF
    String? staffType,
    String? facilityUuid,
  }) async {
    if (password.isEmpty) {
      errorText = 'Vui lòng nhập mật khẩu';
      notifyListeners();
      return null;
    }

    try {
      final token = await AuthService().getToken();
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

      final String updateUrl;
      switch (role) {
        case 'CUSTOMER':
          updateUrl = UserServerApi.patchCustomer(uuid);
          break;
        case 'STAFF':
          updateUrl = UserServerApi.patchStaff(uuid);
          break;
        default:
          updateUrl = UserServerApi.patchAdmin(uuid);
      }

      final request = http.MultipartRequest('PATCH', Uri.parse(updateUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['mail'] = mail;
      request.fields['gender'] = gender;
      request.fields['isActive'] = isActive.toString();
      if (birthday != null) {
        request.fields['birthday'] = birthday.toIso8601String().split('T')[0];
      }
      if (role == 'CUSTOMER') {
        if (weight != null) request.fields['weight'] = weight.toString();
        if (height != null) request.fields['height'] = height.toString();
      } else if (role == 'STAFF') {
        if (staffType != null) request.fields['type'] = staffType;
        if (facilityUuid != null) request.fields['facilityUuid'] = facilityUuid;
      }
      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', selectedImage!.path),
        );
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

  Future<bool> changePassword({
    required String oldPass,
    required String newPass,
    required String confirmPass,
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
      final token = await AuthService().getToken();
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