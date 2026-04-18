import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api/gym_server_api.dart';
import '../models/pay_customer.dart';
import '../services/auth_service.dart';

class ManagerPayCustomerPage extends StatefulWidget {
  const ManagerPayCustomerPage({super.key});

  @override
  State<ManagerPayCustomerPage> createState() =>
      _ManagerPayCustomerPageState();
}

class _ManagerPayCustomerPageState extends State<ManagerPayCustomerPage> {
  List<PayCustomer> list = [];

  bool isLoading = false;
  bool isFirstLoad = true;
  bool hasMore = true;

  int page = 0;
  final int size = 10;

  String sortField = "date";
  String sortDir = "desc";

  final ScrollController _scrollController = ScrollController();

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

    setState(() {
      isLoading = true;
      isFirstLoad = list.isEmpty;
    });

    final token = await AuthService().getToken();
    final url = "${GymServerApi.getPayCustomersSort}?sortField=$sortField&sortDir=$sortDir&page=$page&size=$size";

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List content = json["content"];
        final newData = content.map((e) => PayCustomer.fromJson(e)).toList();
        setState(() {
          list.addAll(newData);
          page++;
          hasMore = page < json["totalPages"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi tải dữ liệu")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
        isFirstLoad = false;
      });
    }
  }

  Future<void> deleteItem(String uuid) async {
    final token = await AuthService().getToken();

    final res = await http.delete(
      Uri.parse(GymServerApi.deletePayCustomer(uuid)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      setState(() {
        list.removeWhere((e) => e.uuid == uuid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa")),
      );
    }
  }

  void showDetailDialog(PayCustomer p) {
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
                // HEADER
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.customerName ?? "Không tên",
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

                // CONTENT
                buildInfoRow(Icons.card_membership, "Gói", p.planName ?? "-"),

                buildInfoRow(
                  Icons.calendar_today,
                  "Ngày",
                  p.date != null
                      ? DateFormat('dd/MM/yyyy').format(p.date!)
                      : "-",
                ),

                buildInfoRow(Icons.attach_money, "Giá", "${p.price ?? 0} VNĐ"),

                buildStatusRow(p.status),

                if (p.bankCode != null)
                  buildInfoRow(Icons.account_balance, "Ngân hàng", p.bankCode!),

                if (p.txnRef != null)
                  buildInfoRow(Icons.confirmation_number, "Mã GD", p.txnRef!),

                const SizedBox(height: 20),

                // ACTIONS
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

                    ElevatedButton.icon(
                      onPressed: () async {
                        await deleteItem(p.uuid!);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Xóa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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

  Widget buildStatusRow(String? status) {
    Color color;

    switch (status) {
      case "SUCCESS":
        color = Colors.green;
        break;
      case "FAILED":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          const Text(
            "Trạng thái: ",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status ?? "-",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(PayCustomer p) {
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
            const Icon(Icons.receipt_long, color: Colors.orange),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.customerName ?? "Không tên",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    p.date != null
                        ? DateFormat('dd/MM/yyyy').format(p.date!)
                        : "-",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "${NumberFormat("#,###").format(p.price ?? 0)} VNĐ",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  buildStatusChip(p.status),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () => showDetailDialog(p),
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
  Widget buildStatusChip(String? status) {
    Color color;

    switch (status) {
      case "SUCCESS":
        color = Colors.green;
        break;
      case "FAILED":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status ?? "-",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thanh toán"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFD740),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchData(isRefresh: true),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F123A),

      body: isFirstLoad && isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),

          Expanded(
            child: list.isEmpty
                ? const Center(
              child: Text(
                "Không có dữ liệu",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: list.length + 1,
              itemBuilder: (context, index) {
                if (index < list.length) {
                  return buildCard(list[index]);
                }

                return hasMore
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child:
                      CircularProgressIndicator()),
                )
                    : const Padding(
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
        ],
      ),
    );
  }
}