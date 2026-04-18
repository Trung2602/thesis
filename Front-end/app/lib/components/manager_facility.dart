import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:http/http.dart' as http;

import '../models/facility.dart';
import '../services/auth_service.dart';

class ManagerFacilityPage extends StatefulWidget {
  const ManagerFacilityPage({super.key});

  @override
  State<ManagerFacilityPage> createState() => _ManagerFacilityPageState();
}

class _ManagerFacilityPageState extends State<ManagerFacilityPage> {
  List<Facility> facilities = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  List<Facility>? cache;

  @override
  void initState() {
    super.initState();
    fetchFacilities();
  }

  Future<void> fetchFacilities({bool isRefresh = false}) async {
    if (isLoading) return;
    if (cache != null && !isRefresh) {
      setState(() {
        facilities = cache!;
        isFirstLoad = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
      if (facilities.isEmpty) isFirstLoad = true;
    });

    final token = await AuthService().getToken();
    final res = await http.get(
      Uri.parse(GymServerApi.getFacilities),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Facility.fromJson(e)).toList();
      cache = newData;
      setState(() {
        facilities = newData;
      });
    }
    setState(() {
      isLoading = false;
      isFirstLoad = false;
    });
  }

  Future<void> deleteFacility(String uuid) async {
    final token = await AuthService().getToken();
    final res = await http.delete(
      Uri.parse(GymServerApi.deleteFacility(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa")),
      );
      cache = null;
      fetchFacilities(isRefresh: true);
    }
  }

  void openForm({Facility? facility}) {
    final nameController =
    TextEditingController(text: facility?.name ?? "");
    final addressController =
    TextEditingController(text: facility?.address ?? "");

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
                    const Icon(Icons.business, color: Colors.amber),
                    const SizedBox(width: 10),
                    Text(
                      facility == null ? "Thêm cơ sở" : "Sửa cơ sở",
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
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Tên cơ sở",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Địa chỉ",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 20),

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

                        final name = nameController.text.trim();
                        final address = addressController.text.trim();

                        if (name.isEmpty || address.isEmpty) return;

                        final body = {
                          "uuid": facility?.uuid,
                          "name": name,
                          "address": address,
                        };

                        await http.post(
                          Uri.parse(GymServerApi.postFacility),
                          headers: {
                            "Content-Type": "application/json",
                            "Authorization": "Bearer $token",
                          },
                          body: jsonEncode(body),
                        );

                        Navigator.pop(context);
                        fetchFacilities(isRefresh: true);
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

  void showDetail(Facility f) {
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
                    const Icon(Icons.business, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.name ?? "",
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

                buildInfoRow(Icons.home_work, "Cơ sở", f.name ?? ""),
                buildInfoRow(Icons.location_on, "Địa chỉ", f.address ?? ""),

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
                        openForm(facility: f);
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
                        deleteFacility(f.uuid!);
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

  Widget buildFacilityCard(Facility f) {
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
            const Icon(Icons.business, color: Colors.orange),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    f.address ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetail(f),
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
        title: const Text("Quản lý cơ sở"),
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
          if (isLoading && isFirstLoad) const LinearProgressIndicator(),
          Expanded(
            child: isLoading && isFirstLoad
                ? const SizedBox()
                : facilities.isEmpty
                ? const Center(
              child: Text(
                "Không có cơ sở nào",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : RefreshIndicator(
              onRefresh: () => fetchFacilities(isRefresh: true),
              child: ListView.builder(
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  return buildFacilityCard(facilities[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}