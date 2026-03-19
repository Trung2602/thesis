import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class StaffSchedule {
  final String? uuid;
  final DateTime? date;

  final String? staffUuid;
  final String? staffName;

  final String? shiftUuid;
  final String? shiftName;

  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;

  StaffSchedule({
    this.uuid,
    this.date,
    this.staffUuid,
    this.staffName,
    this.shiftUuid,
    this.shiftName,
    this.checkIn,
    this.checkOut,
  });

  // String "HH:mm:ss" -> TimeOfDay
  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // TimeOfDay -> String "HH:mm:ss"
  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m:00";
  }

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    return StaffSchedule(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      staffUuid: json['staffUuid'],
      staffName: json['staffName'],
      shiftUuid: json['shiftUuid'],
      shiftName: json['shiftName'],
      checkIn: _parseTime(json['checkIn']),
      checkOut: _parseTime(json['checkOut']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'staffUuid': staffUuid,
      'shiftUuid': shiftUuid,
      'checkIn': _formatTime(checkIn),
      'checkOut': _formatTime(checkOut),
    };
  }
}