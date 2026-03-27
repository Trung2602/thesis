// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym/models/account_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
import '../models/account.dart';
import 'package:provider/provider.dart';

import '../models/customer_request.dart';

class AuthService {
  Future<Account?> login(BuildContext context, String mail, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(Api.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mail": mail, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];

      if (token != null) {
        // Lưu token
        await prefs.setString("token", token);

        // Gọi API /account/me để lấy thông tin account
        final meResponse = await http.get(
          Uri.parse(Api.me),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (meResponse.statusCode == 200) {
          final userData = jsonDecode(meResponse.body);
          final account = Account.fromJson(userData);

          // Lưu account JSON để dùng lại
          await prefs.setString("account", jsonEncode(account.toJson()));

          final accountProvider = Provider.of<AccountProvider>(context, listen: false);
          accountProvider.setAccount(account);

          return account;
        }
      }
    } else if (response.statusCode == 401) {
      // Sai mail hoặc password
      print("Sai mail hoặc password");
      return null;
    } else {
      // Có thể log error để debug
      print("Login failed: ${response.statusCode} - ${response.body}");
    }

    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Account?> getSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("account");
    if (jsonString != null) {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return Account.fromJson(data);
    }
    return null;
  }

  Future<bool> registerCustomer(CustomerRequest request, File? image) async {

    var uri = Uri.parse(Api.register);

    var req = http.MultipartRequest("POST", uri);

    request.toJson().forEach((key, value) {
      req.fields[key] = value.toString();
    });

    if (image != null) {
      req.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    var res = await req.send();
    var response = await http.Response.fromStream(res);

    return response.statusCode == 200;
  }

  // Xác thực OTP
  Future<bool> verifyOtp(String mail, int otp) async {
    final response = await http.post(
      Uri.parse(Api.otpURL),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "mail": mail,
        "otp": otp,
      }),
    );

    if (response.statusCode == 200) {
      return true; // OTP đúng
    } else {
      debugPrint("OTP sai hoặc hết hạn: ${response.body}");
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("account"); // xoá luôn account khi logout
    context.read<AccountProvider>().clearAccount();
  }
}
