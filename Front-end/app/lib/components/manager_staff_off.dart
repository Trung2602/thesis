import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api/gym_server_api.dart';
import '../models/staff_day_off.dart';
import '../services/auth_service.dart';

class ManagerDayOffPage extends StatefulWidget {
  const ManagerDayOffPage({super.key});

  @override
  State<ManagerDayOffPage> createState() => _ManagerDayOffPageState();
}

class _ManagerDayOffPageState extends State<ManagerDayOffPage> {
  List<StaffDayOff> list = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;

  int page = 0;
  final int size = 20;

  int selectedMonth = DateTime.now().month;
  final yearController =
  TextEditingController(text: DateTime.now().year.toString());

  final ScrollController _scrollController = ScrollController();
  final Map<String, List<StaffDayOff>> cache = {};

  String get cacheKey => "$selectedMonth-${yearController.text}";

  @override
  void initState() {
    super.initState();
    fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchData();
      }
    });
  }

  Future<void> fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      list.clear();
      hasMore = true;
    }

    if (!isRefresh && cache.containsKey(cacheKey)) {
      setState(() {
        list = cache[cacheKey]!;
        isFirstLoad = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      if (page == 0) isFirstLoad = true;
    });

    final token = await AuthService().getToken();

    final url = "${GymServerApi.getStaffDayOffsFilter}?page=$page&size=$size&month=$selectedMonth&year=${yearController.text}";

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List data = decoded is Map ? decoded['content'] : decoded;

      final newData = StaffDayOff.fromJsonList(data);

      setState(() {
        list.addAll(newData);
        cache[cacheKey] = list;
        page++;
        if (newData.length < size) hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
      isFirstLoad = false;
    });
  }

  Future<void> deleteItem(String uuid) async {
    final token = await AuthService().getToken();

    final res = await http.delete(
      Uri.parse(GymServerApi.deleteStaffDayOff(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa")),
      );
      fetchData(isRefresh: true);
    }
  }

  void showDetail(StaffDayOff d) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF1A237E),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.event_busy, color: Colors.amber),
                  SizedBox(width: 10),
                  Text(
                    "Chi tiết ngày nghỉ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),

              Text(
                "Nhân viên: ${d.name ?? 'Không có tên'}",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 10),

              Text(
                "Ngày: ${DateFormat('dd/MM/yyyy').format(d.date)}",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    label: const Text("Đóng",
                        style: TextStyle(color: Colors.white70)),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      deleteItem(d.uuid);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Xóa",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(StaffDayOff d) {
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
            const Icon(Icons.event_busy, color: Colors.orange),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name ?? "Không có tên",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(d.date),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetail(d),
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

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              controller: yearController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Năm",
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          const SizedBox(width: 10),

          IconButton(
            onPressed: () {
              setState(() {
                selectedMonth--;
                if (selectedMonth < 1) selectedMonth = 12;
              });
              fetchData(isRefresh: true);
            },
            icon: const Icon(Icons.arrow_left, color: Colors.white),
          ),

          Text(
            "Tháng $selectedMonth",
            style: const TextStyle(color: Colors.white),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                selectedMonth++;
                if (selectedMonth > 12) selectedMonth = 1;
              });
              fetchData(isRefresh: true);
            },
            icon: const Icon(Icons.arrow_right, color: Colors.white),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: () => fetchData(isRefresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
            ),
            child: const Text(
              "Xem",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý ngày nghỉ"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
      ),
      backgroundColor: const Color(0xFF0F123A),
      body: Column(
        children: [
          buildHeader(),

          if (isFirstLoad)
            const LinearProgressIndicator(),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: list.length + 1,
              itemBuilder: (context, index) {
                if (index < list.length) {
                  return buildCard(list[index]);
                }

                return hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "Hết dữ liệu",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}