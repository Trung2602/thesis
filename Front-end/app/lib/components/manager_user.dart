import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:http/http.dart' as http;

import '../models/account_lite.dart';
import '../services/auth_service.dart';
import '../models/account.dart';

class ManagerUserPage extends StatefulWidget {
  const ManagerUserPage({super.key});

  @override
  State<ManagerUserPage> createState() => _ManagerUserPageState();
}

class _ManagerUserPageState extends State<ManagerUserPage>
    with SingleTickerProviderStateMixin {
  List<AccountLite> users = [];
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
      Uri.parse("${UserServerApi.loadAccount}?role=$role"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("STATUS: ${res.statusCode}");
    debugPrint("BODY: ${res.body}");
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      setState(() {
        users = data.map((e) => AccountLite.fromJson(e)).toList();
      });
    }

    setState(() => isLoading = false);
  }

  // ================= DELETE =================
  Future<void> deleteUser(String uuid) async {
    final token = await AuthService().getToken();

    await http.delete(
      Uri.parse(UserServerApi.deleteAccount(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    fetchUsers(role: roles[_tabController.index]);
  }

  // ================= FORM =================
  String getDetailApi(String role, String uuid) {
    switch (role) {
      case "ADMIN":
        return UserServerApi.getAdminByUuid(uuid);
      case "STAFF":
        return UserServerApi.getStaffByUuid(uuid);
      case "CUSTOMER":
        return UserServerApi.getCustomerByUuid(uuid);
      default:
        throw Exception("Invalid role");
    }
  }

  String getCreateApi(String role) {
    switch (role) {
      case "ADMIN":
        return UserServerApi.postAdmin;
      case "STAFF":
        return UserServerApi.postStaff;
      case "CUSTOMER":
        return UserServerApi.postCustomer;
      default:
        throw Exception("Invalid role");
    }
  }

  String getUpdateApi(String role) {
    switch (role) {
      case "ADMIN":
        return UserServerApi.patchAdmin;
      case "STAFF":
        return UserServerApi.patchStaff;
      case "CUSTOMER":
        return UserServerApi.patchCustomer;
      default:
        throw Exception("Invalid role");
    }
  }

  Future<Account> fetchDetail(String uuid, String role) async {
    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(getDetailApi(role, uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return Account.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Load detail failed");
    }
  }

  void openForm({String? uuid, required String role}) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(uuid == null ? "Thêm User" : "Sửa User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tên"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
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
                });

                if (uuid == null) {
                  await http.post(
                    Uri.parse(getCreateApi(role)),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: body,
                  );
                } else {
                  await http.patch(
                    Uri.parse(getUpdateApi(role)),
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
  Widget buildUserCard(AccountLite u, int index) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text("${index + 1}"),
        ),
        title: Text(
          u.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          u.mail,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () async {
                final detail = await fetchDetail(u.uuid, u.role);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Chi tiết"),
                    content: Text(detail.toJson().toString()),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                openForm(uuid: u.uuid, role: u.role);
              },
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
        foregroundColor: const Color(0xFFFFD740),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD740),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFFFD740),
          tabs: const [
            Tab(text: "ADMIN"),
            Tab(text: "CUSTOMER"),
            Tab(text: "STAFF"),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                final role = roles[_tabController.index];
                openForm(role: role);
              },
              child: Text("Thêm ${roles[_tabController.index]}"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return buildUserCard(users[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}