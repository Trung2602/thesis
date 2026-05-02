import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym/models/account_provider.dart';
import 'package:gym/models/plan.dart';
import 'package:gym/models/shift.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/info_card.dart';
import '../widgets/schedule_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _provider = DashboardProvider();
  Future<List<Plan>>? _plansFuture;
  Future<List<Shift>>? _shiftsFuture;
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = Provider.of<AccountProvider>(context).account;
    if (account != null && _isFirstLoad) {
      _isFirstLoad = false;
      if (account.role == 'CUSTOMER') {
        _plansFuture = _provider.getPlans();
      } else {
        _shiftsFuture = _provider.getShifts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountProvider>(context).account;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào mừng ${account != null ? account.name : ""} đến với',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                shadows: [Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(2, 2))],
              ),
            ),
            const Text(
              'GALACTIC FITNESS!',
              style: TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 38,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(3, 3))],
              ),
            ),
            const SizedBox(height: 15),
            Row(children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hôm nay: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ]),
            const SizedBox(height: 30),
            const Text(
              'Về Galactic Fitness Center',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 5, color: Colors.black54, offset: Offset(1, 1))],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Trung tâm thể dục thể thao hàng đầu vũ trụ, trang bị bởi công nghệ tiên tiến nhất, và đội ngũ huấn luyện viên là những phi hành gia giàu kinh nghiệm.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                InfoCard(
                  title: 'Cơ Sở Vật Chất Hiện đại',
                  description: 'Hệ thống tập luyện được thiết kế với công nghệ hiện đại nhất vũ trụ.',
                  icon: Icons.space_dashboard,
                ),
                InfoCard(
                  title: 'Đội Ngũ Huấn Luyện Viên Chuyên Nghiệp',
                  description: 'Đội ngũ phi hành gia hướng dẫn chuyên nghiệp, sẵn sàng đưa bạn vươn tới giới hạn.',
                  icon: Icons.group,
                ),
                InfoCard(
                  title: 'Trải Nghiệm Tập Luyện Hiệu Quả',
                  description: 'Dịch vụ mang đến sự thoải mái và hiệu quả tối đa cho từng buổi tập.',
                  icon: Icons.star,
                ),
                InfoCard(
                  title: 'Năng Lượng Bền Bỉ',
                  description: 'Mỗi bài tập đều được thiết kế để tối ưu hóa năng lượng và sức bền của bạn.',
                  icon: Icons.wb_sunny,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              account?.role == 'CUSTOMER' ? 'Gói tập' : 'Ca làm việc',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 5, color: Colors.black54, offset: Offset(1, 1))],
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: account?.role == 'CUSTOMER' ? _plansFuture : _shiftsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }
                if (account?.role == 'CUSTOMER') {
                  return _buildPlanList(snapshot.data as List<Plan>);
                }
                if (account?.type == 'FULLTIME') {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Thời gian: 05:00 - 21:00\nChúc bạn một ngày mới tốt lành!',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }
                return _buildShiftList(snapshot.data as List<Shift>);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(List<Plan> plans) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ScheduleCard(
        title: plans[i].name,
        subtitle: plans[i].description ?? '',
        time: 'Thời hạn: ${plans[i].durationDays} ngày',
        description: 'Giá: ${plans[i].price} VNĐ',
      ),
    );
  }

  Widget _buildShiftList(List<Shift> shifts) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shifts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ScheduleCard(
        title: shifts[i].name,
        subtitle: 'Ca: ${shifts[i].name}',
        time:
        'Giờ: ${Shift.formatTime(shifts[i].checkin) ?? '--:--'} - ${Shift.formatTime(shifts[i].checkout) ?? '--:--'}',
        description: 'Tổng thời gian: ${shifts[i].duration ?? 0} giờ',
      ),
    );
  }
}