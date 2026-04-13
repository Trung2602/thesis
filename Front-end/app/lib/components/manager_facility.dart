import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/facility.dart';
import '../services/auth_service.dart';
import '../api/api.dart';

class ManagerFacilityPage extends StatefulWidget {
  const ManagerFacilityPage({super.key});

  @override
  State<ManagerFacilityPage> createState() => _ManagerFacilityPageState();
}

class _ManagerFacilityPageState extends State<ManagerFacilityPage> {
  List<Facility> facilities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacilities();
  }

  // ================= GET =================
  Future<void> fetchFacilities() async {
    setState(() => isLoading = true);

    final token = await AuthService().getToken();

    final res = await http.get(
      Uri.parse(Api.getFacilities),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      facilities = data.map((e) => Facility.fromJson(e)).toList();
    }

    setState(() => isLoading = false);
  }

  // ================= DELETE =================
  Future<void> deleteFacility(String id) async {
    final token = await AuthService().getToken();

    await http.delete(
      Uri.parse("${Api.deleteFacility}/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    fetchFacilities();
  }

  // ================= FORM =================
  void openForm({Facility? facility}) {
    final nameCtrl = TextEditingController(text: facility?.name ?? "");
    final addressCtrl = TextEditingController(text: facility?.address ?? "");

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(facility == null ? "Thêm cơ sở" : "Sửa cơ sở"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tên cơ sở"),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Địa chỉ"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = await AuthService().getToken();

                final body = jsonEncode({
                  "name": nameCtrl.text,
                  "address": addressCtrl.text,
                });

                if (facility == null) {
                  // CREATE
                  await http.post(
                    Uri.parse(Api.createFacility),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: body,
                  );
                } else {
                  // UPDATE
                  await http.put(
                    Uri.parse("${Api.updateFacility}/${facility.uuid}"),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: body,
                  );
                }

                Navigator.pop(context);
                fetchFacilities();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  // ================= CARD UI =================
  Widget buildFacilityCard(Facility f) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.name ?? "Không tên",
              style: const TextStyle(
                color: Color(0xFFFFAB40),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white60, size: 16),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    f.address ?? "Không có địa chỉ",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => openForm(facility: f),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteFacility(f.uuid!),
                ),
              ],
            )
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
        title: const Text("Quản lý cơ sở"),
        backgroundColor: const Color(0xFF1A237E),
      ),
      backgroundColor: const Color(0xFF0F123A),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD740),
        onPressed: () => openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : facilities.isEmpty
          ? const Center(
        child: Text(
          "Không có cơ sở nào",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          return buildFacilityCard(facilities[index]);
        },
      ),
    );
  }
}