import 'package:flutter/material.dart';

class StaffSchedule {
  final int? id;
  final DateTime? date;
  final String? staffName;
  final String? shiftName;
  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;

  StaffSchedule({
    this.id,
    this.date,
    this.staffName,
    this.shiftName,
    this.checkIn,
    this.checkOut,
  });

  // ====== Helper: String "HH:mm:ss" -> TimeOfDay ======
  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':'); // ["08","00","00"]
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // ====== Helper: TimeOfDay -> String "HH:mm:ss" ======
  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  // ====== From JSON ======
  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    return StaffSchedule(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      staffName: json['staffName'],
      shiftName: json['shiftName'],
      checkIn: _parseTime(json['checkIn']),
      checkOut: _parseTime(json['checkOut']),
    );
  }

  // ====== To JSON ======
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'staffName': staffName,
      'shiftName': shiftName,
      'checkIn': _formatTime(checkIn),
      'checkOut': _formatTime(checkOut),
    };
  }
}
