import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_widgets.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUuid;
  final String otherName;
  final String otherAvatar;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUuid,
    required this.otherName,
    required this.otherAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();

  late FirebaseChatProvider _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<FirebaseChatProvider>(context, listen: false);
    _provider.markAsRead(widget.conversationId);
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
    final error = await _provider.sendMessage(
        widget.conversationId, widget.otherUuid, text);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      _scrollToBottom();
    }
  }

  Future<void> _handleDelete(String messageKey) async {
    final error =
    await _provider.deleteMessage(widget.conversationId, messageKey);
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
                content: const Text('Bạn có chắc muốn xóa tin nhắn này?'),
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
    return Consumer<FirebaseChatProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: const Color(0xFF0F123A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: const Color(0xFFFFD740),
          leadingWidth: 40,
          title: Row(
            children: [
              // Avatar người nhận
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.otherAvatar.isNotEmpty
                    ? NetworkImage(widget.otherAvatar)
                    : null,
                backgroundColor: const Color(0xFF3949AB),
                child: widget.otherAvatar.isEmpty
                    ? Text(
                  widget.otherName.isNotEmpty
                      ? widget.otherName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14),
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                widget.otherName,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: provider.messagesStream(widget.conversationId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final rawMap =
                  snapshot.data!.snapshot.value as Map?;
                  if (rawMap == null || rawMap.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage:
                            widget.otherAvatar.isNotEmpty
                                ? NetworkImage(widget.otherAvatar)
                                : null,
                            backgroundColor:
                            const Color(0xFF3949AB),
                            child: widget.otherAvatar.isEmpty
                                ? Text(
                              widget.otherName.isNotEmpty
                                  ? widget.otherName[0]
                                  .toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24),
                            )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.otherName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hãy gửi tin nhắn đầu tiên!',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }

                  final messagesList = provider.parseMessages(rawMap);
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                    const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messagesList.length,
                    itemBuilder: (context, index) {
                      final data = messagesList[index];
                      final isMe = provider
                          .isMe(data['senderUuid'] as String?);
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
    );
  }
}