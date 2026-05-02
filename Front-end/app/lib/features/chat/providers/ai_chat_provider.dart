import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:gym/api/ai_server_api.dart';
import 'package:gym/services/auth_service.dart';

class AiChatProvider extends ChangeNotifier {
  final List<Map<String, String>> messages = [];
  StompClient? _stompClient;

  bool isLoading = false;
  bool isLoadingHistory = false;
  bool hasMoreHistory = true;
  Future<void> connectWebSocket() async {
    final token = await AuthService().getToken();
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: AiServerApi.wsEndpoint,
        onConnect: _onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onWebSocketError: (e) => debugPrint('WebSocket error: $e'),
        onDisconnect: (_) => debugPrint('WebSocket disconnected'),
      ),
    );
    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _stompClient!.subscribe(
      destination: AiServerApi.aiTopic,
      callback: (frame) {
        if (frame.body == null) return;
        final data = jsonDecode(frame.body!);
        final now = DateTime.now().toIso8601String();
        messages.add({
          'role': 'user',
          'text': data['question'] ?? '',
          'createdAt': now,
        });
        messages.add({
          'role': 'ai',
          'text': data['answer'] ?? '',
          'createdAt': now,
        });
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void deactivate() {
    _stompClient?.deactivate();
  }

  void sendMessage(String text) {
    if (text.isEmpty || _stompClient == null) return;
    messages.add({'role': 'user', 'text': text});
    isLoading = true;
    notifyListeners();

    _stompClient!.send(
      destination: AiServerApi.aiSend,
      body: jsonEncode({'question': text}),
    );
  }

  Future<void> loadChatHistory() async {
    if (isLoadingHistory || !hasMoreHistory) return;
    isLoadingHistory = true;
    notifyListeners();

    try {
      final token = await AuthService().getToken();
      final before =
      messages.isNotEmpty ? messages.first['createdAt'] : null;
      var url = '${AiServerApi.getChatHistory}?pageSize=10';
      if (before != null) url += '&before=$before';

      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (data.isEmpty) {
          hasMoreHistory = false;
        } else {
          final newMessages = <Map<String, String>>[];
          for (final e in data) {
            newMessages.add({
              'role': 'ai',
              'text': e['answer'] ?? '',
              'createdAt': e['createdAt'],
            });
            newMessages.add({
              'role': 'user',
              'text': e['question'] ?? '',
              'createdAt': e['createdAt'],
            });
          }
          messages.insertAll(0, newMessages.reversed.toList());
        }
      } else {
        debugPrint('Failed to load history: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }

    isLoadingHistory = false;
    notifyListeners();
  }

  String formatTime(String? isoTime) {
    if (isoTime == null) return '';
    final date = DateTime.parse(isoTime).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}