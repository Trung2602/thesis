import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/gym_server_api.dart';
import '../models/plan.dart';
import '../services/auth_service.dart';

class ManagerPlanPage extends StatefulWidget {
  const ManagerPlanPage({super.key});

  @override
  State<ManagerPlanPage> createState() => _ManagerPlanPageState();
}

class _ManagerPlanPageState extends State<ManagerPlanPage> {
  List<Plan> plans = [];

  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;
  int page = 0;
  final int size = 10;
  final ScrollController _scrollController = ScrollController();
  final Map<int, List<Plan>> cache = {};

  @override
  void initState() {
    super.initState();
    fetchPlans();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchPlans();
      }
    });
  }

  Future<void> fetchPlans({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      page = 0;
      plans.clear();
      hasMore = true;
      cache.clear();
    }

    if (cache.containsKey(page)) {
      setState(() {
        plans.addAll(cache[page]!);
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

    final uri = Uri.parse(GymServerApi.getPlansFilter).replace(
      queryParameters: {
        "page": "$page",
        "size": "$size",
      },
    );

    final res = await http.get(uri,
      headers: {
      "Authorization":
      "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      final newData = data.map((e) => Plan.fromJson(e)).toList();
      cache[page] = newData;
      setState(() {
        plans.addAll(newData);
        page++;
        if (newData.length < size) hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
      isFirstLoad = false;
    });
  }

  Future<void> deletePlan(String uuid) async {
    final token = await AuthService().getToken();

    final res = await http.delete(
      Uri.parse(GymServerApi.deletePlan(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa")),
      );

      fetchPlans(isRefresh: true);
    }
  }

  void openForm({Plan? plan}) {
    final nameCtrl = TextEditingController(text: plan?.name ?? "");
    final priceCtrl =
    TextEditingController(text: plan?.price?.toString() ?? "");
    final durationCtrl =
    TextEditingController(text: plan?.durationDays?.toString() ?? "");
    final descCtrl =
    TextEditingController(text: plan?.description ?? "");

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          plan == null ? "Thêm gói" : "Sửa gói",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(color: Colors.white24),

                  // NAME
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Tên gói",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PRICE
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Giá",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DURATION
                  TextField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Số ngày",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // DESCRIPTION
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Mô tả",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ACTIONS
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

                          final body = {
                            "uuid": plan?.uuid,
                            "name": nameCtrl.text.trim(),
                            "price": int.tryParse(priceCtrl.text),
                            "durationDays": int.tryParse(durationCtrl.text),
                            "description": descCtrl.text.trim(),
                          };

                          await http.post(
                            Uri.parse(GymServerApi.postPlan),
                            headers: {
                              "Content-Type": "application/json",
                              "Authorization": "Bearer $token",
                            },
                            body: jsonEncode(body),
                          );

                          Navigator.pop(context);
                          fetchPlans(isRefresh: true);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Lưu"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDetail(Plan p) {
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
                    const Icon(Icons.workspace_premium, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.name,
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

                buildInfoRow(Icons.attach_money, "Giá", "${p.price ?? 0} VNĐ"),
                buildInfoRow(Icons.date_range, "Thời hạn", "${p.durationDays ?? 0} ngày"),
                buildInfoRow(Icons.description, "Mô tả", p.description ?? ""),

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
                        openForm(plan: p);
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
                        deletePlan(p.uuid!);
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

  Widget buildPlanCard(Plan p) {
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
            const Icon(Icons.workspace_premium, color: Colors.orange),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.durationDays ?? 0} ngày",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.price ?? 0} VNĐ",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetail(p),
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
        title: const Text("Quản lý gói tập"),
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
              onRefresh: () => fetchPlans(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: plans.length + 1,
                itemBuilder: (context, index) {
                  if (index < plans.length) {
                    return buildPlanCard(plans[index]);
                  }

                  return hasMore
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: CircularProgressIndicator()),
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
          ),
        ],
      ),
    );
  }
}