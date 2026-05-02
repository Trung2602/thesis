import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:gym/firebase_options.dart';
import 'package:gym/models/account_provider.dart';
import '../providers/firebase_chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_widgets.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.android),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const FirebaseChatView();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text('Lỗi Firebase: ${snapshot.error}')),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class FirebaseChatView extends StatefulWidget {
  const FirebaseChatView({super.key});

  @override
  State<FirebaseChatView> createState() => _FirebaseChatViewState();
}

class _FirebaseChatViewState extends State<FirebaseChatView> {
  final _scrollController = ScrollController();
  late final FirebaseChatProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = FirebaseChatProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    _provider.setAccount(account);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    final error = await _provider.sendMessage(text);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      _scrollToBottom();
    }
  }

  Future<void> _handleDelete(String messageKey) async {
    final error = await _provider.deleteMessage(messageKey);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _showMessageOptions(String messageKey) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Xóa tin nhắn',
              style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Xác nhận xóa'),
                content:
                const Text('Bạn có chắc muốn xóa tin nhắn này?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true) await _handleDelete(messageKey);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<FirebaseChatProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: const Color(0xFF0F123A),
          appBar: AppBar(
            title: const Text('Chat cùng huấn luyện viên'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: const Color(0xFFFFD740),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: provider.messagesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final rawMap =
                    snapshot.data!.snapshot.value as Map?;
                    if (rawMap == null || rawMap.isEmpty) {
                      return const Center(
                        child: Text('Chưa có tin nhắn nào',
                            style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final messagesList = provider.parseMessages(rawMap);
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        final data = messagesList[index];
                        final isMe =
                        provider.isMe(data['senderUuid'] as String?);
                        final messageKey = data['key'] as String;

                        return GestureDetector(
                          onLongPress: isMe
                              ? () => _showMessageOptions(messageKey)
                              : null,
                          child: FirebaseChatBubble(
                            data: data,
                            isMe: isMe,
                            myAvatar: provider.account?.avatar,
                            myName: provider.account?.name,
                            formattedTime: provider.formatTime(
                                data['createdAt'] as int?),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ChatInputBar(
                onSend: _handleSend,
                backgroundColor:
                const Color(0xFF1A237E).withValues(alpha: 0.5),
                sendIconColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}