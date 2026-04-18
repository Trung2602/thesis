import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/ai_server_api.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoadingHistory = false;
  bool hasMoreHistory = true;
  StompClient? stompClient;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    loadChatHistory();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 100) {
        loadChatHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    stompClient?.deactivate();
    super.dispose();
  }

  void connectWebSocket() async {
    final token = await AuthService().getToken();
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: AiServerApi.wsEndpoint,
        onConnect: onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onWebSocketError: (error) {
          print('WebSocket Error: $error');
        },
        onDisconnect: (frame) {
          print("Disconnected");
        },
      ),
    );

    stompClient!.activate();
  }

  void onConnect(StompFrame frame) {
    print("Connected to WebSocket");
    stompClient!.subscribe(
      destination: AiServerApi.aiTopic,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          final now = DateTime.now().toIso8601String();
          setState(() {
            messages.add({
              "role": "user",
              "text": data["question"] ?? "",
              "createdAt": now,
            });
            messages.add({
              "role": "ai",
              "text": data["answer"] ?? "",
              "createdAt": now,
            });

            isLoading = false;
          });
        }
      },
    );
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || stompClient == null) return;
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });
    _controller.clear();
    stompClient!.send(
      destination: AiServerApi.aiSend,
      body: jsonEncode({
        "question": text,
      }),
    );
  }

  Future<void> loadChatHistory() async {
    if (isLoadingHistory || !hasMoreHistory) return;
    setState(() => isLoadingHistory = true);
    try {
      final token = await AuthService().getToken();
      final before = messages.isNotEmpty ? messages.first['createdAt'] : null;
      String url = "${AiServerApi.getChatHistory}?pageSize=10";
      if (before != null) {
        url += "&before=$before";
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isEmpty) {
          hasMoreHistory = false;
        } else {
          final newMessages = <Map<String, String>>[];

          for (var e in data) {
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
        print('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
    setState(() => isLoadingHistory = false);
  }

  String formatTime(String? isoTime) {
    if (isoTime == null) return "";
    final date = DateTime.parse(isoTime).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    final time = formatTime(msg["createdAt"]);

    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ),
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.amber
                  : const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg["text"] ?? "",
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AI Fitness Coach",
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return buildMessage(msg);
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      hintStyle:
                      TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.amber,
                  ),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}