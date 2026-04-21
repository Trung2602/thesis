import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/user_server_api.dart';
import 'package:http/http.dart' as http;

import '../api/gym_server_api.dart';
import '../cache/manager_cache.dart';
import '../models/account_lite.dart';
import '../models/facility.dart';
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

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // ================= FETCH FACILITIES =================
  Future<List<Facility>> fetchFacilities() async {
    final cached = ManagerCache().facilityManagerCache["all"];
    if (cached != null && cached.isNotEmpty) return cached;
    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getFacilities),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final facilities = data.map((e) => Facility.fromJson(e)).toList();
      ManagerCache().facilityManagerCache["all"] = facilities;
      return facilities;
    }

    return [];
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

  // ================= FORM =================
  void openForm({String? uuid, required String role}) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedGender = "MALE";
    DateTime? selectedBirthday;

    // STAFF
    final baseSalaryCtrl = TextEditingController();
    String? selectedStaffType;
    Facility? selectedFacility;
    List<Facility> facilities = [];
    final List<String> staffTypes = ["FULLTIME", "PARTTIME", "INTERN"];

    // CUSTOMER
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    DateTime? selectedExpiryDate;

    // ADMIN
    final permissionsCtrl = TextEditingController();

    if (uuid != null) {
      try {
        final detail = await fetchDetail(uuid, role);
        nameCtrl.text = detail.name;
        emailCtrl.text = detail.mail;
        selectedGender = detail.gender;
        selectedBirthday = detail.birthday;

        if (role == "STAFF") {
          baseSalaryCtrl.text = detail.baseSalary?.toString() ?? "";
          selectedStaffType = detail.type;
          facilities = await fetchFacilities();
          selectedFacility = facilities.firstWhere(
                (f) => f.uuid == detail.facilityUuid,
            orElse: () => facilities.isNotEmpty ? facilities.first : Facility(uuid: null, name: detail.facilityName, address: null),
          );
        }

        if (role == "CUSTOMER") {
          weightCtrl.text = detail.weight?.toString() ?? "";
          heightCtrl.text = detail.height?.toString() ?? "";
          selectedExpiryDate = detail.expiryDate;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải dữ liệu: $e")),
        );
        return;
      }
    } else if (role == "STAFF") {
      facilities = await fetchFacilities();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget commonFields() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Tên *"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email *"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    selectedBirthday == null
                        ? "Ngày sinh"
                        : "Ngày sinh: ${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthday ?? DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => selectedBirthday = picked);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue : selectedGender,
                  decoration: const InputDecoration(labelText: "Giới tính"),
                  items: ["MALE", "FEMALE"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) => setDialogState(() => selectedGender = v!),
                ),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: "Mật khẩu *"),
                  obscureText: true,
                ),
              ],
            );

            Widget roleFields() {
              if (role == "STAFF") {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue : selectedStaffType,
                      decoration: const InputDecoration(labelText: "Loại nhân viên"),
                      items: staffTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedStaffType = v),
                    ),
                    TextField(
                      controller: baseSalaryCtrl,
                      decoration: const InputDecoration(
                        labelText: "Lương cơ bản",
                        suffixText: "VNĐ",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    facilities.isEmpty ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Không có cơ sở nào",
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ) : DropdownButtonFormField<Facility>(
                      initialValue : selectedFacility,
                      decoration: const InputDecoration(labelText: "Cơ sở"),
                      items: facilities.map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.name ?? ""),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedFacility = v),
                    ),
                  ],
                );
              }

              if (role == "CUSTOMER") {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: weightCtrl,
                      decoration: const InputDecoration(
                        labelText: "Cân nặng",
                        suffixText: "kg",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: heightCtrl,
                      decoration: const InputDecoration(
                        labelText: "Chiều cao",
                        suffixText: "cm",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedExpiryDate == null
                            ? "Ngày hết hạn thẻ"
                            : "Hết hạn: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.event, size: 20),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedExpiryDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setDialogState(() => selectedExpiryDate = picked);
                      },
                    ),
                  ],
                );
              }
              // if (role == "ADMIN"){
              //   return Column(
              //     TextField( controller: permissionsCtrl,
              //       decoration: const InputDecoration(
              //         labelText: "Quyền hạn",
              //       ),
              //     )
              //   );
              // }
              return const SizedBox.shrink();
            }

            return AlertDialog(
              title: Text("${uuid == null ? "Thêm" : "Sửa"} $role"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    commonFields(),
                    if (role != "ADMIN") ...[
                      const Divider(height: 24),
                      roleFields(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tên và email không được để trống")),
                      );
                      return;
                    }
                    final token = await AuthService().getToken();
                    try {
                      final url = uuid == null ? getCreateApi(role) : getUpdateApi(role);
                      final uri = Uri.parse(url);
                      final headers = {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer $token",
                      };
                      final Map<String, dynamic> bodyMap = {
                        if (uuid != null) "uuid": uuid,
                        "name": nameCtrl.text.trim(),
                        "mail": emailCtrl.text.trim(),
                        "gender": selectedGender,
                        if (selectedBirthday != null) "birthday": formatDate(selectedBirthday!),
                        if (uuid == null && passwordCtrl.text.trim().isNotEmpty)
                          "password": passwordCtrl.text.trim(),
                      };
                      if (role == "STAFF") {
                        if (selectedStaffType != null) {
                          bodyMap["type"] = selectedStaffType;
                        }
                        if (baseSalaryCtrl.text.isNotEmpty) {
                          bodyMap["baseSalary"] = double.tryParse(baseSalaryCtrl.text);
                        }
                        if (selectedFacility != null) {
                          bodyMap["facilityUuid"] = selectedFacility!.uuid;
                        }
                      }
                      if (role == "CUSTOMER") {
                        if (weightCtrl.text.isNotEmpty) {
                          bodyMap["weight"] = double.tryParse(weightCtrl.text);
                        }
                        if (heightCtrl.text.isNotEmpty) {
                          bodyMap["height"] = double.tryParse(heightCtrl.text);
                        }
                        if (selectedExpiryDate != null) {
                          bodyMap["expiryDate"] = formatDate(selectedExpiryDate!);
                        }
                      }
                      final http.Response response;
                      if (uuid == null) {
                        response = await http.post(uri, headers: headers, body: jsonEncode(bodyMap));
                      } else {
                        response = await http.patch(uri, headers: headers, body: jsonEncode(bodyMap));
                      }
                      debugPrint("========== HTTP DEBUG ==========");
                      debugPrint("URL: $url");
                      debugPrint("METHOD: ${uuid == null ? "POST" : "PATCH"}");
                      debugPrint("REQUEST BODY: ${jsonEncode(bodyMap)}");
                      debugPrint("STATUS CODE: ${response.statusCode}");
                      debugPrint("RESPONSE BODY: ${response.body}");
                      debugPrint("================================");
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      fetchUsers(role: roles[_tabController.index]);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi: $e")),
                      );
                    }
                  },
                  child: const Text("Lưu"),
                ),
              ],
            );
          },
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