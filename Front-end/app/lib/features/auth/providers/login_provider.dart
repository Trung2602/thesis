import 'package:flutter/material.dart';
import 'package:gym/services/auth_service.dart';
import 'package:gym/models/account.dart';

class LoginProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  void _setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void _setError(String? msg) {
    errorMessage = msg;
    notifyListeners();
  }

  Future<Account?> login(BuildContext context, String mail, String password) async {
    if (mail.isEmpty || password.isEmpty) {
      _setError('Mail hoặc mật khẩu không được để trống');
      return null;
    }
    _setLoading(true);
    _setError(null);
    try {
      final account = await _authService.login(context, mail, password);
      if (account == null) _setError('Sai địa chỉ mail hoặc mật khẩu');
      return account;
    } catch (e) {
      _setError('Có lỗi xảy ra: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) => _authService.forgotPassword(email);

  Future<bool> verifyOtp(String email, int otp) => _authService.verifyForgotOtp(email, otp);

  Future<bool> resetPassword(String email, String newPassword) => _authService.resetPassword(email, newPassword);
}