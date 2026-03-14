// home.dart
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';
// Import models
import '../models/Account.dart';
import '../models/Plan.dart';
import 'package:gym/models/AccountProvider.dart';
import 'package:gym/models/Shift.dart';
// Import các màn hình con sau này
import 'profile.dart';
import 'day_off.dart';
import 'pay_customer.dart';
import 'salary.dart';
import 'staff_schedule.dart';
import 'login.dart';
import 'customer_schedule.dart';
import 'chat_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Index của item được chọn trên BottomNavigationBar
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
    } else if (savedAccount!.role == 'Customer') {
      _pages = [
        const _DashboardScreen(),
        const CustomerScheduleScreen(),
        const PayCustomerScreen(),
        const Profile(),
      ];
    } else if (savedAccount!.role == 'Staff') {
      _pages = [
        const _DashboardScreen(),
        const CustomerScheduleScreen(),
        if (savedAccount!.type == 'Fulltime')
          const DayOff()
        else
          const StaffScheduleScreen(),
        const SalaryScreen(),
        const Profile(),
      ];
    }
    setState(() {}); // gọi lại build khi _pages thay đổi
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    if (savedAccount == null) return [];

    if (savedAccount!.role == 'Customer') {
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
    } else if (savedAccount!.role == 'Staff') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Trang chủ",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Lịch Trình",
        ),
        // Thêm "Xin nghỉ" hoặc "Ca làm" tuỳ type
        if (savedAccount!.type == "Fulltime")
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
      {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'index': 1},
    ];

    if (savedAccount!.role == 'Customer') {
      menuItems.addAll([
        {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'index': 1},
        {'icon': Icons.payment, 'title': 'Thanh Toán', 'index': 2},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'index': 3},
      ]);
    } else if (savedAccount!.role == 'Staff') {
      menuItems.addAll([
        savedAccount!.type == "Fulltime"
          ? {'icon': Icons.beach_access, 'title': 'Xin Nghỉ', 'index': 2}
          : {'icon': Icons.access_time,  'title': 'Ca Làm',   'index': 2},
        {'icon': Icons.attach_money, 'title': 'Bảng Lương', 'index': 3},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'index': 4},
      ]);
    }

    // Các mục chung
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
    // Nếu chưa có account hoặc chưa build xong pages
    if (savedAccount == null || _pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      // Màu nền tổng thể cho các khu vực không có ảnh nền
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
        iconTheme: const IconThemeData(color: Colors.white), // Đặt màu icon Drawer/back button
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white), // Thông báo
            tooltip: 'Tin nhắn từ Trung Tâm Điều Khiển',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white), // Tìm kiếm
            tooltip: 'Tìm kiếm trong Vũ Trụ',
          ),
        ],
      ),

      // Sidebar điều hướng (Drawer)
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
            ..._buildDrawerItems(), // hiển thị menu dựa role
          ],
        ),
      ),

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

  // Hàm tiện ích để xây dựng các mục trong Drawer
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context); // Đóng Drawer
        if (index >= 0) { // Nếu là một item có trong BottomNavigationBar, chuyển trang
          _onItemTapped(index);
        } else {
          switch (title) {
            case 'Rời khỏi Trạm Vũ Trụ':
              authService.logout(context).then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              });
              break;
            case 'Liên Lạc':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chức năng "$title" đang được phát triển...')),
              );
          }

        }
      },
    );
  }
}

