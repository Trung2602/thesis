import 'package:flutter/material.dart';

import '../../../../models/facility.dart';
import '../providers/user_provider.dart';
import '../widgets/user_card.dart';

class ManagerUserView extends StatefulWidget {
  const ManagerUserView({super.key});

  @override
  State<ManagerUserView> createState() => _ManagerUserViewState();
}

class _ManagerUserViewState extends State<ManagerUserView>
    with SingleTickerProviderStateMixin {
  final _provider = UserProvider();
  late TabController _tabController;
  final List<String> roles = ['ADMIN', 'CUSTOMER', 'STAFF'];

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      if (mounted) setState(() {});
    });
    _tabController = TabController(length: roles.length, vsync: this);
    _provider.fetchUsers(role: roles[0]);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _provider.fetchUsers(role: roles[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _openForm({String? uuid, required String role}) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedGender = 'MALE';
    DateTime? selectedBirthday;

    // STAFF
    final baseSalaryCtrl = TextEditingController();
    String? selectedStaffType;
    Facility? selectedFacility;
    List<Facility> facilities = [];
    final List<String> staffTypes = ['FULLTIME', 'PARTTIME', 'INTERN'];

    // CUSTOMER
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    DateTime? selectedExpiryDate;

    if (uuid != null) {
      try {
        final detail = await _provider.fetchDetail(uuid, role);
        nameCtrl.text = detail.name;
        emailCtrl.text = detail.mail;
        selectedGender = detail.gender;
        selectedBirthday = detail.birthday;

        if (role == 'STAFF') {
          baseSalaryCtrl.text = detail.baseSalary?.toString() ?? '';
          selectedStaffType = detail.type;
          facilities = await _provider.fetchFacilities();
          selectedFacility = facilities.firstWhere(
                (f) => f.uuid == detail.facilityUuid,
            orElse: () => facilities.isNotEmpty
                ? facilities.first
                : Facility(
                uuid: null, name: detail.facilityName, address: null),
          );
        }

        if (role == 'CUSTOMER') {
          weightCtrl.text = detail.weight?.toString() ?? '';
          heightCtrl.text = detail.height?.toString() ?? '';
          selectedExpiryDate = detail.expiryDate;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải dữ liệu: $e')),
        );
        return;
      }
    } else if (role == 'STAFF') {
      facilities = await _provider.fetchFacilities();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Widget commonFields() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                const InputDecoration(labelText: 'Tên *'),
              ),
              TextField(
                controller: emailCtrl,
                decoration:
                const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedBirthday == null
                      ? 'Ngày sinh'
                      : 'Ngày sinh: ${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing:
                const Icon(Icons.calendar_today, size: 20),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedBirthday ?? DateTime(2000),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedBirthday = picked);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration:
                const InputDecoration(labelText: 'Giới tính'),
                items: ['MALE', 'FEMALE']
                    .map((g) => DropdownMenuItem(
                    value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedGender = v!),
              ),
              TextField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: uuid == null ? 'Mật khẩu *' : 'Mật khẩu mới (để trống nếu không đổi)',
                ),
                obscureText: true,
              ),
            ],
          );

          Widget roleFields() {
            if (role == 'STAFF') {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedStaffType,
                    decoration: const InputDecoration(
                        labelText: 'Loại nhân viên'),
                    items: staffTypes
                        .map((t) => DropdownMenuItem(
                        value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedStaffType = v),
                  ),
                  TextField(
                    controller: baseSalaryCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Lương cơ bản',
                        suffixText: 'VNĐ'),
                    keyboardType: TextInputType.number,
                  ),
                  facilities.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Không có cơ sở nào',
                        style: TextStyle(
                            color: Colors.red, fontSize: 13)),
                  )
                      : DropdownButtonFormField<Facility>(
                    initialValue: selectedFacility,
                    decoration: const InputDecoration(
                        labelText: 'Cơ sở'),
                    items: facilities
                        .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.name ?? '')))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedFacility = v),
                  ),
                ],
              );
            }

            if (role == 'CUSTOMER') {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Cân nặng', suffixText: 'kg'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: heightCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Chiều cao', suffixText: 'cm'),
                    keyboardType: TextInputType.number,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      selectedExpiryDate == null
                          ? 'Ngày hết hạn thẻ'
                          : 'Hết hạn: ${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.event, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                        selectedExpiryDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(
                                () => selectedExpiryDate = picked);
                      }
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: Text('${uuid == null ? 'Thêm' : 'Sửa'} $role'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  commonFields(),
                  if (role != 'ADMIN') ...[
                    const Divider(height: 24),
                    roleFields(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty ||
                      emailCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Tên và email không được để trống')),
                    );
                    return;
                  }
                  try {
                    final Map<String, dynamic> bodyMap = {
                      'name': nameCtrl.text.trim(),
                      'mail': emailCtrl.text.trim(),
                      'gender': selectedGender,
                      if (selectedBirthday != null)
                        'birthday':
                        _provider.formatDate(selectedBirthday!),
                      if (passwordCtrl.text.trim().isNotEmpty)
                        'password': passwordCtrl.text.trim(),
                    };
                    if (role == 'STAFF') {
                      if (selectedStaffType != null) {
                        bodyMap['type'] = selectedStaffType;
                      }
                      if (baseSalaryCtrl.text.isNotEmpty) {
                        bodyMap['baseSalary'] = double.tryParse(baseSalaryCtrl.text);
                      }
                      if (selectedFacility != null) {
                        bodyMap['facilityUuid'] = selectedFacility!.uuid;
                      }
                    }
                    if (role == 'CUSTOMER') {
                      if (weightCtrl.text.isNotEmpty) {
                        bodyMap['weight'] = double.tryParse(weightCtrl.text);
                      }
                      if (heightCtrl.text.isNotEmpty) {
                        bodyMap['height'] = double.tryParse(heightCtrl.text);
                      }
                      if (selectedExpiryDate != null) {
                        bodyMap['expiryDate'] = _provider.formatDate(selectedExpiryDate!);
                      }
                    }
                    await _provider.saveUser(
                        uuid: uuid, role: role, bodyMap: bodyMap);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _provider.fetchUsers(
                        role: roles[_tabController.index]);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý User'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD740),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFFFD740),
          tabs: const [
            Tab(text: 'ADMIN'),
            Tab(text: 'CUSTOMER'),
            Tab(text: 'STAFF'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: _provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () =>
                  _openForm(role: roles[_tabController.index]),
              child: Text(
                  'Thêm ${roles[_tabController.index]}'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _provider.users.length,
              itemBuilder: (context, index) {
                final u = _provider.users[index];
                return UserCard(
                  user: u,
                  index: index,
                  onView: () async {
                    final detail =
                    await _provider.fetchDetail(u.uuid, u.role);
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Chi tiết'),
                        content:
                        Text(detail.toJson().toString()),
                      ),
                    );
                  },
                  onEdit: () =>
                      _openForm(uuid: u.uuid, role: u.role),
                  onDelete: () async {
                    await _provider.deleteUser(u.uuid);
                    _provider.fetchUsers(
                        role: roles[_tabController.index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}