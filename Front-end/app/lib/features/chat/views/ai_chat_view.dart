import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_widgets.dart';

class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final _scrollController = ScrollController();
  late final AiChatProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AiChatProvider();
    _provider.connectWebSocket();
    _provider.loadChatHistory();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <= 100) {
        _provider.loadChatHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _provider.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<AiChatProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'AI Fitness Coach',
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
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[
                    provider.messages.length - 1 - index];
                    return AiChatBubble(
                      message: msg,
                      formattedTime: provider.formatTime(msg['createdAt']),
                    );
                  },
                ),
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ChatInputBar(
                onSend: provider.sendMessage,
                backgroundColor: const Color(0xFF1A237E),
                sendIconColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}