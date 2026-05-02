import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/account.dart';

class FirebaseChatProvider extends ChangeNotifier {
  final _messagesRef = FirebaseDatabase.instance.ref('messages');

  Account? account;

  void setAccount(Account? acc) {
    account = acc;
    notifyListeners();
  }

  Stream<DatabaseEvent> get messagesStream =>
      _messagesRef.orderByChild('createdAt').onValue;

  List<Map<String, dynamic>> parseMessages(Map rawMap) {
    final list = rawMap.entries
        .map((e) => {
      'key': e.key,
      ...Map<String, dynamic>.from(e.value as Map),
    })
        .toList();

    list.sort((a, b) {
      final aTime = (a['createdAt'] ?? 0) as num;
      final bTime = (b['createdAt'] ?? 0) as num;
      return aTime.compareTo(bTime);
    });

    return list;
  }

  Future<String?> sendMessage(String text) async {
    if (account == null) return 'Chưa đăng nhập';
    try {
      await _messagesRef.push().set({
        'text': text,
        'senderUuid': account!.uuid,
        'senderName': account!.name,
        'avatar': account!.avatar ?? '',
        'createdAt': ServerValue.timestamp,
      });
      return null; // success
    } catch (e) {
      return 'Gửi thất bại: $e';
    }
  }

  Future<String?> deleteMessage(String messageKey) async {
    try {
      await _messagesRef.child(messageKey).remove();
      return null; // success
    } catch (e) {
      return 'Xóa thất bại: $e';
    }
  }

  String formatTime(int? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  bool isMe(String? senderUuid) => senderUuid == account?.uuid;
}