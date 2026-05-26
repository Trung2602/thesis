import 'package:flutter/material.dart';
import 'package:gym/features/chat/views/ai_chat_view.dart';
import 'package:gym/features/customer_schedule/views/customer_schedule_view.dart';
import 'package:gym/features/day_off/views/day_off_view.dart';
import 'package:gym/features/managers/report/views/report_dashboard_view.dart';
import 'package:gym/features/pay_customer/views/pay_customer_view.dart';
import 'package:gym/features/salary/views/salary_view.dart';
import 'package:gym/features/staff_schedule/views/staff_schedule_view.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account.dart';
import '../../../models/account_provider.dart';
import '../profile/views/profile_view.dart';
import 'views/dashboard_view.dart';
import 'views/home_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  Account? _savedAccount;
  List<Widget> _pages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    if (account != _savedAccount) {
      _savedAccount = account;
      _buildPages();
    }
  }

  void _buildPages() {
    if (_savedAccount == null) {
      _pages = [const DashboardView()];
    } else if (_savedAccount!.role == 'CUSTOMER') {
      _pages = [
        const DashboardView(),
        const CustomerScheduleView(),
        const PayCustomerView(),
        const ProfileView(),
      ];
    } else if (_savedAccount!.role == 'STAFF') {
      _pages = [
        const DashboardView(),
        const CustomerScheduleView(),
        const StaffScheduleView(),
        if (_savedAccount!.type == 'FULLTIME') const DayOffView(),
        const SalaryView(),
        const ProfileView(),
      ];
    } else if (_savedAccount!.role == 'ADMIN') {
      _pages = [
        const DashboardView(),
        const ReportDashboardView(),
        const ProfileView(),
      ];
    }
    setState(() {});
  }

  List<BottomNavigationBarItem> _buildBottomNavItems() {
    if (_savedAccount == null) return [];

    if (_savedAccount!.role == 'CUSTOMER') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch Trình'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Thanh Toán'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Hồ Sơ'),
      ];
    } else if (_savedAccount!.role == 'STAFF') {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.dashboard),       label: 'Trang chủ'),
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_today),  label: 'Lịch Trình'),
        const BottomNavigationBarItem(icon: Icon(Icons.access_time),     label: 'Ca Làm'),
        if (_savedAccount!.type == 'FULLTIME')
          const BottomNavigationBarItem(icon: Icon(Icons.beach_access),  label: 'Xin Nghỉ'),
        const BottomNavigationBarItem(icon: Icon(Icons.attach_money),    label: 'Bảng Lương'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_pin),      label: 'Hồ Sơ'),
      ];
    } else
      if (_savedAccount!.role == 'ADMIN') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
        BottomNavigationBarItem(icon: Icon(Icons.person_pin), label: 'Hồ Sơ'),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    if (_savedAccount == null || _pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F123A),
      appBar: AppBar(
        title: const Text(
          'GALACTIC FITNESS',
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
      drawer: HomeDrawer(
        account: _savedAccount!,
        onTabTap: (i) => setState(() => _selectedIndex = i),
      ),
      floatingActionButton: _savedAccount!.role == 'CUSTOMER'
          ? FloatingActionButton(
        heroTag: 'home_shell_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatView()),
        ),
        backgroundColor: const Color(0xFFFFD740),
        tooltip: 'AI Hỗ Trợ',
        child: const Icon(Icons.smart_toy, color: Colors.black),
      )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _pages.length >= 2
          ? BottomNavigationBar(
        items: _buildBottomNavItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFD740),
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF1A237E),
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      )
          : null,
    );
  }
}