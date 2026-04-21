import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:gym/models/account.dart';
import '../firebase_options.dart';
import 'package:gym/models/account_provider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.android),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const ChatView();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Lỗi Firebase: ${snapshot.error}')),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseReference _messagesRef =
  FirebaseDatabase.instance.ref("messages");

  Account? account;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (account == null) return;

    try {
      await _messagesRef.push().set({
        'text': _controller.text.trim(),
        'senderUuid': account!.uuid,        // ← dùng uuid thay name
        'senderName': account!.name,
        'avatar': account!.avatar ?? '',
        'createdAt': ServerValue.timestamp,
      });
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gửi thất bại: $e")));
    }
  }

  Future<void> _deleteMessage(String messageKey) async {
    try {
      await _messagesRef.child(messageKey).remove();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Xóa thất bại: $e")));
    }
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

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(date);
  }

  void _showMessageOptions(String messageKey) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Xóa tin nhắn", style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Xác nhận xóa"),
                content: const Text("Bạn có chắc muốn xóa tin nhắn này?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await _deleteMessage(messageKey);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      appBar: AppBar(
        title: const Text("Chat cùng huấn luyện viên"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _messagesRef.orderByChild('createdAt').onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messagesMap =
                snapshot.data!.snapshot.value as Map?;

                if (messagesMap == null || messagesMap.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có tin nhắn nào",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                // Giữ key để xóa sau này
                final messagesList = messagesMap.entries
                    .map((e) => {
                  'key': e.key,
                  ...Map<String, dynamic>.from(e.value as Map),
                })
                    .toList();

                messagesList.sort((a, b) {
                  final aTime = (a['createdAt'] ?? 0) as num;
                  final bTime = (b['createdAt'] ?? 0) as num;
                  return aTime.compareTo(bTime);
                });

                // Auto scroll khi có tin mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messagesList.length,
                  itemBuilder: (context, index) {
                    final data = messagesList[index];
                    // ← so sánh uuid thay vì name
                    final isMe = data['senderUuid'] == account?.uuid;
                    final messageKey = data['key'] as String;

                    return GestureDetector(
                      onLongPress: isMe
                          ? () => _showMessageOptions(messageKey)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Avatar người khác
                            if (!isMe) ...[
                              CircleAvatar(
                                backgroundImage: (data['avatar'] != null &&
                                    data['avatar'] != '')
                                    ? NetworkImage(data['avatar'])
                                    : null,
                                child: (data['avatar'] == null ||
                                    data['avatar'] == '')
                                    ? Text(
                                  (data['senderName'] ?? '?')[0]
                                      .toUpperCase(),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Bubble
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color(0x64F11175)
                                      : Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft:
                                    Radius.circular(isMe ? 12 : 0),
                                    bottomRight:
                                    Radius.circular(isMe ? 0 : 12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        data['senderName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFD740),
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(
                                      data['text'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTime(data['createdAt'] as int?),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Avatar mình
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundImage: (account?.avatar != null &&
                                    account!.avatar!.isNotEmpty)
                                    ? NetworkImage(account!.avatar!)
                                    : null,
                                child: (account?.avatar == null ||
                                    account!.avatar!.isEmpty)
                                    ? Text(
                                  (account?.name ?? 'U')[0]
                                      .toUpperCase(),
                                )
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            color: const Color(0xFF1A237E).withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFD740),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}