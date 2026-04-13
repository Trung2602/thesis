import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../api/api.dart';
import '../models/account.dart';

class ManagerUserPage extends StatefulWidget {
  const ManagerUserPage({super.key});

  @override
  State<ManagerUserPage> createState() => _ManagerUserPageState();
}

class _ManagerUserPageState extends State<ManagerUserPage>
    with SingleTickerProviderStateMixin {
  List<Account> users = [];
  bool isLoading = true;

  late TabController _tabController;

  final List<String> roles = ["ADMIN", "CUSTOMER", "STAFF"];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: roles.length, vsync: this);

    fetchUsers(role: roles[0]);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      fetchUsers(role: roles[_tabController.index]);
    });
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers({required String role}) async {
    setState(() => isLoading = true);

    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse("${Api.getUsers}?role=$role"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      users = data.map((e) => Account.fromJson(e)).toList();
    }

    setState(() => isLoading = false);
  }

  // ================= DELETE =================
  Future<void> deleteUser(String id) async {
    final token = await AuthService().getToken();

    await http.delete(
      Uri.parse("${Api.deleteUser}/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    fetchUsers(role: roles[_tabController.index]);
  }

  // ================= FORM =================
  void openForm({Account? user}) {
    final nameCtrl = TextEditingController(text: user?.name ?? "");
    final emailCtrl = TextEditingController(text: user?.mail ?? "");
    String role = user?.role ?? "CUSTOMER";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(user == null ? "Thêm User" : "Sửa User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Tên")),
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email")),
              DropdownButton<String>(
                value: role,
                items: ["CUSTOMER", "STAFF", "ADMIN"]
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => role = val!,
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                final token = await AuthService().getToken();

                final body = jsonEncode({
                  "name": nameCtrl.text,
                  "mail": emailCtrl.text,
                  "role": role,
                });

                if (user == null) {
                  await http.post(
                    Uri.parse(Api.createUser),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: body,
                  );
                } else {
                  await http.put(
                    Uri.parse("${Api.updateUser}/${user.uuid}"),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: body,
                  );
                }

                Navigator.pop(context);
                fetchUsers(role: roles[_tabController.index]);
              },
              child: const Text("Lưu"),
            )
          ],
        );
      },
    );
  }

  // ================= CARD =================
  Widget buildUserCard(Account u) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
          u.avatar.isNotEmpty ? NetworkImage(u.avatar) : null,
          child: u.avatar.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          u.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(u.mail, style: const TextStyle(color: Colors.white70)),
            Text("Role: ${u.role}",
                style: const TextStyle(color: Colors.white54)),

            if (u.role == "STAFF")
              Text("Cơ sở: ${u.facilityName ?? ''}",
                  style: const TextStyle(color: Colors.white54)),

            if (u.role == "CUSTOMER")
              Text("Hết hạn: ${u.expiryDate?.toString().split(' ')[0] ?? ''}",
                  style: const TextStyle(color: Colors.white54)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => openForm(user: u),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteUser(u.uuid),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý User"),
        backgroundColor: const Color(0xFF1A237E),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "ADMIN"),
            Tab(text: "CUSTOMER"),
            Tab(text: "STAFF"),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0F123A),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return buildUserCard(users[index]);
        },
      ),
    );
  }
}