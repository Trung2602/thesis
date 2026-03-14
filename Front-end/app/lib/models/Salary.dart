import 'package:flutter/material.dart';

class Salary {
  final int id;
  final DateTime date;
  final double duration;
  final int dayOff;
  final double price;
  final String staffName;

  Salary({
    required this.id,
    required this.date,
    required this.duration,
    required this.dayOff,
    required this.price,
    required this.staffName,
  });

  // Tạo object từ JSON
  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      date: DateTime.parse(json['date']),
      duration: (json['duration'] ?? 0).toDouble(),
      dayOff: json['dayOff'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      staffName: json['staffName'] ?? '',
    );
  }

  // Chuyển object về JSON (nếu cần gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first, // yyyy-MM-dd
      'duration': duration,
      'dayOff': dayOff,
      'price': price,
      'staffName': staffName,
    };
  }
}
