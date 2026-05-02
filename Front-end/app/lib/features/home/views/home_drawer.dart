import 'package:flutter/material.dart';
import 'package:gym/features/chat/views/firebase_chat_view.dart';
import 'package:gym/features/managers/day_off/views/day_off_manager_view.dart';
import 'package:gym/features/managers/exercise/views/exercise_manager_view.dart';
import 'package:gym/features/managers/facility/views/facility_manager_view.dart';
import 'package:gym/features/managers/food/views/food_manager_view.dart';
import 'package:gym/features/managers/pay_customer/views/pay_customer_manager_view.dart';
import 'package:gym/features/managers/plan/views/plan_manager_view.dart';
import 'package:gym/features/managers/salary/views/salary_manager_view.dart';
import 'package:gym/features/managers/shift/views/shift_manager_view.dart';
import 'package:gym/features/managers/staff_schedule/views/staff_schedule_manager_view.dart';
import '../../managers/user/views/user_manager_view.dart';
import 'package:gym/models/account.dart';
import 'package:gym/services/auth_service.dart';

class HomeDrawer extends StatelessWidget {
  final Account account;
  final void Function(int index) onTabTap;

  const HomeDrawer({
    super.key,
    required this.account,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  backgroundImage: account.avatar.isNotEmpty
                      ? NetworkImage(account.avatar)
                      : null,
                  child: account.avatar.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  account.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  account.role,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ..._buildItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {'icon': Icons.dashboard, 'title': 'Bảng Điều Khiển Thiên Hà', 'tabIndex': 0},
    ];

    if (account.role == 'CUSTOMER') {
      items.addAll([
        {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'tabIndex': 1},
        {'icon': Icons.payment, 'title': 'Thanh Toán', 'tabIndex': 2},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'tabIndex': 3},
      ]);
    } else if (account.role == 'STAFF') {
      items.addAll([
        {'icon': Icons.calendar_today, 'title': 'Lịch Trình', 'tabIndex': 1},
        account.type == 'FULLTIME'
            ? {'icon': Icons.beach_access, 'title': 'Xin Nghỉ', 'tabIndex': 2}
            : {'icon': Icons.access_time, 'title': 'Ca Làm', 'tabIndex': 2},
        {'icon': Icons.attach_money, 'title': 'Bảng Lương', 'tabIndex': 3},
        {'icon': Icons.person, 'title': 'Hồ Sơ Phi Hành Gia', 'tabIndex': 4},
      ]);
    } else if (account.role == 'ADMIN') {
      items.addAll([
        {'icon': Icons.people, 'title': 'Quản lý người dùng', 'page': const ManagerUserView()},
        {'icon': Icons.home_outlined, 'title': 'Cơ sở', 'page': const ManagerFacilityView()},
        {'icon': Icons.payment, 'title': 'Thanh toán khách', 'page': const ManagerPayCustomerView()},
        {'icon': Icons.card_membership, 'title': 'Gói tập', 'page': const ManagerPlanView()},
        {'icon': Icons.attach_money, 'title': 'Bảng lương', 'page': const ManagerSalaryView()},
        {'icon': Icons.schedule, 'title': 'Ca làm', 'page': const ManagerShiftView()},
        {'icon': Icons.beach_access, 'title': 'Xin nghỉ', 'page': const ManagerDayOffView()},
        {'icon': Icons.calendar_month, 'title': 'Lịch nhân viên', 'page': const ManagerStaffScheduleView()},
        {'icon': Icons.restaurant, 'title': 'Thực phẩm', 'page': const ManagerFoodView()},
        {'icon': Icons.fitness_center, 'title': 'Bài tập', 'page': const ManagerExerciseView()},
      ]);
    }

    items.addAll([
      {'icon': Icons.message, 'title': 'Liên Lạc', 'page': const FirebaseChatView()},
      {'icon': Icons.logout, 'title': 'Rời khỏi Trạm Vũ Trụ', 'isLogout': true},
    ]);

    return items.map((item) => _DrawerTile(
      icon: item['icon'] as IconData,
      title: item['title'] as String,
      onTap: () => _handleTap(context, item),
    )).toList();
  }

  void _handleTap(BuildContext context, Map<String, dynamic> item) {
    Navigator.pop(context);

    if (item.containsKey('tabIndex')) {
      onTabTap(item['tabIndex'] as int);
    } else if (item['isLogout'] == true) {
      AuthService().logout(context);
    } else if (item.containsKey('page')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item['page'] as Widget),
      );
    }
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}