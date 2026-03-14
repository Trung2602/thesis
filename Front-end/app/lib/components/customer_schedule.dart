// customer_schedule.dart
import 'dart:convert';
import 'package:gym/models/Account.dart';
import 'package:gym/models/Staff.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gym/api.dart';
import 'package:gym/models/CustomerSchedule.dart';
import 'package:gym/models/AccountProvider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomerScheduleScreen extends StatefulWidget {
  const CustomerScheduleScreen({super.key});

  @override
  State<CustomerScheduleScreen> createState() => _CustomerScheduleScreenState();
}

class _CustomerScheduleScreenState extends State<CustomerScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Account? account;
  List<CustomerSchedule> schedulesForSelectedDay = [];
  bool isLoading = false;
  List<Staff> staffList = [];
  bool isLoadingStaff = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    account = Provider.of<AccountProvider>(context).account;

  }

  Future<void> fetchWorkingStaff({
    required DateTime date,
    required TimeOfDay checkIn,
    required TimeOfDay checkOut,
  }) async {
    setState(() {
      isLoadingStaff = true;
    });

    // Chuyển TimeOfDay sang string HH:mm:ss
    String checkInStr = "${checkIn.hour.toString().padLeft(2,'0')}:${checkIn.minute.toString().padLeft(2,'0')}:00";
    String checkOutStr = "${checkOut.hour.toString().padLeft(2,'0')}:${checkOut.minute.toString().padLeft(2,'0')}:00";

    String dateStr = "${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";

    final uri = Uri.parse("${Api.getWorkingStaff}?date=$dateStr&checkIn=$checkInStr&checkOut=$checkOutStr");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final staffs = data.map((e) => Staff.fromJson(e)).toList();

        setState(() {
          staffList = staffs;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi server: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải danh sách nhân viên: $e")),
      );
    } finally {
      setState(() {
        isLoadingStaff = false;
      });
    }
  }


  Future<List<CustomerSchedule>> getCustomerSchedulesAll(String date) async {
    final uri = Uri.parse("${Api.getCustomerSchedulesAll(account!.id)}?date=$date");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CustomerSchedule.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schedules");
    }
  }
  Future<List<CustomerSchedule>> getCustomerSchedulesFilter(String date) async {
    final uri = Uri.parse("${Api.getCustomerSchedulesFilter}?accountId=${account!.id}&date=$date");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CustomerSchedule.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load schedules");
    }
  }
  Future<CustomerSchedule> postCustomerSchedule(CustomerSchedule dto) async {
    final uri = Uri.parse(Api.postCustomerSchedule);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dto.toJson()), // chuyển DTO sang JSON
    );

    if (response.statusCode == 200) {
      return CustomerSchedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to post schedule: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage('assets/images/background.jpg'),
      //     fit: BoxFit.cover,
      //     opacity: 0.7,
      //   ),
      // ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lịch Trình Huấn Luyện",
                  style: TextStyle(
                    color: Color(0xFFFFAB40),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            // TableCalendar
            Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 7,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) async {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      isLoading = true;
                    });
                    final dateStr = "${selectedDay.year.toString().padLeft(4,'0')}-${selectedDay.month.toString().padLeft(2,'0')}-${selectedDay.day.toString().padLeft(2,'0')}";
                    try {
                      final schedules = await getCustomerSchedulesFilter(dateStr);
                      setState(() {
                        schedulesForSelectedDay = schedules;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi tải lịch: $e')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFFFD740)),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFFFD740)),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    todayDecoration: BoxDecoration(
                      color: Color(0xFF2C318F),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFFFAB40),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.white),
                    holidayTextStyle: TextStyle(color: Colors.greenAccent),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white70),
                    weekendStyle: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                // Nút Today
                ElevatedButton(
                  onPressed: () async {
                    final today = DateTime.now();
                    setState(() {
                      _selectedDay = today;
                      _focusedDay = today;
                      isLoading = true;
                    });

                    // Format ngày theo yyyy-MM-dd
                    final dateStr = "${today.year.toString().padLeft(4,'0')}-"
                        "${today.month.toString().padLeft(2,'0')}-"
                        "${today.day.toString().padLeft(2,'0')}";

                    try {
                      final schedules = await getCustomerSchedulesFilter(dateStr);
                      setState(() {
                        schedulesForSelectedDay = schedules;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi tải lịch hôm nay: $e')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text("Today"),
                ),

                const SizedBox(width: 10),
                //=====================================================
                // Nút Add Schedule
                _selectedDay == null ||
                    _selectedDay!.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) ||
                    account?.role == "Staff"
                    ? const SizedBox.shrink() // Ẩn nút nếu chưa chọn ngày hoặc ngày quá khứ
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () async {
                    // Chọn giờ checkin
                    final TimeOfDay? selectedCheckin = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (selectedCheckin == null) return;

                    // Chọn giờ checkout
                    final TimeOfDay? selectedCheckout = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: selectedCheckin.hour + 1, minute: selectedCheckin.minute),
                    );
                    if (selectedCheckout == null) return;

                    // Lấy danh sách nhân viên đang làm việc
                    await fetchWorkingStaff(
                      date: _selectedDay!,
                      checkIn: selectedCheckin,
                      checkOut: selectedCheckout,
                    );

                    // Mở dialog chọn nhân viên từ danh sách working staff
                    Staff? selectedStaff = await showDialog<Staff>(
                      context: context,
                      builder: (context) {
                        if (isLoadingStaff) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (staffList.isEmpty) {
                          return AlertDialog(
                            title: const Text("Không có nhân viên trống"),
                            content: const Text("Không có nhân viên nào làm việc trong khoảng thời gian này."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        }

                        return AlertDialog(
                          title: const Text("Chọn nhân viên"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: staffList.length,
                              itemBuilder: (context, index) {
                                final staff = staffList[index];
                                return ListTile(
                                  title: Text(staff.name),
                                  onTap: () {
                                    Navigator.of(context).pop(staff); // Trả nhân viên đã chọn
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );

                    if (selectedStaff == null) return;

                    final dateStr = "${_selectedDay!.year.toString().padLeft(4,'0')}-${_selectedDay!.month.toString().padLeft(2,'0')}-${_selectedDay!.day.toString().padLeft(2,'0')}";

                    try {
                      final newSchedule = CustomerSchedule(
                        customerName: account!.name,
                        date: _selectedDay!,
                        checkin: selectedCheckin,
                        checkout: selectedCheckout,
                        staffName: selectedStaff.name, // dùng nhân viên đã chọn
                      );

                      final posted = await postCustomerSchedule(newSchedule);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã thêm lịch: ${posted.date}")),
                      );

                      // Tải lại danh sách sự kiện
                      final schedules = await getCustomerSchedulesFilter(dateStr);
                      setState(() {
                        schedulesForSelectedDay = schedules;
                      });
                    } catch (e) {
                      if (e.toString().contains("409")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lịch trùng ngày và giờ checkin, không thể tạo")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi khi thêm lịch: $e')),
                        );
                      }
                    }
                  },
                  child: const Text("Add Schedule"),
                )

              ],
            ),
            const SizedBox(width: 30),
            const Text(
              "Sự Kiện Trong Ngày Được Chọn:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black54, offset: Offset(1, 1))]
              ),
            ),
            const SizedBox(height: 15),

            // Danh sách sự kiện
            _selectedDay == null
                ? const Text(
              "Hãy chọn một ngày trên lịch để xem lịch trình của bạn.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            )
                : _buildEventListForSelectedDay(_selectedDay!),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }




  // Hàm giả lập để hiển thị danh sách sự kiện cho một ngày cụ thể
  // Trong ứng dụng thực tế, bạn sẽ lấy dữ liệu từ một nguồn nào đó (API, database, v.v.)
  Widget _buildEventListForSelectedDay(DateTime day) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (schedulesForSelectedDay.isEmpty) {
      return Text(
        "Không có sự kiện vào ngày ${day.toLocal().toString().split(' ')[0]}",
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

    return Column(
      children: schedulesForSelectedDay.map((schedule) {
        return Card(
          color: Colors.white.withOpacity(0.15),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: Color(0xFFFFD740)),
            title: Text(
              schedule.facilityName ?? 'Không có tên cơ sở',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Huấn luyện viên: ${schedule.staffName ?? 'Chưa có'}\nKhách hàng: ${schedule.customerName ?? 'Chưa có'}\n${schedule.checkin?.format(context)} - ${schedule.checkout?.format(context)}",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      }).toList(),
    );
  }
}