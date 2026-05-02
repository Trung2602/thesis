import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:gym/cache/manager_cache.dart';
import 'package:gym/features/auth/views/login_view.dart';
import 'package:gym/models/account_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../cache/app_cache.dart';
import '../models/account.dart';
import 'package:provider/provider.dart';

import '../models/customer_request.dart';

class AuthService {
  Future<Account?> login(BuildContext context, String mail, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(UserServerApi.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mail": mail, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      if (token != null) {
        await prefs.setString("token", token);
        final meResponse = await http.get(
          Uri.parse(UserServerApi.me),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        );
        if (meResponse.statusCode == 200) {
          final userData = jsonDecode(meResponse.body);
          final account = Account.fromJson(userData);

          await prefs.setString("account", jsonEncode(account.toJson()));
          final accountProvider = Provider.of<AccountProvider>(context, listen: false);
          accountProvider.setAccount(account);
          return account;
        }
      }
    } else if (response.statusCode == 401) {
      debugPrint("Sai mail hoặc password");
      return null;
    } else {
      debugPrint("Login failed: ${response.statusCode} - ${response.body}");
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

    var uri = Uri.parse(UserServerApi.register);

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
      Uri.parse(UserServerApi.otpURL),
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
    await prefs.remove("account");
    AppCache().clearAll();
    ManagerCache().clearAll();
    if (context.mounted) {
      context.read<AccountProvider>().clearAccount();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
      );
    }
  }

  Future<bool> forgotPassword(String mail) async {
    final response = await http.post(
      Uri.parse(UserServerApi.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mail': mail}),
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyForgotOtp(String mail, int otp) async {
    final response = await http.post(
      Uri.parse(UserServerApi.forgotPasswordVerifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mail': mail, 'otp': otp}),
    );
    return response.statusCode == 200;
  }

  Future<bool> resetPassword(String mail, String newPassword) async {
    final response = await http.post(
      Uri.parse(UserServerApi.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mail': mail,
        'newPassword': newPassword
      }),
    );
    return response.statusCode == 200;
  }

}
