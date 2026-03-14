import 'package:flutter/material.dart';
import '../models/Account.dart';

class AccountProvider with ChangeNotifier {
  Account? _account;

  Account? get account => _account;

  void setAccount(Account? account) {
    _account = account;
    notifyListeners(); // báo cho widget nào đang listen rebuild lại
  }

  void clearAccount() {
    _account = null;
    notifyListeners();
  }
}
