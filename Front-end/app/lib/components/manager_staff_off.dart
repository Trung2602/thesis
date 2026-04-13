import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/staff_day_off.dart';
import '../services/auth_service.dart';
import '../api/api.dart';

class ManagerDayOffPage extends StatefulWidget {
  const ManagerDayOffPage({super.key});

  @override
  State<ManagerDayOffPage> createState() => _ManagerDayOffPageState();
}

class _ManagerDayOffPageState extends State<ManagerDayOffPage> {
  List<StaffDayOff> list = [];

  bool isLoading = false;
  bool hasMore = true;

  int page = 0;
  final int size = 10;

  final ScrollController _scrollController = ScrollController();

  // FILTER
  final nameController = TextEditingController();
  DateTime? selectedDate;

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

  // ================= FETCH =================
  Future<void> fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (isRefresh) {
      page = 0;
      list.clear();
      hasMore = true;
    }

    final token = await AuthService().getToken();

    String url =
        "${Api.getDayOff}?page=$page&size=$size&name=${nameController.text}";

    if (selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      url += "&date=$dateStr";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      final newData = data.map((e) => StaffDayOff.fromJson(e)).toList();

      setState(() {
        list.addAll(newData);
        page++;

        if (newData.length < size) {
          hasMore = false;
        }
      });
    }

    setState(() => isLoading = false);
  }

  // ================= DATE PICKER =================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ================= FILTER UI =================
  Widget buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Tên nhân viên",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Text(
                  selectedDate == null
                      ? "Chọn ngày"
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              IconButton(
                onPressed: pickDate,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
              )
            ],
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              fetchData(isRefresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD740),
            ),
            child: const Text("Tìm kiếm",
                style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget buildCard(StaffDayOff d) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.event_busy, color: Colors.orange),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy').format(d.date),
                style: const TextStyle(color: Colors.white),
              ),
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
        title: const Text("Quản lý ngày nghỉ"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: Column(
        children: [
          buildFilter(),

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
                    child: Text("Hết dữ liệu",
                        style: TextStyle(color: Colors.white70)),
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