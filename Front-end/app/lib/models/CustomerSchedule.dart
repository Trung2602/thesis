import 'package:flutter/material.dart';

class CustomerSchedule {
  final int? id;
  final DateTime? date;
  final TimeOfDay? checkin;
  final TimeOfDay? checkout;
  final String? customerName;
  final String? facilityName;
  final String? staffName;

  CustomerSchedule({
    this.id,
    this.date,
    this.checkin,
    this.checkout,
    this.customerName,
    this.facilityName,
    this.staffName,
  });

  // Chuyển String "HH:mm:ss" -> TimeOfDay
  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':'); // ["08","00","00"]
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Chuyển TimeOfDay -> String "HH:mm:ss"
  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  factory CustomerSchedule.fromJson(Map<String, dynamic> json) {
    return CustomerSchedule(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      checkin: _parseTime(json['checkin']),
      checkout: _parseTime(json['checkout']),
      customerName: json['customerName'],
      facilityName: json['facilityName'],
      staffName: json['staffName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'checkin': _formatTime(checkin),
      'checkout': _formatTime(checkout),
      'customerName': customerName,
      'facilityName': facilityName,
      'staffName': staffName,
    };
  }
}
