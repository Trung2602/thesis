import 'package:flutter/material.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:gym/components/report.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../cache/app_cache.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// Import models
import '../models/account.dart';
import '../models/plan.dart';
import 'package:gym/models/account_provider.dart';
import 'package:gym/models/shift.dart';
// Import các màn hình con
import 'ai_chat.dart';
import 'manager_facility.dart';
import 'manager_pay_customer.dart';
import 'manager_plan.dart';
import 'manager_salary.dart';
import 'manager_shift.dart';
import 'manager_staff_off.dart';
import 'manager_staff_schedule.dart';
import 'manager_user.dart';
import 'profile.dart';
import 'day_off.dart';
import 'pay_customer.dart';
import 'salary.dart';
import 'staff_schedule.dart';
import 'customer_schedule.dart';
import 'chat_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  final AuthService authService = AuthService();
  Account? savedAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;

    if (account != savedAccount) {
      savedAccount = account;
      _buildPages();
    }
  }

  void _buildPages() {
    if (savedAccount == null) {
      _pages = [
        const _DashboardScreen()];
    } else if (savedAccount!.role == 'CUSTOMER') {
      _pages = [
        const _DashboardScreen(),
        const CustomerScheduleScreen(),
        const PayCustomerScreen(),
        const Profile(),
      ];
    } else if (savedAccount!.role == 'STAFF') {
      _pages = [
        const _DashboardScreen(),
        const CustomerScheduleScreen(),
        if (savedAccount!.type == 'FULLTIME')
          const DayOff()
        else
          const StaffScheduleScreen(),
        const SalaryScreen(),
        const Profile(),
      ];
    } else if (savedAccount!.role == 'ADMIN') {
      _pages = [
        const _DashboardScreen(),
        const ReportDashboardPage(),
        const Profile(),
      ];
    }
    setState(() {});
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    if (savedAccount == null) return [];

    if (savedAccount!.role == 'CUSTOMER') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Lịch Trình",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: "Thanh Toán",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_pin),
          label: "Hồ Sơ",
        ),
      ];
    } else if (savedAccount!.role == 'STAFF') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Lịch Trình",
        ),
        if (savedAccount!.type == "FULLTIME")
          const BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: "Xin Nghỉ",
          )
        else
          const BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Ca Làm",
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: "Bảng Lương",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_pin),
          label: "Hồ Sơ",
        ),
      ];
    } else if (savedAccount!.role == 'ADMIN') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Thống kê",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_pin),
          label: "Hồ Sơ",
        ),
      ];
    } else {
      return const [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildDrawerItems() {
    if (savedAccount == null) return [];

    List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard, 'title': 'Bảng Điều Khiển Thiên Hà', 'index': 0},
    ];

    if (savedAccount!.role == 'CUSTOMER') {
      menuItems.addAll([
        {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'index': 1},
        {'icon': Icons.payment, 'title': 'Thanh Toán', 'index': 2},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'index': 3},
      ]);
    } else if (savedAccount!.role == 'STAFF') {
      menuItems.addAll([
        {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'index': 1},
        savedAccount!.type == "FULLTIME"
          ? {'icon': Icons.beach_access, 'title': 'Xin Nghỉ', 'index': 2}
          : {'icon': Icons.access_time,  'title': 'Ca Làm',   'index': 2},
        {'icon': Icons.attach_money, 'title': 'Bảng Lương', 'index': 3},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'index': 4},
      ]);
    } else if (savedAccount!.role == 'ADMIN') {
      menuItems.addAll([
        {'icon': Icons.people, 'title': 'Quản lý người dùng', 'index': -2},
        {'icon': Icons.fitness_center, 'title': 'Cơ sở', 'index': -3},
        {'icon': Icons.payment, 'title': 'Thanh toán khách', 'index': -4},
        {'icon': Icons.card_membership, 'title': 'Gói tập', 'index': -5},
        {'icon': Icons.attach_money, 'title': 'Bảng lương', 'index': -6},
        {'icon': Icons.schedule, 'title': 'Ca làm', 'index': -7},
        {'icon': Icons.beach_access, 'title': 'Xin nghỉ', 'index': -8},
        {'icon': Icons.calendar_month, 'title': 'Lịch nhân viên', 'index': -9},
      ]);
    }
    menuItems.addAll([
      {'icon': Icons.message, 'title': 'Liên Lạc', 'index': -1},
      {'icon': Icons.logout, 'title': 'Rời khỏi Trạm Vũ Trụ', 'index': -1},
    ]);

    return menuItems.map((item) {
      return _buildDrawerItem(item['icon'], item['title'], item['index']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (savedAccount == null || _pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),

      appBar: AppBar(
        title: const Text(
          "GALACTIC FITNESS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Tin nhắn từ Trung Tâm Điều Khiển',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Tìm kiếm trong Vũ Trụ',
          ),
        ],
      ),

      drawer:savedAccount == null
          ? null
          : Drawer(
        backgroundColor: const Color(0xFF1A237E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2C318F)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (savedAccount?.avatar ?? '').isNotEmpty
                        ? NetworkImage(savedAccount!.avatar)
                        : null,
                    child: (savedAccount?.avatar ?? '').isEmpty
                        ? const Icon(Icons.person, size: 30, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    savedAccount?.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    savedAccount?.role ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ..._buildDrawerItems(),
          ],
        ),
      ),

      floatingActionButton: (savedAccount?.role == 'CUSTOMER')
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatPage()),
          );
        },
        backgroundColor: const Color(0xFFFFD740),
        tooltip: 'AI Hỗ Trợ',
        child: const Icon(Icons.smart_toy, color: Colors.black),
      ) : null,

      body: _pages[_selectedIndex],

      bottomNavigationBar: _pages.length >= 2
          ? BottomNavigationBar(
        items: _buildBottomNavItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFD740),
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF1A237E),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ): null,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);

        if (index >= 0) {
          _onItemTapped(index);
        } else {
          switch (index) {
            case -2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerUserPage()));
              break;
            case -3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerFacilityPage()));
              break;
            case -4:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerPayCustomerPage()));
              break;
            case -5:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerPlanPage()));
              break;
            case -6:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerSalaryPage()));
              break;
            case -7:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerShiftPage()));
              break;
            case -8:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerDayOffPage()));
              break;
            case -9:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ManagerStaffSchedulePage()));
              break;
            case -1:
              if (title == 'Rời khỏi Trạm Vũ Trụ') {
                authService.logout(context);
              } else if (title == 'Liên Lạc') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                );
              }
              break;
          }
        }
      },
    );
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen({super.key});
  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  Future<List<Plan>>? _plansFuture;
  Future<List<Shift>>? _shiftsFuture;

  bool isFirstLoad = true;
  final planCache = AppCache().planCache;
  final shiftCache = AppCache().shiftCache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;

    if (account != null && isFirstLoad) {
      isFirstLoad = false;

      if (account.role == "CUSTOMER") {
        _plansFuture = _getPlans();
      } else {
        _shiftsFuture = _getShifts();
      }
    }
  }

  Future<List<Plan>> _getPlans() async {
    const key = "plans";
    if (planCache.containsKey(key)) {
      return planCache[key]!;
    }
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(GymServerApi.getPlans),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final result = data.map((e) => Plan.fromJson(e)).toList();
      planCache[key] = result;
      return result;
    } else {
      throw Exception("Failed to load plans");
    }
  }

  Future<List<Shift>> _getShifts() async {
    const key = "shifts";
    if (shiftCache.containsKey(key)) {
      return shiftCache[key]!;
    }
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(GymServerApi.getShifts),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final result = data.map((e) => Shift.fromJson(e)).toList();
      shiftCache[key] = result;
      return result;
    } else {
      throw Exception("Failed to load shifts");
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chào mừng ${account != null ? " ${account.name}" : ""} đến với",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(2, 2))
                      ]
                  ),
                ),
                Text(
                  "GALACTIC FITNESS!",
                  style: TextStyle(
                      color: Color(0xFFFFAB40),
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(3, 3))
                      ]
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text("Hôm nay: ${_getFormattedDate()}",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.access_time, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(" ${TimeOfDay.now().format(context)}",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                const Text(
                  "Về Galactic Fitness Center",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(1, 1))
                      ]
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Trung tâm thể dục thể thao thể thao hàng đầu vũ trụ, trang bị bởi công nghệ tiên tiến nhất, và đội ngũ huấn luyện viên là những phi hành gia giàu kinh nghiệm.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildInfoCard(
                      'Cơ Sở Vật Chất Hiện đại',
                      'Hệ thống tập luyện được thiết kế với công nghệ hiện đại nhất vũ trụ.',
                      Icons.space_dashboard,
                    ),
                    _buildInfoCard(
                      'Đội Ngũ Huấn Luyện Viên Chuyên Nghiệp',
                      'Đội ngũ phi hành gia hướng dẫn chuyên nghiệp, sẵn sàng đưa bạn vươn tới giới hạn.',
                      Icons.group,
                    ),
                    _buildInfoCard(
                      'Trải Nghiệm Tập Luyện Hiệu Quả',
                      'Dịch vụ mang đến sự thoải mái và hiệu quả tối đa cho từng buổi tập.',
                      Icons.star,
                    ),
                    _buildInfoCard(
                      'Năng Lượng Bền Bỉ',
                      'Mỗi bài tập đều được thiết kế để tối ưu hóa năng lượng và sức bền của bạn.',
                      Icons.wb_sunny,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Text(
                  account?.role == "CUSTOMER" ? "Gói tập" : "Ca làm việc",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(1, 1))
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder(
                  future: account?.role == "CUSTOMER" ? _plansFuture : _shiftsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}"));
                    } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      return const Center(child: Text("Không có dữ liệu"));
                    }

                    if (account?.role == "CUSTOMER") {
                      final plans = snapshot.data as List<Plan>;
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: plans.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return Column(
                            children: [
                              _buildScheduleCard(
                                plan.name,
                                plan.description ?? "",
                                "Thời hạn: ${plan.durationDays} ngày",
                                "Giá: ${plan.price} VNĐ",
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      );
                    } else if (account?.type == "FULLTIME"){
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Thời gian: 05:00 - 21:00\nChúc bạn một ngày mới tốt lành!",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    } else {
                      final shifts = snapshot.data as List<Shift>;
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: shifts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final shift = shifts[index];
                          return Column(
                            children: [
                              _buildScheduleCard(
                                shift.name,
                                "Ca: ${shift.name}",
                                "Giờ: ${Shift.formatTime(shift.checkin) ?? '--:--'} - ${Shift.formatTime(shift.checkout) ?? '--:--'}",
                                "Tổng thời gian: ${shift.duration ?? 0} giờ",
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFFD740)),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String title, String subtitle, String time, String description) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white60, size: 16),
                SizedBox(width: 5),
                Text(time,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