// ==========================================================
// MÀN HÌNH DASHBOARD (TRUNG TÂM ĐIỀU KHIỂN VŨ TRỤ)
// ==========================================================
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/background.jpg'), // Ảnh nền vũ trụ cho Dashboard
          fit: BoxFit.cover,
          opacity: 0.7, // Giảm độ trong suốt
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần chào mừng
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
                      color: Color(0xFFFFAB40), // Màu cam mặt trời
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(3, 3))
                      ]
                  ),
                ),
                const SizedBox(height: 15), // Giảm khoảng cách
                // Phần ngày giờ
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Hôm nay: ${_getFormattedDate()}", // Ngày hiện tại
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.access_time, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      " ${TimeOfDay.now().format(context)}", // Giờ hiện tại
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Giảm khoảng cách

                // Phần giới thiệu phòng gym (tương tự như đoạn đầu video)
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
                const SizedBox(height: 10), // Giảm khoảng cách
                const Text(
                  "Trung tâm thể dục thể thao thể thao hàng đầu vũ trụ, trang bị bởi công nghệ tiên tiến nhất, và đội ngũ huấn luyện viên là những phi hành gia giàu kinh nghiệm.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20), // Giảm khoảng cách

                // Các thẻ thông tin dịch vụ
                GridView.count(
                  crossAxisCount: 2, // 2 cột
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true, // Quan trọng để GridView không bị lỗi khi nằm trong SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Không cho GridView cuộn riêng
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
                const SizedBox(height: 30), // Giảm khoảng cách

                // Phần "Gói tập" hoặc "Ca làm việc"
                Text(
                  account?.role == "Customer" ? "Gói tập" : "Ca làm việc",
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
                  future: account?.role == "Customer" ? fetchPlans() : fetchShifts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}"));
                    } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      return const Center(child: Text("Không có dữ liệu"));
                    }

                    if (account?.role == "Customer") {
                      // Hiển thị danh sách gói tập
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
                    } else if (account?.type == "Fulltime"){
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Thời gian: 05:00 - 21:00\nChúc bạn một ngày mới tốt lành!",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    } else {
                      // Hiển thị lịch ca làm việc
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
                                "Giờ: ${shift.checkin != null ? shift.checkin!.toIso8601String().substring(11, 16) : '--:--'}"
                                    " - ${shift.checkout != null ? shift.checkout!.toIso8601String().substring(11, 16) : '--:--'}",
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


                const SizedBox(height: 30), // Giảm khoảng cách cuối cùng
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm tiện ích để lấy ngày hiện tại định dạng đẹp
  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  // Hàm tiện ích để tạo các thẻ thông tin
  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      color: Colors.white.withOpacity(0.08), // Nền trong suốt nhẹ
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Giảm padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFFD740)), // Giảm kích thước icon
            const SizedBox(height: 5), // Giảm khoảng cách
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15, // Giảm kích thước font
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3), // Giảm khoảng cách
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 12), // Giảm kích thước font
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Plan>> fetchPlans() async {
    final token = await AuthService().getToken();
    final response = await  http.get(Uri.parse(Api.getPlans),
        headers: {"Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load plans");
    }
  }

  Future<List<Shift>> fetchShifts() async {
    final token = await AuthService().getToken();
    final response = await  http.get(Uri.parse(Api.getShifts),
        headers: {"Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Shift.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load plans");
    }
  }

  // Hàm tiện ích để tạo các thẻ lịch trình
  Widget _buildScheduleCard(String title, String subtitle, String time, String description) {
    return Card(
      color: Colors.white.withOpacity(0.1), // Nền trong suốt nhẹ
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(15.0), // Giảm padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFAB40), // Màu cam mặt trời
                fontSize: 18, // Giảm kích thước font
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), // Giảm khoảng cách
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 14), // Giảm kích thước font
            ),
            const SizedBox(height: 4), // Giảm khoảng cách
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white60, size: 16), // Giảm kích thước icon
                SizedBox(width: 5),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white60, fontSize: 13), // Giảm kích thước font
                ),
              ],
            ),
            const SizedBox(height: 8), // Giảm khoảng cách
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 13), // Giảm kích thước font
            ),
            const SizedBox(height: 10), // Giảm khoảng cách
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý thanh toán gói tập

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C318F), // Màu xanh tím nhạt hơn
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Giảm padding nút
                  textStyle: const TextStyle(fontSize: 13), // Giảm kích thước font nút
                ),
                child: const Text("Đăng ký ngày"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
