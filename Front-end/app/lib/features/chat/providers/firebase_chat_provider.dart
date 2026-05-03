import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/account.dart';

class ConversationMeta {
  final String conversationId;
  final String otherUuid;
  final String otherName;
  final String otherAvatar;
  final String lastMessage;
  final int lastTime;
  final int unreadCount;

  ConversationMeta({
    required this.conversationId,
    required this.otherUuid,
    required this.otherName,
    required this.otherAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });
}

class FirebaseChatProvider extends ChangeNotifier {
  final _db = FirebaseDatabase.instance;

  Account? account;

  static String buildConversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void setAccount(Account? acc) {
    account = acc;
    notifyListeners();
  }

  Future<void> registerUser() async {
    if (account == null) return;

    await _db.ref('users/${account!.uuid}').set({
      'uuid': account!.uuid,
      'name': account!.name,
      'avatar': account!.avatar ?? '',
      'lastSeen': ServerValue.timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final snapshot = await _db.ref('users').get();
    if (!snapshot.exists) return [];

    final rawMap = snapshot.value as Map?;
    if (rawMap == null) return [];

    final lowerQuery = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (final entry in rawMap.entries) {
      final user = Map<String, dynamic>.from(entry.value as Map);
      final name = (user['name'] as String? ?? '').toLowerCase();
      final uuid = user['uuid'] as String? ?? '';

      if (uuid == account?.uuid) continue;

      if (name.contains(lowerQuery)) {
        results.add({
          'uuid': uuid,
          'name': user['name'] ?? 'Unknown',
          'avatar': user['avatar'] ?? '',
        });
      }
    }

    return results;
  }

  Stream<DatabaseEvent> get conversationsStream {
    if (account == null) return const Stream.empty();
    return _db
        .ref('user_conversations/${account!.uuid}')
        .onValue;
  }

  Future<List<ConversationMeta>> loadConversationMetas(
      Map rawIndex) async {
    if (account == null) return [];
    final metas = <ConversationMeta>[];

    for (final convId in rawIndex.keys) {
      try {
        final metaSnap =
        await _db.ref('conversations/$convId/metadata').get();
        if (!metaSnap.exists) continue;

        final meta = Map<String, dynamic>.from(metaSnap.value as Map);
        final participants =
        List<String>.from(meta['participants'] as List? ?? []);

        final otherUuid =
        participants.firstWhere((p) => p != account!.uuid, orElse: () => '');
        if (otherUuid.isEmpty) continue;

        // Lấy thông tin user kia
        final userSnap = await _db.ref('users/$otherUuid').get();
        String otherName = 'Unknown';
        String otherAvatar = '';
        if (userSnap.exists) {
          final userData =
          Map<String, dynamic>.from(userSnap.value as Map);
          otherName = userData['name'] as String? ?? 'Unknown';
          otherAvatar = userData['avatar'] as String? ?? '';
        }

        metas.add(ConversationMeta(
          conversationId: convId.toString(),
          otherUuid: otherUuid,
          otherName: otherName,
          otherAvatar: otherAvatar,
          lastMessage: meta['lastMessage'] as String? ?? '',
          lastTime: (meta['lastTime'] as num?)?.toInt() ?? 0,
          unreadCount:
          (meta['unread_${account!.uuid}'] as num?)?.toInt() ?? 0,
        ));
      } catch (_) {
        continue;
      }
    }

    metas.sort((a, b) => b.lastTime.compareTo(a.lastTime));
    return metas;
  }

  Future<String> getOrCreateConversation(String otherUuid) async {
    if (account == null) throw Exception('Chưa đăng nhập');
    final convId = buildConversationId(account!.uuid, otherUuid);

    final existing =
    await _db.ref('conversations/$convId/metadata').get();
    if (!existing.exists) {
      // Tạo conversation mới
      await _db.ref('conversations/$convId/metadata').set({
        'participants': [account!.uuid, otherUuid],
        'lastMessage': '',
        'lastTime': ServerValue.timestamp,
        'unread_${account!.uuid}': 0,
        'unread_$otherUuid': 0,
      });
      // Index cho cả 2 phía
      await _db
          .ref('user_conversations/${account!.uuid}/$convId')
          .set(true);
      await _db
          .ref('user_conversations/$otherUuid/$convId')
          .set(true);
    }

    return convId;
  }

  Stream<DatabaseEvent> messagesStream(String conversationId) {
    return _db
        .ref('conversations/$conversationId/messages')
        .orderByChild('createdAt')
        .onValue;
  }

  Future<String?> sendMessage(
      String conversationId, String otherUuid, String text) async {
    if (account == null) return 'Chưa đăng nhập';
    try {
      final msgRef =
      _db.ref('conversations/$conversationId/messages').push();
      await msgRef.set({
        'text': text,
        'senderUuid': account!.uuid,
        'senderName': account!.name,
        'avatar': account!.avatar ?? '',
        'createdAt': ServerValue.timestamp,
      });

      await _db.ref('conversations/$conversationId/metadata').update({
        'lastMessage': text,
        'lastTime': ServerValue.timestamp,
        'unread_$otherUuid': ServerValue.increment(1),
      });

      return null;
    } catch (e) {
      return 'Gửi thất bại: $e';
    }
  }

  Future<String?> deleteMessage(
      String conversationId, String messageKey) async {
    try {
      await _db
          .ref('conversations/$conversationId/messages/$messageKey')
          .remove();
      return null;
    } catch (e) {
      return 'Xóa thất bại: $e';
    }
  }

  Future<void> markAsRead(String conversationId) async {
    if (account == null) return;
    await _db
        .ref('conversations/$conversationId/metadata')
        .update({'unread_${account!.uuid}': 0});
  }

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

  String formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('dd/MM HH:mm').format(dt);
  }

  String formatLastTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return DateFormat('dd/MM').format(dt);
  }

  bool isMe(String? senderUuid) => senderUuid == account?.uuid;
}