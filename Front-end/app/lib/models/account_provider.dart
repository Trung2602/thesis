import 'package:flutter/material.dart';
import '../features/chat/providers/firebase_chat_provider.dart';
import 'account.dart';


class AccountProvider with ChangeNotifier {
  Account? _account;

  Account? get account => _account;

  Future<void> setAccount(Account? account) async {
    _account = account;
    notifyListeners();
  }

  void clearAccount() {
    _account = null;
    notifyListeners();
  }
}
