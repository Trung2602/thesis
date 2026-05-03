import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../api/user_server_api.dart';
import '../providers/firebase_chat_provider.dart';
import 'firebase_chat_view.dart';

class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ConversationListView();
  }
}

class _ConversationListView extends StatefulWidget {
  const _ConversationListView();

  @override
  State<_ConversationListView> createState() =>
      _ConversationListViewState();
}

class _ConversationListViewState extends State<_ConversationListView> {
  late final FirebaseChatProvider _provider;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;

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
    _provider.registerUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
      return;
    }
    setState(() => _searchLoading = true);
    final results = await _provider.searchUsers(query);
    setState(() {
      _searchResults = results;
      _searchLoading = false;
    });
  }

  Future<void> _openChatWith(String otherUuid, String otherName, String otherAvatar) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập Firebase hết hạn, vui lòng đăng nhập lại')),
      );
      return;
    }
    try {
      final convId = await _provider.getOrCreateConversation(otherUuid);
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _searchResults = [];
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChangeNotifierProvider.value(
                value: _provider,
                child: ChatPage(
                  conversationId: convId,
                  otherUuid: otherUuid,
                  otherName: otherName,
                  otherAvatar: otherAvatar,
                ),
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F123A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: const Color(0xFFFFD740),
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            onChanged: _onSearch,
          )
              : const Text('Tin nhắn'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _searchResults = [];
                  }
                });
              },
            ),
          ],
        ),
        body: _isSearching ? _buildSearchBody() : _buildConversationList(),
      ),
    );
  }

  // ─── Search body ────────────────────────────────────────────────────────────

  Widget _buildSearchBody() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Nhập tên để tìm kiếm',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    if (_searchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy người dùng',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchTile(
          name: user['name'] as String,
          avatar: user['avatar'] as String,
          onTap: () => _openChatWith(
            user['uuid'] as String,
            user['name'] as String,
            user['avatar'] as String,
          ),
        );
      },
    );
  }

  // ─── Conversation list ──────────────────────────────────────────────────────

  Widget _buildConversationList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _provider.conversationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawMap = snapshot.data?.snapshot.value as Map?;
        if (rawMap == null || rawMap.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có cuộc trò chuyện nào',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn 🔍 để tìm và nhắn tin với ai đó',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<List<ConversationMeta>>(
          future: _provider.loadConversationMetas(rawMap),
          builder: (context, metaSnap) {
            if (!metaSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final metas = metaSnap.data!;
            return ListView.separated(
              itemCount: metas.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final meta = metas[index];
                return _ConversationTile(
                  meta: meta,
                  formatTime: _provider.formatLastTime(meta.lastTime),
                  onTap: () => _openChatWith(
                    meta.otherUuid,
                    meta.otherName,
                    meta.otherAvatar,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationMeta meta;
  final String formatTime;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.meta,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _Avatar(url: meta.otherAvatar, name: meta.otherName),
      title: Text(
        meta.otherName,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        meta.lastMessage.isEmpty ? 'Bắt đầu trò chuyện' : meta.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: meta.unreadCount > 0
              ? Colors.white70
              : Colors.white38,
          fontWeight: meta.unreadCount > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatTime,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          if (meta.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD740),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                meta.unreadCount > 99
                    ? '99+'
                    : '${meta.unreadCount}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  final String name;
  final String avatar;
  final VoidCallback onTap;

  const _UserSearchTile({
    required this.name,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _Avatar(url: avatar, name: name),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.chat_bubble_outline,
          color: Colors.white38, size: 20),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String name;

  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = url.isNotEmpty;
    return CircleAvatar(
      radius: 24,
      backgroundImage: hasAvatar ? NetworkImage(url) : null,
      backgroundColor: const Color(0xFF3949AB),
      child: !hasAvatar
          ? Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      )
          : null,
    );
  }
}