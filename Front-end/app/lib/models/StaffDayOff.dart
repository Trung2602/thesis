import 'package:flutter/material.dart';

class StaffDayOff {
  final int id;
  final DateTime date;
  final String staffName;

  StaffDayOff({
    required this.id,
    required this.date,
    required this.staffName,
  });

  // Tạo object từ JSON
  factory StaffDayOff.fromJson(Map<String, dynamic> json) {
    return StaffDayOff(
      id: json['id'],
      date: DateTime.parse(json['date']),
      staffName: json['staffName'] ?? '',
    );
  }

  // Chuyển object về JSON (nếu cần gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first, // yyyy-MM-dd
      'staffName': staffName,
    };
  }

  // Parse danh sách từ JSON array
  static List<StaffDayOff> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StaffDayOff.fromJson(e)).toList();
  }
}
