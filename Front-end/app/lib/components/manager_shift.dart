import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/gym_server_api.dart';
import '../models/shift.dart';
import '../services/auth_service.dart';

class ManagerShiftPage extends StatefulWidget {
  const ManagerShiftPage({super.key});

  @override
  State<ManagerShiftPage> createState() => _ManagerShiftPageState();
}

class _ManagerShiftPageState extends State<ManagerShiftPage> {
  List<Shift> shifts = [];

  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;

  int page = 0;
  final int size = 10;

  final ScrollController _scrollController = ScrollController();

  final Map<int, List<Shift>> cache = {};

  @override
  void initState() {
    super.initState();
    fetchShifts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchShifts();
      }
    });
  }

  Future<void> fetchShifts({bool isRefresh = false}) async {
    if (isLoading) return;
    if (isRefresh) {
      page = 0;
      shifts.clear();
      hasMore = true;
      cache.clear();
    }

    if (cache.containsKey(page)) {
      setState(() {
        shifts.addAll(cache[page]!);
        page++;
        isFirstLoad = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
      if (page == 0) isFirstLoad = true;
    });
    final token = await AuthService().getToken();
    final uri = Uri.parse(GymServerApi.getShiftsFilter).replace(queryParameters: {
      "page": "$page",
      "size": "$size",
    });

    final res = await http.get(uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Shift.fromJson(e)).toList();
      cache[page] = newData;
      setState(() {
        shifts.addAll(newData);
        page++;

        if (newData.length < size) hasMore = false;
      });
    }
    setState(() {
      isLoading = false;
      isFirstLoad = false;
    });
  }

  Future<void> deleteShift(String uuid) async {
    final token = await AuthService().getToken();

    final res = await http.delete(
      Uri.parse(GymServerApi.deleteShift(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa")),
      );

      fetchShifts(isRefresh: true);
    }
  }

  void openForm({Shift? shift}) {
    final nameCtrl = TextEditingController(text: shift?.name ?? "");
    TimeOfDay? checkin = shift?.checkin;
    TimeOfDay? checkout = shift?.checkout;
    Future<void> pickTime(bool isCheckin) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: isCheckin
            ? (checkin ?? TimeOfDay.now())
            : (checkout ?? TimeOfDay.now()),
      );
      if (picked != null) {
        setState(() {
          if (isCheckin) {
            checkin = picked;
          } else {
            checkout = picked;
          }
        });
      }
    }
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1A237E),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.amber),
                    const SizedBox(width: 10),
                    Text(
                      shift == null ? "Thêm ca làm" : "Sửa ca làm",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Colors.white24),

                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Tên ca",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 15),
                buildTimeRow(
                  title: "Check-in",
                  time: checkin,
                  onPick: () => pickTime(true),
                ),

                const SizedBox(height: 10),

                buildTimeRow(
                  title: "Check-out",
                  time: checkout,
                  onPick: () => pickTime(false),
                ),

                const SizedBox(height: 20),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     TextButton(
                //       onPressed: () => Navigator.pop(context),
                //       child: const Text(
                //         "Hủy",
                //         style: TextStyle(color: Colors.white70),
                //       ),
                //     ),
                //
                //     ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.amber,
                //       ),
                //       onPressed: () async {
                //         final token = await AuthService().getToken();
                //
                //         final body = jsonEncode({
                //           "uuid": shift?.uuid,
                //           "name": nameCtrl.text.trim(),
                //           "checkin": checkin == null
                //               ? null
                //               : "${checkin!.hour.toString().padLeft(2, '0')}:${checkin!.minute.toString().padLeft(2, '0')}",
                //           "checkout": checkout == null
                //               ? null
                //               : "${checkout!.hour.toString().padLeft(2, '0')}:${checkout!.minute.toString().padLeft(2, '0')}",
                //         });
                //         await http.post(
                //           Uri.parse(GymServerApi.postShift),
                //           headers: {
                //             "Content-Type": "application/json",
                //             "Authorization": "Bearer $token",
                //           },
                //           body: body,
                //         );
                //         Navigator.pop(context);
                //         fetchShifts(isRefresh: true);
                //       },
                //       child: const Text("Lưu"),
                //     ),
                //   ],
                // )
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      label: const Text(
                        "Hủy",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      onPressed: () async {
                        final token = await AuthService().getToken();

                        final body = jsonEncode({
                          "uuid": shift?.uuid,
                          "name": nameCtrl.text.trim(),
                          "checkin": checkin == null
                              ? null
                              : "${checkin!.hour.toString().padLeft(2, '0')}:${checkin!.minute.toString().padLeft(2, '0')}",
                          "checkout": checkout == null
                              ? null
                              : "${checkout!.hour.toString().padLeft(2, '0')}:${checkout!.minute.toString().padLeft(2, '0')}",
                        });

                        await http.post(
                          Uri.parse(GymServerApi.postShift),
                          headers: {
                            "Content-Type": "application/json",
                            "Authorization": "Bearer $token",
                          },
                          body: body,
                        );

                        Navigator.pop(context);
                        fetchShifts(isRefresh: true);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Lưu"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showDetail(Shift s) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1A237E),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Divider(color: Colors.white24),

                buildInfoRow(Icons.schedule, "Thời gian", "${Shift.formatTime(s.checkin)} - ${Shift.formatTime(s.checkout)}",),
                buildInfoRow(Icons.timer, "Số giờ", "${s.duration ?? 0} giờ",),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      label: const Text(
                        "Đóng",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        openForm(shift: s);
                      },
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      label: const Text(
                        "Sửa",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteShift(s.uuid!);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeRow({required String title, required TimeOfDay? time, required VoidCallback onPick,}) {
    String text = time == null ? "Chọn giờ"
        : "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return Row(
      children: [
        Expanded(
          child: Text(
            "$title: $text",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.access_time, color: Colors.white70),
        )
      ],
    );
  }

  Widget buildShiftCard(Shift s) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.orange),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${Shift.formatTime(s.checkin)} - ${Shift.formatTime(s.checkout)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${s.duration ?? 0} giờ",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetail(s),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD740),
              ),
              child: const Text(
                "Chi tiết",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý ca làm"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD740),
        onPressed: () => openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          if (isLoading && isFirstLoad)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => fetchShifts(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: shifts.length + 1,
                itemBuilder: (context, index) {
                  if (index < shifts.length) {
                    return buildShiftCard(shifts[index]);
                  }
                  return hasMore ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: CircularProgressIndicator()),
                  ) : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text("Hết dữ liệu",
                          style: TextStyle(
                              color: Colors.white70)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}