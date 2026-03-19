import 'dart:convert';

import 'package:flutter/material.dart';

class Shift {
  final String? uuid;
  final String? name;
  final TimeOfDay? checkin;
  final TimeOfDay? checkout;
  final double? duration;

  Shift({
    this.uuid,
    this.name,
    this.checkin,
    this.checkout,
    this.duration,
  });

  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m:00";
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      uuid: json['uuid'],
      name: json['name'],
      checkin: _parseTime(json['checkin']),
      checkout: _parseTime(json['checkout']),
      duration: json['duration'] != null
          ? double.parse(json['duration'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'checkin': _formatTime(checkin),
      'checkout': _formatTime(checkout),
      'duration': duration,
    };
  }
}
