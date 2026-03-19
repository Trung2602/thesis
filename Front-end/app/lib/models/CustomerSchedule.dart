import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerSchedule {
  final String? uuid;

  final DateTime? date;
  final TimeOfDay? checkin;
  final TimeOfDay? checkout;

  final String? customerUuid;
  final String? staffUuid;
  final String? facilityUuid;

  final String? customerName;
  final String? facilityName;
  final String? staffName;

  CustomerSchedule({
    this.uuid,
    this.date,
    this.checkin,
    this.checkout,
    this.customerUuid,
    this.staffUuid,
    this.facilityUuid,
    this.customerName,
    this.facilityName,
    this.staffName,
  });

  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  factory CustomerSchedule.fromJson(Map<String, dynamic> json) {
    return CustomerSchedule(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      checkin: _parseTime(json['checkin']),
      checkout: _parseTime(json['checkout']),
      customerUuid: json['customerUuid'],
      staffUuid: json['staffUuid'],
      facilityUuid: json['facilityUuid'],
      customerName: json['customerName'],
      facilityName: json['facilityName'],
      staffName: json['staffName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'checkin': _formatTime(checkin),
      'checkout': _formatTime(checkout),
      'customerUuid': customerUuid,
      'staffUuid': staffUuid,
      'facilityUuid': facilityUuid,
      'customerName': customerName,
      'facilityName': facilityName,
      'staffName': staffName,
    };
  }
}