import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/shift.dart';
import '../services/auth_service.dart';
import '../api/api.dart';

class ManagerShiftPage extends StatefulWidget {
  const ManagerShiftPage({super.key});

  @override
  State<ManagerShiftPage> createState() => _ManagerShiftPageState();
}

class _ManagerShiftPageState extends State<ManagerShiftPage> {
  List<Shift> shifts = [];

  bool isLoading = false;
  bool hasMore = true;

  int page = 0;
  final int size = 10;

  final ScrollController _scrollController = ScrollController();

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

  // ================= FETCH =================
  Future<void> fetchShifts({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (isRefresh) {
      page = 0;
      shifts.clear();
      hasMore = true;
    }

    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse("${Api.getShifts}?page=$page&size=$size"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      final newData = data.map((e) => Shift.fromJson(e)).toList();

      setState(() {
        shifts.addAll(newData);
        page++;

        if (newData.length < size) {
          hasMore = false;
        }
      });
    }

    setState(() => isLoading = false);
  }

  // ================= CARD =================
  Widget buildShiftCard(Shift s) {
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
              s.name,
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white60, size: 16),
                const SizedBox(width: 5),
                Text(
                  "${Shift.formatTime(s.checkin) ?? '--:--'} - ${Shift.formatTime(s.checkout) ?? '--:--'}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              "Thời lượng: ${s.duration ?? 0} giờ",
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
        title: const Text("Quản lý ca làm"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: ListView.builder(
        controller: _scrollController,
        itemCount: shifts.length + 1,
        itemBuilder: (context, index) {
          if (index < shifts.length) {
            return buildShiftCard(shifts[index]);
          }

          // loading / hết dữ liệu
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
    );
  }
}