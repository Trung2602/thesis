import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double radius;

  const ChatAvatar({
    super.key,
    this.avatarUrl,
    this.name,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: !hasAvatar
          ? Text((name ?? '?')[0].toUpperCase())
          : null,
    );
  }
}

class FirebaseChatBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final String? myAvatar;
  final String? myName;
  final String formattedTime;

  const FirebaseChatBubble({
    super.key,
    required this.data,
    required this.isMe,
    required this.formattedTime,
    this.myAvatar,
    this.myName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            ChatAvatar(
              avatarUrl: data['avatar'] as String?,
              name: data['senderName'] as String?,
            ),
            const SizedBox(width: 8),
          ],
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
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            ChatAvatar(avatarUrl: myAvatar, name: myName),
          ],
        ],
      ),
    );
  }
}

class AiChatBubble extends StatelessWidget {
  final Map<String, String> message;
  final String formattedTime;

  const AiChatBubble({
    super.key,
    required this.message,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message['role'] == 'user';

    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            formattedTime,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        Align(
          alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isUser ? Colors.amber : const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message['text'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}