import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/staff_schedule.dart';
import '../models/shift.dart';
import '../services/auth_service.dart';
import '../api/api.dart';

class ManagerStaffSchedulePage extends StatefulWidget {
  const ManagerStaffSchedulePage({super.key});

  @override
  State<ManagerStaffSchedulePage> createState() =>
      _ManagerStaffSchedulePageState();
}

class _ManagerStaffSchedulePageState
    extends State<ManagerStaffSchedulePage> {
  List<StaffSchedule> schedules = [];
  List<Shift> shifts = [];

  bool isLoading = false;
  bool hasMore = true;

  int page = 0;
  final int size = 10;

  final ScrollController _scrollController = ScrollController();

  // FILTER
  final nameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedShiftUuid;

  @override
  void initState() {
    super.initState();
    fetchShifts();
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

  // ================= FETCH SHIFTS =================
  Future<void> fetchShifts() async {
    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(Api.getShifts),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        shifts = data.map((e) => Shift.fromJson(e)).toList();
      });
    }
  }

  // ================= FETCH SCHEDULE =================
  Future<void> fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (isRefresh) {
      page = 0;
      schedules.clear();
      hasMore = true;
    }

    final token = await AuthService().getToken();

    String url =
        "${Api.getStaffSchedule}?page=$page&size=$size&name=${nameController.text}";

    if (selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      url += "&date=$dateStr";
    }

    if (selectedShiftUuid != null) {
      url += "&shiftUuid=$selectedShiftUuid";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      final newData =
      data.map((e) => StaffSchedule.fromJson(e)).toList();

      setState(() {
        schedules.addAll(newData);
        page++;

        if (newData.length < size) hasMore = false;
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
          // NAME
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Tên nhân viên",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),

          const SizedBox(height: 10),

          // DATE
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

          // SHIFT DROPDOWN
          DropdownButton<String>(
            value: selectedShiftUuid,
            hint: const Text("Chọn ca làm",
                style: TextStyle(color: Colors.white70)),
            dropdownColor: const Color(0xFF1A237E),
            items: shifts
                .map((s) => DropdownMenuItem(
              value: s.uuid,
              child: Text(s.name,
                  style: const TextStyle(color: Colors.white)),
            ))
                .toList(),
            onChanged: (val) {
              setState(() => selectedShiftUuid = val);
            },
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
  Widget buildCard(StaffSchedule s) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.staffName ?? "",
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Ngày: ${s.date != null ? DateFormat('dd/MM/yyyy').format(s.date!) : ''}",
              style: const TextStyle(color: Colors.white70),
            ),

            Text(
              "Ca: ${s.shiftName ?? ''}",
              style: const TextStyle(color: Colors.white70),
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
        title: const Text("Quản lý lịch làm"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: Column(
        children: [
          buildFilter(),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: schedules.length + 1,
              itemBuilder: (context, index) {
                if (index < schedules.length) {
                  return buildCard(schedules[index]);
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