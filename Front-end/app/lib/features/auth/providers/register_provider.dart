import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gym/services/auth_service.dart';
import 'package:gym/models/customer_request.dart';

class RegisterProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _picker = ImagePicker();

  bool isLoading = false;
  String? errorMessage;
  File? selectedImage;
  bool gender = true; // true = MALE
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void toggleGender(bool val) {
    gender = val;
    notifyListeners();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<bool> register({
    required String mail,
    required String password,
    required String confirmPassword,
    required String name,
    required String birthday,
    required String weight,
    required String height,
  }) async {
    if (selectedImage == null) {
      errorMessage = 'Vui lòng chọn ảnh đại diện';
      notifyListeners();
      return false;
    }
    if (password != confirmPassword) {
      errorMessage = 'Mật khẩu không khớp';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = CustomerRequest(
        mail: mail,
        password: password,
        name: name,
        birthday: DateTime.parse(birthday),
        gender: gender ? 'MALE' : 'FEMALE',
        weight: double.tryParse(weight) ?? 0,
        height: double.tryParse(height) ?? 0,
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      );
      final registered = await _authService.registerCustomer(request, selectedImage);
      return registered;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String mail, int otp) =>
      _authService.verifyOtp(mail, otp);
}